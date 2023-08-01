module LispRunners

import ..LispParsers: parse_lisp
import ..SexprParsers: parse_sexpr

function repl()
    lispmain = Module(:lispmain, false, false)
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