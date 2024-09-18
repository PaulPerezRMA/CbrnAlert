# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""
    FlexpartInput(;
        uuid=nothing,
        name=nothing,
        status=nothing,
        date_created=nothing,
        control=nothing,
    )

    - uuid::String
    - name::String
    - status::RunStatus
    - date_created::ZonedDateTime
    - control::Dict{String, String}
"""
Base.@kwdef mutable struct FlexpartInput <: OpenAPI.APIModel
    uuid::Union{Nothing, String} = nothing
    name::Union{Nothing, String} = nothing
    status = nothing # spec type: Union{ Nothing, RunStatus }
    date_created::Union{Nothing, ZonedDateTime} = nothing
    control::Union{Nothing, Dict{String, String}} = nothing

    function FlexpartInput(uuid, name, status, date_created, control, )
        OpenAPI.validate_property(FlexpartInput, Symbol("uuid"), uuid)
        OpenAPI.validate_property(FlexpartInput, Symbol("name"), name)
        OpenAPI.validate_property(FlexpartInput, Symbol("status"), status)
        OpenAPI.validate_property(FlexpartInput, Symbol("date_created"), date_created)
        OpenAPI.validate_property(FlexpartInput, Symbol("control"), control)
        return new(uuid, name, status, date_created, control, )
    end
end # type FlexpartInput

const _property_types_FlexpartInput = Dict{Symbol,String}(Symbol("uuid")=>"String", Symbol("name")=>"String", Symbol("status")=>"RunStatus", Symbol("date_created")=>"ZonedDateTime", Symbol("control")=>"Dict{String, String}", )
OpenAPI.property_type(::Type{ FlexpartInput }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_FlexpartInput[name]))}

function check_required(o::FlexpartInput)
    o.uuid === nothing && (return false)
    o.name === nothing && (return false)
    o.date_created === nothing && (return false)
    o.control === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ FlexpartInput }, name::Symbol, val)
    if name === Symbol("date_created")
        OpenAPI.validate_param(name, "FlexpartInput", :format, val, "date-time")
    end
end
