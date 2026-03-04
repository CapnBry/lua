---@meta

-- Lua 5.2 bit32 library (available in EdgeTX runtime)
-- Custom definition to avoid deprecation warnings from lua-language-server.
-- The built-in bit32 is disabled in .luarc.json because LuaLS marks it
-- deprecated under Lua 5.3, but EdgeTX's runtime still requires it.

---@class bit32lib
bit32 = {}

---@param ... integer
---@return integer
function bit32.band(...) end

---@param ... integer
---@return integer
function bit32.bor(...) end

---@param ... integer
---@return integer
function bit32.bxor(...) end

---@param x integer
---@return integer
function bit32.bnot(x) end

---@param ... integer
---@return boolean
function bit32.btest(...) end

---@param x integer
---@param disp integer
---@return integer
function bit32.lshift(x, disp) end

---@param x integer
---@param disp integer
---@return integer
function bit32.rshift(x, disp) end

---@param x integer
---@param disp integer
---@return integer
function bit32.arshift(x, disp) end

---@param x integer
---@param disp integer
---@return integer
function bit32.lrotate(x, disp) end

---@param x integer
---@param disp integer
---@return integer
function bit32.rrotate(x, disp) end

---@param n integer
---@param field integer
---@param width? integer
---@return integer
function bit32.extract(n, field, width) end

---@param n integer
---@param v integer
---@param field integer
---@param width? integer
---@return integer
function bit32.replace(n, v, field, width) end
