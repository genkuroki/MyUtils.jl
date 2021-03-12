# See julia/stdlib/Distributed/src/macros.jl

using Distributed: preduce, pfor, make_preduce_body, make_pfor_body

function my_make_preduce_body(var, prebody, body)
    quote
        function (reducer, R, lo::Int, hi::Int)
            $(esc(prebody))
            $(esc(var)) = R[lo]
            ac = $(esc(body))
            if lo != hi
                for $(esc(var)) in R[(lo+1):hi]
                    ac = reducer(ac, $(esc(body)))
                end
            end
            ac
        end
    end
end

function my_make_pfor_body(var, prebody, body)
    quote
        function (R, lo::Int, hi::Int)
            $(esc(prebody))
            for $(esc(var)) in R[lo:hi]
                $(esc(body))
            end
        end
    end
end

"""
    @my_distributed

A distributed memory, parallel for loop of the form:

```julia
@my_distributed begin
    prebody
end [reducer] for var = range
    body
end
```
"""
macro my_distributed(args...)
    na = length(args)
    if na==2
        prebody, loop = args
    elseif na==3
        prebody, reducer, loop = args
    else
        throw(ArgumentError("wrong number of arguments to @my_distributed"))
    end
    if !isa(loop,Expr) || loop.head !== :for
        error("malformed @my_distributed loop")
    end
    var = loop.args[1].args[1]
    r = loop.args[1].args[2]
    body = loop.args[2]
    if na==2
        syncvar = esc(Base.sync_varname)
        return quote
            local ref = pfor($(my_make_pfor_body(var, prebody, body)), $(esc(r)))
            if $(Expr(:islocal, syncvar))
                put!($syncvar, ref)
            end
            ref
        end
    else
        return :(preduce($(esc(reducer)), $(my_make_preduce_body(var, prebody, body)), $(esc(r))))
    end
end
