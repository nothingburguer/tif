#include <stdio.h>
#include <lua5.4/lua.h>
#include <lua5.4/lualib.h>
#include <lua5.4/lauxlib.h>

#define TIF_LIB_PATH "/usr/local/lib/tif"

static void push_args(lua_State *L, int argc, char **argv) {
    lua_newtable(L);

    for (int i = 0; i < argc; i++) {
        lua_pushinteger(L, i);
        lua_pushstring(L, argv[i]);
        lua_settable(L, -3);
    }

    lua_setglobal(L, "arg");
}

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate();
    if (!L) {
        fprintf(stderr, "tif: failed to create Lua state\n");
        return 1;
    }

    luaL_openlibs(L);
    push_args(L, argc, argv);

    char buf[512];
    snprintf(buf, sizeof(buf),
        "package.path = '%s/?.luac;' .. package.path\n"
        "package.cpath = ''",
        TIF_LIB_PATH
    );

    if (luaL_dostring(L, buf) != LUA_OK) {
        fprintf(stderr, "tif: failed to configure Lua paths: %s\n",
                lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    char main_path[512];
    snprintf(main_path, sizeof(main_path),
             "%s/main.luac", TIF_LIB_PATH);

    if (luaL_dofile(L, main_path) != LUA_OK) {
        fprintf(stderr, "tif runtime error: %s\n",
                lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    lua_close(L);
    return 0;
}

