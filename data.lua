
local ranges = require("range-util").ranges

local data = data
local next = next

local empty_png = "__core__/graphics/empty.png"

local function create_radar(radar_range, name_postfix)
  return {
    type = "radar",
    name = "RadarEquipment-radar-"..name_postfix,

    icon = empty_png,
    icon_size = 1,
    collision_box = {{0, 0}, {0, 0}},
    collision_mask = {},
    flags = {
      "not-rotatable",
      "placeable-off-grid",
      "not-repairable",
      "not-on-map",
      "not-blueprintable",
      "not-deconstructable",
      "hidden",
      "not-flammable",
      "no-copy-paste",
      "not-selectable-in-game",
      "not-upgradable",
      "not-in-kill-statistics",
    },
    selectable_in_game = false,

    create_ghost_on_death = false,

    energy_per_nearby_scan = "1J",
    energy_per_sector = "1J",
    energy_source = {type = "void"},
    energy_usage = "1W",
    max_distance_of_nearby_sector_revealed = radar_range,
    max_distance_of_sector_revealed = radar_range,
    pictures = {
      direction_count = 1,
      filename = empty_png,
      size = 1,
    },
    radius_minimap_visualisation_color = {0, 0, 0, 0},
  }
end

local radar_count = 0
local radars = {}
for radar_range, chunk_range in next, ranges do
  radar_count = radar_count + 1
  radars[radar_count] = create_radar(radar_range, tostring(chunk_range))
end
data:extend(radars)

data:extend{
  {
    type = "item",
    name = "RadarEquipment-portable-radar",

    icon = empty_png,
    icon_size = 1,
    stack_size = 20,
    placed_as_equipment_result = "RadarEquipment-portable-radar",
  },
  {
    type = "energy-shield-equipment",
    name = "RadarEquipment-portable-radar",

    categories = {"armor"},
    energy_source = {
      type = "electric",
      buffer_capacity = "400kJ",
      input_flow_limit = "80kW",
      drain = "40kW",
      usage_priority = "secondary-input",
    },
    shape = {
      type = "full",
      width = 2,
      height = 2,
    },
    sprite = {
      filename = empty_png,
      size = 1,
    },

    energy_per_shield = "40kJ",
    max_shield_value = 0,
  },
}
