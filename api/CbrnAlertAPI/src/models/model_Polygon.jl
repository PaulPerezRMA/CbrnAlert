# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""GeoJSon geometry

    Polygon(;
        type=nothing,
        bbox=nothing,
        coordinates=nothing,
    )

    - type::String
    - bbox::Vector{Float64}
    - coordinates::Vector{Vector}
"""
Base.@kwdef mutable struct Polygon <: OpenAPI.APIModel
    type::Union{Nothing, String} = nothing
    bbox::Union{Nothing, Vector{Float64}} = nothing
    coordinates::Union{Nothing, Vector{Vector}} = nothing

    function Polygon(type, bbox, coordinates, )
        OpenAPI.validate_property(Polygon, Symbol("type"), type)
        OpenAPI.validate_property(Polygon, Symbol("bbox"), bbox)
        OpenAPI.validate_property(Polygon, Symbol("coordinates"), coordinates)
        return new(type, bbox, coordinates, )
    end
end # type Polygon

const _property_types_Polygon = Dict{Symbol,String}(Symbol("type")=>"String", Symbol("bbox")=>"Vector{Float64}", Symbol("coordinates")=>"Vector{Vector}", )
OpenAPI.property_type(::Type{ Polygon }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_Polygon[name]))}

function check_required(o::Polygon)
    o.type === nothing && (return false)
    o.coordinates === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ Polygon }, name::Symbol, val)
    if name === Symbol("type")
        OpenAPI.validate_param(name, "Polygon", :enum, val, ["Point", "MultiPoint", "LineString", "MultiLineString", "Polygon", "MultiPolygon"])
    end
end
