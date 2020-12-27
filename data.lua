
local empty_png = "__core__/graphics/empty.png"

local function create_radar(range)
  return {
    type = "radar",
    name = "RadarEquipment-radar",

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
    -- healing_per_tick = 0,
    -- max_health = 1,
    -- TODO: set resitances to everything? it can't really be hit though, can it
    -- it seems to die to the flamethrower right now and i'm not sure why exactly

    energy_per_nearby_scan = "1J",
    energy_per_sector = "1J",
    energy_source = {type = "void"},
    energy_usage = "1W",
    max_distance_of_nearby_sector_revealed = range,
    max_distance_of_sector_revealed = range,
    pictures = {
      direction_count = 1,
      filename = empty_png,
      size = 1,
    },
    radius_minimap_visualisation_color = {0, 0, 0, 0},
  }
end

data:extend{
  create_radar(0),
}
