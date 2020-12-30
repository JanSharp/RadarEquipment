
---@class ScriptData
---@field owners OwnerData[]
---@field grid_lookup GridLookups

---@alias GridLookups table<string, GridLookup> @ LuaEquipmentGrid.prototype.name -> GridLookup
---@alias GridLookup table<LuaEquipmentGrid, OwnerData>

---@class OwnerData
---@field owner LuaEntity
---@field surface LuaSurface
---@field force LuaForce
---@field grid LuaEquipmentGrid
---@field radars LuaEntity[]
---@field prev_x number
---@field prev_y number
---@field base_chunk_range integer
---@field portable_radar_count integer|nil
---@field target_chunk_range integer|nil
---@field chunk_range integer|nil

---@class LuaEntity
---@class LuaEquipmentGrid
---@class LuaForce
---@class LuaSurface

---@class Position
---@field x number
---@field y number
