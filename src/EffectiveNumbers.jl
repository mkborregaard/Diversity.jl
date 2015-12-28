"""
### Calculates the weighted powermean of a series of numbers

Calculates *order*th power mean of *values*, weighted by
*weights*. By default, *weights* are equal and *order*
is 1, so this is just the arithmetic mean.

#### Arguments:
- `values`: values for which to calculate mean
- `order`: order of power mean
- `weights`: weights of elements, normalised to 1 inside function

#### Returns:
- weighted power mean(s)
"""
function powermean{S <: AbstractFloat}(values::AbstractArray{S, 1},
                                       order::Real = 1,
                                       weights::AbstractArray{S, 1} = ones(values))
    length(values) == length(weights) ||
    throw(DimensionMismatch("powermean: Weight and value vectors must be the same length"))
    
    # Normalise weights to sum to 1 (as per Rényi)
    proportions = weights / sum(weights)

    # Check whether all proportions are NaN - happens in normalisation when all
    # weights are zero in group. In that case we want to propagate the NaN
    if (all(isnan(proportions)))
        return(NaN)
    end
    
    # Extract values with non-zero weights
    present = filter(x -> !isapprox(x[1], 0.0), zip(proportions, values))
    if (isinf(order))
      if (order > 0) # +Inf -> Maximum
        reduce((a, b) -> a[2] > b[2] ? a : b, present)[2]
      else # -Inf -> Minimum
        reduce((a, b) -> a[2] < b[2] ? a : b, present)[2]
      end
    else
      if (isapprox(order, 0))
        mapreduce(pair -> pair[2] ^ pair[1], *, present)
      else
        mapreduce(pair -> pair[1] * pair[2] ^ order, +,
                  present) ^ (1.0 / order)
        end
    end
end

# This is the next most common case - a vector of orders
function powermean{S <: AbstractFloat}(values::AbstractArray{S, 1},
                                       orders::Vector,
                                       weights::AbstractArray{S, 1} = ones(values))
    map(order -> powermean(values, order, weights), orders)
end

# This is the next most simple case - matrices with subcommunities, and an order or orders
function powermean{S <: AbstractFloat}(values::AbstractArray{S, 2},
                                       orders,
                                       weights::AbstractArray{S, 2} = ones(values))
    size(values) == size(weights) ||
    throw(DimensionMismatch("powermean: Weight and value matrixes must be the same size"))

    map(col -> powermean(values[:,col], orders, weights[:, col]), 1:size(values)[2])
end

"""
### Calculates Hill / naive-similarity diversity

Calculates Hill number or naive diversity of order(s) *qs* of a
population with given relative proportions.

#### Arguments:
- `proportions`: relative proportions of different types in population
- `qs`: single number or vector of orders of diversity measurement

#### Returns:
- Diversity of order qs (single number or vector of diversities)"""
function qD{S <: Real}(proportions::AbstractArray{S, 1}, qs)
    if !isapprox(sum(proportions), 1.)
        warn("qD: Population proportions don't sum to 1, fixing...")
        proportions /= sum(proportions)
    end
    powermean(proportions, qs - 1., proportions) .^ -1
end

"""
### Calculates Leinster-Cobbold / similarity-sensitive diversity

Calculates Leinster-Cobbold general diversity of >= 1 order(s) *qs* of
a population with given relative *proportions*, and similarity matrix
*Z*.

#### Arguments:
- `proportions`: relative proportions of different types in a population
- `qs`: single number or vector of orders of diversity measurement
- `Z`: similarity matrix

#### Returns:
- Diversity of order qs (single number or vector of diversities)
"""
function qDZ{S <: AbstractFloat, T <: Similarity}(proportions::Vector{S}, qs,
                                         sim::T = Unique())
    if !isapprox(sum(proportions), 1.)
        warn("qDZ: Population proportions don't sum to 1, fixing...")
        proportions /= sum(proportions)
    end
    z = get_similarities(proportions, sim)
    powermean(z * proportions, qs - 1., proportions) .^ -1
end

qDZ{S <: AbstractFloat, T <: Similarity}(proportions::Matrix{S}, qs,
                                         sim::T = Unique()) =
                                             mapslices(p -> qDZ(p, qs, get_similarities(proportions, sim)),
                                                       proportions, 1)

qDZ{S <: AbstractFloat}(proportions::Array{S}, qs, z::Matrix{S}) = qDZ(proportions, qs, GeneralSimilarity(z))
