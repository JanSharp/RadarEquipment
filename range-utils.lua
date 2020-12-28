
local radar_count = 7

local ranges = {}
local range_lookup = {}
local highest_radar_range
local highest_chunk_range

do
  local radar_range = 0
  local chunk_range = 2
  for i = 1, radar_count do
    local current_chunk_range = chunk_range - 1
    chunk_range = chunk_range * 2

    ranges[radar_range] = current_chunk_range
    radar_range = current_chunk_range

    for i_chunk_range = current_chunk_range, chunk_range - 2 do
      range_lookup[i_chunk_range] = radar_range
    end
  end
  highest_radar_range = radar_range / 2 + 1
  highest_chunk_range = chunk_range / 2 - 1
end

return {
  ranges = ranges,
  range_lookup = range_lookup,
  highest_radar_range = highest_radar_range,
  highest_chunk_range = highest_chunk_range,
}
