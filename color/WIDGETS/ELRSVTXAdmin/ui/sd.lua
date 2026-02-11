---------------------------------------------------------------------------
-- VTX Administrator Widget - UI for 480x272 (SD)                        --
-- Standard definition landscape (TX15, T15 Pro, ST16, PL18, Horus)      --
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

-- Breakpoints: absolute pixel values for 480x272.
WidgetUI.breakpoints = {
  topBarW  = 100,
  sixthH   = 50,
  quarterH = 70,
  thirdH   = 100,
  halfH    = 125,
}

WidgetUI.fonts = {
  sixth   = { status = BOLD },
  quarter = { status = BOLD },
  third   = { status = BOLD },
  half    = { hero = BOLD, detail = SMLSIZE },
  full    = { hero = MIDSIZE, detail = SMLSIZE },
}


-- ============================================================================
-- Minimized layout builders (by widget height tier)
-- ============================================================================

local TopBarUI = loadScript("/WIDGETS/ELRSVTXAdmin/ui/topbar.lua")({
  Protocol = Protocol, VTX = VTX,
})

--- 1/6: single row. Wide: status + detail + cheatsheet. Narrow: status + detail.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildSixth(w, h, opa)
  local wide = w > 200
  local c1w = math.floor(w * 0.22)
  local columns = {
    { type = "label", w = c1w, color = VTXDisplay.mainColor,
      font = function() return Protocol.isActive() and WidgetUI.fonts.sixth.status or SMLSIZE end,
      text = VTXDisplay.statusLine },
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

--- 1/4: two rows. Row 1: status + power. Row 2: cheatsheet.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildQuarter(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
      { type = "label", w = c1w, align = LEFT, text = VTXDisplay.statusLine,
        color = VTXDisplay.mainColor,
        font = function() return Protocol.isActive() and WidgetUI.fonts.quarter.status or SMLSIZE end },
      { type = "label", font = WidgetUI.fonts.quarter.status, align = LEFT,
        text = VTXDisplay.powerShort,
        color = COLOR_THEME_SECONDARY1 },
    }},
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end
  WidgetLayout.column(w, h, opa, rows)
end

--- 1/3: title + status + detail, cheatsheet.
--- Fixed-width status column prevents layout jumping when values change.
function WidgetUI.buildThird(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER, children = {
        { type = "label", w = c1w, align = LEFT, text = VTXDisplay.statusLine,
          color = VTXDisplay.mainColor,
          font = function() return Protocol.isActive() and WidgetUI.fonts.third.status or SMLSIZE end },
        { type = "label", font = SMLSIZE, align = LEFT, text = VTXDisplay.detailLine,
          color = COLOR_THEME_SECONDARY1 },
      },
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
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "label", align = LEFT, text = VTXDisplay.statusLine,
      color = VTXDisplay.mainColor,
      font = function() return Protocol.isActive() and WidgetUI.fonts.half.hero or 0 end },
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

--- 1/1: title + MIDSIZE status + detail + cheatsheet.
function WidgetUI.buildFull(w, h, opa)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
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
