---@meta

-- EdgeTX LCD drawing module
-- Source: edgetx/radio/src/lua/api_colorlcd.cpp, api_stdlcd.cpp

---@class lcd
lcd = {}

--- Refresh the LCD screen. On color LCDs (2.4.0+) this is done automatically.
--- @since 2.0.0
function lcd.refresh() end

--- Clear the LCD screen.
--- @since 2.0.0
---@param color? integer Fill color (color LCD only, defaults to COLOR_THEME_SECONDARY3)
function lcd.clear(color) end

--- Reset the backlight timeout.
--- @since 2.3.6
function lcd.resetBacklightTimeout() end

--- Draw a single pixel at (x,y).
--- @since 2.0.0
---@param x integer
---@param y integer
---@param flags? integer Drawing flags
function lcd.drawPoint(x, y, flags) end

--- Draw a straight line between two points.
--- If either endpoint is outside the LCD, the whole line will not be drawn.
--- @since 2.0.0
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param pattern integer SOLID or DOTTED
---@param flags? integer Drawing flags
function lcd.drawLine(x1, y1, x2, y2, pattern, flags) end

--- Draw a rectangle outline.
--- @since 2.0.0
---@param x integer
---@param y integer
---@param w integer Width in pixels
---@param h integer Height in pixels
---@param flags? integer Drawing flags
---@param thickness? integer Border thickness in pixels (color LCD only, default 1)
---@param opacity? integer 0-15 (color LCD only, default 0)
function lcd.drawRectangle(x, y, w, h, flags, thickness, opacity) end

--- Draw a solid filled rectangle.
--- @since 2.0.0
---@param x integer
---@param y integer
---@param w integer Width in pixels
---@param h integer Height in pixels
---@param flags? integer Drawing flags
---@param opacity? integer 0-15 (color LCD only, default 0)
function lcd.drawFilledRectangle(x, y, w, h, flags, opacity) end

--- Invert a rectangular region. Color LCD only.
--- @since 2.8.0
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param flags? integer Drawing flags
function lcd.invertRect(x, y, w, h, flags) end

--- Draw a text string at (x,y).
--- @since 2.0.0
---@param x integer
---@param y integer
---@param text string
---@param flags? integer Drawing flags (font size, alignment, color, INVERS, BLINK, SHADOWED, etc.)
---@param inversColor? integer Color LCD only: overrides the inverse text color when INVERS flag is set
function lcd.drawText(x, y, text, flags, inversColor) end

--- Draw text inside a bounding rectangle with automatic line breaks.
--- Color LCD only. RIGHT, CENTER, VCENTER are not implemented.
--- @since 2.5.0
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param text string
---@param flags? integer Drawing flags
---@param inversColor? integer Color LCD only: overrides the inverse text color when INVERS flag is set
---@return integer x X position where text drawing ended
---@return integer y Y position where text drawing ended
function lcd.drawTextLines(x, y, w, h, text, flags, inversColor) end

--- Get the width and height of a text string when drawn with the given flags.
--- Color LCD only.
--- @since 2.5.0
---@param text string
---@param flags? integer Drawing flags (font size, etc.)
---@return integer width
---@return integer height
function lcd.sizeText(text, flags) end

--- Display a value formatted as time at (x,y).
--- @since 2.0.0
---@param x integer
---@param y integer
---@param value integer Time in seconds
---@param flags? integer Drawing flags (use TIMEHOUR to show hours)
---@param inversColor? integer Color LCD only: overrides the inverse text color when INVERS flag is set
function lcd.drawTimer(x, y, value, flags, inversColor) end

--- Display a number at (x,y). Use PREC1/PREC2 flags for decimal precision.
--- @since 2.0.0
---@param x integer
---@param y integer
---@param value integer
---@param flags? integer Drawing flags
---@param inversColor? integer Color LCD only: overrides the inverse text color when INVERS flag is set
function lcd.drawNumber(x, y, value, flags, inversColor) end

