module LispParsers

import ..SexprParsers

function parse_lisp(input)::Expr
    sexprs = SexprParsers.parse_sexpr_sequence(input)
    Expr(:toplevel, map(parse_expression, sexprs)...)
end

function parse_expression(sexpr)
    return sexpr
end

function parse_expression(sexpr::Array{Any})
    if sexpr[1] == :import
        println("$(sexpr[2:end])")
        return Expr(:toplevel, map(parse_importset, sexpr[2:end])...)

    elseif sexpr[1] == :define
        return make_definition(sexpr[2], parse_expression(sexpr[3]))
        
    elseif sexpr[1] == :lambda
        params = sexpr[2]
        body = sexpr[3]
        return Expr(:->, Expr(:tuple, params...), body)

    else
        return Expr(:call, map(parse_expression, sexpr)...)
    end
end

function parse_importset(imps)
    if imps[1] == :only
        args = imps[2:end]
        return Expr(:import, Expr(:(:), map((x) -> Expr(:., x), args)...))
    end
    error(imps)
end

function parse_importset(lib::Symbol)
    return Expr(:using, Expr(:., lib))
end

function make_definition(signature::Array{Any}, body::Any)
    return Expr(:function, Expr(:call, signature...), body)
end

function make_definition(variable::Symbol, value::Any)
    return Expr(:(=), variable, value)
end

end
