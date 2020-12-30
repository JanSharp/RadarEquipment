
local grid_lookup_util = require("grid-lookup-util")

local range_util = require("range-util")
local range_lookup = range_util.range_lookup

local x_index_sign_lookup = {-1, 1, -1, 1}
local y_index_sign_lookup = {-1, -1, 1, 1}

local script_data

---@param owner_data OwnerData
---@return integer @ the amount of tiles the radars need to be away from the owner
--- for the corrent target_chunk_range
local function get_distance_to_owner(owner_data)
  local chunk_range = owner_data.chunk_range
  local target_chunk_range = owner_data.target_chunk_range
  local chunk_dist = (target_chunk_range - chunk_range) / 2
  return chunk_dist * 32
end

local create_radar
do
  -- TODO: optimize to cache tables for every chunk_range
  ---@type Position
  local position = {}
  local create_radar_data = {
    create_build_effect_smoke = false,
    position = position,
  }
  ---@param owner_data OwnerData
  ---@param index integer @index in radars array
  ---@return LuaEntity @ the created radar entity
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

---@param owner_data OwnerData
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

---@param owner_data OwnerData
---@param portable_radar_count integer
---@return boolean @ did it udpate radar positions?
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

---@param owner_data OwnerData
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

---@param grid LuaEquipmentGrid
local function on_equipment_grid_updated(grid)
  local owner_data = grid_lookup_util.get_owner_data(grid)
  if owner_data then
    check_equipment(owner_data)
  else
    error("--TODO: create new owner data after a grid got chagned and no existing data was found")
  end
end


--[[

sudo code:

function create_owner_data()
end

function delete_owner_data()
end


function get_target_chunk_range()
  calculate target_chunk_range
  return result
end

function get_radar_range()
  calculate new radar_range
  return result
end

function get_active_portable_radar_count()
  set result to 0
  for portable_radar in all equipments do
    if valid then
      if it has enough power then
        increment active count
      end
    else
      remove_portable_radar()
    end
  end
  return result
end


function create_radars()
  create all radars needed to cover the target_chunk_range
  at the correct offsets to the owner
  set them all to destructible = false
end

function create_radar()
  very much a duplicate of create_radars()
  and since it is so similar, it is going to do the same thing,
  but actually take a "scope" parameter,
  which when nil will be supplied with all the reused data needed
  for creating radars
end

function delete_radars()
  delete all radars
end

function add_portable_radar()
  add the given portalbe radar from owner_data
end

function remove_portable_radar()
  remove the given portalbe radar from owner_data
end


function update_radar_offsets()
  teleports existing radars to the correct offset
  to properly cover target_chunk_range
end

function update_radars()
  calculate the distance the owner moved
  using prev_x and prev_y
  if it is 0 then return end

  update prev_x and prev_y
  for radar in all radars do
    if valid then
      radar.teleport()
    else
      create_radar()
    end
  end
end

function update_target_chunk_range()
  get_target_chunk_range()
  if it is the same then return end

  get_radar_range()
  if it is different then
    set it on owner_data
    delete_radars()
    create_radars()
  end
  update_radar_offsets()
end

function update_active_portable_radar_count()
  get_active_portable_radar_count()
  if it is the same then return end

  set it on owner_data
  update_target_chunk_range()
end



-- only needed if i want to supoort someone adding equipments to the grid
-- with a script. but it most likely wouldn't actually help anyway, because
-- it would have to find the grid in the first place
-- which would most likely require keeping track of every grid in existance
-- and that's dumb
-- actually nvm, it's needed when creating the owner_data... right?
-- no. create would not want other update functions to be called.
-- a create function should never call update functions
function update_portable_radar_count()
  get all equipments from the grid
  find all portable radar ones
  overwrite the existing list with the new one
  if the new count is different then
    update_active_portable_rdarar_count()
  end
end

]]


return {
  on_equipment_grid_updated = on_equipment_grid_updated,
  check_equipment = check_equipment,
}
