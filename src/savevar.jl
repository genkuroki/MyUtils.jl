"""
    savevar(fn, x)

saves the value of `x` to the file `fn`, where `fn` is the filename string of the file.
"""
savevar(fn, x) = write(fn, string(x))

"""
    loadvar(fn)

loads the file `fn` (the filename string of the file) and `Meta.parse |> eval`.
"""
loadvar(fn) = read(fn, String) |> Meta.parse |> eval

"""
    dir_savevar

is the default directory to which `@savevar` saves the values of variables.
"""
const dir_savevar = "."

"""
    fn_savevar(x::Symbol)

is the filename string to which `@savevar` saves the value of a variable.
"""
fn_savevar(x::Symbol) = joinpath(dir_savevar, string(x) * ".txt")

"""
    @savevar(args...)

saves the variables in args to the corresponding textfiles.

Example: `@savevar A B C` saves the variables `A`, `B`, `C` to textfiles. 
"""
macro savevar(args...)
    A = [:(savevar($(fn_savevar(x)), $(esc(x)))) for x in args]
    quote $(A...); nothing end
end

"""
    @loadvar(args...)

loads the values from the textfiles corresponding to `args`.
If `length(args)` is greater than 1, then it returns the tuple of the values.

Example: `a, b, c = @loadvar A B C` loads 
the values of `A`, `B`, `C` in textfiles to the variables `a`, `b`, `c`.
"""
macro loadvar(args...)
    if length(args) == 1
        x = args[1]
        :(loadvar($(fn_savevar(x))))
    else
        A = [:(loadvar($(fn_savevar(x)))) for x in args]
        :(($(A...),))
    end
end
