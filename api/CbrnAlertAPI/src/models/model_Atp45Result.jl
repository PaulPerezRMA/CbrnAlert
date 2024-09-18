# This file was generated by the Julia OpenAPI Code Generator
# Do not modify this file directly. Modify the OpenAPI specification instead.


@doc raw"""
    Atp45Result(;
        collection=nothing,
        metadata=nothing,
    )

    - collection::Atp45ResultCollection
    - metadata::Any
"""
Base.@kwdef mutable struct Atp45Result <: OpenAPI.APIModel
    collection = nothing # spec type: Union{ Nothing, Atp45ResultCollection }
    metadata::Union{Nothing, Any} = nothing

    function Atp45Result(collection, metadata, )
        OpenAPI.validate_property(Atp45Result, Symbol("collection"), collection)
        OpenAPI.validate_property(Atp45Result, Symbol("metadata"), metadata)
        return new(collection, metadata, )
    end
end # type Atp45Result

const _property_types_Atp45Result = Dict{Symbol,String}(Symbol("collection")=>"Atp45ResultCollection", Symbol("metadata")=>"Any", )
OpenAPI.property_type(::Type{ Atp45Result }, name::Symbol) = Union{Nothing,eval(Base.Meta.parse(_property_types_Atp45Result[name]))}

function check_required(o::Atp45Result)
    o.collection === nothing && (return false)
    true
end

function OpenAPI.validate_property(::Type{ Atp45Result }, name::Symbol, val)
end
