
local range_util = require("range-util")
local range_lookup = range_util.range_lookup

local function create_radar()
  -- TODO: impl
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

  local diff_x = prev_x - pos_x
  local diff_y = prev_y - pos_y
  owner_data.prev_x = pos_x
  owner_data.prev_y = pos_y

  local radars = owner_data.radars
  for key, radar in next, radars do
    if radar.valid then
      radar.teleport(diff_x, diff_y)
    else
      radars[key] = create_radar()
    end
  end
end

local function update_portable_radar_count(owner_data, portable_radar_count)
  if owner_data.portable_radar_count ~= portable_radar_count then
    if portable_radar_count == 0 then
      -- TODO: cleanup and remove the owner data
      return
    end

    owner_data.portable_radar_count = portable_radar_count
    local target_chunk_range = owner_data.base_radar_range + portable_radar_count
    local radar_range = range_lookup[target_chunk_range]
    if not radar_range then
      radar_range = range_util.highest_radar_range
      error("--TODO: not implemented. huge target_chunk_range that needs more than 4 radars")
    else
      if owner_data.radar_range ~= radar_range then
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

        -- TODO: create new radars
      else
        -- TODO: change position of all radars. best would be with absolute teleports
        teleport_radars(owner_data)
      end
    end
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
  update_portable_radar_count(owner_data, portable_radar_count)
end

return {
  check_equipment = check_equipment,
}
