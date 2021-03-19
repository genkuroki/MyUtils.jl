# See julia/base/threadingconstructs.jl

using Base.Threads
using Base.Threads: threading_run

function _my_threadsfor(iter, lbody, prebody, postbody, schedule)
    lidx = iter.args[1]         # index
    range = iter.args[2]
    quote
        local threadsfor_fun
        let range = $(esc(range))
        function threadsfor_fun(onethread=false)
            r = range # Load into local variable
            lenr = length(r)
            # divide loop iterations among threads
            if onethread
                tid = 1
                len, rem = lenr, 0
            else
                tid = threadid()
                len, rem = divrem(lenr, nthreads())
            end
            # not enough iterations for all the threads?
            if len == 0
                if tid > rem
                    return
                end
                len, rem = 1, 0
            end
            # compute this thread's iterations
            f = firstindex(r) + ((tid-1) * len)
            l = f + len - 1
            # distribute remaining iterations evenly
            if rem > 0
                if tid <= rem
                    f = f + (tid-1)
                    l = l + tid
                else
                    f = f + rem
                    l = l + rem
                end
            end
            # run prebody
            $(esc(prebody))
            # run this thread's iterations
            for i = f:l
                local $(esc(lidx)) = @inbounds r[i]
                $(esc(lbody))
            end
            # run postbody
            $(esc(postbody))
        end
        end
        if threadid() != 1 || ccall(:jl_in_threaded_region, Cint, ()) != 0
            $(if schedule === :static
              :(error("`@my_threads :static` can only be used from thread 1 and not nested"))
              else
              # only use threads when called from thread 1, outside @threads
              :(Base.invokelatest(threadsfor_fun, true))
              end)
        else
            threading_run(threadsfor_fun)
        end
        nothing
    end
end

"""
    @my_threads

A macro to parallelize a `for` loop to run with multiple threads. 
It splits the iteration space among multiple tasks with `prebody` and `postbody`.
It runs those tasks on threads according to a scheduling policy.

Usage:

```julia
@my_threads [schedule] begin
    prebody
end for ...
    ...
end begin
    postbody
end
```
"""
macro my_threads(args...)
    na = length(args)
    if na == 4
        sched, prebody, ex, bostbody = args
        if sched isa QuoteNode
            sched = sched.value
        elseif sched isa Symbol
            # for now only allow quoted symbols
            sched = nothing
        end
        if sched !== :static
            throw(ArgumentError("unsupported schedule argument in @threads"))
        end
    elseif na == 3
        sched = :default
        prebody, ex, postbody = args
    else
        throw(ArgumentError("wrong number of arguments in @my_threads"))
    end
    if !(isa(ex, Expr) && ex.head === :for)
        throw(ArgumentError("@my_threads requires a `for` loop expression"))
    end
    if !(ex.args[1] isa Expr && ex.args[1].head === :(=))
        throw(ArgumentError("nested outer loops are not currently supported by @my_threads"))
    end
    return _my_threadsfor(ex.args[1], ex.args[2], prebody, postbody, sched)
end