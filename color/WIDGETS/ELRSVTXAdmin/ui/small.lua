---------------------------------------------------------------------------
-- VTX Administrator Widget - UI for 320x240 (Small)                     --
-- Small color LCD (PA01)                                                --
---------------------------------------------------------------------------

local ctx = ...
local VTX = ctx.VTX
local Protocol = ctx.Protocol
local Presets = ctx.Presets
local crsf = ctx.crsf
local bgOpacity = ctx.bgOpacity
local VTXDisplay = ctx.VTXDisplay
local WidgetLayout = ctx.WidgetLayout

local WidgetUI = {}

-- Breakpoints: absolute pixel values for 320x240.
-- Smallest color screen — everything is compact.
WidgetUI.breakpoints = {
  topBarW  = 80,
  sixthH   = 38,
  quarterH = 54,
  thirdH   = 76,
  halfH    = 100,
}

WidgetUI.fonts = {
  sixth   = { status = BOLD },
  quarter = { status = BOLD },
  third   = { status = BOLD },
  half    = { hero = BOLD, detail = SMLSIZE },
  full    = { hero = MIDSIZE, detail = SMLSIZE },
}

local function pitModeColor()
  if not Protocol.isActive() or VTX.state.band == 0 then
    return COLOR_THEME_SECONDARY1
  end
  return VTX.state.pitmode and RED or COLOR_THEME_SECONDARY1
end

local function pitModeText()
  if not Protocol.isActive() or VTX.state.band == 0 then
    return ""
  end
  return VTX.state.pitmode and "Pit Mode On" or "Pit Mode Off"
end

local function pitModeTextLong()
  if not Protocol.isActive() then
    return ""
  end
  if VTX.state.band == 0 then
    return "VTX Disabled"
  end
  return VTX.state.pitmode and "Pit Mode On" or "Pit Mode Off"
end

-- ============================================================================
-- Minimized display helpers (small-screen-specific overrides)
-- ============================================================================

--- Shorter detail line for compact 320x240 screen.
local function detailLine()
  if not Protocol.isActive() then return "" end
  if VTX.state.band == 0 then return "" end
  local pwr = VTX.state.power > 0 and table.concat({"P", VTX.state.power}) or "P-"
  local pit = VTX.state.pitmode and " Pit" or ""
  return table.concat({pwr, pit})
end

-- ============================================================================
-- Minimized layout builders (by widget height tier)
-- ============================================================================

local TopBarUI = loadScript("/WIDGETS/ELRSVTXAdmin/ui/topbar.lua")({
  Protocol = Protocol, VTX = VTX,
})

--- 1/6: single row with status + power + pit mode + cheatsheet.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildSixth(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local columns = {
    { type = "label", w = c1w, color = VTXDisplay.mainColor,
      font = function() return Protocol.isActive() and WidgetUI.fonts.sixth.status or SMLSIZE end,
      text = VTXDisplay.statusLine },
    { type = "label", font = SMLSIZE, align = LEFT,
      text = VTXDisplay.powerShort,
      color = COLOR_THEME_SECONDARY1 },
    { type = "label", font = SMLSIZE, align = LEFT,
      color = pitModeColor,
      text = pitModeText },
  }
  local labels = VTXDisplay.build6posLabels()
  for _, lbl in ipairs(labels) do
    columns[#columns + 1] = lbl
  end

  WidgetLayout.row(w, h, opa, columns)
end

--- 1/4: two rows. Row 1: status + power + pit. Row 2: cheatsheet.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildQuarter(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
      { type = "label", w = c1w, align = LEFT, text = VTXDisplay.statusLine,
        color = VTXDisplay.mainColor,
        font = function() return Protocol.isActive() and WidgetUI.fonts.quarter.status or SMLSIZE end },
      { type = "label", font = SMLSIZE, align = LEFT,
        text = VTXDisplay.powerShort,
        color = COLOR_THEME_SECONDARY1 },
      { type = "label", font = SMLSIZE, align = LEFT,
        color = RED,
        text = function()
          if not Protocol.isActive() or VTX.state.band == 0 then
            return ""
          end
          return VTX.state.pitmode and "Pit" or ""
        end },
    }},
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end
  WidgetLayout.column(w, h, opa, rows)
end

--- 1/3: status + power + pit mode, cheatsheet. No title on small screen.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildThird(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {}
  -- No title row — too tight on 320x240
  rows[#rows + 1] = {
    type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
    align = LEFT + VCENTER, children = {
      { type = "label", w = c1w, align = LEFT, text = VTXDisplay.statusLine,
        color = VTXDisplay.mainColor,
        font = function() return Protocol.isActive() and WidgetUI.fonts.third.status or SMLSIZE end },
      { type = "label", font = SMLSIZE, align = LEFT,
        text = VTXDisplay.powerShort,
        color = COLOR_THEME_SECONDARY1 },
      { type = "label", font = SMLSIZE, align = LEFT,
        color = pitModeColor,
        text = pitModeText },
    },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- 1/2: title + status + detail + cheatsheet.
function WidgetUI.buildHalf(w, h, opa)
  local rows = {
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
      { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    }},
    { type = "label", align = LEFT, text = VTXDisplay.statusLine,
      color = VTXDisplay.mainColor,
      font = function() return Protocol.isActive() and WidgetUI.fonts.half.hero or 0 end },
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
      { type = "label", font = SMLSIZE, align = LEFT,
        text = VTXDisplay.powerShort,
        color = COLOR_THEME_SECONDARY1 },
      { type = "label", font = SMLSIZE, align = LEFT,
        color = pitModeColor,
        text = pitModeTextLong },
    }},
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- 1/1: title + MIDSIZE status + detail + cheatsheet.
function WidgetUI.buildFull(w, h, opa)
  local rows = {
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
      { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    }},
    { type = "label", align = LEFT, text = VTXDisplay.statusLine,
      color = VTXDisplay.mainColor,
      font = function() return Protocol.isActive() and WidgetUI.fonts.full.hero or 0 end },
    { type = "label", font = WidgetUI.fonts.full.detail, align = LEFT,
      text = VTXDisplay.detailLong,
      color = COLOR_THEME_SECONDARY1 },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- Route to the appropriate minimized layout based on widget dimensions.
function WidgetUI.build(wgtZone, opts)
  lvgl.clear()
  local w, h = wgtZone.w, wgtZone.h
  local opa = bgOpacity(opts)
  local bp = WidgetUI.breakpoints
  if     w < bp.topBarW  then TopBarUI.build(w, h)
  elseif h < bp.sixthH   then WidgetUI.buildSixth(w, h, opa)
  elseif h < bp.quarterH then WidgetUI.buildQuarter(w, h, opa)
  elseif h < bp.thirdH   then WidgetUI.buildThird(w, h, opa)
  elseif h < bp.halfH    then WidgetUI.buildHalf(w, h, opa)
  else                         WidgetUI.buildFull(w, h, opa)
  end
end

return WidgetUI
