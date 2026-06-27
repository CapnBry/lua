-- ELRS Config Tool (EdgeTX 2.11+ LVGL)
-- Requires useLvgl = true and a color radio

local CRSF = loadScript("/SCRIPTS/ELRS/crsf.lua")()

local targetIdx   = 1                 -- 1 = Transmitter, 2 = Receiver
local bindPhrase  = ""
local uidText     = ""
local HISTORY_MAX = 5
local history     = {}

local MSP_ELRS_RXTX_CONFIG = 45
local ELRS_RXTX_SUBCMD_UID = 0
local ELRS_RXTX_SUBCMD_BIND_PHRASE = 1

local deferCb
local function deferSet(interval, fn, ctx)
  deferCb = {
    start = getTime(),
    interval = interval,
    fn = fn,
    ctx = ctx
  }
end

local function deferClear()
  deferCb = nil
end

local function deferCheck()
  if deferCb == nil then return end

  if getTime() - deferCb.start < deferCb.interval then
    return
  end

  -- clear the defer first, if the callback wants to set a new one
  local oldcb = deferCb
  deferCb = nil
  oldcb.fn(oldcb.ctx)
end

local function addToHistory(s)
  if s == nil or s == "" then return end

  -- remove this value from the history list if already there
  for idx = #history, 1, -1 do
    if history[idx] == s then
      table.remove(history, idx)
    end
  end

  table.insert(history, 1, s)

  while #history > HISTORY_MAX do
    table.remove(history)
  end

  local f = io.open("elrs-phrase.txt", "w")
  if f == nil then return end
  io.write(f, table.concat(history, '\n'))
  io.close(f)
end

local function loadHistory()
  local f = io.open("elrs-phrase.txt", "r")
  if f == nil then return end

  history = {}
  local all = io.read(f, 64 * HISTORY_MAX)
  io.close(f)

  if all == nil or all == "" then return end

  for line in string.gmatch(all, "[^\n]+") do
    history[#history + 1] = line
  end

  bindPhrase = history[1] or ""
end

local function onMspResponse(data)
  if data[1] == CRSF.CONST.ADDRESS_RADIO_TRANSMITTER
    and (data[2] == CRSF.CONST.ADDRESS_RX or data[2] == CRSF.CONST.ADDRESS_TX_MODULE) then
    local mspCmd = data[5]

    if mspCmd == MSP_ELRS_RXTX_CONFIG and data[6] == ELRS_RXTX_SUBCMD_UID then
      deferClear()
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
    ELRS_RXTX_SUBCMD_UID
  })

  -- Retry if no response
  deferSet(50, requestUid)
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
    ELRS_RXTX_SUBCMD_BIND_PHRASE }

  -- append the phrase as bytes
  for i = 1, #bindPhrase do data[#data+1] = string.byte(bindPhrase, i) end

  CRSF.push(CRSF.CONST.FRAMETYPE_MSP_WRITE, data)

  addToHistory(bindPhrase)
  -- refresh the UID in 1000ms
  deferSet(100, requestUid)
end

local rebuildUi
local function history_text(id)
  return history[id]
end
local function history_visible(id)
  return history_text(id) ~= nil
end
local function history_press(id)
  bindPhrase = history[id]
  rebuildUi()
end

rebuildUi = function ()
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
        type  = lvgl.BOX,
        x     = 120,
        flexFlow    = lvgl.FLOW_ROW,
        flexPad     = lvgl.PAD_MEDIUM,
        children = {
          {
            type   = lvgl.TEXT_EDIT,
            w      = 240,
            value  = bindPhrase,
            length = 52, -- packet is only so big and can't span
            set = function(v) bindPhrase = v end,
          },
          {
            type  = lvgl.BUTTON,
            text  = "Set",
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
        x     = 120,
        flexFlow    = lvgl.FLOW_ROW,
        flexPad     = lvgl.PAD_MEDIUM,
        children = {
          {
            type   = lvgl.CHOICE,
            title  = "Select Target",
            values = {"Transmitter", "Receiver"},
            get    = function() return targetIdx end,
            set    = function(n) targetIdx = n end,
          },
          {
            type  = lvgl.BUTTON,
            text  = "Request UID",
            press = requestUid,
          },
        },
      },
    },
  })

  -- ***** Bind Phrase History *****
  local row = pg:box({
    w = lvgl.PERCENT_SIZE + 100, y = 82,
    flexFlow    = lvgl.FLOW_COLUMN,
    flexPad     = lvgl.PAD_MEDIUM,
    visible     = function () return #history end,
  })
  row:label({text = "Bind Phrase History"})
  for i = 1, HISTORY_MAX do
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

  loadHistory()
  rebuildUi()

  CRSF:registerHandler(CRSF.CONST.FRAMETYPE_MSP_RESP, onMspResponse)
  deferSet(1, requestUid)
end

local function run(event, touchState)
  if lvgl == nil then
    lcd.drawText(0, 0, "LVGL (EdgeTX 2.11+) required", COLOR_THEME_WARNING)
    return 0
  end

  CRSF:poll()
  -- Must come after poll so a telemetry queue is established
  deferCheck()

  return 0
end

return { init = init, run = run, useLvgl = true }
