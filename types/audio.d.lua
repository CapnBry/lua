---@meta

-- EdgeTX audio and haptic playback functions
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Play an audio file from the SD card.
--- @since 2.0.0
---@param path string Audio file path (e.g. "/SOUNDS/en/hello.wav")
---@param volume? integer Volume override (1-5, omit to use system setting)
function playFile(path, volume) end

--- Play a number with optional unit announcement.
--- @since 2.0.0
---@param value integer Number to play
---@param unit integer Unit constant (UNIT_*)
---@param attributes? integer
---@param volume? integer Volume override (1-5, omit to use system setting)
function playNumber(value, unit, attributes, volume) end

--- Play a duration value (hours, minutes, seconds).
--- @since 2.0.0
---@param duration integer Seconds
---@param playTime? integer Non-zero to announce as time of day
---@param volume? integer Volume override (1-5, omit to use system setting)
function playDuration(duration, playTime, volume) end

--- Play a tone with configurable frequency, duration, and pattern.
--- @since 2.1.0
---@param frequency integer Hz
---@param duration integer ms
---@param pause integer ms of silence after tone
---@param flags? integer 0 or PLAY_NOW
---@param freqIncr? integer Frequency increment per repeat
---@param volume? integer Volume override (1-5, omit to use system setting)
function playTone(frequency, duration, pause, flags, freqIncr, volume) end

--- Generate haptic feedback.
--- @since 2.2.0
---@param duration integer ms
---@param pause? integer ms of silence after haptic
---@param flags? integer 0 or PLAY_NOW
function playHaptic(duration, pause, flags) end

--- Flush the audio queue, stopping all current and pending audio playback.
function flushAudio() end

-- ==========================================================================
-- Audio constants
-- ==========================================================================

---@type integer
PLAY_NOW = 0
---@type integer
PLAY_BACKGROUND = 0
---@type integer
TIMEHOUR = 0
