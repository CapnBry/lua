---@meta

-- EdgeTX LVGL module (color LCD only)
-- Source: edgetx/radio/src/lua/api_colorlcd_lvgl.cpp

---@class LvglObject
local LvglObject = {}

---@param settings LvglLabelSettings
---@return LvglObject
function LvglObject:label(settings) end

---@param settings LvglRectangleSettings
---@return LvglObject
function LvglObject:rectangle(settings) end

---@param settings LvglBoxSettings
---@return LvglObject
function LvglObject:box(settings) end

---@param settings LvglButtonSettings
---@return LvglObject
function LvglObject:button(settings) end

---@param settings LvglMomentaryButtonSettings
---@return LvglObject
function LvglObject:momentaryButton(settings) end

---@param settings LvglToggleSettings
---@return LvglObject
function LvglObject:toggle(settings) end

---@param settings LvglTextEditSettings
---@return LvglObject
function LvglObject:textEdit(settings) end

---@param settings LvglNumberEditSettings
---@return LvglObject
function LvglObject:numberEdit(settings) end

---@param settings LvglChoiceSettings
---@return LvglObject
function LvglObject:choice(settings) end

---@param settings LvglSliderSettings
---@return LvglObject
function LvglObject:slider(settings) end

---@param settings LvglSettingSettings
---@return LvglObject
function LvglObject:setting(settings) end

---@param settings LvglHlineSettings
---@return LvglObject
function LvglObject:hline(settings) end

---@param settings LvglVlineSettings
---@return LvglObject
function LvglObject:vline(settings) end

---@param settings LvglLineSettings
---@return LvglObject
function LvglObject:line(settings) end

---@param settings LvglTriangleSettings
---@return LvglObject
function LvglObject:triangle(settings) end

---@param settings LvglCircleSettings
---@return LvglObject
function LvglObject:circle(settings) end

---@param settings LvglArcSettings
---@return LvglObject
function LvglObject:arc(settings) end

---@param settings LvglImageSettings
---@return LvglObject
function LvglObject:image(settings) end

---@param settings LvglQrcodeSettings
---@return LvglObject
function LvglObject:qrcode(settings) end

---@param settings LvglSourceSettings
---@return LvglObject
function LvglObject:source(settings) end

---@param settings LvglSwitchSettings
---@return LvglObject
function LvglObject:switch(settings) end

function LvglObject:show() end
function LvglObject:hide() end
function LvglObject:enable() end
function LvglObject:disable() end
function LvglObject:close() end
function LvglObject:clear() end

---@param tree table[]
---@return table
function LvglObject:build(tree) end

---@param settings table
function LvglObject:set(settings) end

---@return integer x
---@return integer y
function LvglObject:getScrollPos() end

-- ==========================================================================
-- Common settings (inherited by all widgets via LvglWidgetObjectBase)
-- ==========================================================================

---@class LvglCommonSettings
---@field x? integer X position (or PERCENT_SIZE+N for percentage)
---@field y? integer Y position
---@field w? integer Width (0 = auto size to fit content, or PERCENT_SIZE+N)
---@field h? integer Height (0 = auto size to fit content, or PERCENT_SIZE+N)
---@field color? integer|fun():integer Primary color
---@field opacity? integer|fun():integer 0-255
---@field visible? fun():boolean Dynamic visibility
---@field size? fun(w: integer, h: integer): integer, integer Dynamic size callback
---@field pos? fun(): integer, integer Dynamic position callback

-- ==========================================================================
-- Page
-- ==========================================================================

