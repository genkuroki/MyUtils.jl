module MyUtils

include("my_threads.jl")
include("my_distributed.jl")
include("PrintfFunctions.jl")

using .PrintfFunctions
export printf, sprintf

end
