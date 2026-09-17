-------------------------
--- COLORS
-------------------------

local color_metatable = {
    as_rgb = function(color) return color.rgb end,
    fade = function(color, factor)
        local rgb = color:as_rgb()
        return Color.rgb(
            math.min(rgb[1] * factor, 255),
            math.min(rgb[2] * factor, 255),
            math.min(rgb[3] * factor, 255)
        )
    end
}
color_metatable.__index = color_metatable

Color = {
    rgb = function (r, g, b)
        local new_color = { rgb = { r, g, b } }
        setmetatable(new_color, color_metatable)
        return new_color
    end,
}

Color.none   = Color.rgb(0, 0, 0)
Color.white  = Color.rgb(255, 255, 255)
Color.red    = Color.rgb(255, 0, 0)
Color.orange = Color.rgb(255, 128, 0)
Color.yellow = Color.rgb(255, 255, 0)
Color.lime   = Color.rgb(128, 255, 0)
Color.green  = Color.rgb(0, 255, 0)
Color.cyan   = Color.rgb(0, 255, 255)
Color.blue   = Color.rgb(0, 0, 255)
Color.pink   = Color.rgb(255, 0, 255)

-------------------------
--- EFFECT TYPE
-------------------------

local effect_metatable = {}

EffectType = {
    COLOR = 1,
    VALUE = 2,
}

function Effect(f, length, type)
    if type == nil then type = EffectType.COLOR end

    local effect = {
        f = f,
        len = length,
        type = type,
    }
    setmetatable(effect, effect_metatable)
    return effect
end

--------------------------
--- BASIC EFFECTS
--------------------------

-- Set to a fixed color for the given duration.
-- If length is not given, the effect runs indefinitely
function fixed_color(color, length)
    -- TODO: assert color is a valid color
    if length == nil then length = math.huge end
    assert(type(length) == "number")
    return Effect(function (t) return color end, length)
end

-- Repeat the given effect for the given number of times
function rep(effect, times)
    local effect_fun = effect.f
    local effect_len = effect.len
    return Effect(
        function(t) return effect_fun(t % effect_len) end,
        effect.len * times
    )
end

-- Create a sequence from a given list of effect.
-- Effects shall be given as a list {effect1, effect2, ...}
function seq(effects)
    -- effect_table will contain pairs of {end_time, effect_function}
    assert(#effects > 0, "No effects given to sequence")
    local effect_table = {}
    local start_time = 0
    print(#effects)
    for i, effect in ipairs(effects) do
        local end_time = start_time + effect.len
        effect_table[i] = { start_time, end_time, effect.f }
        start_time = end_time
    end
    local seq_len = start_time

    return Effect(
        function(t)
            for _, effect in ipairs(effect_table) do
                if (t < effect[2]) then return effect[3](t - effect[1]) end
            end
        end,
        seq_len
    )
end

-- Concatenate 2 effects.
-- Equivalent to seq{e1, e2}
function concat(e1, e2)
    local total_len = e1.len + e2.len
    local e1_fun, e2_fun = e1.f, e2.f
    local e1_len = e1.len
    return Effect(
        function(t)
            if t < e1_len then return e1_fun(t)
            elseif t < total_len then return e2_fun(t - e1_len)
            else return end
        end,
        total_len
    )
end

-- Loop the given effect forever
function loop(effect)
    local effect_fun = effect.f
    local effect_len = effect.len
    return Effect(
        function(t) return effect_fun(t % effect_len) end,
        math.huge
    )
end

--------------------
--- TIME WARPING
--------------------

-- Stretch an effect with the given factor
-- a factor greater than 1 slows down the effect (multiplies the duration)
-- a factor smaller than 1 speeds up the effect (divides the duration)
-- a negative factor reverses the effect
function stretch(effect, factor)
    assert(type(factor) == "number")
    assert(factor ~= 0, "the stretch factor cannot be 0")

    if factor < 0 then
        effect = reverse(effect)
        factor = -factor
    end

    local effect_fun = effect.f

    return Effect(
        function(t) return effect_fun(t / factor) end,
        effect.len * factor
    )
end

-- Speed up/slow down an efect so that the result has the given length
function adjust_length(effect, len)
    local effect_fun = effect.f
    local stretch_factor = len / effect.len
    return Effect(
        function(t) return effect_fun(t / stretch_factor) end,
        len
    )
end

-- Reverse an effect
function reverse(effect)
    local epsilon = 1e-9
    local effect_fun = effect.f
    local effect_len = effect.len
    return Effect(
        -- Substract a small epsilon to prevent out-of-bounds problems at t = 0
        -- (effects are undefined at t = effect.len)
        function(t) return effect_fun(effect_len - t - epsilon) end,
        effect.len
    )
end

---------------------
-- COLOR MODIFIERS
---------------------

-- MODIFIERS

local function value_modifier(effect, modifier, value)
    local effect_fun = effect.f
    local f
    if type(value) == "number" then
        f = function(t) return modifier(effect_fun(t), value) end
    elseif type(value) == "table" then --and value.type == EffectType.VALUE then
        local value_fun, value_len = value.f, value.len
        f = function(t) return modifier(effect_fun(t), value_fun(t % value_len)) end
    else error("Invalid value") end

    return Effect(f, effect.len)
end

function brightness_modifier(effect, value)
    return value_modifier(effect, color_metatable.fade, value)
end

-----------
-- CURVES
-----------

function const(v, len)
    return Effect(
        function (t) return v end,
        len,
        EffectType.VALUE
    )
end

function lerp(v1, v2, len)
    if len == nil then len = 1 end
    local offset = v1
    local slope = (v2 - v1) / len
    return Effect(
        function (t) return offset + slope * (t % len) end,
        len,
        EffectType.VALUE
    )
end

function sine(v1, v2, len)
    if len == nil then len = 1 end
    local t_mul = 2 * math.pi / len
    local t_offset = math.pi / 2
    local scale = (v2 - v1) / 2
    local offset = v1 + (v2 - v1) / 2

    return Effect(
        function(t) return offset + math.sin(t * t_mul - t_offset) * scale end,
        len,
        EffectType.VALUE
    )
end

function half_sine(v1, v2, len)
    if len == nil then len = 1 end
    local t_mul = math.pi / len
    local scale = (v2 - v1)
    local offset = v1

    return Effect(
        function(t) return offset + math.abs(math.sin(t * t_mul)) * scale end,
        len,
        EffectType.VALUE
    )
end

------------------------------
--- EFFECT OPERATORS
------------------------------

effect_metatable.__concat = concat
effect_metatable.__pow = rep
effect_metatable.__mul = stretch
effect_metatable.__div = function(effect, factor) return stretch(effect, 1 / factor) end
effect_metatable.__mod = adjust_length
effect_metatable.__bnot = reverse
effect_metatable.__len = function(effect) return effect.len end
effect_metatable.__call = function(effect, t) return effect.f(t) end

-------------------------------
--- EFFECT RUNNER
-------------------------------

local DEFAULT_PERIOD_MS = 1000 // 60

function run(effect, period_ms)
    assert(effect.type == EffectType.COLOR,
        "The given effect is invalid or does not generate a color"
    )

    if period_ms == nil then period_ms = DEFAULT_PERIOD_MS end

    local effect_fun, effect_len = effect.f, effect.len

    while true do
        local t = time() / 1000
        if t >= effect_len then break end

        local color_rgb = effect_fun(t):as_rgb()
        led.setColor(math.floor(color_rgb[1]), math.floor(color_rgb[2]), math.floor(color_rgb[3]))
        sleep(period_ms)
    end
end
