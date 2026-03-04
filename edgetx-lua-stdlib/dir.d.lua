---@meta

-- EdgeTX filesystem module
-- Source: edgetx/radio/src/lua/api_filesystem.cpp

---@class dir
dir = {}

--- Return an iterator listing all file and directory names in a directory.
--- @since 2.5.0
---@param path? string Working directory
---@return fun():string|nil iterator Returns filenames one at a time
function dir.dir(path) end

--- Check the existence of a file or directory. Returns nil if not found.
--- @since 2.5.0
---@param path? string Path to the object
---@return {size: integer, attrib: integer, time: {year: integer, mon: integer, day: integer, hour: integer, hour12: integer, min: integer, sec: integer, suffix: string}}|nil stat
function dir.fstat(path) end

--- Delete a file or directory.
--- @since 2.9.0
---@param path? string Path to file or directory to delete
---@return integer result FRESULT (0=OK, 4=File not found, 5=Path not found, 6=Path invalid)
function dir.del(path) end

--- Change the working directory.
--- @since 2.3.0
---@param path? string New working directory
function dir.chdir(path) end

--- Create a directory.
--- @since 2.11.0
---@param path string Directory path to create
---@return integer result FRESULT (0=OK, 6=Path invalid, 8=Directory exists)
function dir.mkdir(path) end

--- Rename or move a file or directory. The new parent directory must already exist.
--- @since 2.11.0
---@param oldPath string Current path
---@param newPath string New path
---@return integer result FRESULT (0=OK, 6=Path invalid, 8=Directory exists)
function dir.rename(oldPath, newPath) end

-- ==========================================================================
-- File attribute constants (for dir.fstat attrib field)
-- ==========================================================================

---@type integer
AM_RDO = 0
---@type integer
AM_HID = 0
---@type integer
AM_SYS = 0
---@type integer
AM_DIR = 0
---@type integer
AM_ARC = 0
