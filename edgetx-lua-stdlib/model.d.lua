---@meta

-- EdgeTX model module
-- Source: edgetx/radio/src/lua/api_model.cpp

---@class model
model = {}

--- Get current model information.
--- @since 2.0.6
---@return {name: string, extendedLimits: boolean, jitterFilter: integer, bitmap: string, labels: string, filename: string}
function model.getInfo() end

--- Set current model information. Missing fields remain unchanged.
--- @since 2.0.6
---@param info {name?: string, extendedLimits?: boolean, jitterFilter?: integer, bitmap?: string}
function model.setInfo(info) end

--- Get RF module parameters. Returns nil if index is invalid.
--- @since 2.2.0
---@param index integer Module slot (0=internal, 1=external)
---@return {subType: integer, modelId: integer, firstChannel: integer, channelsCount: integer, Type: integer, protocol?: integer, subProtocol?: integer, channelsOrder?: integer}|nil module
function model.getModule(index) end

--- Set RF module parameters. Missing fields remain unchanged.
--- @since 2.2.0
---@param index integer Module slot (0=internal, 1=external)
---@param config {Type?: integer, subType?: integer, modelId?: integer, firstChannel?: integer, channelsCount?: integer, protocol?: integer, subProtocol?: integer}
function model.setModule(index, config) end

--- Get model timer parameters.
--- @since 2.0.0
---@param index integer Timer index (0-based)
---@return {mode: integer, start: integer, value: integer, countdownBeep: integer, minuteBeep: boolean, persistent: integer, name: string, showElapsed: boolean, switch: integer, countdownStart: integer, extraHaptic: integer}|nil timer
function model.getTimer(index) end

--- Set model timer parameters. Missing fields remain unchanged.
--- @since 2.0.0
---@param index integer Timer index (0-based)
---@param config {mode?: integer, start?: integer, value?: integer, countdownBeep?: integer, minuteBeep?: boolean, persistent?: integer, name?: string, showElapsed?: boolean, switch?: integer, countdownStart?: integer, extraHaptic?: integer}
function model.setTimer(index, config) end

--- Reset model timer to its startup value.
--- @since 2.0.0
---@param index integer Timer index (0-based)
function model.resetTimer(index) end

--- Clear all flight modes.
function model.deleteFlightModes() end

--- Get flight mode data.
--- @since 2.1.7
---@param index integer Flight mode index (0-based)
---@return {name: string, switch: integer, fadeIn: integer, fadeOut: integer, trimsValues: table<integer, integer>, trimsModes: table<integer, integer>} flightMode
function model.getFlightMode(index) end

--- Set flight mode parameters. Missing fields remain unchanged.
--- @since 2.1.7
---@param index integer Flight mode index (0-based)
---@param config {name?: string, switch?: integer, fadeIn?: integer, fadeOut?: integer, trimsValues?: table<integer, integer>, trimsModes?: table<integer, integer>}
---@return integer result 0=success, 2=invalid index
function model.setFlightMode(index, config) end

--- Return the number of lines for the given input.
--- @since 2.0.0
---@param input integer Input index (0-based)
---@return integer count
function model.getInputsCount(input) end

--- Get input line configuration.
--- @since 2.0.0
---@param input integer Input index (0-based)
---@param line integer Line number within input (0-based)
---@return {name: string, inputName: string, source: integer, scale: integer, weight: integer, offset: integer, switch: integer, curveType: integer, curveValue: integer, trimSource: integer, side: integer, flightModes: integer} inputConfig
function model.getInput(input, line) end

--- Insert an input line at the specified position.
--- @since 2.0.0
---@param input integer Input index (0-based)
---@param line integer Line number to insert at (0-based)
---@param config {name?: string, inputName?: string, source?: integer, scale?: integer, weight?: integer, offset?: integer, switch?: integer, curveType?: integer, curveValue?: integer, trimSource?: integer, side?: integer, flightModes?: integer}
function model.insertInput(input, line, config) end

--- Delete a line from the specified input.
--- @since 2.0.0
---@param input integer Input index (0-based)
---@param line integer Line number (0-based)
function model.deleteInput(input, line) end

--- Delete all input lines.
function model.deleteInputs() end

--- Set all inputs to defaults (one stick per input).
function model.defaultInputs() end

--- Get the number of mixer lines for the given channel.
--- @since 2.0.0
---@param channel integer Channel index (0-based)
---@return integer count
function model.getMixesCount(channel) end

