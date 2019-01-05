using Diversity.API
using EcoBase: AbstractAssemblage

"""
    gettypes(m::AbstractAssemblage)

Returns the AbstractTypes component of the metacommunity.
"""
function gettypes(m::AbstractAssemblage)
    return _gettypes(m)
end

"""
    getpartition(m::AbstractAssemblage)

Returns the AbstractPartition component of the metacommunity.

"""
function getpartition(m::AbstractAssemblage)
        return _getpartition(m)
end

"""
    counttypes(m::AbstractAssemblage[, raw::Bool = false])
    counttypes(t::AbstractTypes[, raw::Bool = false])

Returns number of types in an `AbstractTypes` object or the
`AbstractAssemblage` containing it. `raw` determines whether to
count the number of raw or processed types, which varies, for instance,
when the types are determined by a phylogeny.
"""
function counttypes end

function counttypes(m::AbstractAssemblage, raw::Bool = false)
    return _counttypes(_gettypes(m), raw)
end

function counttypes(t::AbstractTypes, raw::Bool = false)
    return _counttypes(t, raw)
end

"""
    countsubcommunities(m::AbstractAssemblage)
    countsubcommunities(p::AbstractPartition)

Returns number of subcommunities in an `AbstractPartition` object or the
`AbstractAssemblage` containing it.
"""
function countsubcommunities end

function countsubcommunities(m::AbstractAssemblage)
    return _countsubcommunities(_getpartition(m))
end

function countsubcommunities(p::AbstractPartition)
    return _countsubcommunities(p)
end

"""
    gettypenames(m::AbstractAssemblage[, raw::Bool = false])
    gettypenames(t::AbstractTypes[, raw::Bool = false])

Returns the names of the types of the `AbstractTypes` object or the
`AbstractAssemblage` containing it. `raw` determines whether to
count the number of raw or processed types, which varies, for instance,
when the types are determined by a phylogeny.
"""
function gettypenames end

function gettypenames(m::AbstractAssemblage, raw::Bool = false)
    return _gettypenames(_gettypes(m), raw)
end

function gettypenames(t::AbstractTypes, raw::Bool = false)
    return _gettypenames(t, raw)
end

"""
    getdiversityname(m::AbstractAssemblage)
    getdiversityname(t::AbstractTypes)

Returns the name of the diversity type used.
"""
function getdiversityname end

getdiversityname(t::AbstractTypes) = getdiversityname(t)
getdiversityname(m::AbstractAssemblage) = _getdiversityname(_gettypes(m))

"""
    addedoutputcols(m::AbstractAssemblage)
    addedoutputcols(t::AbstractTypes)

Returns the name of any additional columns needed to disambiguate the
diversity type used.
"""
function addedoutputcols end

addedoutputcols(t::AbstractTypes) = _addedoutputcols(t)
addedoutputcols(m::AbstractAssemblage) = addedoutputcols(_gettypes(m))

"""
    getaddedoutput(::AbstractTypes)

Returns the contents of any additional columns to be added to outputs.
"""
function getaddedoutput end

getaddedoutput(t::AbstractTypes) = _getaddedoutput(t)
getaddedoutput(m::AbstractAssemblage) = _getaddedoutput(_gettypes(m))

"""
    getsubcommunitynames(m::AbstractAssemblage)
    getsubcommunitynames(p::AbstractPartition)

Returns the names of the subcommunities in an `AbstractPartition` object or the
`AbstractAssemblage` containing it.
"""
function getsubcommunitynames end

function getsubcommunitynames(m::AbstractAssemblage)
    return _getsubcommunitynames(_getpartition(m))
end

function getsubcommunitynames(p::AbstractPartition)
    return _getsubcommunitynames(p)
end

"""
    getabundance(m::AbstractAssemblage, raw::Bool)

Returns the abundances array of the metacommunity.
"""
function getabundance(m::AbstractAssemblage, raw::Bool = false)
    return _getabundance(m, raw)
end

"""
    getmetaabundance(m::AbstractAssemblage)

Returns the metacommunity abundances of the metacommunity.
"""
function getmetaabundance(m::AbstractAssemblage, raw::Bool = false)
    return _getmetaabundance(m, raw)
end

"""
    getweight(m::AbstractAssemblage)

Returns the subcommunity weights of the metacommunity.
"""
function getweight(m::AbstractAssemblage)
    return _getweight(m)
end

"""
    getordinariness!(m::AbstractAssemblage)

Returns (and possibly calculates) the ordinariness array of the subcommunities.
"""
function getordinariness!(m::AbstractAssemblage)
    return _getordinariness!(m)
end

"""
    getmetaordinariness!(m::AbstractAssemblage)

Returns (and possibly calculates) the ordinariness of the
metacommunity as a whole.
"""
function getmetaordinariness!(m::AbstractAssemblage)
    return _getmetaordinariness!(m)
end

"""
    calcsimilarity(t::AbstractTypes, scale::Real)

Retrieves (and possibly calculates) a similarity matrix from t.
"""
function calcsimilarity(t::AbstractTypes, scale::Real)
    return _calcsimilarity(t, scale)
end
