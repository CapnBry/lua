---@meta

-- EdgeTX global functions and constants
-- Source: edgetx/radio/src/lua/api_general.cpp

-- ==========================================================================
-- System information
-- ==========================================================================

--- Return EdgeTX version information.
--- @since 2.0.0
---@return string version Full version string (e.g. "2.11.0")
---@return string radio Radio type string (e.g. "tx16s-2.11.0")
---@return integer major Major version number
---@return integer minor Minor version number
---@return integer revision Revision number
---@return string osname OS name (e.g. "EdgeTX")
function getVersion() end

--- Return general radio settings.
--- @since 2.0.0
---@return {battWarn: number, battMin: number, battMax: number, imperial: integer, language: string, voice: string, gtimer: integer} settings
function getGeneralSettings() end

--- Return radio global timer data.
--- @since 2.3.0
---@return {total: integer, session: integer, throttle: integer, throttlepct: integer}
function getGlobalTimer() end

--- Reset one or all radio global timers.
--- @since 2.3.0
---@param which? string "total"|"session"|"throttle"|"throttlepct" (default "total")
function resetGlobalTimer(which) end

--- Return rotary encoder speed.
---@return integer speed ROTENC_LOWSPEED, ROTENC_MIDSPEED, or ROTENC_HIGHSPEED
function getRotEncSpeed() end

--- Return rotary encoder mode.
---@return integer mode
function getRotEncMode() end

--- Return the current stick mode (1-4).
---@return integer mode
function getStickMode() end

-- ==========================================================================
-- Source and value functions
-- ==========================================================================

--- Return the current value of a source. GPS and cells return tables.
--- @since 2.0.0
---@param source integer|string Source index or name
---@return integer|number|string|table|nil value
function getValue(source) end

--- Return the current output value for a channel (after all processing).
---@param index integer Channel index (0-based)
---@return integer value
function getOutputValue(index) end

--- Return the value of a source with freshness information.
---@param source integer|string Source index or name
---@return integer|number|string|table|nil value
---@return boolean isCurrent True if telemetry stream is currently active
---@return boolean isFresh True if data has been recently updated
function getSourceValue(source) end

--- Return information about a field/source. Returns nil if source not found.
--- For telemetry sources, the `unit` field is also included.
--- @since 2.0.8
---@param source integer|string Source index or name
---@return {id: integer, name: string, desc: string, unit?: integer}|nil info
function getFieldInfo(source) end

--- Return information about a source. Same as getFieldInfo().
---@param source integer|string Source index or name
---@return {id: integer, name: string, desc: string, unit?: integer}|nil info
function getSourceInfo(source) end

--- Get the source index for a named source.
---@param name string Source name
---@return integer|nil index
function getSourceIndex(name) end

--- Get the display name for a source index.
---@param index integer Source index
---@return string|nil name
function getSourceName(index) end

--- Return an iterator over sources. Optional first/last to limit range.
---@param first? integer Starting source index
---@param last? integer Ending source index
---@return function iterator
function sources(first, last) end

-- ==========================================================================
-- Switch functions
-- ==========================================================================

--- Set a function switch (sticky switch) state.
---@param index integer Switch index
---@param value boolean
---@return boolean bufferFull True if the command buffer is full
function setStickySwitch(index, value) end

--- Get the value of a logical switch.
---@param index integer Logical switch index (0-based)
---@return boolean|nil value nil if index is invalid
function getLogicalSwitchValue(index) end

--- Get information about a physical switch position.
--- @since 2.6.0
---@param index integer Switch source index (MIXSRC_FIRST_SWITCH-based)
---@return {type: integer, isCustomisableSwitch: boolean, name: string}|nil info
function getSwitchInfo(index) end

--- Get the switch index for a named switch position.
--- @since 2.6.0
---@param name string Switch position name (as shown in radio menus)
---@return integer|nil index
function getSwitchIndex(name) end

