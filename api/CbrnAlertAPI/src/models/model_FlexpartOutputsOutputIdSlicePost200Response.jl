# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.



@doc raw"""
    FlexpartOutputsOutputIdSlicePost200Response(; value=nothing)
"""
mutable struct FlexpartOutputsOutputIdSlicePost200Response <: OpenAPI.OneOfAPIModel
    value::Any # Union{ GeoJsonSliceResponse, Vector{Float64} }
    FlexpartOutputsOutputIdSlicePost200Response() = new()
    FlexpartOutputsOutputIdSlicePost200Response(value) = new(value)
end # type FlexpartOutputsOutputIdSlicePost200Response

function OpenAPI.property_type(::Type{ FlexpartOutputsOutputIdSlicePost200Response }, name::Symbol, json::Dict{String,Any})
    
    # no discriminator specified, can't determine the exact type
    return fieldtype(FlexpartOutputsOutputIdSlicePost200Response, name)
end
