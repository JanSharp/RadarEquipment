
local grid_lookup_util = require("grid-lookup-util")

local range_util = require("range-util")
local range_lookup = range_util.range_lookup

local x_index_sign_lookup = {-1, 1, -1, 1}
local y_index_sign_lookup = {-1, -1, 1, 1}


---@param owner_data OwnerData
---@return integer @ target_chunk_range
local function get_target_chunk_range(owner_data)
  return owner_data.base_chunk_range + owner_data.active_portable_radar_count * 2
end

---@param owner_data OwnerData
---@return integer @ chunk_range
local function get_chunk_range(owner_data)
  local chunk_range = range_lookup[owner_data.target_chunk_range]
  if not chunk_range then
    chunk_range = range_util.highest_chunk_range
    error("--TODO: not implemented. huge target_chunk_range that needs more than 4 radars.")
  else
  end
  return chunk_range
end

---@param owner_data OwnerData
---@return table<LuaEquipment, true> @ portable_radars
---@return integer @ portable_radar_count
local function get_portable_radars(owner_data)
  local portable_radar_count = 0
  local portable_radars = {}
  for _, equipment in next, owner_data.grid.equipment do
    if equipment.name == "RadarEquipment-portable-radar" then
      portable_radar_count = portable_radar_count + 1
      portable_radars[equipment] = true
    end
  end
  return portable_radars, portable_radar_count
end

--- updates portable_radar_count as well
---@param owner_data OwnerData
---@param portable_radar LuaEquipment
local function add_portable_radar(owner_data, portable_radar)
  owner_data.portable_radar_count = owner_data.portable_radar_count + 1
  owner_data.portable_radars[portable_radar] = true
end

--- updates portable_radar_count as well
---@param owner_data OwnerData
---@param portable_radar LuaEquipment
local function remove_portable_radar(owner_data, portable_radar)
  -- remove the given portalbe radar from owner_data
  owner_data.portable_radar_count = owner_data.portable_radar_count - 1
  local portable_radars = owner_data.portable_radars
  if portable_radars[portable_radar] then
    portable_radars[portable_radar] = nil
  elseif portable_radar.valid then
    for other_portable_radar in next, portable_radars do
      if portable_radar == other_portable_radar then
        portable_radars[portable_radar] = nil
        break
      end
    end
  else
    -- this could instead simply discard of the entire list and recreate it from all equipments
    -- maybe do that but with a warn? no it should simply not be allowed, preiod
    error("Unable to remove unknown invalid portable_radar equipment from owner_data.")
  end
end

---@param owner_data OwnerData
---@return integer @ active_portable_radar_count
local function get_active_portable_radar_count(owner_data)
  local active_portable_radar_count = 0
  for portable_radar in next, owner_data.portable_radars do
    if portable_radar.valid then
      if portable_radar.energy > 1000 then
        active_portable_radar_count = active_portable_radar_count + 1
      end
    else
      remove_portable_radar(owner_data, portable_radar)
    end
  end
  return active_portable_radar_count
end

---@param owner LuaEntity
---@return OwnerData
local function create_owner_data(owner)
  ---@type Position
  local owner_position = owner.position
  ---@type OwnerData
  local owner_data = {
    owner = owner,
    surface = owner.surface,
    force = owner.force,
    grid = owner.grid,
    portable_radars = "nil",
    portable_radar_count = "nil",
    active_portable_radar_count = "nil",
    radars = {},
    prev_x = owner_position.x,
    prev_y = owner_position.y,
    base_chunk_range = 5, -- TODO: properly evaluate base_chunk_range
    target_chunk_range = "nil",
    chunk_range = "nil",
  }
  owner_data.portable_radars, owner_data.portable_radar_count = get_portable_radars(owner_data)
  owner_data.active_portable_radar_count = get_active_portable_radar_count(owner_data)
  owner_data.target_chunk_range = get_target_chunk_range(owner_data)
  owner_data.chunk_range = get_chunk_range(owner_data)
  -- create_radars(owner_data)
  return owner_data
end

---@param owner_data OwnerData
local function delete_owner_data(owner_data)
  -- delete_radars(owner_data)
end


return {
  create_owner_data = create_owner_data,
  delete_owner_data = delete_owner_data,
  -- on_equipment_grid_updated = on_equipment_grid_updated,
  -- check_equipment = check_equipment,

  get_active_portable_radar_count = get_active_portable_radar_count,
}

--[[

sudo code:

function create_owner_data()
  store get_portable_radars()
  store get_active_portable_radar_count()
  store get_target_chunk_range()
  store get_chunk_range()
  create_radars()
end

function delete_owner_data()
  delete_radars()
end


function get_target_chunk_range()
  calculate target_chunk_range
  return result
end

function get_chunk_range()
  calculate new chunk_range
  return result
end

function get_portable_radars()
  get all equipments from the grid
  return all portable radar ones
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

  get_chunk_range()
  if it is different then
    set it on owner_data
    delete_radars()
    create_radars()
  else
    update_radar_offsets()
  end
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
  get_portable_radars()
  overwrite the existing list with the new one
  update_active_portable_radar_count()
end

]]
