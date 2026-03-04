---@meta

-- EdgeTX time and clock functions
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Return the time since the radio was started in multiples of 10ms.
--- Uses a 32-bit counter (enough for 497 days).
--- @since 2.0.0
---@return integer timestamp 10ms tick count
function getTime() end

--- Return current system date and time from the RTC.
--- @since 2.0.0
---@return {year: integer, mon: integer, day: integer, hour: integer, min: integer, sec: integer, hour12: integer, suffix: string}
function getDateTime() end

--- Return current RTC time as a Unix timestamp (seconds since epoch).
---@return integer seconds Unix timestamp from RTC
function getRtcTime() end
