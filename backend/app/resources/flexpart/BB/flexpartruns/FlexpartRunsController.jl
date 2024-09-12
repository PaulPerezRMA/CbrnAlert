module FlexpartRunsController

using Genie
using Genie.Requests
using Genie.Renderer.Json: json
using SearchLight
using SearchLight.Relationships


using Flexpart
using Dates
using NCDatasets

using CbrnAlertApp: STATUS_CREATED, STATUS_FINISHED, STATUS_ONGOING, STATUS_ERRORED
using CbrnAlertApp: _area

using CbrnAlertApp.Users
using CbrnAlertApp.Users: current_user
using CbrnAlertApp.FlexpartInputs
using CbrnAlertApp.FlexpartRuns
using CbrnAlertApp.FlexpartOutputs

using CbrnAlertApp: API

# const API = CbrnAlertApp.API

# const FLEXPART_RUN_FAILED = Genie.Router.error(500, "Flexpart run failed", "application/json", error_info="Flexpart run failed")

struct FlexpartRunException{T} <: Exception
  error::API.OpenAPI.APIModel
end
FlexpartRunException(code::AbstractString) = FlexpartRunException{Symbol(code)}(API.FlexpartRunError(;error = "The Flexpart run failed.", code))

run_error_throw(e::FlexpartRunException) = throw(Genie.Exceptions.ExceptionalResponse(json(e.error, status = 500)))

const UNAVAILABLE_METEO_EXCEPTION = FlexpartRunException("noMeteoFieldsAvailable")
const UNKNOWN_EXCEPTION = FlexpartRunException("unknownFlexpartRunError")


function _iscompleted(fpsim)
  lines = readlines(joinpath(Flexpart.getpath(fpsim), "output.log"))
  any(occursin.("CONGRATULATIONS", lines))
end

function _throw_run_errors(filepath)
  lines = readlines(filepath)
  for line in lines
      if occursin("STOP NO METEO FIELDS AVAILABLE", line)
          throw(UNAVAILABLE_METEO_EXCEPTION)
      end
  end
  throw(UNKNOWN_EXCEPTION)
end
_check_run_errors(fpsim::FlexpartSim) = joinpath(Flexpart.getpath(fpsim), "output.log")

function run()
  runtype = Genie.Router.params(:runType, "simple")

  if runtype == "simple"
    run_simple()
  else
    run_detailed()
  end
end

function run_simple()
  payload = Genie.Requests.jsonpayload()
  input_id = Genie.Router.params(:inputId)

  # COMMAND options
  sim_start = DateTime(payload["command"]["start"])
  sim_end = DateTime(payload["command"]["end"])
  time_step = payload["command"]["timeStep"]
  output_type = payload["command"]["outputType"]

  # RELEASE options
  release_start = DateTime(payload["releases"][1]["start"])
  release_end = DateTime(payload["releases"][1]["end"])
  lon, lat = values(payload["releases"][1]["location"])
  release_mass = payload["releases"][1]["mass"]
  release_height = payload["releases"][1]["height"]

  # OUTGRID options
  gridres = payload["outgrid"]["gridres"]
  area = payload["outgrid"]["area"]
  heights = payload["outgrid"]["heights"]

  fprun = FlexpartRuns.create()
  fpsim = Flexpart.FlexpartSim(joinpath(fprun.path, "pathnames"))
  @info "FlexpartSim created at $(Flexpart.getpath(fpsim))"

  fpoptions = FlexpartOption(fpsim)
  Flexpart.remove_unused_species!(fpoptions)

  # Set simulation start and end
  Flexpart.set_cmd_dates!(fpoptions, sim_start, sim_end)

  cmd = Dict(
    # Set simulation step
    :LOUTSTEP => time_step,
    :LOUTAVER => time_step,
    :LOUTSAMPLE => convert(Int64, time_step / 4),
    :LSYNCTIME => convert(Int64, time_step / 4),
    # Set netcdf output
    :IOUT => output_type + 8
  )
  merge!(fpoptions["COMMAND"][:COMMAND], cmd)

  # Set release options
  Flexpart.set_point_release!(fpoptions, lon, lat)
  releases_options = Dict(
    :IDATE1 => Dates.format(release_start, "yyyymmdd"),
    :ITIME1 => Dates.format(release_start, "HHMMSS"),
    :IDATE2 => Dates.format(release_end, "yyyymmdd"),
    :ITIME2 => Dates.format(release_end, "HHMMSS"),
    :Z1 => release_height,
    :Z2 => release_height,
    :PARTS => Flexpart.MAX_PARTICLES,
    :MASS => release_mass
  )
  Flexpart.merge!(fpoptions["RELEASES"][:RELEASE], releases_options)

  # Set outgrid options
  area_f = _area(area)
  outgrid = Flexpart.area2outgrid(area_f, gridres)
  Flexpart.merge!(fpoptions["OUTGRID"][:OUTGRID], outgrid)
  fpoptions["OUTGRID"][:OUTGRID][:OUTHEIGHTS] = join(heights, ", ")

  # Save the options
  Flexpart.save(fpoptions)
  @warn "Flexpart options saved"

  # Get the input and adapt the Available file
  fpinput = findone(FlexpartInput, uuid=input_id)
  fpsim[:input] = abspath(joinpath(fpinput.path, "output"))
  avs = Available(fpsim)

  # Save the available file and the flexpart paths
  Flexpart.save(avs)
  Flexpart.save(fpsim)


  return run(fpsim, fprun) |> API.FlexpartRun |> json
