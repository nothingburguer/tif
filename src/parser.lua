local Parser = {}
Parser.__index = Parser

function Parser:new(tokens)
    return setmetatable({tokens=tokens, pos=1}, self)
end

function Parser:current()
    return self.tokens[self.pos]
end

function Parser:advance()
    self.pos = self.pos + 1
end

function Parser:expect(t)
    local tok = self:current()
    if not tok or tok.type ~= t then
        error("Expected " .. t)
    end
    self:advance()
    return tok
end

function Parser:parse()
    local nodes = {}
    while self.pos <= #self.tokens do
        table.insert(nodes, self:statement())
    end
    return nodes
end

function Parser:statement()
    local tok = self:current()

	if tok.value == "fn" then
		self:advance()

		local return_type = self:expect("id").value
		self:expect("colon")
		local name = self:expect("id").value

		self:expect("lparen")

		local params = {}
		if self:current().type ~= "rparen" then
			repeat
				table.insert(params, self:expect("id").value)
				if self:current().type == "comma" then
					self:advance()
				else
					break
				end
			until false
		end

		self:expect("rparen")
		self:expect("lbrace")

		local body = {}
		while self:current().type ~= "rbrace" do
			table.insert(body, self:statement())
		end
		self:expect("rbrace")

		return {
			type = "funcdef",
			name = name,
			params = params,
			body = body,
			ret_type = return_type
		}
	end

    if tok.value == "let" then
        self:advance()
        local name = self:expect("id").value
        self:expect("op")
        local expr = self:expression()
        return {type="var", name=name, expr=expr}

    elseif tok.value == "print" then
        self:advance()
        self:expect("lparen")
        local expr = self:expression()
        self:expect("rparen")
        return {type="print", expr=expr}

    elseif tok.value == "while" then
        self:advance()
        local cond = self:expression()
        self:expect("lbrace")
        local body = {}
        while self:current().type ~= "rbrace" do
            table.insert(body, self:statement())
        end
        self:expect("rbrace")
        return {type="while", cond=cond, body=body}

    elseif tok.value == "if" then
        self:advance()
        local cond = self:expression()
        self:expect("lbrace")

        local then_body = {}
        while self:current().type ~= "rbrace" do
            table.insert(then_body, self:statement())
        end
        self:expect("rbrace")

        local else_body = nil
        if self:current() and self:current().value == "else" then
            self:advance()
            self:expect("lbrace")
            else_body = {}
            while self:current().type ~= "rbrace" do
                table.insert(else_body, self:statement())
            end
            self:expect("rbrace")
        end

        return {type="if", cond=cond, then_body=then_body, else_body=else_body}

	elseif tok.value == "return" then
		self:advance()
		local expr = self:expression()
		return { type="return", expr=expr }

    else
        local name = self:expect("id").value
        self:expect("op")
        local expr = self:expression()
        return {type="assign", name=name, expr=expr}
    end
end

function Parser:expression()
    local left = self:term()

    while self.pos <= #self.tokens and self:current().type == "op" do
        local op = self:current().value
        self:advance()
        local right = self:term()
        left = {type="binop", op=op, left=left, right=right}
    end

    return left
end

function Parser:term()
    local tok = self:current()

    if tok.type == "number" then
        self:advance()
        return {type="number", value=tonumber(tok.value)}
     
	elseif tok.type == "id" then
        local name = tok.value
	   	self:advance()
        
        if self:current() and self:current().type == "lparen" then
            self:advance()
            local args = {}
            
            if self:current().type ~= "rparen" then
                repeat
	                table.insert(args, self:expression())
                    if self:current().type == "comma" then
	                    self:advance()
                    else
                        break
                    end
                until false
            end
         
            self:expect("rparen")
            return { type="funccall", name=name, args=args }
        end
        
	    return {type="varref", name=name}
        
    elseif tok.type == "lparen" then
        self:advance()
        local expr = self:expression()
        self:expect("rparen")
        return expr

    elseif tok.type == "string" then
        self:advance()
        return {type="string", value=tok.value:sub(2, -2)}

    end

    error("Unexpected token")
end

return Parser

