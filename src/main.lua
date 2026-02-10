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
    print([[
tif — the minimal interpreted programming language

Usage:
    tif <file.tlf>

File extension:
    .tlf (Tif Language File)

Copyright:
    MIT License, Copyright (c) 2026 nothingburguer
]])
    os.exit(1)
end

run_file(arg[1])
