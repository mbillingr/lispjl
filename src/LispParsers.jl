module LispParsers

import ..SexprParsers

function parse_lisp(input)::Expr
    sexprs = SexprParsers.parse_sexpr_sequence(input)
    Expr(:toplevel, map((x)->parse_expression(x, :toplevel), sexprs)...)
end

function parse_expression(sexpr, context)
    return sexpr
end

function parse_expression(sexpr::Array{Any}, context=:toplevel)
    if sexpr[1] == Symbol("define-library")
        libname = sexpr[2]
        modname = libname[end]
        body = map((x)->parse_expression(x, :block), sexpr[3:end])
        return Expr(:module, false, modname, Expr(:block, body...))

    elseif sexpr[1] == :export
        return Expr(:export, sexpr[2:end]...)

    elseif sexpr[1] == :import
        return Expr(context, map((x)->parse_importset(x, context), sexpr[2:end])...)

    elseif sexpr[1] == :begin
        return Expr(:block, map((x)->parse_expression(x, :block), sexpr[2:end])...)

    elseif sexpr[1] == :define
        return make_definition(sexpr[2], parse_expression(sexpr[3], context))

    elseif sexpr[1] == :lambda
        params = sexpr[2]
        body = sexpr[3]
        return Expr(:->, Expr(:tuple, params...), body)

    else
        return Expr(:call, map((x)->parse_expression(x, context), sexpr)...)
    end
end

function parse_importset(imps, context)
    if imps[1] == :only
        args = imps[2:end]
        return Expr(:import, Expr(:(:), map((x) -> Expr(:., x), args)...))
    end

    return Expr(context,
        :(__internal__.runtime.ensure_module($imps, __internal__.libs)),
        Expr(:using, Expr(:., :., :__internal__, :libs, imps...))
    )
end

function make_lib_juliapath(lib_scmpath)
    path = lib_scmpath[1]
    for part in lib_scmpath[2:end]
        path = :($path.$part)
    end
    return path
end

function make_definition(signature::Array{Any}, body::Any)
    return Expr(:function, Expr(:call, signature...), body)
end

function make_definition(variable::Symbol, value::Any)
    return Expr(:(=), variable, value)
end

end
