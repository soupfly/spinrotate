-- spinrotate/tools.lua

-----------------------------------------------------------------------
-- Tools that trigger rotation when used on a node
-----------------------------------------------------------------------

minetest.register_tool("spinrotate:rotate_left", {
    description = "Rotate Left Tool",
    inventory_image = "default_tool_woodpick.png",
    on_use = function(itemstack, user, pointed)
        if pointed.type == "node" then
            spinrotate.rotate_node(pointed.under, user, "left")
        end
        return itemstack
    end,
})

minetest.register_tool("spinrotate:rotate_right", {
    description = "Rotate Right Tool",
    inventory_image = "default_tool_stonepick.png",
    on_use = function(itemstack, user, pointed)
        if pointed.type == "node" then
            spinrotate.rotate_node(pointed.under, user, "right")
        end
        return itemstack
    end,
})
