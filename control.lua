
local equipment_util = require("equipment-util")

local events = defines.events

local script_data
local owners

-- local function add_player(player)
--   local owner_data = {
--     owner = player.character,
--   }
--   owners[player.index] = owner_data
-- end

-- local function remove_player(player)
--   local player_index = player.player_index
--   local owner_data = owners[player_index]
--   owners[player_index] = nil
--   -- TODO: cleanup radars
-- end

script.on_event(events.on_player_created, function(event)
  -- add_player(game.get_player(event.player_index))

  local player = game.get_player(event.player_index)
  local spidertron = player.surface.create_entity{
    name = "spidertron",
    position = {0, 0},
    force = player.force,
  }
  local grid = spidertron.grid
  grid.put{name = "RadarEquipment-portable-radar"}
  grid.put{name = "RadarEquipment-portable-radar"}
  grid.put{name = "RadarEquipment-portable-radar"}
  grid.put{name = "RadarEquipment-portable-radar"}
  grid.put{name = "RadarEquipment-portable-radar"}
  grid.put{name = "RadarEquipment-portable-radar"}
  player.cursor_stack.set_stack{name = "spidertron-remote"}
  player.cursor_stack.connected_entity = spidertron

  local owner_data = {
    owner = spidertron,
    surface = spidertron.surface,
    force = spidertron.force,
    prev_x = 0,
    prev_y = 0,
    radars = {},
    grid = grid,
    base_chunk_range = (3 * 2) - 1, -- for spidertrons a range of 1 actually is just one chunk while for radars that is a 3 by 3
  }
  owners[#owners+1] = owner_data

  equipment_util.check_equipment(owner_data)
end)

script.on_event(events.on_tick, function(event)
  for _, owner_data in next, owners do
    equipment_util.check_equipment(owner_data)
  end
end)

script.on_init(function()
  owners = {}
  script_data = {
    players = owners,
  }
  global.script_data = script_data

  -- for _, player in pairs(game.players) do
  --   add_player(player)
  -- end
end)

script.on_load(function()
  script_data = global.script_data
  owners = script_data.players
end)