--- Display a telemetry value at (x,y).
--- @since 2.0.6
---@param x integer
---@param y integer
---@param source integer|string Source index or name (only telemetry sources are valid)
---@param flags? integer Drawing flags
function lcd.drawChannel(x, y, source, flags) end

--- Draw the text representation of a switch at (x,y).
--- @since 2.0.0
---@param x integer
---@param y integer
---@param switch integer Switch index; negative number shows negated switch
---@param flags? integer Drawing flags
function lcd.drawSwitch(x, y, switch, flags) end

--- Display the name of the corresponding source at (x,y).
--- @since 2.0.0
---@param x integer
---@param y integer
---@param source integer Source index
---@param flags? integer Drawing flags
function lcd.drawSource(x, y, source, flags) end

--- Draw a horizontal gauge bar.
--- @since 2.0.0
---@param x integer
---@param y integer
---@param w integer Width in pixels
---@param h integer Height in pixels
---@param fill integer Current fill amount
---@param maxfill integer Maximum fill value
---@param flags? integer Drawing flags
function lcd.drawGauge(x, y, w, h, fill, maxfill, flags) end

--- Draw a .bmp pixmap at (x,y). B&W LCD only; on color LCD use lcd.drawBitmap().
---@param x integer
---@param y integer
---@param name string File path on SD card
function lcd.drawPixmap(x, y, name) end

--- Draw a title bar with page counter. B&W LCD only.
---@param title string
---@param page integer Current page (1-based)
---@param pages integer Total number of pages
function lcd.drawScreenTitle(title, page, pages) end

--- Draw a combobox (dropdown selector). B&W LCD only.
---@param x integer
---@param y integer
---@param w integer Width in pixels
---@param list table Array of option strings
---@param idx integer Selected index
---@param flags integer Drawing flags
function lcd.drawCombobox(x, y, w, list, idx, flags) end

--- Display a bitmap at (x,y). Color LCD only.
--- Omitting scale draws at 1:1 and is faster than specifying 100.
--- @since 2.2.0
---@param bmp BitmapObject Bitmap opened with bitmap.open()
---@param x integer
---@param y integer
---@param scale? integer Percentage (0 or omit = 1:1, 50 = half, 200 = double)
function lcd.drawBitmap(bmp, x, y, scale) end

--- Display a bitmap pattern (mask) at (x,y) using the current color. Color LCD only.
--- @since 2.8.0
---@param mask string Binary mask data from bitmap.toMask()
---@param x integer
---@param y integer
---@param flags? integer Drawing flags (color)
function lcd.drawBitmapPattern(mask, x, y, flags) end

--- Display a pie-shaped slice of a bitmap pattern. Color LCD only.
--- @since 2.8.0
---@param mask string Binary mask data from bitmap.toMask()
---@param x integer
---@param y integer
---@param startAngle integer
---@param endAngle integer
---@param flags? integer Drawing flags (color)
function lcd.drawBitmapPatternPie(mask, x, y, startAngle, endAngle, flags) end

--- Change an indexed color (theme colors or CUSTOM_COLOR).
--- Changing theme colors affects all widgets and the radio UI. Color LCD only.
--- @since 2.2.0
---@param colorIndex integer One of the COLOR_THEME_* or CUSTOM_COLOR constants
---@param color integer RGB color value (from lcd.RGB() or another color constant)
function lcd.setColor(colorIndex, color) end

--- Get the RGB565 color value from a color flag. Color LCD only.
--- @since 2.3.11
---@param colorIndex integer Color constant or flags containing color
---@return integer|nil color RGB565 color value, or nil for invalid input
function lcd.getColor(colorIndex) end

--- Create an RGB color flag from components. Color LCD only.
--- Can be called as lcd.RGB(r, g, b) or lcd.RGB(rgb).
--- @since 2.2.0
---@overload fun(rgb: integer): integer
---@param r integer 0-255
---@param g integer 0-255
---@param b integer 0-255
---@return integer color Color flag with RGB565 value
function lcd.RGB(r, g, b) end

