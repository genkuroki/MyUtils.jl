module PrintfFunctions

using Printf

export printf, sprintf

# The following code is copied from 
#
#     https://github.com/JuliaIO/Formatting.jl/pull/15/files
#
# and modified to work with Julia v1.x.
# 
###########
#
# Implementation of printf() and sprintf() that uses generated functions
# and the existing @printf and @sprintf macros.
#
# Original work by Tim Holy. Minor edits by Daniel Carrera.
#
struct FormatString{S} end

FormatString(str::AbstractString) = FormatString{Symbol(str)}

@generated function Base.print(::Type{FormatString{format}}, args...) where format
    meta = Expr(:meta, :inline)
    fmt = string(format)
    allargs = [:(args[$d]) for d = 1:length(args)]
    quote
        @printf($fmt, $(allargs...))
    end
end
@generated function Base.sprint(::Type{FormatString{format}}, args...) where format
    meta = Expr(:meta, :inline)
    fmt = string(format)
    allargs = [:(args[$d]) for d = 1:length(args)]
    quote
        @sprintf($fmt, $(allargs...))
    end
end

#
# USAGE: printf("%6d  %7.2f", 220/7, 22/7)
#
function printf(s::AbstractString, args...)
    print(FormatString(s), args...)
end
function sprintf(s::AbstractString, args...)
    sprint(FormatString(s), args...)
end
###########

end