--- Get mixer line configuration.
--- @since 2.0.0
---@param channel integer Channel index (0-based)
---@param line integer Line number within channel (0-based)
---@return {name: string, source: integer, weight: integer, offset: integer, switch: integer, curveType: integer, curveValue: integer, multiplex: integer, flightModes: integer, carryTrim: boolean, mixWarn: integer, delayPrec: integer, delayUp: integer, delayDown: integer, speedPrec: integer, speedUp: integer, speedDown: integer} mix
function model.getMix(channel, line) end

--- Insert a mixer line at the specified position.
--- @since 2.0.0
---@param channel integer Channel index (0-based)
---@param line integer Line number to insert at (0-based)
---@param config {name?: string, source?: integer, weight?: integer, offset?: integer, switch?: integer, curveType?: integer, curveValue?: integer, multiplex?: integer, flightModes?: integer, carryTrim?: boolean, mixWarn?: integer, delayPrec?: integer, delayUp?: integer, delayDown?: integer, speedPrec?: integer, speedUp?: integer, speedDown?: integer}
function model.insertMix(channel, line, config) end

--- Delete a mixer line from the specified channel.
--- @since 2.0.0
---@param channel integer Channel index (0-based)
---@param line integer Line number (0-based)
function model.deleteMix(channel, line) end

--- Remove all mixer lines.
function model.deleteMixes() end

--- Get logical switch parameters.
--- @since 2.0.0
---@param index integer Logical switch index (0-based)
---@return {func: integer, v1: integer, v2: integer, v3: integer, ["and"]: integer, delay: integer, duration: integer, state: boolean, persistent: boolean} logicalSwitch
function model.getLogicalSwitch(index) end

--- Set logical switch parameters. Missing fields remain unchanged.
--- @since 2.0.0
---@param index integer Logical switch index (0-based)
---@param config {func?: integer, v1?: integer, v2?: integer, v3?: integer, ["and"]?: integer, delay?: integer, duration?: integer, state?: boolean, persistent?: boolean}
function model.setLogicalSwitch(index, config) end

--- Get custom (special) function parameters.
--- @since 2.0.0
---@param index integer Function index (0-based)
---@return {switch: integer, func: integer, name?: string, value?: integer, mode?: integer, param?: integer, active: integer, repetition: integer} customFunction
function model.getCustomFunction(index) end

--- Set custom (special) function parameters. Missing fields remain unchanged.
--- @since 2.0.0
---@param index integer Function index (0-based)
---@param config {switch?: integer, func?: integer, name?: string, value?: integer, mode?: integer, param?: integer, active?: integer, repetition?: integer}
function model.setCustomFunction(index, config) end

--- Get curve parameters. The `y` table contains point values (1-based).
--- The `x` table is only present for custom curve types.
--- @since 2.0.12
---@param index integer Curve index (0-based)
---@return {name: string, type: integer, smooth: boolean, points: integer, y: table<integer, integer>, x?: table<integer, integer>} curve
function model.getCurve(index) end

--- Set curve parameters.
--- @since 2.0.12
---@param index integer Curve index (0-based)
---@param config {name?: string, type?: integer, smooth?: boolean, points?: integer, y?: table<integer, integer>, x?: table<integer, integer>}
---@return integer result 0=success, 1=wrong number of points, 2=invalid curve number
function model.setCurve(index, config) end

--- Get output (servo) channel parameters. Values are in 0.1% units.
--- @since 2.0.0
---@param index integer Output channel index (0-based)
---@return {name: string, min: integer, max: integer, offset: integer, ppmCenter: integer, symetrical: integer, revert: integer, curve?: integer} output
function model.getOutput(index) end

--- Set output (servo) channel parameters. Missing fields remain unchanged.
--- @since 2.0.0
---@param index integer Output channel index (0-based)
---@param config {name?: string, min?: integer, max?: integer, offset?: integer, ppmCenter?: integer, symetrical?: integer, revert?: integer, curve?: integer}
function model.setOutput(index, config) end

--- Get the current value of a global variable.
--- @since 2.1.0
---@param index integer GVar index (0-based)
---@param flightMode integer Flight mode index (0-based)
---@return integer value
function model.getGlobalVariable(index, flightMode) end

--- Set the value of a global variable.
--- @since 2.1.0
---@param index integer GVar index (0-based)
---@param flightMode integer Flight mode index (0-based)
---@param value integer
function model.setGlobalVariable(index, flightMode, value) end

--- Get global variable details (name, range, unit, etc.).
---@param index integer GVar index (0-based)
---@return {name: string, min: integer, max: integer, prec: integer, unit: integer, popup: boolean}|nil details
function model.getGlobalVariableDetails(index) end

--- Set global variable details. Missing fields remain unchanged.
---@param index integer GVar index (0-based)
---@param details {name?: string, min?: integer, max?: integer, prec?: integer, unit?: integer, popup?: boolean}
function model.setGlobalVariableDetails(index, details) end

