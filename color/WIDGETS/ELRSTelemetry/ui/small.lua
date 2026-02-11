---------------------------------------------------------------------------
-- ELRS Telemetry Widget - UI for 320x240 (Small)                       --
-- Small color LCD (PA01)                                               --
---------------------------------------------------------------------------

local ctx = ...
local Telemetry = ctx.Telemetry
local crsf = ctx.crsf
local bgOpacity = ctx.bgOpacity
local WidgetLayout = ctx.WidgetLayout

local WidgetUI = {}

-- Breakpoints: absolute pixel values for 320x240.
-- Smallest color screen — everything is compact.
WidgetUI.breakpoints = {
  topBarW  = 80,
  tinyH    = 30,
  smallH   = 42,
  thirdH   = 58,
}

WidgetUI.fonts = {
  tiny   = { hero = BOLD },
  small  = { hero = BOLD },
  third  = { hero = BOLD, detail = SMLSIZE },
  normal = { hero = MIDSIZE, detail = SMLSIZE },
}

-- ============================================================================
-- Minimized display helpers
-- ============================================================================

local function heroColorMismatch()
  if crsf.modelMismatch then
    return RED
  end
  return COLOR_THEME_PRIMARY1
end

local function detailColor()
  if not crsf.rxConnected then
    return COLOR_THEME_SECONDARY1
  end
  return Telemetry.rangeColor(Telemetry.smoothRng or 0)
end

local function heroTextLq()
  local status = Telemetry.statusText()
  if status then
    return status
  end
  local tlm = Telemetry.readLink()
  return table.concat({"LQ ", tostring(tlm.rqly or 0), "%"})
end

-- ============================================================================
-- Minimized layout builders (by widget height tier)
-- ============================================================================

local TopBarUI = loadScript("/WIDGETS/ELRSTelemetry/ui/topbar.lua")({
  crsf = crsf, Telemetry = Telemetry,
})

--- Tiny: single compact line — LQ (bold) + Range/dBm (colored) + RF mode (neutral).
--- Fixed-width columns prevent layout jumping when digit counts change.
function WidgetUI.buildTiny(w, h, opa)
  local c1w = math.floor(w * 0.28)
  local c2w = math.floor(w * 0.40)
  local c3w = w - c1w - c2w
  local columns = {
    { type = "box", w = c1w, h = lvgl.UI_ELEMENT_HEIGHT, children = {
      { type = "label", y = lvgl.PAD_SMALL, font = BOLD,
        color = heroColorMismatch,
        text = heroTextLq },
    }},
    { type = "box", w = c2w, h = lvgl.UI_ELEMENT_HEIGHT, children = {
      { type = "label", y = lvgl.PAD_SMALL, font = SMLSIZE, color = detailColor,
        text = Telemetry.signalText },
    }},
    { type = "box", w = c3w, h = lvgl.UI_ELEMENT_HEIGHT, children = {
      { type = "label", y = lvgl.PAD_SMALL, font = SMLSIZE, color = COLOR_THEME_SECONDARY1,
        text = function()
          local tlm = Telemetry.readLink()
          return Telemetry.getRfModeStr(tlm.rfmd)
        end },
    }},
  }
  WidgetLayout.row(w, h, opa, columns)
end

--- Small: LQ + Range/dBm on row 1, RF mode + Power on row 2.
--- Fixed-width first column prevents layout jumping when digit counts change.
function WidgetUI.buildSmall(w, h, opa)
  local c1w = math.floor(w * 0.30)
  local rows = {
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY, align = LEFT + VCENTER, children = {
      { type = "label", w = c1w, font = BOLD, align = LEFT,
        color = heroColorMismatch,
        text = heroTextLq },
      { type = "label", font = SMLSIZE, align = LEFT, color = detailColor,
        text = Telemetry.signalText },
    }},
    { type = "box", w = w, flexFlow = lvgl.FLOW_ROW, flexPad = lvgl.PAD_TINY, align = LEFT, children = {
      { type = "label", font = SMLSIZE, align = LEFT, color = COLOR_THEME_SECONDARY1,
        text = Telemetry.rfDetailText },
    }},
  }
  WidgetLayout.column(w, h, opa, rows)
end

--- 1/3: hero LQ + Range/RSSI detail + RF mode. No title on small screen.
function WidgetUI.buildThird(w, h, opa)
  local rows = {}
  -- No title row — too tight on 320x240
  rows[#rows + 1] = {
    type = "label", font = WidgetUI.fonts.third.hero, align = LEFT,
    color = heroColorMismatch,
    text = heroTextLq,
  }
  rows[#rows + 1] = {
    type = "label", font = WidgetUI.fonts.third.detail, align = LEFT,
    color = detailColor,
    text = Telemetry.signalText,
  }
  rows[#rows + 1] = {
    type = "label", font = SMLSIZE, align = LEFT,
    color = COLOR_THEME_SECONDARY1,
    text = Telemetry.rfDetailText,
  }

  WidgetLayout.column(w, h, opa, rows)
end

--- Normal: full telemetry display with title.
function WidgetUI.buildNormal(w, h, opa)
  local rows = {
    { type = "label", font = BOLD, text = "ExpressLRS", color = COLOR_THEME_SECONDARY1, align = LEFT },
    { type = "label", align = LEFT,
      color = heroColorMismatch,
      font = function()
        if Telemetry.statusText() then
          return BOLD
        end
        return MIDSIZE
      end,
      text = heroTextLq },
    { type = "label", font = WidgetUI.fonts.normal.detail, align = LEFT,
      color = detailColor,
      text = Telemetry.signalText },
    { type = "label", font = SMLSIZE, align = LEFT,
      color = COLOR_THEME_SECONDARY1,
      text = Telemetry.rfDetailText },
    { type = "label", font = SMLSIZE, align = LEFT, color = COLOR_THEME_PRIMARY3,
      text = function()
        local vbat = crsf.getSensorValue("RxBt")
        if vbat == nil or vbat <= 0 then
          return ""
        end
        Telemetry.checkCellCount(vbat)
        local cells = Telemetry.cellCnt
        if cells then
          return string.format("Bat %dS %.2fV", cells, vbat / cells)
        end
        return string.format("Bat %.2fV", vbat)
      end },
  }
  WidgetLayout.column(w, h, opa, rows)
end

--- Route to the appropriate minimized layout based on widget dimensions.
function WidgetUI.build(wgtZone, opts)
  lvgl.clear()
  local w, h = wgtZone.w, wgtZone.h
  local opa = bgOpacity(opts)
  local bp = WidgetUI.breakpoints
  if     w < bp.topBarW then TopBarUI.build(w, h)
  elseif h < bp.tinyH   then WidgetUI.buildTiny(w, h, opa)
  elseif h < bp.smallH  then WidgetUI.buildSmall(w, h, opa)
  elseif h < bp.thirdH  then WidgetUI.buildThird(w, h, opa)
  else                        WidgetUI.buildNormal(w, h, opa)
  end
end

return WidgetUI