--- Full-screen page layout with header bar, title, and optional navigation.
---@class LvglPageSettings
---@field title? string|fun():string Header title text
---@field subtitle? string|fun():string Header subtitle text
---@field icon? string Path to 30x30 grayscale mask image
---@field back? fun() Called on back button / RTN key
---@field menu? fun() Called on menu button
---@field prevButton? {press: fun(), active?: fun():boolean}
---@field nextButton? {press: fun(), active?: fun():boolean}
---@field backButton? boolean Show exit/back button in header right
---@field flexFlow? integer FLOW_ROW or FLOW_COLUMN
---@field flexPad? integer Padding between flex items
---@field scrollBar? boolean
---@field scrollDir? integer SCROLL_OFF, SCROLL_HOR, SCROLL_VER, SCROLL_ALL
---@field scrolled? fun(x: integer, y: integer)
---@field scrollTo? fun(): integer, integer
---@field align? integer Flex layout alignment (LEFT, CENTER, RIGHT, VTOP, VCENTER, VBOTTOM)
---@field borderPad? integer|{left?: integer, right?: integer, top?: integer, bottom?: integer}
---@field active? fun():boolean

-- ==========================================================================
-- Dialog
-- ==========================================================================

--- Modal dialog with a title bar and close button.
---@class LvglDialogSettings : LvglCommonSettings
---@field title? string|fun():string
---@field flexFlow? integer
---@field flexPad? integer
---@field close? fun() Called when dialog is closed
---@field borderPad? integer|{left?: integer, right?: integer, top?: integer, bottom?: integer}
---@field active? fun():boolean

-- ==========================================================================
-- Confirm / Message popups
-- ==========================================================================

--- Yes/No confirmation dialog.
---@class LvglConfirmSettings
---@field title? string|fun():string
---@field message? string
---@field confirm? fun() Called when Yes is tapped
---@field cancel? fun() Called when No is tapped

--- Information message dialog.
---@class LvglMessageSettings
---@field title? string|fun():string
---@field message? string
---@field details? string Additional detail text

-- ==========================================================================
-- Menu
-- ==========================================================================

--- Popup menu for selecting from a list of options.
---@class LvglMenuSettings
---@field title? string|fun():string
---@field values? string[] List of menu item strings
---@field get? fun():integer Current selection index (1-based)
---@field set? fun(index: integer) Selection changed

-- ==========================================================================
-- Label
-- ==========================================================================

--- Display a text label.
---@class LvglLabelSettings : LvglCommonSettings
---@field text? string|fun():string
---@field font? integer|fun():integer Font flag (BOLD, SMLSIZE, MIDSIZE, DBLSIZE, etc.)
---@field align? integer|fun():integer Text alignment (LEFT, CENTER, RIGHT, VCENTER, etc.)
---@field children? table[]

-- ==========================================================================
-- Rectangle
-- ==========================================================================

--- Display a rectangle (outline or filled).
---@class LvglRectangleSettings : LvglCommonSettings
---@field thickness? integer Border thickness (0 = invisible border)
---@field filled? boolean|fun():boolean
---@field rounded? integer Corner radius (must be >= thickness if > 0)
---@field flexFlow? integer
---@field flexPad? integer
---@field borderPad? integer|{left?: integer, right?: integer, top?: integer, bottom?: integer}
---@field align? integer|fun():integer
---@field scrollBar? boolean
---@field scrollDir? integer
---@field scrolled? fun(x: integer, y: integer)
---@field scrollTo? fun(): integer, integer
---@field active? fun():boolean
---@field children? table[]

-- ==========================================================================
-- Box (layout container)
-- ==========================================================================

--- Invisible container for managing child layout.
---@class LvglBoxSettings : LvglCommonSettings
---@field flexFlow? integer FLOW_ROW or FLOW_COLUMN
---@field flexPad? integer Padding between flex items
---@field borderPad? integer|{left?: integer, right?: integer, top?: integer, bottom?: integer}
---@field align? integer|fun():integer
---@field scrollBar? boolean
---@field scrollDir? integer
---@field scrolled? fun(x: integer, y: integer)
---@field scrollTo? fun(): integer, integer
---@field active? fun():boolean
---@field children? table[]

-- ==========================================================================
-- Button
-- ==========================================================================

--- Text button using the EdgeTX style.
---@class LvglButtonSettings : LvglCommonSettings
---@field text? string|fun():string
---@field font? integer|fun():integer
---@field cornerRadius? integer
---@field textColor? integer|fun():integer
---@field press? fun() Called when button is tapped
---@field longpress? fun() Called on long press
---@field checked? boolean Initial checked state
---@field active? fun():boolean

