-- PARAMETERS

local colors = {
    Color.lime,
    Color.orange,
    Color.cyan
}
local period = 1  -- duration of each color

--------------

local function fade_in_out(color, len)
    local fade_len = len * 0.2
    local fade_in = lerp(0, 1, fade_len)
    local fade_out = ~fade_in
    local curve = fade_in .. const(1, len - #fade_in - #fade_out) .. fade_out
    return brightness_modifier(fixed_color(color, len), curve)
end

local fades = {}
for i, color in ipairs(colors) do
	fades[i] = fade_in_out(color, period)
end

run(loop(seq(fades)))
