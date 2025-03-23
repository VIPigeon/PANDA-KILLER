import sys
import itertools

from string import ascii_lowercase

from luaparser import ast

DO_NOT_RENAME = [
    # Lua keywords (do not rename these)
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
    "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then",
    "true", "until", "while",

    "self",

    # Core Functions
    "TIC",

    "btn", "btnp", "clip", "exit", "fget", "font", "fset", "key", "keyp",
    "map", "mget", "mset", "music", "peek", "peek4", "poke", "poke4", "pmem",
    "print", "rect", "reset", "sfx", "spr", "sync", "time", "trace", "tri",

    # Graphics
    "circ", "circb", "cls", "elli", "ellib", "line", "pix", "tri", "trib",

    # Sound
    "music", "sfx",

    # Input
    "mouse",

    # Map
    "map", "mget", "mset",

    # Memory
    "pmem", "peek", "peek4", "poke", "poke4",

    # Math
    "abs", "atan", "band", "bnot", "bor", "bxor", "cos", "flr", "max", "min",
    "mid", "rnd", "shl", "shr", "sin", "sqrt", "sgn", "vbank",

    # System
    "time", "tstamp",

    # Callbacks (TIC-80 lifecycle functions)
    "_init", "_update", "_draw", "_scanline", "_border", "_exit", "_update60",

    # Special Variables
    "_SCREEN", "_MOUSE", "_PALETTE", "_COLORS", "_WIDTH", "_HEIGHT",

    # Table library (split into 'table' + function names)
    "table", "insert", "remove", "concat", "sort", "pack", "unpack", "move", "clear",

    # Math library (split into 'math' + function names)
    "math", "abs", "acos", "asin", "atan", "ceil", "cos", "deg", "exp", "floor",
    "fmod", "log", "max", "min", "modf", "rad", "random", "randomseed", "sin", "sqrt",
    "tan", "tointeger", "type", "ult",

    # String library (split into 'string' + function names)
    "string", "byte", "char", "dump", "find", "format", "gmatch", "gsub", "len",
    "lower", "match", "rep", "reverse", "sub", "upper", "pack", "unpack",

    # Core functions (direct names)
    "assert", "collectgarbage", "dofile", "error", "getmetatable", "ipairs", "load",
    "loadfile", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen",
    "rawset", "require", "select", "setmetatable", "tonumber", "tostring", "type",
    "xpcall",

    # Special globals
    "_G", "_VERSION",

    # Metafields (metamethods)
    "__index", "__newindex", "__call", "__add", "__sub", "__mul", "__div", "__mod",
    "__pow", "__unm", "__concat", "__len", "__eq", "__lt", "__le", "__tostring",
    "__metatable", "__gc", "__mode", "__idiv", "__band", "__bor", "__bxor",
    "__bnot", "__shl", "__shr", "__pairs", "__ipairs",
]

def minimize_lua_source(code):
    tree = ast.parse(code)

    variables_map = {}

    rep_count = 1
    prod = itertools.product(ascii_lowercase, repeat=rep_count)

    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and node.id not in variables_map and node.id not in DO_NOT_RENAME:
            next_id = next(prod, None)
            while next_id is None:
                if next_id is None:
                    rep_count += 1
                    prod = itertools.product(ascii_lowercase, repeat=rep_count)
                next_id = next(prod, None)
            next_id_str = ''.join(next_id)

            if next_id_str not in DO_NOT_RENAME:
                variables_map[node.id] = next_id_str

    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and node.id in variables_map:
            node.id = variables_map[node.id]

    minimized_code = ast.to_lua_source(tree)
    minimized_code = ' '.join(minimized_code.split()) + '\n'
    minimized_code = minimized_code.replace("'''", "'\\''")

    return minimized_code

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <file.lua>")
    sys.exit(1)

lua_source_code = None
with open(sys.argv[1], 'r') as input_file:
    lua_source_code = input_file.read()

with open('mini.lua', 'w') as file:
    minimized_code = minimize_lua_source(lua_source_code)
    file.write(minimized_code)