-- ==========================================================================
-- Momentary Button
-- ==========================================================================

--- Momentary button that fires on press and release.
---@class LvglMomentaryButtonSettings : LvglCommonSettings
---@field text? string|fun():string
---@field font? integer|fun():integer
---@field cornerRadius? integer
---@field textColor? integer|fun():integer
---@field press? fun() Called on press
---@field release? fun() Called on release
---@field active? fun():boolean

-- ==========================================================================
-- Toggle
-- ==========================================================================

--- Toggle switch using the EdgeTX style.
---@class LvglToggleSettings : LvglCommonSettings
---@field get? fun():integer Returns 0 or 1
---@field set? fun(value: integer) Receives 0 or 1
---@field active? fun():boolean

-- ==========================================================================
-- Text Edit
-- ==========================================================================

--- Text input field.
---@class LvglTextEditSettings : LvglCommonSettings
---@field value? string Initial text value
---@field length? integer Max text length (1-128, default 32)
---@field set? fun(value: string) Called when text is changed
---@field active? fun():boolean

-- ==========================================================================
-- Number Edit
-- ==========================================================================

--- Numeric input field with +/- adjustment.
---@class LvglNumberEditSettings : LvglCommonSettings
---@field min? integer Default -1024
---@field max? integer Default 1024
---@field get? fun():integer
---@field set? fun(value: integer) Called on user interaction
---@field edited? fun(value: integer) Called when editing is committed
---@field display? fun(value: integer):string Custom display formatting
---@field active? fun():boolean

-- ==========================================================================
-- Choice (dropdown)
-- ==========================================================================

--- Button that opens a popup menu for selecting from a list.
---@class LvglChoiceSettings : LvglCommonSettings
---@field title? string|fun():string Popup title
---@field values? string[] List of option strings
---@field get? fun():integer Current selection index (1-based)
---@field set? fun(index: integer) Selection changed (receives 1..n)
---@field filter? fun(index: integer):boolean Filter callback for available options
---@field popupWidth? integer Width of the choice popup
---@field active? fun():boolean

-- ==========================================================================
-- Slider
-- ==========================================================================

--- Horizontal slider.
---@class LvglSliderSettings : LvglCommonSettings
---@field min? integer Default 0
---@field max? integer Default 100
---@field get? fun():integer
---@field set? fun(value: integer) Called on user interaction
---@field active? fun():boolean

-- ==========================================================================
-- Setting (label + control container)
-- ==========================================================================

--- A labeled row containing a title and child controls.
---@class LvglSettingSettings : LvglCommonSettings
---@field title? string|fun():string
---@field flexFlow? integer
---@field flexPad? integer
---@field borderPad? integer|{left?: integer, right?: integer, top?: integer, bottom?: integer}
---@field active? fun():boolean
---@field children? table[]

-- ==========================================================================
-- Source selector
-- ==========================================================================

--- Source picker control.
---@class LvglSourceSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field filter? integer Bitmask of SRC_* constants
---@field active? fun():boolean

-- ==========================================================================
-- Switch selector
-- ==========================================================================

--- Switch picker control.
---@class LvglSwitchSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field filter? integer Bitmask of SW_* constants
---@field active? fun():boolean

-- ==========================================================================
-- File picker
-- ==========================================================================

--- File selection control.
---@class LvglFileSettings : LvglCommonSettings
---@field title? string|fun():string
---@field folder? string Folder path
---@field extension? string File extension filter
---@field maxLen? integer Maximum filename length
---@field hideExtension? boolean Hide extension in display
---@field get? fun():string
---@field set? fun(value: string)
---@field active? fun():boolean

-- ==========================================================================
-- Font picker
-- ==========================================================================

--- Font selection control.
---@class LvglFontSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field active? fun():boolean

-- ==========================================================================
-- Align picker
-- ==========================================================================

