---@meta

-- EdgeTX widget shared memory and option type constants
-- Source: edgetx/radio/src/lua/api_general.cpp

-- ==========================================================================
-- Shared memory (color LCD only)
-- ==========================================================================

--- Set a shared memory variable (for inter-widget communication). Color LCD only.
---@param index integer Variable index
---@param value integer
function setShmVar(index, value) end

--- Get a shared memory variable value. Color LCD only.
---@param index integer Variable index
---@return integer|nil value nil if index is invalid
function getShmVar(index) end

-- ==========================================================================
-- Widget option type constants
-- ==========================================================================

---@type integer
COLOR = 0
---@type integer
BOOL = 0
---@type integer
STRING = 0
---@type integer
TIMER = 0
---@type integer
TEXT_SIZE = 0
---@type integer
ALIGNMENT = 0
---@type integer
SWITCH = 0
---@type integer
SLIDER = 0
---@type integer
CHOICE = 0
---@type integer
FILE = 0
