# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""
    Atp45ZoneAllOf(;
        properties=nothing,
        geometry=nothing,
    )

    - properties::Atp45ZoneAllOfProperties
    - geometry::Polygon
"""
Base.@kwdef mutable struct Atp45ZoneAllOf <: OpenAPI.APIModel
    properties = nothing # spec type: Union{ Nothing, Atp45ZoneAllOfProperties }
    geometry = nothing # spec type: Union{ Nothing, Polygon }

    function Atp45ZoneAllOf(properties, geometry, )
        OpenAPI.validate_property(Atp45ZoneAllOf, Symbol("properties"), properties)
        OpenAPI.validate_property(Atp45ZoneAllOf, Symbol("geometry"), geometry)
        return new(properties, geometry, )
    end
end # type Atp45ZoneAllOf

const _property_types_Atp45ZoneAllOf = Dict{Symbol,String}(Symbol("properties")=>"Atp45ZoneAllOfProperties", Symbol("geometry")=>"Polygon", )
OpenAPI.property_type(::Type{ Atp45ZoneAllOf }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_Atp45ZoneAllOf[name]))}

function check_required(o::Atp45ZoneAllOf)
    o.properties === nothing && (return false)
    o.geometry === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ Atp45ZoneAllOf }, name::Symbol, val)
end