--- Get the display name for a switch index.
--- @since 2.6.0
---@param index integer Switch index
---@return string|nil name
function getSwitchName(index) end

--- Get the current value of a switch.
---@param index integer Switch index
---@return boolean|nil value nil if index is invalid
function getSwitchValue(index) end

--- Return an iterator over switch positions. Optional first/last to limit range.
---@param first? integer Starting switch index
---@param last? integer Ending switch index
---@return function iterator
function switches(first, last) end

-- ==========================================================================
-- Stick and channel functions
-- ==========================================================================

--- Return the default stick index for a given channel.
--- @since 2.0.0
---@param channel integer Channel number (0-3)
---@return integer stick Stick index (0-3)
function defaultStick(channel) end

--- Return the default channel for a given stick. Returns nil if not found.
--- @since 2.0.0
---@param stick integer Stick index (0-3)
---@return integer|nil channel
function defaultChannel(stick) end

-- ==========================================================================
-- Flight mode
-- ==========================================================================

--- Return the current flight mode number and name.
--- @since 2.1.7
---@param index? integer Flight mode index (default: current active mode)
---@return integer mode
---@return string name
function getFlightMode(index) end

-- ==========================================================================
-- UI / popup functions
-- ==========================================================================

--- Take a screenshot and save to SD card.
function screenshot() end

--- Show an input popup dialog with adjustable numeric value.
--- @since 2.0.0
---@param title string
---@param event integer
---@param input integer Current value
---@param min integer Minimum value
---@param max integer Maximum value
---@return integer|string result "OK", "CANCEL", or current input value
function popupInput(title, event, input, min, max) end

--- Show a warning popup. Returns "CANCEL" when dismissed, nil while still showing.
--- @since 2.0.0
---@param title string
---@param event integer
---@return string|nil result "CANCEL" when dismissed, nil while still showing
function popupWarning(title, event) end

--- Show a confirmation popup with OK/Cancel buttons.
--- @since 2.0.0
---@overload fun(title: string, event: integer): string|nil @Deprecated 2-arg form
---@param title string
---@param message string
---@param event? integer
---@return string|nil result "OK", "CANCEL", or nil while still showing
function popupConfirmation(title, message, event) end

--- Stop key repeat events for the given key.
---@param event integer Key event to kill
function killEvents(event) end

-- ==========================================================================
-- Touch event constants (color LCD with touch)
-- ==========================================================================

---@type integer
EVT_TOUCH_FIRST = 0
---@type integer
EVT_TOUCH_BREAK = 0
---@type integer
EVT_TOUCH_SLIDE = 0
---@type integer
EVT_TOUCH_TAP = 0

-- ==========================================================================
-- Virtual event constants
-- ==========================================================================

---@type integer
EVT_VIRTUAL_PREV = 0
---@type integer
EVT_VIRTUAL_PREV_REPT = 0
---@type integer
EVT_VIRTUAL_NEXT = 0
---@type integer
EVT_VIRTUAL_NEXT_REPT = 0
---@type integer
EVT_VIRTUAL_DEC = 0
---@type integer
EVT_VIRTUAL_DEC_REPT = 0
---@type integer
EVT_VIRTUAL_INC = 0
---@type integer
EVT_VIRTUAL_INC_REPT = 0
---@type integer
EVT_VIRTUAL_PREV_PAGE = 0
---@type integer
EVT_VIRTUAL_NEXT_PAGE = 0
---@type integer
EVT_VIRTUAL_MENU = 0
---@type integer
EVT_VIRTUAL_MENU_LONG = 0
---@type integer
EVT_VIRTUAL_ENTER = 0
---@type integer
EVT_VIRTUAL_ENTER_LONG = 0
---@type integer
EVT_VIRTUAL_EXIT = 0
---@type integer
EVT_EXIT_BREAK = 0

-- ==========================================================================
-- Key event constants (generated per-radio, superset listed)
-- ==========================================================================

