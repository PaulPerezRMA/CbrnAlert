# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""
    Atp45ResultCollectionAllOf(;
        features=nothing,
    )

    - features::Vector{Atp45Zone}
"""
Base.@kwdef mutable struct Atp45ResultCollectionAllOf <: OpenAPI.APIModel
    features::Union{Nothing, Vector} = nothing # spec type: Union{ Nothing, Vector{Atp45Zone} }

    function Atp45ResultCollectionAllOf(features, )
        OpenAPI.validate_property(Atp45ResultCollectionAllOf, Symbol("features"), features)
        return new(features, )
    end
end # type Atp45ResultCollectionAllOf

const _property_types_Atp45ResultCollectionAllOf = Dict{Symbol,String}(Symbol("features")=>"Vector{Atp45Zone}", )
OpenAPI.property_type(::Type{ Atp45ResultCollectionAllOf }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_Atp45ResultCollectionAllOf[name]))}

function check_required(o::Atp45ResultCollectionAllOf)
    o.features === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ Atp45ResultCollectionAllOf }, name::Symbol, val)
end