--- Alignment selection control.
---@class LvglAlignSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field active? fun():boolean

-- ==========================================================================
-- Color picker
-- ==========================================================================

--- Color selection control.
---@class LvglColorSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field active? fun():boolean

-- ==========================================================================
-- Timer picker
-- ==========================================================================

--- Timer selection control.
---@class LvglTimerSettings : LvglCommonSettings
---@field get? fun():integer
---@field set? fun(value: integer)
---@field active? fun():boolean

-- ==========================================================================
-- Geometry primitives
-- ==========================================================================

--- Horizontal line.
---@class LvglHlineSettings : LvglCommonSettings
---@field thickness? integer
---@field rounded? boolean Round end caps
---@field dashGap? integer Gap size for dashed lines
---@field dashWidth? integer Dash size for dashed lines

--- Vertical line.
---@class LvglVlineSettings : LvglCommonSettings
---@field thickness? integer
---@field rounded? boolean Round end caps
---@field dashGap? integer
---@field dashWidth? integer

--- One or more connected line segments.
---@class LvglLineSettings : LvglCommonSettings
---@field pts? table|fun():table Array of {x, y} points (at least 2)
---@field thickness? integer
---@field rounded? boolean Round end caps

--- Filled triangle defined by 3 points.
---@class LvglTriangleSettings : LvglCommonSettings
---@field pts? table|fun():table Array of 3 {x, y} points

--- Circle (outline or filled).
---@class LvglCircleSettings : LvglCommonSettings
---@field radius? integer|fun():integer
---@field filled? boolean|fun():boolean
---@field thickness? integer

