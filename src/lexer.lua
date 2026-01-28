local M = {}

function M.tokenize(code)
    local tokens = {}
    local i = 1

    local patterns = {
        {"string", '^"[^"]*"'},
        {"number", "^%d+"},
        {"id", "^[%a_][%w_]*"},
        {"op", "^[=!<>]="},
        {"op", "^[%+%-%*/=<>]"},
        {"lparen", "^%("},
        {"rparen", "^%)"},
        {"lbrace", "^{"},
        {"rbrace", "^}"},
        {"comma", "^,"},
        {"space", "^%s+"},
		{"colon", "^:"},
    }

    while i <= #code do
        local substr = code:sub(i)
        local matched = false

        for _, p in ipairs(patterns) do
            local t, pattern = p[1], p[2]
            local m = substr:match(pattern)
            if m then
                matched = true
                if t ~= "space" then
                    table.insert(tokens, {type=t, value=m})
                end
                i = i + #m
                break
            end
        end

        if not matched then
            error("Invalid character: " .. substr:sub(1,1))
        end
    end

    return tokens
end

return M

