savevar(fn, x) = write(fn, string(x))
loadvar(fn) = read(fn, String) |> Meta.parse |> eval

const dir_savevar = "."
fn_savevar(x::Symbol) = joinpath(dir_savevar, string(x) * ".txt")
macro savevar(x) :(savevar($(fn_savevar(x)), $(esc(x)))) end
macro loadvar(x) :(loadvar($(fn_savevar(x)))) end
