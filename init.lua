-- spinrotate/init.lua

local modpath = minetest.get_modpath("spinrotate")

-- Initialize global namespace
spinrotate = {}

-- 1. Load the animation backend first so the tools can use it
dofile(modpath .. "/animate.lua")

-- 2. Load the tools configuration
dofile(modpath .. "/tools.lua")
