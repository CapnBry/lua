---@meta

-- EdgeTX bitmap module (color LCD only)
-- Source: edgetx/radio/src/lua/api_colorlcd.cpp

---@class BitmapObject

---@class bitmap
bitmap = {}

--- Load a bitmap from the SD card. Bitmaps should be loaded only once; store the
--- returned object for later drawing with lcd.drawBitmap(). If loading fails the
--- resulting bitmap object will have width and height of zero.
--- Loading can fail if the file is not found, the image is invalid,
--- the system is low on memory, or combined Lua bitmap usage exceeds the limit.
--- @since 2.2.0
---@param path string Full path to the bitmap on SD card (e.g. "/IMAGES/test.bmp")
---@return BitmapObject bmp
function bitmap.open(path) end

--- Return width and height of a bitmap object.
--- @since 2.2.0
---@param bmp BitmapObject Bitmap previously opened with bitmap.open()
---@return integer width Width in pixels
---@return integer height Height in pixels
function bitmap.getSize(bmp) end

--- Return a new resized copy of a bitmap.
--- @since 2.8.0
---@param bmp BitmapObject Bitmap previously opened with bitmap.open()
---@param width integer New width in pixels
---@param height integer New height in pixels
---@return BitmapObject|nil resized nil if input bitmap is invalid
function bitmap.resize(bmp, width, height) end

--- Convert a bitmap to an 8-bit mask for use with lcd.drawBitmapPattern().
--- @since 2.8.0
---@param bmp BitmapObject Bitmap previously opened with bitmap.open()
---@return string mask Binary mask data
function bitmap.toMask(bmp) end

--- @deprecated Use `bitmap` module instead.
---@class Bitmap
Bitmap = {}

--- @deprecated Use `bitmap.open` instead.
---@param path string Full path to the bitmap on SD card
---@return BitmapObject bmp
function Bitmap.open(path) end

--- @deprecated Use `bitmap.getSize` instead.
---@param bmp BitmapObject
---@return integer width
---@return integer height
function Bitmap.getSize(bmp) end

--- @deprecated Use `bitmap.resize` instead.
---@param bmp BitmapObject
---@param width integer
---@param height integer
---@return BitmapObject|nil resized
function Bitmap.resize(bmp, width, height) end

--- @deprecated Use `bitmap.toMask` instead.
---@param bmp BitmapObject
---@return string mask
function Bitmap.toMask(bmp) end
