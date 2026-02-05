<a href='https://postimg.cc/MMYpZB5t' target='_blank'><img src='https://i.postimg.cc/MMYpZB5t/tif.png' border='0' alt='tif'/></a>

<br>

`tif` is a small interpreted programming language implemented in Lua.  
It was designed to be simple, lightweight, and easy to understand, serving both as an educational project and as a base for experimentation with language design and interpreter implementation.

## Overview

The language is built around a classic interpreter architecture:

- **Lexer** – converts source code into tokens  
- **Parser** – builds an Abstract Syntax Tree (AST)  
- **Interpreter** – evaluates the AST directly

`tif` does not rely on external dependencies beyond the Lua runtime.

## Features

- Variable declaration and assignment
- Arithmetic expressions
- Comparison operators
- `while` loops
- Built-in `print` function
- Simple and readable syntax
- AST-based execution model
- `if/else` statements
- Functions
- Optional typed declaration

## Examples
<br>

**Example 1:**

```rust
let x = 3

while x > 0 {
    print(x)
    x = x - 1
}
```
<br>

**Example 2:**

```rust
fn int:sum(a, b) {
    return a + b
}

let int:x = 10
x = sum(x, 5)

print(x)
```
