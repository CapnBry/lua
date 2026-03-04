---@meta

-- EdgeTX serial port communication functions
-- Source: edgetx/radio/src/lua/api_general.cpp

--- Set the serial port baud rate for Lua serial communication.
---@param baudrate integer Baud rate (e.g. 115200)
function setSerialBaudrate(baudrate) end

--- Write a string to the serial port.
---@param data string Bytes to send
function serialWrite(data) end

--- Read bytes from the serial port. Returns an empty string if no data available.
---@param num? integer Maximum number of bytes to read (0 = all available)
---@return string data
function serialRead(num) end

--- Get external serial port power state.
---@param port_nr integer Port number
---@return boolean|nil power true/false for power state, nil if unavailable
function serialGetPower(port_nr) end

--- Set external serial port power state.
---@param port_nr integer Port number
---@param power integer Power value (0=off, 1=on)
---@return boolean success
function serialSetPower(port_nr, power) end