--- Draw a circle outline. Color LCD only.
--- @since 2.4.0
---@param x integer Center X
---@param y integer Center Y
---@param r integer Radius in pixels
---@param flags? integer Drawing flags
function lcd.drawCircle(x, y, r, flags) end

--- Draw a filled circle. Color LCD only.
--- @since 2.4.0
---@param x integer Center X
---@param y integer Center Y
---@param r integer Radius in pixels
---@param flags? integer Drawing flags
function lcd.drawFilledCircle(x, y, r, flags) end

--- Draw a triangle outline. Color LCD only.
--- @since 2.4.0
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param x3 integer
---@param y3 integer
---@param flags? integer Drawing flags
function lcd.drawTriangle(x1, y1, x2, y2, x3, y3, flags) end

--- Draw a filled triangle. Color LCD only.
--- @since 2.4.0
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param x3 integer
---@param y3 integer
---@param flags? integer Drawing flags
function lcd.drawFilledTriangle(x1, y1, x2, y2, x3, y3, flags) end

--- Draw an arc (ring segment). Color LCD only.
--- @since 2.4.0
---@param x integer Center X
---@param y integer Center Y
---@param r integer Radius in pixels
---@param startAngle integer
---@param endAngle integer
---@param flags? integer Drawing flags
function lcd.drawArc(x, y, r, startAngle, endAngle, flags) end

--- Draw a filled pie slice. Color LCD only.
--- @since 2.4.0
---@param x integer Center X
---@param y integer Center Y
---@param r integer Radius in pixels
---@param startAngle integer
---@param endAngle integer
---@param flags? integer Drawing flags
function lcd.drawPie(x, y, r, startAngle, endAngle, flags) end

--- Draw a filled annulus (ring sector). Color LCD only.
--- @since 2.4.0
---@param x integer Center X
---@param y integer Center Y
---@param rInner integer Inner radius
---@param rOuter integer Outer radius
---@param startAngle integer
---@param endAngle integer
---@param flags? integer Drawing flags
function lcd.drawAnnulus(x, y, rInner, rOuter, startAngle, endAngle, flags) end

--- Draw a line clipped to a rectangle. Color LCD only.
--- @since 2.4.0
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param xmin integer Clip region left
---@param xmax integer Clip region right
---@param ymin integer Clip region top
---@param ymax integer Clip region bottom
---@param pattern integer FORCE, ERASE, or DOTTED
---@param flags? integer Drawing flags
function lcd.drawLineWithClipping(x1, y1, x2, y2, xmin, xmax, ymin, ymax, pattern, flags) end

--- Draw a HUD-style horizon rectangle with pitch and roll perspective. Color LCD only.
--- @since 2.4.0
---@param pitch number Pitch angle in degrees
---@param roll number Roll angle in degrees
---@param xmin integer
---@param xmax integer
---@param ymin integer
---@param ymax integer
---@param flags? integer Drawing flags
function lcd.drawHudRectangle(pitch, roll, xmin, xmax, ymin, ymax, flags) end

--- Exit full screen widget mode. Color LCD only.
--- @since 2.5.0
function lcd.exitFullScreen() end

--- Get the X position after the last lcd.drawText(). B&W LCD only.
---@return integer x
function lcd.getLastPos() end

--- Get the right edge X position after the last lcd.drawText(). B&W LCD only.
---@return integer x
function lcd.getLastRightPos() end

--- Get the left edge X position after the last lcd.drawText(). B&W LCD only.
---@return integer x
function lcd.getLastLeftPos() end

-- ==========================================================================
-- Display helper functions
-- ==========================================================================

--- Convert a value (0-15) to a grey color flag. B&W LCD only (not color LCD).
---@param value integer Grey level (0-15)
---@return integer color
function GREY(value) end

-- ==========================================================================
-- Display flag constants
-- ==========================================================================

