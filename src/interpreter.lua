local M = {}
local FUNCTIONS = {}

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
        if not fn then error("Undefined function: "..expr.name) end
        
        local local_env = {}
        
        for i, param in ipairs(fn.params) do
            local_env[param] = M.eval_expr(expr.args[i], env)
        end
        
        local result = M.exec(fn.body, local_env)
        if result and result.__return ~= nil then
            return result.__return
        end
        
        return nil
    elseif expr.type == "string" then
        return expr.value
    end
end

function M.exec(nodes, env)
    for _, node in ipairs(nodes) do
        if node.type == "var" then
            env[node.name] = M.eval_expr(node.expr, env)
        elseif node.type == "assign" then
            env[node.name] = M.eval_expr(node.expr, env)
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

