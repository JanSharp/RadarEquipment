
local math_huge = math.huge
local int32_max_value = (2 ^ 31) - 1
local empty_png = "__core__/graphics/empty.png"

local scale = 1
local leg_scale = 1

data:extend{
  {
    type = "spider-leg",
    name = "RadarEquipment-spidertron-leg",

    icon = empty_png,
    icon_size = 1,
    collision_box = {{0, 0}, {0, 0}},
    collision_mask = {},
    selectable_in_game = false,

    create_ghost_on_death = false,
    healing_per_tick = math_huge,
    max_health = int32_max_value,
    -- TODO: set resitances to everything? it can't really be hit though, can it

    graphics_set = {},
    initial_movement_speed = math_huge,
    movement_acceleration = math_huge,
    movement_based_position_selection_distance = 256,
    part_length = 512,

    target_position_randomisation_distance = 0, -- not on the wiki?
    minimal_step_size = math_huge, -- not on the wiki?
  },
  {
    type = "equipment-category",
    name = "RadarEquipment-armor",
  },
  {
    type = "movement-bonus-equipment",
    name = "RadarEquipment-infinite-speed",

    categories = {"RadarEquipment-armor", "armor"},
    energy_source = {
      type = "void",
      usage_priority = "secondary-input",
    },
    shape = {
      type = "full",
      width = 1,
      height = 1,
    },
    sprite = {
      filename = empty_png,
      size = 1,
    },

    energy_consumption = "1W",
    movement_bonus = 1000,
  },
  {
    type = "item",
    name = "RadarEquipment-infinite-speed",

    icon = empty_png,
    icon_size = 1,
    stack_size = 1,
    flags = {
      "hidden",
      "not-stackable",
    },
    placed_as_equipment_result = "RadarEquipment-infinite-speed",
  },
  {
    type = "equipment-grid",
    name = "RadarEquipment-spidertron-equipment-grid",

    equipment_categories = {"RadarEquipment-armor", "armor"},
    height = 4,
    width = 5,
    -- locked = true, -- TODO: enable this if once i do everything by script
  },
  {
    type = "spider-vehicle",
    name = "RadarEquipment-spidertron",
    collision_box = {{-1 * scale, -1 * scale}, {1 * scale, 1 * scale}},
    sticker_box = {{-1.5 * scale, -1.5 * scale}, {1.5 * scale, 1.5 * scale}},
    selection_box = {{-1 * scale, -1 * scale}, {1 * scale, 1 * scale}},
    drawing_box = {{-3 * scale, -4 * scale}, {3 * scale, 2 * scale}},
    icon = "__base__/graphics/icons/spidertron.png",
    mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8},
    open_sound = { filename = "__base__/sound/spidertron/spidertron-door-open.ogg", volume= 0.35 },
    close_sound = { filename = "__base__/sound/spidertron/spidertron-door-close.ogg", volume = 0.4 },
    sound_minimum_speed = 0.1,
    sound_scaling_ratio = 0.6,
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/spidertron/spidertron-vox.ogg",
        volume = 0.35
      },
      activate_sound =
      {
        filename = "__base__/sound/spidertron/spidertron-activate.ogg",
        volume = 0.5
      },
      deactivate_sound =
      {
        filename = "__base__/sound/spidertron/spidertron-deactivate.ogg",
        volume = 0.5
      },
      match_speed_to_activity = true
    },
    icon_size = 64, icon_mipmaps = 4,
    weight = 10 ^ 18, -- 10 ^ -18,
    braking_force = math_huge,
    friction_force = 10 ^ 18, -- 10 ^ -18,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    collision_mask = {},
    minable = {mining_time = 1, result = "spidertron"},
    max_health = 3000,
    resistances =
    {
      {
        type = "fire",
        decrease = 15,
        percent = 60
      },
      {
        type = "physical",
        decrease = 15,
        percent = 60
      },
      {
        type = "impact",
        decrease = 50,
        percent = 80
      },
      {
        type = "explosion",
        decrease = 20,
        percent = 75
      },
      {
        type = "acid",
        decrease = 0,
        percent = 70
      },
      {
        type = "laser",
        decrease = 0,
        percent = 70
      },
      {
        type = "electric",
        decrease = 0,
        percent = 70
      }
    },
    minimap_representation =
    {
      filename = "__base__/graphics/entity/spidertron/spidertron-map.png",
      flags = {"icon"},
      size = {128, 128},
      scale = 0.5
    },
    corpse = "spidertron-remnants",
    dying_explosion = "spidertron-explosion",
    energy_per_hit_point = 1,
    guns = { "spidertron-rocket-launcher-1", "spidertron-rocket-launcher-2", "spidertron-rocket-launcher-3", "spidertron-rocket-launcher-4" },
    inventory_size = 80,
    equipment_grid = "RadarEquipment-spidertron-equipment-grid",
    trash_inventory_size = 20,
    height = 1.5  * scale * leg_scale,
    torso_rotation_speed = math_huge,
    chunk_exploration_radius = 3,
    selection_priority = 51,
    graphics_set = spidertron_torso_graphics_set(scale),
    energy_source =
    {
      type = "void"
    },
    movement_energy_consumption = "250kW",
    automatic_weapon_cycling = true,
    chain_shooting_cooldown_modifier = 0.5,
    spider_engine =
    {
      legs =
      {
        { -- 1
          leg = "RadarEquipment-spidertron-leg",
          mount_position = {0, 0},
          ground_position = {0, 0},
          blocking_legs = {},
        },
        -- { -- 2
        --   leg = arguments.name .. "-leg-2",
        --   mount_position = util.by_pixel(23  * scale, -10  * scale),--{0.75, -0.25},
        --   ground_position = {3  * leg_scale, -1  * leg_scale},
        --   blocking_legs = {1, 3},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 3
        --   leg = arguments.name .. "-leg-3",
        --   mount_position = util.by_pixel(25  * scale, 4  * scale),--{0.75, 0.25},
        --   ground_position = {3  * leg_scale, 1  * leg_scale},
        --   blocking_legs = {2, 4},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 4
        --   leg = arguments.name .. "-leg-4",
        --   mount_position = util.by_pixel(15  * scale, 17  * scale),--{0.5, 0.75},
        --   ground_position = {2.25  * leg_scale, 2.5  * leg_scale},
        --   blocking_legs = {3},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 5
        --   leg = arguments.name .. "-leg-5",
        --   mount_position = util.by_pixel(-15 * scale, -22 * scale),--{-0.5, -0.75},
        --   ground_position = {-2.25 * leg_scale, -2.5 * leg_scale},
        --   blocking_legs = {6, 1},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 6
        --   leg = arguments.name .. "-leg-6",
        --   mount_position = util.by_pixel(-23 * scale, -10 * scale),--{-0.75, -0.25},
        --   ground_position = {-3 * leg_scale, -1 * leg_scale},
        --   blocking_legs = {5, 7},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 7
        --   leg = arguments.name .. "-leg-7",
        --   mount_position = util.by_pixel(-25 * scale, 4 * scale),--{-0.75, 0.25},
        --   ground_position = {-3 * leg_scale, 1 * leg_scale},
        --   blocking_legs = {6, 8},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- },
        -- { -- 8
        --   leg = arguments.name .. "-leg-8",
        --   mount_position = util.by_pixel(-15 * scale, 17 * scale),--{-0.5, 0.75},
        --   ground_position = {-2.25 * leg_scale, 2.5 * leg_scale},
        --   blocking_legs = {7},
        --   leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        -- }
      },
      military_target = "spidertron-military-target", -- TODO: fix this
    }
  },
}
