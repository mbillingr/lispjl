module SexprParsers

import ..Tokenizers

export parse_sexpr, parse_sexpr_sequence

function parse_sexpr(str::String)
    tokens = Iterators.Stateful(Tokenizers.tokenize(str, true))
    parse_sexpr(tokens)
end

function parse_sexpr_sequence(str::String)
    tokens = Iterators.Stateful(Tokenizers.tokenize(str, true))
    parse_sexpr_sequence(tokens)
end

function parse_sexpr_sequence(tokens)
    items = []
    try
        while true
            push!(items, parse_sexpr(tokens))
        end
    catch EOFError
    end
    return items
end

function parse_sexpr(tokens)
    tok = popfirst!(tokens)

    if tok == "("
        return parse_sexpr_list(tokens)
    end

    try
        i = parse(Int, tok)
        return i
    catch ArgumentError
    end

    return Symbol(tok)
end

function parse_sexpr_list(tokens)
    tok = peek(tokens)
    items = []
    while tok != ")"
        push!(items, parse_sexpr(tokens))
        tok = peek(tokens)
    end
    popfirst!(tokens)    
    return items
end

function append(xs::Tuple{}, x)
    return (x, ())
end

function append(xs::Tuple{Any, Any}, x)
    (head, tail) = xs
    return (head, append(tail, x))
end

end