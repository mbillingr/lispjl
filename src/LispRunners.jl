module LispRunners

import ..LispParsers: parse_lisp
import ..SexprParsers: parse_sexpr

function repl()
    lispmain = Module(:lispmain, false, false)
    lisplibs = Module(:lisplibs, false, false)
    internal = Module(:internal)

    Core.eval(internal, :(import lispjl.Runtime as runtime))
    Core.eval(internal, :(main = $lispmain))
    Core.eval(internal, :(libs = $lisplibs))

    # todo: rename to something that won't clash with anything defined in lisp
    Core.eval(lispmain, :(__internal__ = $internal))  


    for line in prompt("> ")
        expr = parse_lisp(line)
        value = Core.eval(lispmain, expr)
        if value !== nothing
            println(value)
        end
    end
end

function prompt(prompt::String)
    return Prompt(prompt, eachline())
end

struct Prompt
    prompt::String
    lines::Base.EachLine
end

function Iterators.iterate(p::Prompt, state=nothing)
    print("> ")
    iterate(p.lines)
end

end