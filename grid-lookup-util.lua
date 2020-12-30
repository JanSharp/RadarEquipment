
local script_data
local grid_lookup

---@param owner_data OwnerData
local function add_owner_data(owner_data)
  local grid = owner_data.grid
  local name = grid.prototype.name
  local lookup = grid_lookup[name]
  if not lookup then
    lookup = {}
    grid_lookup[name] = lookup
  end
  lookup[grid] = owner_data
end

---@param owner_data OwnerData
local function remove_owner_data(owner_data)
  local grid = owner_data.grid
  local name = grid.prototype.name
  local lookup = grid_lookup[name]
  lookup[grid] = nil
  if not next(lookup) then
    grid_lookup[name] = nil
  end
end

---@param grid LuaEquipmentGrid
---@return OwnerData|nil
local function get_owner_data(grid)
  local lookup = grid_lookup[grid.prototype.name]
  for other_grid, owner_data in next, lookup do
    if grid == other_grid then
      return owner_data
    end
  end
  return nil
end

local function setup()
  script_data = global.script_data
  grid_lookup = script_data.grid_lookup
end

return {
  setup = setup,
  add_owner_data = add_owner_data,
  remove_owner_data = remove_owner_data,
  get_owner_data = get_owner_data,
}
