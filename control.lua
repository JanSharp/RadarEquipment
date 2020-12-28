
local equipment_util = require("equipment-util")

local events = defines.events

local script_data
local owners

local function add_player(player)
  local owner_data = {
    owner = player.character,
  }
  owners[player.index] = owner_data
end

local function remove_player(player)
  local player_index = player.player_index
  local owner_data = owners[player_index]
  owners[player_index] = nil
  -- TODO: cleanup radars
end

script.on_event(events.on_player_created, function(event)
  add_player(game.get_player(event.player_index))
end)

script.on_init(function()
  owners = {}
  script_data = {
    players = owners,
  }
  global.script_data = script_data

  for _, player in pairs(game.players) do
    add_player(player)
  end
end)

script.on_load(function()
  script_data = global.script_data
  owners = script_data.players
end)
