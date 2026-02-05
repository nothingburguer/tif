local M = {}
local FUNCTIONS = {}

local TYPE_CHECKERS = {
    int = function(v)
        return type(v) == "number" and math.floor(v) == v
    end,

    string = function(v)
        return type(v) == "string"
    end,

    bool = function(v)
        return type(v) == "boolean"
    end
}

local function check_type(expected, value, context)
    local checker = TYPE_CHECKERS[expected]
    if not checker then
        error("Unknown type: " .. expected)
    end

    if not checker(value) then
        error(
            "Type error: expected " .. expected ..
            " in " .. context ..
            ", got " .. type(value)
        )
    end
end

function M.eval_expr(expr, env)
    if expr.type == "number" then
        return expr.value
    elseif expr.type == "varref" then
        return env[expr.name] or 0
    elseif expr.type == "binop" then
        local a = M.eval_expr(expr.left, env)
        local b = M.eval_expr(expr.right, env)
        local op = expr.op

        if op == "+" then return a + b end
        if op == "-" then return a - b end
        if op == "*" then return a * b end
        if op == "/" then return a / b end
        if op == ">" then return a > b end
        if op == "<" then return a < b end
        if op == "==" then return a == b end

        error("Unknown operator: " .. op)
    elseif expr.type == "funccall" then
        local fn = FUNCTIONS[expr.name]
        if not fn then
            error("Undefined function: " .. expr.name)
        end

        if #expr.args ~= #fn.params then
            error("Function '" .. expr.name .. "' expects " ..
                #fn.params .. " arguments, got " .. #expr.args)
        end

        local local_env = { __types = {} }

        for i, param in ipairs(fn.params) do
            local value = M.eval_expr(expr.args[i], env)
            local_env[param] = value
        end

        local result = M.exec(fn.body, local_env)

        if fn.ret_type then
            local ret = result and result.__return or nil
            check_type(fn.ret_type, ret, "return of function '" .. fn.name .. "'")
            return ret
        end

        return result and result.__return or nil
    elseif expr.type == "string" then
        return expr.value
    end
end

function M.exec(nodes, env)
    for _, node in ipairs(nodes) do
        if node.type == "var" then
            local value = M.eval_expr(node.expr, env)

            if node.var_type then
                check_type(node.var_type, value, "variable '" .. node.name .. "'")
                env.__types = env.__types or {}
                env.__types[node.name] = node.var_type
            end

            env[node.name] = value
        elseif node.type == "assign" then
            local value = M.eval_expr(node.expr, env)

            if env.__types and env.__types[node.name] then
                check_type(
                    env.__types[node.name],
                    value,
                    "variable '" .. node.name .. "'"
                )
            end

            env[node.name] = value
        elseif node.type == "print" then
            print(M.eval_expr(node.expr, env))
        elseif node.type == "while" then
            while M.eval_expr(node.cond, env) do
                M.exec(node.body, env)
            end
        elseif node.type == "funcdef" then
            FUNCTIONS[node.name] = node
        elseif node.type == "return" then
            return { __return = M.eval_expr(node.expr, env) }
        elseif node.type == "if" then
            if M.eval_expr(node.cond, env) then
                M.exec(node.then_body, env)
            elseif node.else_body then
                M.exec(node.else_body, env)
            end
        end
    end
end

return M

