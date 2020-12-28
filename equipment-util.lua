
local range_util = require("range-util")
local range_lookup = range_util.range_lookup

local x_index_sign_lookup = {-1, 1, -1, 1}
local y_index_sign_lookup = {-1, -1, 1, 1}

local function get_distance_to_owner(owner_data)
  local chunk_range = owner_data.chunk_range
  local target_chunk_range = owner_data.target_chunk_range
  local chunk_dist = (target_chunk_range - chunk_range) / 2
  return chunk_dist * 32
end

local create_radar
do
  -- TODO: optimize to cache tables for every chunk_range
  local position = {}
  local create_radar_data = {
    create_build_effect_smoke = false,
    position = position,
  }
  function create_radar(owner_data, index)
    local owner_position = owner_data.owner.position
    create_radar_data.name = "RadarEquipment-radar-"..owner_data.chunk_range
    create_radar_data.force = owner_data.force
    local distance = get_distance_to_owner(owner_data)
    position.x = owner_position.x + distance * x_index_sign_lookup[index]
    position.y = owner_position.y + distance * y_index_sign_lookup[index]
    local entity = owner_data.surface.create_entity(create_radar_data)
    if not entity then
      error("--TODO: scream! the radar couldn't get created.")
    end
    return entity
  end
end

local function teleport_radars(owner_data)
  local owner = owner_data.owner
  local owner_position = owner.position

  local pos_x = owner_position.x
  local pos_y = owner_position.y
  local prev_x = owner_data.prev_x
  local prev_y = owner_data.prev_y

  if pos_x == prev_x and pos_y == prev_y then
    return
  end

  local diff_x = pos_x - prev_x
  local diff_y = pos_y - prev_y
  owner_data.prev_x = pos_x
  owner_data.prev_y = pos_y

  local radars = owner_data.radars
  for index, radar in next, radars do
    if radar.valid then
      radar.teleport(diff_x, diff_y)
    else
      radars[index] = create_radar(owner_data, index)
    end
  end
end

local function update_portable_radar_count(owner_data, portable_radar_count)
  if owner_data.portable_radar_count ~= portable_radar_count then
    if portable_radar_count == nil then
      -- TODO: cleanup and remove the owner data
      return
    end

    owner_data.portable_radar_count = portable_radar_count
    local target_chunk_range = owner_data.base_chunk_range + portable_radar_count * 2
    owner_data.target_chunk_range = target_chunk_range
    local chunk_range = range_lookup[target_chunk_range]
    if not chunk_range then
      chunk_range = range_util.highest_chunk_range
      error("--TODO: not implemented. huge target_chunk_range that needs more than 4 radars.")
    else
      if owner_data.chunk_range ~= chunk_range then
        owner_data.chunk_range = chunk_range

        -- delete existing radars
        local radars = owner_data.radars
        if radars then
          local key, radar = next(radars)
          while key do
            local next_key, next_radar = next(radars, key)
            radars[key] = nil
            if radar.valid then
              radar.destroy()
            end
            key, radar = next_key, next_radar
          end
        end

        -- create new radars
        for i = 1, 4 do
          radars[i] = create_radar(owner_data, i)
        end
      else
        -- TODO: change position of all radars. best would be with absolute teleports
        teleport_radars(owner_data)
      end
    end

    return true
  else
    return false
  end
end

local function check_equipment(owner_data)
  local owner = owner_data.owner
  if not owner.valid then
    -- TODO: cleanup and remove the owner data
    return
  end
  local grid = owner_data.grid
  if not grid.valid then
    grid = owner.grid
    if not grid then
      -- TODO: cleanup and remove the owner data
      return
    end
  end

  local contents = grid.get_contents()
  local portable_radar_count = contents["RadarEquipment-portable-radar"]
  if not update_portable_radar_count(owner_data, portable_radar_count) then
    teleport_radars(owner_data)
  end
end

return {
  check_equipment = check_equipment,
}
