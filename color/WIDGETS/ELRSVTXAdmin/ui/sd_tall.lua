---------------------------------------------------------------------------
-- VTX Administrator Widget - UI for 480x320 (SD Tall)                   --
-- TX16S, TX16S MAX, TX16S Mark II                                       --
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

-- Breakpoints: absolute pixel values for 480x320.
-- 48px taller than 480x272 so widget zones are proportionally taller.
WidgetUI.breakpoints = {
  topBarW  = 100,
  sixthH   = 50,
  quarterH = 62,
  thirdH   = 118,
  halfH    = 147,
}

WidgetUI.fonts = {
  sixth   = { status = BOLD },
  quarter = { status = BOLD },
  third   = { status = BOLD },
  half    = { hero = MIDSIZE, detail = SMLSIZE },
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


-- ============================================================================
-- Minimized layout builders (by widget height tier)
-- ============================================================================

local TopBarUI = loadScript("/WIDGETS/ELRSVTXAdmin/ui/topbar.lua")({
  Protocol = Protocol, VTX = VTX,
})

--- 1/6: single row. Wide: band + detail + cheatsheet. Narrow: band + detail.
--- Fixed-width band column prevents layout jumping when values change.
--- Status text (loading/error/off) uses unconstrained label for narrow columns.
function WidgetUI.buildSixth(w, h, opa)
  local wide = w > 200
  local c1w = math.floor(w * 0.22)
  local columns = {
    { type = "label", color = VTXDisplay.mainColor, font = BOLD,
      text = VTXDisplay.statusText, visible = VTXDisplay.showStatus },
    { type = "label", w = c1w, color = VTXDisplay.mainColor,
      font = WidgetUI.fonts.sixth.status, text = VTXDisplay.bandChannel,
      visible = VTXDisplay.showChannel },
    { type = "label", font = SMLSIZE,
      color = COLOR_THEME_SECONDARY1, text = VTXDisplay.detailLine },
  }
  if wide then
    local labels = VTXDisplay.build6posLabels()
    for _, lbl in ipairs(labels) do
      columns[#columns + 1] = lbl
    end
  end

  WidgetLayout.row(w, h, opa, columns)
end

--- 1/4: two rows. Row 1: band + power (+ pit mode when wide). Row 2: cheatsheet.
--- Fixed-width band column prevents layout jumping when values change.
--- Status text (loading/error/off) uses unconstrained label for narrow columns.
function WidgetUI.buildQuarter(w, h, opa)
  local wide = w > 200
  local c1w = math.floor(w * 0.22)
  local row1 = {
    { type = "label", w = c1w, align = LEFT, text = VTXDisplay.bandChannel,
      color = VTXDisplay.mainColor, font = WidgetUI.fonts.quarter.status },
    { type = "label", font = WidgetUI.fonts.quarter.status, align = LEFT,
        text = VTXDisplay.powerShort,
      color = COLOR_THEME_SECONDARY1 },
  }
  if wide then
    row1[#row1 + 1] = {
      type = "label", font = SMLSIZE, align = LEFT,
      color = pitModeColor,
      text = pitModeText,
    }
  end
  local rows = {
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, visible = VTXDisplay.showChannel,
      children = row1 },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end
  WidgetLayout.column(w, h, opa, rows)
end

--- 1/3: three rows — title, band + detail, cheatsheet.
--- 480x320 has enough room for a title row.
--- Fixed-width band column prevents layout jumping when values change.
--- Status text (loading/error/off) uses unconstrained label for narrow columns.
function WidgetUI.buildThird(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {}
  -- Title row — 480x320 has more vertical room than 480x272
  rows[#rows + 1] = {
    type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1,
  }
  rows[#rows + 1] = {
    type = "label", align = LEFT, text = VTXDisplay.statusText,
    color = VTXDisplay.mainColor, font = BOLD,
    visible = VTXDisplay.showStatus,
  }
  rows[#rows + 1] = {
    type = "box", w = w, flexFlow = lvgl.FLOW_ROW, borderPad = 0, flexPad = lvgl.PAD_TINY,
    align = LEFT + VCENTER, visible = VTXDisplay.showChannel,
    children = {
      { type = "label", w = c1w, align = LEFT, text = VTXDisplay.bandChannel,
        color = VTXDisplay.mainColor, font = WidgetUI.fonts.third.status },
      { type = "label", font = SMLSIZE, align = LEFT, text = VTXDisplay.detailLine,
        color = COLOR_THEME_SECONDARY1 },
    },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- 1/2: title + band/status + detail + cheatsheet.
function WidgetUI.buildHalf(w, h, opa)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "label", align = LEFT, text = VTXDisplay.bandChannel,
      color = VTXDisplay.mainColor, font = WidgetUI.fonts.half.hero,
      visible = VTXDisplay.showChannel },
    { type = "label", font = SMLSIZE, align = LEFT,
      text = VTXDisplay.detailLong,
      color = COLOR_THEME_SECONDARY1 },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- 1/1: title + band/status + detail + cheatsheet.
function WidgetUI.buildFull(w, h, opa)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "label", align = LEFT, text = VTXDisplay.bandChannel,
      color = VTXDisplay.mainColor, font = WidgetUI.fonts.full.hero,
      visible = VTXDisplay.showChannel },
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
