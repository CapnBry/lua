-- ELRS Config Tool (EdgeTX 2.11+ LVGL)
-- Requires useLvgl = true and a color radio

local CRSF = loadScript("/SCRIPTS/ELRS/crsf.lua")()

local targetIdx   = 1                 -- 1 = Transmitter, 2 = Receiver
local bindPhrase  = ""
local uidText     = ""

local MSP_ELRS_RXTX_CONFIG = 45
local ELRS_RXTX_SUBCMD_UID = 0
local ELRS_RXTX_SUBCMD_BIND_PHRASE = 1

local Defer = { _deferCb = nil }

function Defer.setTimeout(interval, fn, ctx)
  Defer._deferCb = {
    start = getTime(),
    interval = interval,
    fn = fn,
    ctx = ctx,
  }
end

function Defer.clear()
  Defer._deferCb = nil
end

function Defer.poll()
  if Defer._deferCb == nil then return end

  if getTime() - Defer._deferCb.start < Defer._deferCb.interval then
    return
  end

  -- clear the defer first, if the callback wants to set a new one
  local oldcb = Defer._deferCb
  Defer._deferCb = nil
  oldcb.fn(oldcb.ctx)
end

local History = {
  MAX = 5,
  FNAME = "elrs-phrase.txt",
  vals = {},
}

function History.add(s)
  if s == nil or s == "" then return end

  -- remove this value from the history list if already there
  for idx = #History.vals, 1, -1 do
    if History.vals[idx] == s then
      table.remove(History.vals, idx)
    end
  end

  table.insert(History.vals, 1, s)

  while #History.vals > History.MAX do
    table.remove(History.vals)
  end

  local f = io.open(History.FNAME, "w")
  if f == nil then return end
  io.write(f, table.concat(History.vals, '\n'))
  io.close(f)
end

function History.load()
  local f = io.open(History.FNAME, "r")
  if f == nil then return end

  History.vals = {}
  local all = io.read(f, 64 * History.MAX)
  io.close(f)

  if all == nil or all == "" then return end

  for line in string.gmatch(all, "[^\n]+") do
    History.vals[#History.vals + 1] = line
  end

  return History.vals[1]
end

local function onMspResponse(data)
  if data[1] == CRSF.CONST.ADDRESS_RADIO_TRANSMITTER
    and (data[2] == CRSF.CONST.ADDRESS_RX or data[2] == CRSF.CONST.ADDRESS_TX_MODULE) then
    local mspCmd = data[5]

    if mspCmd == MSP_ELRS_RXTX_CONFIG and data[6] == ELRS_RXTX_SUBCMD_UID then
      Defer.clear()
      local rxTx = (data[2] == CRSF.CONST.ADDRESS_RX) and "RX" or "TX"
      uidText = string.format("%s: %d, %d, %d, %d, %d, %d",
          rxTx, data[7], data[8], data[9], data[10], data[11], data[12])
    end
  end
end

local function requestUid()
  uidText = "Updating..."

  CRSF.push(CRSF.CONST.FRAMETYPE_MSP_REQ, {
    (targetIdx == 1) and CRSF.CONST.ADDRESS_TX_MODULE or CRSF.CONST.ADDRESS_RX,
    CRSF.CONST.ADDRESS_RADIO_TRANSMITTER,
    0x30,
    0x01,
    MSP_ELRS_RXTX_CONFIG,
    ELRS_RXTX_SUBCMD_UID,
  })

  -- Retry if no response
  Defer.setTimeout(50, requestUid)
end

local function sendBindphrase()
  if bindPhrase == "" then return end

  local rxTx = (targetIdx == 1) and "Transmitter" or "Receiver"
  uidText = "Setting " .. rxTx .. "..."

  local data = {
    (targetIdx == 1) and CRSF.CONST.ADDRESS_TX_MODULE or CRSF.CONST.ADDRESS_RX,
    CRSF.CONST.ADDRESS_RADIO_TRANSMITTER,
    0x30,
    0x01 + #bindPhrase,
    MSP_ELRS_RXTX_CONFIG,
    ELRS_RXTX_SUBCMD_BIND_PHRASE,
  }

  -- append the phrase as bytes
  for i = 1, #bindPhrase do data[#data+1] = string.byte(bindPhrase, i) end

  CRSF.push(CRSF.CONST.FRAMETYPE_MSP_WRITE, data)

  History.add(bindPhrase)
  -- refresh the UID in 1000ms
  Defer.setTimeout(100, requestUid)
end

local rebuildUi
local function history_text(id)
  return History.vals[id]
end
local function history_visible(id)
  return history_text(id) ~= nil
end
local function history_press(id)
  bindPhrase = History.vals[id]
  rebuildUi()
end

rebuildUi = function()
  lvgl.clear()

  local pg = lvgl.page({
    title    = "ExpressLRS Bind Phrase",
    subtitle = function() return uidText end,
  })

  local tbox = pg:box({
    w = lvgl.PERCENT_SIZE + 100,
    flexFlow = lvgl.FLOW_COLUMN,
  })

  -- ***** Bind Phrase label + text edit + Set button *****
  tbox:setting({
    w = lvgl.PERCENT_SIZE + 100,
    title = "Bind Phrase",
    children = {
      {
        type = lvgl.BOX,
        x = 120,
        flexFlow = lvgl.FLOW_ROW,
        flexPad = lvgl.PAD_MEDIUM,
        children = {
          {
            type = lvgl.TEXT_EDIT,
            w = 240,
            value = bindPhrase,
            length = 52, -- packet is only so big and can't span
            set = function(v) bindPhrase = v end,
          },
          {
            type = lvgl.BUTTON,
            text = "Set",
            press = sendBindphrase,
          },
        },
      },
    },
  })

  -- ***** Target label + dropdown + Request UID button *****
  tbox:setting({
    w = lvgl.PERCENT_SIZE + 100,
    title = "Target",
    children = {
      {
        type  = lvgl.BOX,
        x = 120,
        flexFlow = lvgl.FLOW_ROW,
        flexPad = lvgl.PAD_MEDIUM,
        children = {
          {
            type = lvgl.CHOICE,
            title = "Select Target",
            values = {"Transmitter", "Receiver"},
            get = function() return targetIdx end,
            set = function(n) targetIdx = n end,
          },
          {
            type = lvgl.BUTTON,
            text = "Request UID",
            press = requestUid,
          },
        },
      },
    },
  })

  -- ***** Bind Phrase History *****
  local row = pg:box({
    w = lvgl.PERCENT_SIZE + 100, y = 82,
    flexFlow = lvgl.FLOW_COLUMN,
    flexPad = lvgl.PAD_MEDIUM,
    visible = function () return #History.vals end,
  })
  row:label({text = "Bind Phrase History"})
   for i = 1, History.MAX do
      row:button({
        w = lvgl.PERCENT_SIZE + 80,
        text = function () return history_text(i) end,
        visible = function () return history_visible(i) end,
        press = function () return history_press(i) end,
      })
  end
end

local function init()
  if lvgl == nil then return end

  bindPhrase = History.load() or ""
  rebuildUi()

  CRSF:registerHandler(CRSF.CONST.FRAMETYPE_MSP_RESP, onMspResponse)
  Defer.setTimeout(1, requestUid)
end

local function run(event, touchState)
  if lvgl == nil then
    lcd.drawText(0, 0, "LVGL (EdgeTX 2.11+) required", COLOR_THEME_WARNING)
    return 0
  end

  CRSF:poll()
  -- Must come after poll so a telemetry queue is established
  Defer.poll()

  return 0
end

return { init = init, run = run, useLvgl = true }