end

function run_detailed()
end

function run(fpsim::FlexpartSim, fprun::FlexpartRun)
  fpoptions = FlexpartOption(fpsim)
  Flexpart.remove_unused_species!(fpoptions)
  FlexpartRuns.change_options!(fprun.name, fpoptions)
  output_path = joinpath(Flexpart.getpath(fpsim), "output.log")
  open(output_path, "w") do logf
    FlexpartRuns.change_status!(fprun.name, STATUS_ONGOING)
    Flexpart.run(fpsim) do stream
      # log_and_broadcast(stream, request_data["ws_info"], logf)
      line = readline(stream, keep=true)
      Base.write(logf, line)
      flush(logf)
    end
  end

  if _iscompleted(fpsim)
    output_dir = joinpath(fprun.path, "output/")
    nc_file = joinpath(output_dir, filter(x -> endswith(x, ".nc"), readdir(output_dir))[1])
    _round_dims(nc_file)
    FlexpartRuns.change_status!(fprun.name, STATUS_FINISHED)
  else
    @info "Flexpart run with name $(fprun.name) has failed"
    FlexpartRuns.change_status!(fprun.name, STATUS_ERRORED)
    try _throw_run_errors(output_path)
    catch e
      # With this error, an output has normally been produced, so we relate it to the run.
      if e isa FlexpartRunException{:noMeteoFieldsAvailable}
        FlexpartOutputs.add!(fprun)
      end
      run_error_throw(e)
    finally
      FlexpartRuns.assign_to_user!(current_user(), fprun)
      if ENV["GENIE_ENV"] == "prod"
        rm(Flexpart.getpath(fpsim), recursive=true)
      end
    end
  end

  FlexpartRuns.assign_to_user!(current_user(), fprun)

  FlexpartOutputs.add!(fprun)

  return fprun
end

function _round_dims(netcdf_file::AbstractString)
  # Check if the file path is valid
  if !ispath(netcdf_file)
      throw(ArgumentError("The provided file path '$netcdf_file' is not valid."))
  end
  ds = Dataset(netcdf_file, "r")
  # Extract dimensions
  longitudes = Float64.(round.(ds["longitude"][:], digits=6))
  latitudes = Float64.(round.(ds["latitude"][:], digits=6))
  close(ds)

  ds = Dataset(netcdf_file, "a")
  # Round the coordinates
  ds["longitude"][:] = longitudes
  ds["latitude"][:] = latitudes
  close(ds)
end

function get_runs()
  fpruns = user_related(FlexpartRun)
  # filter!(FlexpartRuns.isfinished, fpruns)
  filter!(x -> x.status == STATUS_FINISHED, fpruns)
  API.FlexpartRun.(fpruns) |> json
end

function get_run()
  id = Genie.Router.params(:runId)
  fprun = FlexpartRuns._get_run(id)
  Users.@hasaccess!(fprun)
  API.FlexpartRun(fprun) |> json
end

function delete_run()
  id = Genie.Router.params(:runId)
  to_delete = findone(FlexpartRun, uuid = id)
  related_outputs = related(to_delete, FlexpartOutput)
  for out in related_outputs
      SearchLight.delete(out)
  end
  FlexpartRuns.delete!(to_delete)
  API.FlexpartRun(to_delete) |> json
end

end
