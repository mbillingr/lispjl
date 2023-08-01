module Tokenizers

struct Tokenizer
    input::String
end

function tokenize(input::String, drop_whitespace::Bool=false)
    if drop_whitespace
        Iterators.filter(!is_space, tokenize(input))
    else
        return Tokenizer(input)
    end
end

function Base.iterate(itr::Tokenizer, state=1)
    if state > lastindex(itr.input)
        return nothing
    elseif isspace(itr.input[state])
        return tokenize_whitespace(itr.input, state)
    else
        return tokenize_symbol(itr.input, state)
    end
end

function tokenize_symbol(input, state)
    first = state
    last_state = state
    while state <= lastindex(input) && !is_delimiter(input[state])
        last_state = state
        state = nextind(input, state)
    end
    if state == last_state
        return (input[first:state], nextind(input, state))
    else
        return (input[first:last_state], state)
    end
end

function tokenize_whitespace(input, state)
    first = state
    last_state = state
    while state <= lastindex(input) && isspace(input[state])
        last_state = state
        state = nextind(input, state)
    end
    return (input[first:last_state], state)
end

function is_delimiter(ch)
    ch == ':' || ch == '(' || ch == ')' || ch == '[' || ch == ']' || ch == '{' || ch == '}' || isspace(ch)
end

function is_space(str)
    isspace(str[1])
end

end