---@type integer
FULLSCALE = 0
---@type integer
STDSIZE = 0
---@type integer
XXLSIZE = 0
---@type integer
DBLSIZE = 0
---@type integer
MIDSIZE = 0
---@type integer
SMLSIZE = 0
---@type integer
TINSIZE = 0
---@type integer
BOLD = 0
---@type integer
BLINK = 0
---@type integer
INVERS = 0
---@type integer
VCENTER = 0
---@type integer
VTOP = 0
---@type integer
VBOTTOM = 0
---@type integer
RIGHT = 0
---@type integer
LEFT = 0
---@type integer
CENTER = 0
---@type integer
PREC1 = 0
---@type integer
PREC2 = 0
---@type integer
SHADOWED = 0
---@type integer
FIXEDWIDTH = 0

-- ==========================================================================
-- Color constants (color LCD only)
-- ==========================================================================

---@type integer
COLOR_THEME_PRIMARY1 = 0
---@type integer
COLOR_THEME_PRIMARY2 = 0
---@type integer
COLOR_THEME_PRIMARY3 = 0
---@type integer
COLOR_THEME_SECONDARY1 = 0
---@type integer
COLOR_THEME_SECONDARY2 = 0
---@type integer
COLOR_THEME_SECONDARY3 = 0
---@type integer
COLOR_THEME_FOCUS = 0
---@type integer
COLOR_THEME_EDIT = 0
---@type integer
COLOR_THEME_ACTIVE = 0
---@type integer
COLOR_THEME_WARNING = 0
---@type integer
COLOR_THEME_DISABLED = 0
---@type integer
CUSTOM_COLOR = 0
---@type integer
BLACK = 0
---@type integer
WHITE = 0
---@type integer
LIGHTWHITE = 0
---@type integer
LIGHTGREY = 0
---@type integer
DARKGREY = 0
---@type integer
RED = 0
---@type integer
DARKRED = 0
---@type integer
LIGHTRED = 0
---@type integer
GREEN = 0
---@type integer
DARKGREEN = 0
---@type integer
BRIGHTGREEN = 0
---@type integer
BLUE = 0
---@type integer
DARKBLUE = 0
---@type integer
CYAN = 0
---@type integer
YELLOW = 0
---@type integer
LIGHTBROWN = 0
---@type integer
DARKBROWN = 0
---@type integer
ORANGE = 0
---@type integer
MAGENTA = 0

-- ==========================================================================
-- Drawing pattern constants
-- ==========================================================================

---@type integer
SOLID = 0
---@type integer
DOTTED = 0
---@type integer
FILL_WHITE = 0
---@type integer
GREY_DEFAULT = 0
---@type integer
FORCE = 0
---@type integer
ERASE = 0
---@type integer
ROUND = 0

-- ==========================================================================
-- Screen dimension constants
-- ==========================================================================

---@type integer
LCD_W = 0
---@type integer
LCD_H = 0
---@type integer
MENU_HEADER_HEIGHT = 0

-- ==========================================================================
-- Special character constants (light userdata)
-- ==========================================================================

---@type any
CHAR_RIGHT = nil
---@type any
CHAR_LEFT = nil
---@type any
CHAR_UP = nil
---@type any
CHAR_DOWN = nil
---@type any
CHAR_DELTA = nil
---@type any
CHAR_STICK = nil
---@type any
CHAR_POT = nil
---@type any
CHAR_SLIDER = nil
---@type any
CHAR_SWITCH = nil
---@type any
CHAR_TRIM = nil
---@type any
CHAR_INPUT = nil
---@type any
CHAR_FUNCTION = nil
---@type any
CHAR_CYC = nil
---@type any
CHAR_TRAINER = nil
---@type any
CHAR_CHANNEL = nil
---@type any
CHAR_TELEMETRY = nil
---@type any
CHAR_LUA = nil
---@type any
CHAR_LS = nil
---@type any
CHAR_CURVE = nil
