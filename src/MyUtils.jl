module MyUtils

include("defunpack.jl")
include("my_threads.jl")
include("my_distributed.jl")
include("printf_functions.jl")
include("remove_one_from.jl")
include("showimg.jl")
include("savevar.jl")

using .PrintfFunctions
export printf, sprintf

using .DefUnPack
export @defunpack

end
