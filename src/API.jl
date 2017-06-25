using Compat
using Diversity

### AbstractPartition API

"""
    AbstractPartition

Abstract supertype for all partitioning types. AbstractPartition
subtypes allow you to define how to partition your total metacommunity
(e.g. an ecosystem) into smaller components (e.g. subcommunities).
"""
@compat abstract type AbstractPartition end

"""
    _getsubcommunitynames(p::AbstractPartition)

Returns the names of the subcommunities in the partition
object. Must be implemented by each AbstractPartition subtype.
"""
function _getsubcommunitynames end

"""
    _countsubcommunities(::AbstractPartition)

Returns number of subcommunities in a partition, p. May be implemented
by each AbstractPartition subtype. Default is to count length of
subcommunity name vector.
"""
function _countsubcommunities end
function _countsubcommunities(p::AbstractPartition)
    return length(_getsubcommunitynames(p))
end

### AbstractTypes API

"""
    AbstractTypes

Abstract supertype for all similarity types. Its subtypes allow you to
define how similarity is measured between individuals.
"""
@compat abstract type AbstractTypes end

"""
    _gettypenames(t::AbstractTypes, raw::Bool)

Returns the names of the types in an AbstractTypes object. Must be
implemented by each AbstractTypes subtype. `raw` determines whether
to count the number of raw or processed types, which varies, for
instance, when the types are determined by a phylogeny.
"""
function _gettypenames end

"""
    _calcsimilarity(t::AbstractTypes, scale::Real)

Retrieves (and possibly calculates) a similarity matrix from t. Must be
implemented by each AbstractTypes subtype.
"""
function _calcsimilarity end

"""
    _counttypes(::AbstractTypes, raw::Bool)

Returns number of types in an AbstractTypes object, t. May be
implemented by each AbstractTypes subtype. `raw` determines whether
to count the number of raw or processed types, which varies, for
instance, when the types are determined by a phylogeny. Default is to
count length of corresponding types name vector.
"""
function _counttypes end

function _counttypes(t::AbstractTypes, raw::Bool)
    return length(_gettypenames(t, raw))
end

"""
    _calcabundance(t::AbstractTypes, a::AbstractArray)

Calculates the abundance a for AbstractTypes, t (if necessary). May be
implemented by each AbstractTypes subtype.
"""
function _calcabundance end
function _calcabundance(::AbstractTypes, a::AbstractArray)
    return a, one(eltype(a))
end

"""
    _calcordinariness(t::AbstractTypes, a::AbstractArray, scale::Real)

Calculates the ordinariness of abundance a from AbstractTypes, t. May be
implemented by each AbstractTypes subtype.
"""
function _calcordinariness end
function _calcordinariness(t::AbstractTypes, a::AbstractArray, ::Real)
    abundance, scale = _calcabundance(t, a)
    return _calcsimilarity(t, scale) * abundance
end

### AbstractMetacommunity API

"""
    AbstractMetacommunity{FP, ARaw, APro, Sim, Part}

AbstractMetacommunity is the abstract supertype of all metacommunity
types. AbstractMetacommunity subtypes allow you to define how to
partition your total metacommunity (e.g. an ecosystem) into smaller
components (e.g. subcommunities), and how to assess similarity between
individuals within it.

"""
@compat abstract type AbstractMetacommunity{FP <: AbstractFloat,
                                            ARaw <: AbstractArray,
                                            AProcessed <: AbstractMatrix,
                                            Sim <: AbstractTypes,
                                            Part <: AbstractPartition} end

"""
    _gettypes(::AbstractMetacommunity)

Returns the AbstractTypes component of the metacommunity. Must be
implemented by each AbstractMetacommunity subtype.
"""
function _gettypes end

"""
    _getpartition(::AbstractMetacommunity)

Returns the AbstractPartition component of the metacommunity. Must be
implemented by each AbstractMetacommunity subtype.
"""
function _getpartition end

"""
    _getabundance(m::AbstractMetacommunity, raw::Bool)

Returns the abundances array of the metacommunity. Must be implemented
by each AbstractMetacommunity subtype.
"""
function _getabundance end

"""
    _getmetaabundance(m::AbstractMetacommunity, raw::Bool)

Returns the metacommunity abundances of the metacommunity. May be
implemented by each AbstractMetacommunity subtype.
"""
function _getmetaabundance end
function _getmetaabundance(m::AbstractMetacommunity, raw::Bool)
    return reduce(+, SubcommunityIterator(m, mc -> _getabundance(mc, raw)))
end

"""
    _getscale(m::AbstractMetacommunity)

Returns a scaling factor for the metacommunity (needed for
phylogenetics). Normally ignored. Must be implemented by each
AbstractMetacommunity subtype.
"""
function _getscale end

"""
    _getweight(m::AbstractMetacommunity)

Returns the subcommunity weights of the metacommunity. May be
implemented by each AbstractMetacommunity subtype.
"""
function _getweight end
function _getweight(m::AbstractMetacommunity)
    return reduce(+, TypeIterator(m, mc -> _getabundance(mc, false)))
end

"""
    _getordinariness!(m::AbstractMetacommunity)

Returns (and possibly calculates) the ordinariness array of the
subcommunities. May be implemented by each AbstractMetacommunity
subtype.
"""
function _getordinariness! end
function _getordinariness!(m::AbstractMetacommunity)
    return _calcordinariness(_gettypes(m), _getabundance(m, false), _getscale(m))
end

"""
    _getmetaordinariness!(m::AbstractMetacommunity)

Returns (and possibly calculates) the ordinariness of the
metacommunity as a whole. May be implemented by each
AbstractMetacommunity subtype.
"""
function _getmetaordinariness! end
function _getmetaordinariness!(m::AbstractMetacommunity)
    return reduce(+, SubcommunityIterator(m, _getordinariness!))
end

### Other optional APIs to implement

"""
    floattypes(t)

This function returns a set containing the floating point types that
are compatible with the Diversity-related object, t.

"""
function floattypes end

function floattypes{A <: AbstractArray}(::A)
    return Set([eltype(A)])
end

function floattypes(::AbstractTypes)
    return Set(subtypes(AbstractFloat))
end

function floattypes(::AbstractPartition)
    return Set(subtypes(AbstractFloat))
end

function floattypes{FP, A, Sim, Part}(::AbstractMetacommunity{FP, A, Sim, Part})
    return Set([FP])
end

"""
    typematch(args...)

Checks whether the types of a variety of Diversity-related objects
have compatible types (using floattypes()).

"""
typematch(args...) = length(mapreduce(floattypes, ∩, args)) ≥ 1

"""
    mcmatch(procm::AbstractArray, sim::AbstractTypes, part::AbstractPartition)

Checks for type and size compatibility for elements contributing to a Metacommunity
"""
function mcmatch end

function mcmatch(procm::AbstractMatrix, sim::AbstractTypes, part::AbstractPartition)
    realm = _calcabundance(sim, procm)[1]
    return typematch(realm, sim, part) &&
        _counttypes(sim, true) == size(procm, 1) &&
        _counttypes(sim, false) == size(realm, 1) &&
        _countsubcommunities(part) == size(realm, 2) &&
        sum(realm) ≈ 1.0
end
