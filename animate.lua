-- spinrotate/animate.lua

spinrotate = spinrotate or {}

spinrotate.ANIM_TIME = 0.5
spinrotate.ANIM_TIME_ADJUSTMENT = spinrotate.ANIM_TIME * .08

-----------------------------------------------------------------------
-- Map node textures to cube faces based on the node's facedir value.
-----------------------------------------------------------------------
local function map_node_tiles_to_cube(node_tiles, facedir)
    facedir = facedir or 0
    local rotation = facedir % 4  -- 0=S, 1=W, 2=N, 3=E

    local tiles = {}
    for i = 1, 6 do
        local t = node_tiles[i] or node_tiles[#node_tiles] or ""
        tiles[i] = (type(t) == "table") and t.name or t
    end

    local final_tiles = {
        tiles[1], -- top
        tiles[2], -- bottom
        tiles[3], -- right
        tiles[4], -- left
        tiles[5], -- back
        tiles[6], -- front
    }

    if rotation == 0 then
        -- Facing South: Default orientation, no changes needed
    elseif rotation == 1 then
        -- Facing West
        final_tiles[3] = tiles[5]
        final_tiles[4] = tiles[6]
        final_tiles[5] = tiles[4]
        final_tiles[6] = tiles[3]
        final_tiles[1] = final_tiles[1] .. "^[transformR270"
        final_tiles[2] = final_tiles[2] .. "^[transformR90"
    elseif rotation == 2 then
        -- Facing North
        final_tiles[3] = tiles[4]
        final_tiles[4] = tiles[3]
        final_tiles[5] = tiles[6]
        final_tiles[6] = tiles[5]
        final_tiles[1] = final_tiles[1] .. "^[transformR180"
        final_tiles[2] = final_tiles[2] .. "^[transformR180"
    elseif rotation == 3 then
        -- Facing East
        final_tiles[3] = tiles[6]
        final_tiles[4] = tiles[5]
        final_tiles[5] = tiles[3]
        final_tiles[6] = tiles[4]
        final_tiles[1] = final_tiles[1] .. "^[transformR90"
        final_tiles[2] = final_tiles[2] .. "^[transformR270"
    end

    return final_tiles
end

-----------------------------------------------------------------------
-- Spinning cube entity used to animate the rotation of a node.
-----------------------------------------------------------------------
minetest.register_entity("spinrotate:spin_entity", {
    initial_properties = {
        visual = "cube",
        textures = {
            "default_wood.png", "default_wood.png", "default_wood.png",
            "default_wood.png", "default_wood.png", "default_wood.png",
        },
        physical = true,
        collide_with_objects = true,
        pointable = false,
        static_save = false,
        is_visible = true,
        visual_size = {x = 1, y = 1, z = 1},
    },

    direction = 1,
    elapsed = 0,
    old_facedir = 0,
    new_facedir = 0,
    node_textures = nil,
    properties_set = false,

    on_activate = function(self)
        self.elapsed = 0
    end,

    on_step = function(self, dtime)
        self.elapsed = self.elapsed + dtime

        if not self.properties_set and self.node_textures then
            self.object:set_properties({textures = self.node_textures})
            self.properties_set = true
        end

        local anim_rot = (self.elapsed / spinrotate.ANIM_TIME) * (math.pi / 2) * self.direction
        self.object:set_rotation({x = 0, y = anim_rot, z = 0})

        if self.elapsed >= spinrotate.ANIM_TIME then
            self.object:remove()
        end
    end,
})

-----------------------------------------------------------------------
-- Global wrapper function to handle node switching and spawning
-----------------------------------------------------------------------
function spinrotate.rotate_node(pos, player, direction)
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]

    if not def or def.paramtype2 ~= "facedir" then return end

    local old_facedir = node.param2
    local new_facedir = node.param2

    if direction == "left" then
        new_facedir = (new_facedir + 1) % 4
    else
        new_facedir = (new_facedir + 3) % 4
    end

    local node_tiles = {}
    if def.tiles then
        for i = 1, 6 do
            local tile = def.tiles[i] or def.tiles[1] or "default_wood.png"
            if type(tile) == "string" then
                node_tiles[i] = tile
            else
                node_tiles[i] = tile.name or "default_wood.png"
            end
        end
    else
        node_tiles = {
            "default_wood.png", "default_wood.png", "default_wood.png",
            "default_wood.png", "default_wood.png", "default_wood.png"
        }
    end

    local textures = map_node_tiles_to_cube(node_tiles, old_facedir)

    minetest.set_node(pos, {name = "air"})

    local obj = minetest.add_entity(pos, "spinrotate:spin_entity")
    if obj then
        local lua = obj:get_luaentity()
        lua.direction = (direction == "left") and -1 or 1
        lua.old_facedir = old_facedir
        lua.new_facedir = new_facedir
        lua.node_textures = textures
    end

    minetest.after(spinrotate.ANIM_TIME - spinrotate.ANIM_TIME_ADJUSTMENT, function()
        minetest.set_node(pos, {name = node.name, param2 = new_facedir})
    end)
end