--- Get telemetry sensor parameters. The `id` and `instance` fields are
--- only present for custom sensors; `formula` is only present for calculated sensors.
--- @since 2.2.0
---@param index integer Sensor index (0-based)
---@return {type: integer, name: string, unit: integer, prec: integer, id?: integer, instance?: integer, formula?: integer} sensor
function model.getSensor(index) end

--- Reset telemetry sensor to default value.
---@param index integer Sensor index (0-based)
function model.resetSensor(index) end

--- Get heli swash ring parameters. Only available on builds with HELI support.
---@return {type: integer, value: integer, collectiveSource: integer, aileronSource: integer, elevatorSource: integer, collectiveWeight: integer, aileronWeight: integer, elevatorWeight: integer} swashRing
function model.getSwashRing() end

--- Set heli swash ring parameters. Missing fields remain unchanged.
--- Only available on builds with HELI support.
---@param config {type?: integer, value?: integer, collectiveSource?: integer, aileronSource?: integer, elevatorSource?: integer, collectiveWeight?: integer, aileronWeight?: integer, elevatorWeight?: integer}
function model.setSwashRing(config) end

-- ==========================================================================
-- Global model-related functions
-- ==========================================================================

--- Return trainer connection status.
---@return integer status
function getTrainerStatus() end

-- ==========================================================================
-- Input / source type constants
-- ==========================================================================

---@type integer
VALUE = 0
---@type integer
SOURCE = 0
---@type integer
REPLACE = 0
---@type integer
MIXSRC_MIN = 0
---@type integer
MIXSRC_MAX = 0
---@type integer
MIXSRC_FIRST_INPUT = 0
---@type integer
MIXSRC_CH1 = 0
---@type integer
SWSRC_LAST = 0
---@type integer
SWITCH_COUNT = 0
---@type integer
MAX_SENSORS = 0
---@type integer
MAX_OUTPUT_CHANNELS = 0
---@type integer
LIMIT_EXT_PERCENT = 0
---@type integer
LIMIT_STD_PERCENT = 0

-- ==========================================================================
-- Logical switch function constants
-- ==========================================================================

---@type integer
LS_FUNC_NONE = 0
---@type integer
LS_FUNC_VEQUAL = 0
---@type integer
LS_FUNC_VALMOSTEQUAL = 0
---@type integer
LS_FUNC_VPOS = 0
---@type integer
LS_FUNC_VNEG = 0
---@type integer
LS_FUNC_APOS = 0
---@type integer
LS_FUNC_ANEG = 0
---@type integer
LS_FUNC_AND = 0
---@type integer
LS_FUNC_OR = 0
---@type integer
LS_FUNC_XOR = 0
---@type integer
LS_FUNC_EDGE = 0
---@type integer
LS_FUNC_EQUAL = 0
---@type integer
LS_FUNC_GREATER = 0
---@type integer
LS_FUNC_LESS = 0
---@type integer
LS_FUNC_DIFFEGREATER = 0
---@type integer
LS_FUNC_ADIFFEGREATER = 0
---@type integer
LS_FUNC_TIMER = 0
---@type integer
LS_FUNC_STICKY = 0

-- ==========================================================================
-- Custom function constants
-- ==========================================================================

---@type integer
FUNC_OVERRIDE_CHANNEL = 0
---@type integer
FUNC_TRAINER = 0
---@type integer
FUNC_INSTANT_TRIM = 0
---@type integer
FUNC_RESET = 0
---@type integer
FUNC_SET_TIMER = 0
---@type integer
FUNC_ADJUST_GVAR = 0
---@type integer
FUNC_VOLUME = 0
---@type integer
FUNC_SET_FAILSAFE = 0
---@type integer
FUNC_RANGECHECK = 0
---@type integer
FUNC_BIND = 0
---@type integer
FUNC_PLAY_SOUND = 0
---@type integer
FUNC_PLAY_TRACK = 0
---@type integer
FUNC_PLAY_VALUE = 0
---@type integer
FUNC_PLAY_SCRIPT = 0
---@type integer
FUNC_BACKGND_MUSIC = 0
---@type integer
FUNC_BACKGND_MUSIC_PAUSE = 0
---@type integer
FUNC_VARIO = 0
---@type integer
FUNC_HAPTIC = 0
---@type integer
FUNC_LOGS = 0
---@type integer
FUNC_BACKLIGHT = 0
---@type integer
FUNC_SCREENSHOT = 0
---@type integer
FUNC_RACING_MODE = 0
---@type integer
FUNC_PUSH_CUST_SWITCH = 0
---@type integer
FUNC_SET_SCREEN = 0
---@type integer
FUNC_DISABLE_TOUCH = 0
