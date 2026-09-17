#include <stdio.h>
#include <time.h>

#include "lua.h"
#include "lauxlib.h"

#pragma export(libinit)

// ======== GRAPHICS ========

#include "tigr/tigr.h"

static const int window_size = 240;
static const int circle_x = window_size / 2;
static const int circle_y = window_size / 2;
static const int circle_radius = 100;

static Tigr *screen;

static void create_window(void) {
    screen = tigrWindow(window_size, window_size, "Glowie script preview", TIGR_AUTO);
    tigrClear(screen, tigrRGB(0, 0, 0));
    tigrUpdate(screen);
}

static void set_color(char r, char g, char b) {
    tigrFillCircle(screen, circle_x, circle_y, circle_radius, tigrRGB(r, g, b));
    tigrUpdate(screen);
}

// ========== TIME ===========

static struct timespec start_time;

static void reset_time(void) {
    clock_gettime(CLOCK_MONOTONIC, &start_time);
}

static unsigned int get_time_ms(void) {
    struct timespec current_time;
    clock_gettime(CLOCK_MONOTONIC, &current_time);
    unsigned int time = (current_time.tv_sec - start_time.tv_sec) * 1000 +
                        (current_time.tv_nsec - start_time.tv_nsec) / 1000000;
    return time;
}

static void sleep_ms(unsigned int time) {
    struct timespec sleep_ts = {
        .tv_sec = time / 1000,
        .tv_nsec = (time % 1000) * 1000000L
    };
    nanosleep(&sleep_ts, NULL);
}

// ========== LUA FUNCTIONS ==========

static int lua_setColor(lua_State* L) {
    int r = luaL_checkinteger(L, 1);
    int g = luaL_checkinteger(L, 2);
    int b = luaL_checkinteger(L, 3);
    set_color(r, g, b);
    return 0;
}

static int lua_time(lua_State* L) {
    unsigned int time = get_time_ms();
    lua_pushinteger(L, time);
    return 1;
}

static int lua_sleep(lua_State* L) {
    int time_ms = luaL_checkinteger(L, 1);
    sleep_ms(time_ms);
    return 0;
}

// ========= OPEN LIB =============

int luaopen_previewlib(lua_State* L) {
    reset_time();
    create_window();

    lua_newtable(L);
    lua_pushcfunction(L, lua_setColor);
    lua_setfield(L, -2, "setColor");
    lua_setglobal(L, "led");

    lua_register(L, "time", lua_time);
    lua_register(L, "sleep", lua_sleep);
    return 0;
}
