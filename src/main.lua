local script_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = script_dir .. "?.lua;" .. package.path

local lexer = require("lexer")
local Parser = require("parser")
local interp = require("interpreter")

local function run_file(path)
    local f = io.open(path, "r")
    if not f then
        error("Cannot open file: " .. path)
    end

    local code = f:read("*a")
    f:close()

    local tokens = lexer.tokenize(code)
    local parser = Parser:new(tokens)
    local ast = parser:parse()
    interp.exec(ast, {})
end

if not arg[1] then
    print("tif interpreter")
    print("Usage:")
    print("  tif file.tifx")
    os.exit(1)
end

run_file(arg[1])

