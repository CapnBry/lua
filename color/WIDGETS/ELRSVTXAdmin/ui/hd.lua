---------------------------------------------------------------------------
-- VTX Administrator Widget - UI for 800x480 (HD)                        --
-- High definition landscape (TX16S Mark 3)                              --
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

-- Breakpoints: absolute pixel values for 800x480.
-- Reference zone heights (no deco → with deco):
--   1/6: 69→~58   1/4: 104→~87   1/3: 139→116   1/2: 209→175   3/4: 313→~262
-- Thresholds must work for both decorated and undecorated layouts.
WidgetUI.breakpoints = {
  topBarW  = 200,
  sixthH   = 78,   -- between 1/6 (~58-69) and 1/4 (~87-104)
  quarterH = 110,  -- between 1/4 (~87-104) and 1/3 (116-139)
  thirdH   = 155,  -- between 1/3 (116-139) and 1/2 (175-209)
  halfH    = 235,  -- between 1/2 (175-209) and 3/4 (~262-313)
}

WidgetUI.fonts = {
  sixth   = { status = BOLD },
  quarter = { status = BOLD },
  third   = { status = MIDSIZE },
  half    = { hero = MIDSIZE, detail = SMLSIZE },
  full    = { hero = MIDSIZE, detail = 0 },
}


-- ============================================================================
-- Minimized layout builders (by widget height tier)
-- ============================================================================

local TopBarUI = loadScript("/WIDGETS/ELRSVTXAdmin/ui/topbar.lua")({
  Protocol = Protocol, VTX = VTX,
})

--- 1/6: single row. Wide: band + detail + cheatsheet. Narrow: band + detail.
--- Fixed-width band column prevents layout jumping when values change.
--- Loading state uses unconstrained label to avoid overflow in narrow columns.
function WidgetUI.buildSixth(w, h, opa)
  local wide = w > 400
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

--- 1/4: band + power, cheatsheet.
--- Fixed-width band column prevents layout jumping when values change.
--- Loading state uses unconstrained label to avoid overflow in narrow columns.
function WidgetUI.buildQuarter(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER,
      visible = VTXDisplay.showChannel,
      children = {
      { type = "label", w = c1w, align = LEFT, text = VTXDisplay.bandChannel,
        color = VTXDisplay.mainColor, font = WidgetUI.fonts.quarter.status },
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

--- 1/3: title + band + power, cheatsheet.
--- Fixed-width band column prevents layout jumping when values change.
--- Loading state uses unconstrained label to avoid overflow in narrow columns.
function WidgetUI.buildThird(w, h, opa)
  local c1w = math.floor(w * 0.22)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY,
      align = LEFT + VCENTER,
      visible = VTXDisplay.showChannel,
      children = {
        { type = "label", w = c1w, align = LEFT, text = VTXDisplay.bandChannel,
          color = VTXDisplay.mainColor, font = WidgetUI.fonts.third.status },
        { type = "label", font = WidgetUI.fonts.third.status, align = LEFT,
          text = VTXDisplay.powerShort,
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

--- 1/2: title + MIDSIZE band + detail + cheatsheet.
function WidgetUI.buildHalf(w, h, opa)
  local rows = {
    { type = "label", font = BOLD, text = "VTX Admin", color = COLOR_THEME_SECONDARY1 },
    { type = "label", align = LEFT, text = VTXDisplay.statusText,
      color = VTXDisplay.mainColor, font = BOLD,
      visible = VTXDisplay.showStatus },
    { type = "label", align = LEFT, text = VTXDisplay.bandChannel,
      color = VTXDisplay.mainColor, font = WidgetUI.fonts.half.hero,
      visible = VTXDisplay.showChannel },
    { type = "label", font = WidgetUI.fonts.half.detail, align = LEFT,
      text = VTXDisplay.detailLong,
      color = COLOR_THEME_SECONDARY1 },
  }
  local cheatsheet = VTXDisplay.buildCheatsheet()
  if cheatsheet then
    rows[#rows + 1] = cheatsheet
  end

  WidgetLayout.column(w, h, opa, rows)
end

--- 1/1: title + DBLSIZE band + detail + cheatsheet.
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
