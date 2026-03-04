---@meta

-- EdgeTX Lua runtime introspection functions
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Load and compile a Lua script from the SD card.
--- Returns the compiled chunk or nil + error message.
--- @since 2.2.0
---@param path? string Script file path
---@param mode? string Compilation mode
---@param env? table Custom environment table
---@return function|nil chunk
---@return string|nil errmsg
function loadScript(path, mode, env) end

--- Return Lua memory usage as a percentage (0-100).
---@return integer percent
function getUsage() end

--- Return available Lua memory in bytes.
---@return integer bytes
function getAvailableMemory() end
