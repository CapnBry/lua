---@meta

-- EdgeTX Lua runtime overrides
-- Only libraries that differ from standard Lua 5.3 are redefined here.
-- string, math (core), bit32, table, and base globals use LuaLS builtins.

-- ==========================================================================
-- io library (5 functions only, non-standard signatures)
-- EdgeTX uses FatFs; all functions take a file handle as the first argument.
-- No file methods (:read, :write, etc.), no io.lines, io.input, io.output.
-- ==========================================================================

---@class file*

io = {}

--- Open a file on the SD card. Returns file handle on success, or nil + error
--- message on failure.
---@param filename string Full path on SD card
---@param mode? "r"|"rb"|"w"|"wb"|"a"|"ab" Default "r". Only the first character matters; 'b' is accepted but ignored.
---@return file*|nil handle
---@return string|nil errmsg
function io.open(filename, mode) end

--- Read up to `size` bytes from the file. Returns an empty string at end of file.
---@param file file*
---@param size integer Number of bytes to read
---@return string data Empty string on EOF
function io.read(file, size) end

--- Write values to the file. Accepts strings and numbers.
---@param file file*
---@param ... string|number
---@return file* file The file handle on success
function io.write(file, ...) end

--- Close the file handle.
---@param file file*
function io.close(file) end

--- Seek to an absolute byte offset in the file.
---@param file file*
---@param offset integer Absolute byte offset (unsigned)
---@return integer result FRESULT (0 = OK)
function io.seek(file, offset) end

-- ==========================================================================
-- math compat functions (LUA_COMPAT_5_2 / LUA_COMPAT_MATHLIB)
-- These are deprecated in standard Lua 5.3 but available in EdgeTX.
-- ==========================================================================

---@deprecated Use `math.atan(y, x)` instead
---@param y number
---@param x? number
---@return number
function math.atan2(y, x) end

---@deprecated
---@param x number
---@return number
function math.cosh(x) end

---@deprecated
---@param x number
---@return number
function math.sinh(x) end

---@deprecated
---@param x number
---@return number
function math.tanh(x) end

---@deprecated Use `x ^ y` instead
---@param x number
---@param y number
---@return number
function math.pow(x, y) end

---@deprecated
---@param x number
---@return number m
---@return integer e
function math.frexp(x) end

---@deprecated
---@param m number
---@param e integer
---@return number
function math.ldexp(m, e) end

---@deprecated Use `math.log(x, 10)` instead
---@param x number
---@return number
function math.log10(x) end