---@type integer
EVT_ENTER_FIRST = 0
---@type integer
EVT_ENTER_BREAK = 0
---@type integer
EVT_ENTER_LONG = 0
---@type integer
EVT_ENTER_REPT = 0
---@type integer
EVT_MENU_FIRST = 0
---@type integer
EVT_MENU_BREAK = 0
---@type integer
EVT_MENU_LONG = 0
---@type integer
EVT_MENU_REPT = 0
---@type integer
EVT_TELEM_FIRST = 0
---@type integer
EVT_TELEM_BREAK = 0
---@type integer
EVT_TELEM_LONG = 0
---@type integer
EVT_TELEM_REPT = 0
---@type integer
EVT_MODEL_FIRST = 0
---@type integer
EVT_MODEL_BREAK = 0
---@type integer
EVT_MODEL_LONG = 0
---@type integer
EVT_MODEL_REPT = 0
---@type integer
EVT_SYS_FIRST = 0
---@type integer
EVT_SYS_BREAK = 0
---@type integer
EVT_SYS_LONG = 0
---@type integer
EVT_SYS_REPT = 0
---@type integer
EVT_UP_FIRST = 0
---@type integer
EVT_UP_BREAK = 0
---@type integer
EVT_UP_LONG = 0
---@type integer
EVT_UP_REPT = 0
---@type integer
EVT_DOWN_FIRST = 0
---@type integer
EVT_DOWN_BREAK = 0
---@type integer
EVT_DOWN_LONG = 0
---@type integer
EVT_DOWN_REPT = 0
---@type integer
EVT_LEFT_FIRST = 0
---@type integer
EVT_LEFT_BREAK = 0
---@type integer
EVT_LEFT_LONG = 0
---@type integer
EVT_LEFT_REPT = 0
---@type integer
EVT_RIGHT_FIRST = 0
---@type integer
EVT_RIGHT_BREAK = 0
---@type integer
EVT_RIGHT_LONG = 0
---@type integer
EVT_RIGHT_REPT = 0
---@type integer
EVT_PAGEUP_FIRST = 0
---@type integer
EVT_PAGEUP_BREAK = 0
---@type integer
EVT_PAGEUP_LONG = 0
---@type integer
EVT_PAGEUP_REPT = 0
---@type integer
EVT_PAGEDN_FIRST = 0
---@type integer
EVT_PAGEDN_BREAK = 0
---@type integer
EVT_PAGEDN_LONG = 0
---@type integer
EVT_PAGEDN_REPT = 0
---@type integer
EVT_PAGE_FIRST = 0
---@type integer
EVT_PAGE_BREAK = 0
---@type integer
EVT_PAGE_LONG = 0
---@type integer
EVT_PAGE_REPT = 0
---@type integer
EVT_PLUS_FIRST = 0
---@type integer
EVT_PLUS_BREAK = 0
---@type integer
EVT_PLUS_LONG = 0
---@type integer
EVT_PLUS_REPT = 0
---@type integer
EVT_MINUS_FIRST = 0
---@type integer
EVT_MINUS_BREAK = 0
---@type integer
EVT_MINUS_LONG = 0
---@type integer
EVT_MINUS_REPT = 0
---@type integer
EVT_SHIFT_FIRST = 0
---@type integer
EVT_SHIFT_BREAK = 0
---@type integer
EVT_SHIFT_LONG = 0
---@type integer
EVT_SHIFT_REPT = 0
---@type integer
EVT_ROT_FIRST = 0
---@type integer
EVT_ROT_BREAK = 0
---@type integer
EVT_ROT_LONG = 0
---@type integer
EVT_ROT_REPT = 0
---@type integer
EVT_ROT_LEFT = 0
---@type integer
EVT_ROT_RIGHT = 0
---@type integer
ROTENC_LOWSPEED = 0
---@type integer
ROTENC_MIDSPEED = 0
---@type integer
ROTENC_HIGHSPEED = 0
