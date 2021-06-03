# License is MIT: https://github.com/genkuroki/MyUtils.jl/blob/main/LICENSE

"""
    RemoveOneFrom(A::AbstractVector, k::Integer) <: AbstractVector

Equivalent to A[[1:k-1; k+1:end]] without unnecessary memory allocation.

Example

```julia
A = [1, 2, 3, 4, 5]
R = RemoveOneFrom(A, 3)
@show collect(R)
# -> collect(R) = [1, 2, 4, 5]
R[3] = 99
@show R
# -> R = [1, 2, 99, 5]
@show A
# -> A = [1, 2, 3, 99, 5]
```
"""
struct RemoveOneFrom{T, A<:AbstractVector{T}, K<:Integer} <: AbstractVector{T}
    A::A
    k::K
end

Base.size(x::RemoveOneFrom) = (size(x.A, 1) - 1,)
Base.getindex(x::RemoveOneFrom, i) = i < x.k ? x.A[i] : x.A[i+1]
Base.getindex(x::RemoveOneFrom, ::Colon) = collect(x)
Base.setindex!(x::RemoveOneFrom, v, i) = i < x.k ? (x.A[i] = v) : (x.A[i+1] = v)