--- Arc segment with optional background arc.
---@class LvglArcSettings : LvglCommonSettings
---@field radius? integer|fun():integer
---@field thickness? integer
---@field rounded? boolean Round arc ends
---@field startAngle? integer|fun():integer Degrees (0=right/3 o'clock, clockwise)
---@field endAngle? integer|fun():integer
---@field bgColor? integer|fun():integer Background arc color
---@field bgOpacity? integer|fun():integer Background arc opacity (0-255)
---@field bgStartAngle? integer|fun():integer
---@field bgEndAngle? integer|fun():integer

--- Display an image from the SD card.
---@class LvglImageSettings : LvglCommonSettings
---@field file? string|fun():string Full path to image file
---@field fill? boolean Scale to fill parent frame (may crop)
---@field active? fun():boolean

--- Display a QR code.
---@class LvglQrcodeSettings : LvglCommonSettings
---@field data? string URL or content to encode
---@field bgColor? integer Background (light) color

-- ==========================================================================
-- lvgl module
-- ==========================================================================

---@class lvgl
lvgl = {}

--- Remove all LVGL objects, or only children of a specific object.
---@param obj? LvglObject
function lvgl.clear(obj) end

--- Build a widget tree from a declarative table.
---@param tree table[]
---@return table
function lvgl.build(tree) end

--- Check if the current script is running in app mode (One-Time script).
---@return boolean
function lvgl.isAppMode() end

--- Check if the widget is running in full-screen mode.
---@return boolean
function lvgl.isFullScreen() end

--- Exit full-screen widget mode.
function lvgl.exitFullScreen() end

--- Get the current widget context table.
---@return table context
function lvgl.getContext() end

--- Update properties of an existing LVGL object.
---@param obj LvglObject
---@param settings table
function lvgl.set(obj, settings) end

--- Show an LVGL object.
---@param obj LvglObject
function lvgl.show(obj) end

--- Hide an LVGL object.
---@param obj LvglObject
function lvgl.hide(obj) end

--- Enable an LVGL object (restore interactivity).
---@param obj LvglObject
function lvgl.enable(obj) end

--- Disable an LVGL object (grey out, prevent interaction).
---@param obj LvglObject
function lvgl.disable(obj) end

--- Close and destroy an LVGL object.
---@param obj LvglObject
function lvgl.close(obj) end

--- Get the scroll position of an LVGL object.
---@param obj LvglObject
---@return integer x
---@return integer y
function lvgl.getScrollPos(obj) end

-- Widget creation functions

---@param settings LvglPageSettings
---@return LvglObject
function lvgl.page(settings) end

---@param parent_or_settings LvglObject|LvglDialogSettings
---@param settings? LvglDialogSettings
---@return LvglObject
function lvgl.dialog(parent_or_settings, settings) end

---@param settings LvglConfirmSettings
---@return LvglObject
function lvgl.confirm(settings) end

---@param settings LvglMessageSettings
---@return LvglObject
function lvgl.message(settings) end

---@param settings LvglMenuSettings
---@return LvglObject
function lvgl.menu(settings) end

---@param parent_or_settings LvglObject|LvglLabelSettings
---@param settings? LvglLabelSettings
---@return LvglObject
function lvgl.label(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglRectangleSettings
---@param settings? LvglRectangleSettings
---@return LvglObject
function lvgl.rectangle(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglBoxSettings
---@param settings? LvglBoxSettings
---@return LvglObject
function lvgl.box(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglButtonSettings
---@param settings? LvglButtonSettings
---@return LvglObject
function lvgl.button(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglMomentaryButtonSettings
---@param settings? LvglMomentaryButtonSettings
---@return LvglObject
function lvgl.momentaryButton(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglToggleSettings
---@param settings? LvglToggleSettings
---@return LvglObject
function lvgl.toggle(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglTextEditSettings
---@param settings? LvglTextEditSettings
---@return LvglObject
function lvgl.textEdit(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglNumberEditSettings
---@param settings? LvglNumberEditSettings
---@return LvglObject
function lvgl.numberEdit(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglChoiceSettings
---@param settings? LvglChoiceSettings
---@return LvglObject
function lvgl.choice(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglSliderSettings
---@param settings? LvglSliderSettings
---@return LvglObject
function lvgl.slider(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglSliderSettings
---@param settings? LvglSliderSettings
---@return LvglObject
function lvgl.verticalSlider(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglSettingSettings
---@param settings? LvglSettingSettings
---@return LvglObject
function lvgl.setting(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglSourceSettings
---@param settings? LvglSourceSettings
---@return LvglObject
function lvgl.source(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglSwitchSettings
---@param settings? LvglSwitchSettings
---@return LvglObject
function lvgl.switch(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglFileSettings
---@param settings? LvglFileSettings
---@return LvglObject
function lvgl.file(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglFontSettings
---@param settings? LvglFontSettings
---@return LvglObject
function lvgl.font(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglAlignSettings
---@param settings? LvglAlignSettings
---@return LvglObject
function lvgl.align(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglColorSettings
---@param settings? LvglColorSettings
---@return LvglObject
function lvgl.color(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglTimerSettings
---@param settings? LvglTimerSettings
---@return LvglObject
function lvgl.timer(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglHlineSettings
---@param settings? LvglHlineSettings
---@return LvglObject
function lvgl.hline(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglVlineSettings
---@param settings? LvglVlineSettings
---@return LvglObject
function lvgl.vline(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglLineSettings
---@param settings? LvglLineSettings
---@return LvglObject
function lvgl.line(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglTriangleSettings
---@param settings? LvglTriangleSettings
---@return LvglObject
function lvgl.triangle(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglCircleSettings
---@param settings? LvglCircleSettings
---@return LvglObject
function lvgl.circle(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglArcSettings
---@param settings? LvglArcSettings
---@return LvglObject
function lvgl.arc(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglImageSettings
---@param settings? LvglImageSettings
---@return LvglObject
function lvgl.image(parent_or_settings, settings) end

---@param parent_or_settings LvglObject|LvglQrcodeSettings
---@param settings? LvglQrcodeSettings
---@return LvglObject
function lvgl.qrcode(parent_or_settings, settings) end

-- ==========================================================================
-- LVGL constants
-- ==========================================================================

-- Layout flow
---@type integer
lvgl.FLOW_ROW = 0
---@type integer
lvgl.FLOW_COLUMN = 0

-- Padding presets
---@type integer
lvgl.PAD_TINY = 0
---@type integer
lvgl.PAD_SMALL = 0
---@type integer
lvgl.PAD_MEDIUM = 0
---@type integer
lvgl.PAD_LARGE = 0
---@type integer
lvgl.PAD_OUTLINE = 0
---@type integer
lvgl.PAD_BORDER = 0

-- Source filter bitmask constants
---@type integer
lvgl.SRC_ALL = 0
---@type integer
lvgl.SRC_INPUT = 0
---@type integer
lvgl.SRC_LUA = 0
---@type integer
lvgl.SRC_STICK = 0
---@type integer
lvgl.SRC_POT = 0
---@type integer
lvgl.SRC_OTHER = 0
---@type integer
lvgl.SRC_HELI = 0
---@type integer
lvgl.SRC_TRIM = 0
---@type integer
lvgl.SRC_SWITCH = 0
---@type integer
lvgl.SRC_LOGICAL_SWITCH = 0
---@type integer
lvgl.SRC_TRAINER = 0
---@type integer
lvgl.SRC_CHANNEL = 0
---@type integer
lvgl.SRC_GVAR = 0
---@type integer
lvgl.SRC_TELEM = 0
---@type integer
lvgl.SRC_CLEAR = 0
---@type integer
lvgl.SRC_INVERT = 0

-- Switch filter bitmask constants
---@type integer
lvgl.SW_ALL = 0
---@type integer
lvgl.SW_SWITCH = 0
---@type integer
lvgl.SW_TRIM = 0
---@type integer
lvgl.SW_LOGICAL_SWITCH = 0
---@type integer
lvgl.SW_TELEM = 0
---@type integer
lvgl.SW_OTHER = 0
---@type integer
lvgl.SW_CLEAR = 0

-- Scroll direction constants
---@type integer
lvgl.SCROLL_OFF = 0
---@type integer
lvgl.SCROLL_HOR = 0
---@type integer
lvgl.SCROLL_VER = 0
---@type integer
lvgl.SCROLL_ALL = 0

-- Layout helper constants
---@type integer
lvgl.PERCENT_SIZE = 0
---@type integer
lvgl.PAGE_BODY_HEIGHT = 0
---@type integer
lvgl.UI_ELEMENT_HEIGHT = 0
---@type number
lvgl.LCD_SCALE = 0.0

-- Widget type constants (for use in build() tables)
---@type integer
lvgl.LABEL = 0
---@type integer
lvgl.RECTANGLE = 0
---@type integer
lvgl.CIRCLE = 0
---@type integer
lvgl.ARC = 0
---@type integer
lvgl.HLINE = 0
---@type integer
lvgl.VLINE = 0
---@type integer
lvgl.LINE = 0
---@type integer
lvgl.TRIANGLE = 0
---@type integer
lvgl.IMAGE = 0
---@type integer
lvgl.QRCODE = 0
---@type integer
lvgl.BOX = 0
---@type integer
lvgl.BUTTON = 0
---@type integer
lvgl.MOMENTARY_BUTTON = 0
---@type integer
lvgl.TOGGLE = 0
---@type integer
lvgl.TEXT_EDIT = 0
---@type integer
lvgl.NUMBER_EDIT = 0
---@type integer Typo in C++ source, kept for compatibility
lvgl.CHOIDE = 0
---@type integer
lvgl.CHOICE = 0
---@type integer
lvgl.SLIDER = 0
---@type integer
lvgl.VERTICAL_SLIDER = 0
---@type integer
lvgl.PAGE = 0
---@type integer
lvgl.FONT = 0
---@type integer
lvgl.ALIGN = 0
---@type integer
lvgl.COLOR = 0
---@type integer
lvgl.TIMER = 0
---@type integer
lvgl.SWITCH = 0
---@type integer
lvgl.SOURCE = 0
---@type integer
lvgl.FILE = 0
---@type integer
lvgl.SETTING = 0
