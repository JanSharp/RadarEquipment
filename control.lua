
local equipment_util = require("equipment-util")
local grid_lookup_util = require("grid-lookup-util")

local events = defines.events
local script = script
local on_event = script.on_event

---@type ScriptData
local script_data
local owners
local grid_lookup

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

on_event(events.on_player_created, function(event)
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

  local owner_data = equipment_util.create_owner_data(spidertron)

  local breakpoint

  -- ---@type OwnerData
  -- local owner_data = {
  --   owner = spidertron,
  --   surface = spidertron.surface,
  --   force = spidertron.force,
  --   prev_x = 0,
  --   prev_y = 0,
  --   radars = {},
  --   grid = grid,
  --   base_chunk_range = (3 * 2) - 1, -- for spidertrons a range of 1 actually is just one chunk while for radars that is a 3 by 3
  -- }
  owners[#owners+1] = owner_data

  -- grid_lookup_util.add_owner_data(owner_data)
  -- equipment_util.check_equipment(owner_data)
end)

on_event(events.on_tick, function(event)
  for _, owner_data in next, owners do
    -- equipment_util.check_equipment(owner_data)
    local aprc = equipment_util.get_active_portable_radar_count(owner_data)
    if aprc ~= owner_data.active_portable_radar_count then
      owner_data.active_portable_radar_count = aprc
    end
  end
end)

on_event(events.on_player_placed_equipment, function(event)
  if event.equipment.name == "RadarEquipment-portable-radar" then
    equipment_util.on_equipment_grid_updated(event.grid)
  end
end)

on_event(events.on_player_removed_equipment, function(event)
  if event.equipment.name == "RadarEquipment-portable-radar" then
    equipment_util.on_equipment_grid_updated(event.grid)
  end
end)

local function setup_other_files()
  grid_lookup_util.setup()
end

script.on_init(function()
  owners = {}
  script_data = {
    owners = owners,
    ---@type GridLookups
    grid_lookup = {},
  }
  global.script_data = script_data

  -- for _, player in pairs(game.players) do
  --   add_player(player)
  -- end
  setup_other_files()
end)

script.on_load(function()
  script_data = global.script_data
  owners = script_data.owners

  setup_other_files()
end)
