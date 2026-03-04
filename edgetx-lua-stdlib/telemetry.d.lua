---@meta

-- EdgeTX telemetry protocol functions and sensor unit constants
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Push telemetry data via ACCESS protocol (PXX2). When called without
--- parameters, returns the output buffer availability.
---@overload fun(): boolean
---@param module integer Module number (-1 for default)
---@param rxUid integer Receiver UID
---@param sensorId integer Physical sensor ID
---@param frameId integer Frame type
---@param dataId integer Data ID
---@param value integer Data value
---@return boolean success
function accessTelemetryPush(module, rxUid, sensorId, frameId, dataId, value) end

--- Pop a received S.PORT telemetry frame. Returns nil if queue is empty.
--- @since 2.0.0
---@return integer|nil physicalId
---@return integer|nil primId
---@return integer|nil dataId
---@return integer|nil value
function sportTelemetryPop() end

--- Push an S.PORT telemetry frame. When called without parameters,
--- returns buffer availability. Returns nil if protocol is wrong.
--- @since 2.0.0
---@overload fun(): boolean
---@param sensor integer Sensor physical ID
---@param frame integer Frame type
---@param dataId integer Data ID
---@param value integer Data value
---@return nil|boolean success nil if wrong protocol, boolean otherwise
function sportTelemetryPush(sensor, frame, dataId, value) end

--- Set a telemetry sensor value. Automatically creates the sensor if needed.
--- @since 2.2.0
---@param id integer Sensor ID
---@param subId integer Sub-ID (0-7)
---@param instance integer Instance
---@param value integer Sensor value
---@param unit? integer Unit constant (UNIT_*, default 0)
---@param precision? integer Decimal precision (default 0)
---@param name? string Sensor name (up to 4 chars, auto-generated from ID if omitted)
---@return boolean success
function setTelemetryValue(id, subId, instance, value, unit, precision, name) end

--- Pop a received Crossfire telemetry packet. Returns nil if queue is empty.
--- @since 2.2.0
---@return integer|nil command
---@return integer[]|nil data Array of payload bytes
function crossfireTelemetryPop() end

--- Push a Crossfire telemetry packet. When called without parameters,
--- returns buffer availability. Returns nil if protocol is wrong.
--- @since 2.2.0
---@overload fun(): boolean
---@param command integer CRSF command byte
---@param data integer[] Array of payload bytes
---@return nil|boolean success nil if wrong protocol, boolean otherwise
function crossfireTelemetryPush(command, data) end

--- Pop a received Ghost telemetry packet. Returns nil if queue is empty.
--- @since 2.7.0
---@return integer|nil type
---@return integer[]|nil data Array of payload bytes
function ghostTelemetryPop() end

--- Push a Ghost telemetry packet. When called without parameters,
--- returns buffer availability. Returns nil if protocol is wrong.
--- @since 2.7.0
---@overload fun(): boolean
---@param type integer Ghost frame type
---@param data integer[] Array of payload bytes (max 10)
---@return nil|boolean success nil if wrong protocol, boolean otherwise
function ghostTelemetryPush(type, data) end

--- Read or write the Multi module shared buffer. When called with two
--- arguments, writes `value` at `index`. Always returns the current value.
---@param index integer Buffer index (0-based)
---@param value? integer Value to write (omit to just read; internal sentinel is 0x100)
---@return integer value Current buffer value at index
function multiBuffer(index, value) end

--- Return RSSI value and alarm thresholds.
--- @since 2.0.0
---@return integer rssi Current RSSI
---@return integer alarm_low Low alarm threshold
---@return integer alarm_crit Critical alarm threshold
function getRSSI() end

--- Return RSSI Alarm Status (RAS) or nil if not available.
---@return integer|nil value
function getRAS() end

--- Return built-in GPS data or nil if no GPS present.
---@return table|nil gpsData
function getTxGPS() end

-- ==========================================================================
-- Unit constants
-- ==========================================================================

---@type integer
UNIT_RAW = 0
---@type integer
UNIT_VOLTS = 0
---@type integer
UNIT_AMPS = 0
---@type integer
UNIT_MILLIAMPS = 0
---@type integer
UNIT_KTS = 0
---@type integer
UNIT_METERS_PER_SECOND = 0
---@type integer
UNIT_FEET_PER_SECOND = 0
---@type integer
UNIT_KMH = 0
---@type integer
UNIT_MPH = 0
---@type integer
UNIT_METERS = 0
---@type integer
UNIT_KM = 0
---@type integer
UNIT_FEET = 0
---@type integer
UNIT_CELSIUS = 0
---@type integer
UNIT_FAHRENHEIT = 0
---@type integer
UNIT_PERCENT = 0
---@type integer
UNIT_MAH = 0
---@type integer
UNIT_WATTS = 0
---@type integer
UNIT_MILLIWATTS = 0
---@type integer
UNIT_DB = 0
---@type integer
UNIT_RPMS = 0
---@type integer
UNIT_G = 0
---@type integer
UNIT_DEGREE = 0
---@type integer
UNIT_RADIANS = 0
---@type integer
UNIT_MILLILITERS = 0
---@type integer
UNIT_FLOZ = 0
---@type integer
UNIT_MILLILITERS_PER_MINUTE = 0
---@type integer
UNIT_HERTZ = 0
---@type integer
UNIT_MS = 0
---@type integer
UNIT_US = 0
---@type integer
UNIT_DBM = 0
---@type integer
UNIT_HOURS = 0
---@type integer
UNIT_MINUTES = 0
---@type integer
UNIT_SECONDS = 0
---@type integer
UNIT_CELLS = 0
---@type integer
UNIT_DATETIME = 0
---@type integer
UNIT_GPS = 0
---@type integer
UNIT_BITFIELD = 0
---@type integer
UNIT_TEXT = 0
