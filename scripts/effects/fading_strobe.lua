-- PARAMETERS

local flash_color = Color.white
local flash_period = 1/6
local fade_period = 3

--------------

local flash = (fixed_color(flash_color, 0.5) .. fixed_color(Color.none, 0.5)) % flash_period
run(brightness_modifier(loop(flash), sine(0.1, 1, fade_period)))
