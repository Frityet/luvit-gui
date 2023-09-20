#include <lua.hpp>
#include <cstdio>
#include <chrono>

using LuaReference = int64_t;

#if defined (__APPLE__)

#include <CoreFoundation/CoreFoundation.h>

static int run_on_runloop(lua_State *state)
{
    auto interval = luaL_optnumber(state, 2, 0.000000001);
    auto runloop = CFRunLoopGetMain();

    luaL_checktype(state, 1, LUA_TFUNCTION);
    lua_pushvalue(state, 1);

    auto func_ref = luaL_ref(state, LUA_REGISTRYINDEX);

    struct CallbackInfo {
        lua_State *state;
        LuaReference func_ref;
    };

    auto callback_info = new CallbackInfo { state, func_ref };
    auto ctx = CFRunLoopTimerContext {
        .info = callback_info,
    };

    auto timer = CFRunLoopTimerCreate(nullptr, 0, interval, 0, 0, [](CFRunLoopTimerRef timer, void *info) {
        auto callback_info = static_cast<CallbackInfo *>(info);
        auto state = callback_info->state;
        auto func_ref = callback_info->func_ref;

        lua_rawgeti(state, LUA_REGISTRYINDEX, func_ref);
        if (lua_type(state, -1) != LUA_TFUNCTION) {
            const char *tname = lua_typename(state, lua_type(state, -1));
            luaL_error(state, "value of type %s at index %d is not a function\nChecked registry with refrence %d", tname, -1, func_ref);
            return;
        }

        if (lua_pcall(state, 0, 1, 0) != LUA_OK) {
            luaL_error(state, "error running function in timer at %p: %s", timer, lua_tostring(state, -1));
            return;
        }
        auto result = lua_toboolean(state, -1);
        lua_pop(state, 1);

        if (!result) {
            luaL_unref(state, LUA_REGISTRYINDEX, func_ref);
            delete callback_info;
            CFRunLoopTimerInvalidate(timer);
        }
    }, &ctx);

    CFRunLoopAddTimer(runloop, timer, kCFRunLoopCommonModes);
    CFRelease(timer);
    return 0;
}

#elif defined (__linux__) //GTK

#include <gtk/gtk.h>

static int run_on_runloop(lua_State *state)
{
    auto interval = luaL_optnumber(state, 2, 0.1);

    luaL_checktype(state, 1, LUA_TFUNCTION);
    lua_pushvalue(state, 1);

    auto func_ref = luaL_ref(state, LUA_REGISTRYINDEX);

    struct CallbackInfo {
        lua_State *state;
        LuaReference func_ref;
    };

    auto callback_info = new CallbackInfo { state, func_ref };

    auto timer = g_timeout_add(interval * 1000, [](void *info) -> gboolean {
        auto callback_info = static_cast<CallbackInfo *>(info);
        auto state = callback_info->state;
        auto func_ref = callback_info->func_ref;

        lua_rawgeti(state, LUA_REGISTRYINDEX, func_ref);
        if (lua_type(state, -1) != LUA_TFUNCTION) {
            const char *tname = lua_typename(state, lua_type(state, -1));
            luaL_error(state, "value of type %s at index %d is not a function\nChecked registry with refrence %d", tname, -1, func_ref);
            return false;
        }

        if (lua_pcall(state, 0, 1, 0) != LUA_OK) {
            luaL_error(state, "error running function in timer at %p: %s", timer, lua_tostring(state, -1));
            return false;
        }
        auto result = lua_toboolean(state, -1);
        lua_pop(state, 1);

        if (!result) {
            luaL_unref(state, LUA_REGISTRYINDEX, func_ref);
            delete callback_info;
            return false;
        }
        return true;
    }, callback_info);

    return 0;
}

#elif defined (_WIN32)

#include <windows.h>

static int run_on_runloop(lua_State *state)
{
    auto interval = luaL_optnumber(state, 2, 0.1);

    luaL_checktype(state, 1, LUA_TFUNCTION);
    lua_pushvalue(state, 1);

    auto func_ref = luaL_ref(state, LUA_REGISTRYINDEX);

    struct CallbackInfo {
        lua_State *state;
        LuaReference func_ref;
    };

    auto callback_info = new CallbackInfo { state, func_ref };

    auto timer = SetTimer(nullptr, 0, interval * 1000, [](HWND hwnd, UINT msg, UINT_PTR id, DWORD time) {
        auto callback_info = reinterpret_cast<CallbackInfo *>(id);
        auto state = callback_info->state;
        auto func_ref = callback_info->func_ref;

        lua_rawgeti(state, LUA_REGISTRYINDEX, func_ref);
        if (lua_type(state, -1) != LUA_TFUNCTION) {
            const char *tname = lua_typename(state, lua_type(state, -1));
            luaL_error(state, "value of type %s at index %d is not a function\nChecked registry with refrence %d", tname, -1, func_ref);
            return;
        }

        if (lua_pcall(state, 0, 1, 0) != LUA_OK) {
            luaL_error(state, "error running function in timer at %p: %s", timer, lua_tostring(state, -1));
            return;
        }
        auto result = lua_toboolean(state, -1);
        lua_pop(state, 1);

        if (!result) {
            luaL_unref(state, LUA_REGISTRYINDEX, func_ref);
            delete callback_info;
            KillTimer(hwnd, id);
        }
    });

    return 0;
}

#else
#error "Unsupported platform"
#endif

//accurate `clock` f
static int accurate_clock(lua_State *lua)
{
    lua_pushnumber(lua, std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 100.0);
    return 1;
}

static const luaL_Reg LIBRARY[] = {
    { "enqueue", &run_on_runloop },
    { "clock", &accurate_clock },
    {}
};

extern "C" int luaopen_utilities(lua_State *state)
{
    luaL_newlib(state, LIBRARY);
    return 1;
}
