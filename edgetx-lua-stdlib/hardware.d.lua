---@meta

-- EdgeTX LED and IMU hardware functions
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Set the color of an RGB LED in the strip.
---@param index integer LED index (0-based)
---@param red integer 0-255
---@param green integer 0-255
---@param blue integer 0-255
---@return boolean success
function setRGBLedColor(index, red, green, blue) end

--- Apply all pending RGB LED color changes.
function applyRGBLedColors() end

--- Set or cancel a CFS (Customizable Function Switch) LED color override.
--- Call with only the name to cancel the override.
---@param name string Switch name
---@param red? integer 0-255 (omit all color args to cancel override)
---@param green? integer 0-255
---@param blue? integer 0-255
---@return boolean success
function setCFSLedColor(name, red, green, blue) end

--- Set the IMU X-axis calibration parameters.
---@param offset integer Degrees (-180 to 180)
---@param range integer Degrees (0 to 180)
---@return boolean success
function setIMU_X(offset, range) end

--- Set the IMU Y-axis calibration parameters.
---@param offset integer Degrees (-180 to 180)
---@param range integer Degrees (0 to 180)
---@return boolean success
function setIMU_Y(offset, range) end

-- ==========================================================================
-- Hardware constants
-- ==========================================================================

---@type integer
LED_STRIP_LENGTH = 0
