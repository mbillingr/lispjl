module Runtime

export ensure_module

import ..LispParsers: parse_lisp
import ..SexprParsers: parse_sexpr

HERE = Base.Filesystem.pwd()

function ensure_module(importset, parent_module::Module, file_path::String = HERE * "/libscm")
    if length(importset) == 0
        return
    end

    mod = importset[1]
    file_path = file_path * "/" * String(mod)

    if isdefined(parent_module, mod)
        return
    end

    if length(importset) == 1
        file_path = file_path * ".scm"
        src = read(file_path, String)
        expr = parse_lisp(src)
        value = Core.eval(parent_module, expr)
    else
        mod_obj = Core.eval(parent_module, :(module $mod end))
        ensure_module(importset[2:end], mod_obj, file_path)
    end
end

end