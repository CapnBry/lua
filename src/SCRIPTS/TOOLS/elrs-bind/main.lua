-- TNS|ELRS Bind Manager|TNE

local CRSF = loadScript("/SCRIPTS/ELRS/crsf.lua")()

local targetIdx = 1 -- 1 = Transmitter, 2 = Receiver, 3 = Both
local targetBothStep = nil -- If setting Both RX and TX, state of change
local bindPhrase = ""
local uidText = ""

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
  if Defer._deferCb == nil then
    return
  end

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
  FNAME = "history.txt",
  vals = {},
}

function History.add(s)
  if s == nil or s == "" then
    return
  end

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

  History.save()
end

function History.remove(idx)
  table.remove(History.vals, idx)
  History.save()
end

function History.save()
  local f = io.open(History.FNAME, "w")
  if f == nil then
    return
  end
  io.write(f, table.concat(History.vals, "\n"))
  io.close(f)
end

function History.load()
  local f = io.open(History.FNAME, "r")
  if f == nil then
    return
  end

  History.vals = {}
  local all = io.read(f, 64 * History.MAX)
  io.close(f)

  if all == nil or all == "" then
    return
  end

  for line in string.gmatch(all, "[^\n]+") do
    History.vals[#History.vals + 1] = line
  end

  return History.vals[1]
end

local function onMspResponse(data)
  if
    data[1] == CRSF.CONST.ADDRESS_RADIO_TRANSMITTER
    and (data[2] == CRSF.CONST.ADDRESS_RX or data[2] == CRSF.CONST.ADDRESS_TX_MODULE)
  then
    local mspCmd = data[5]

    if mspCmd == MSP_ELRS_RXTX_CONFIG and data[6] == ELRS_RXTX_SUBCMD_UID then
      Defer.clear()
      local rxTx = (data[2] == CRSF.CONST.ADDRESS_RX) and "RX" or "TX"
      uidText =
        string.format("%s: %d, %d, %d, %d, %d, %d", rxTx, data[7], data[8], data[9], data[10], data[11], data[12])
    end
  end
end

local function isTargetReachable()
  return targetIdx == 1 or (targetIdx == 2 and CRSF.isConnected)
end

local function isTargetReachableOrBoth()
  return isTargetReachable() or targetIdx == 3
end

local function requestUid()
  if not isTargetReachable() then
    uidText = "Idle"
    return
  end

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
  if bindPhrase == "" then
    return
  end

  -- BothStep state machine
  if targetIdx == 3 then
    if targetBothStep == nil then
      -- Send to RX
      targetBothStep = 2
    elseif targetBothStep == 2 then
      -- Stop both, send to TX, and change the select to TX
      targetBothStep = nil
      targetIdx = 1
    end
  end

  local effectiveTargetIdx = targetBothStep or targetIdx
  if targetBothStep == nil then
    local rxTx = (targetIdx == 1) and "Transmitter" or "Receiver"
    uidText = "Setting " .. rxTx .. "..."
  else
    uidText = "Setting RX and disconnecting..."
  end

  local data = {
    (effectiveTargetIdx == 1) and CRSF.CONST.ADDRESS_TX_MODULE or CRSF.CONST.ADDRESS_RX,
    CRSF.CONST.ADDRESS_RADIO_TRANSMITTER,
    0x30,
    0x01 + #bindPhrase,
    MSP_ELRS_RXTX_CONFIG,
    ELRS_RXTX_SUBCMD_BIND_PHRASE,
  }

  -- append the phrase as bytes
  for i = 1, #bindPhrase do
    data[#data + 1] = string.byte(bindPhrase, i)
  end

  CRSF.push(CRSF.CONST.FRAMETYPE_MSP_WRITE, data)

  History.add(bindPhrase)
  if targetBothStep == nil then
    -- refresh the UID in 1000ms
    Defer.setTimeout(100, requestUid)
  else
    -- Perform the next step of setBindphrase() for Both
    Defer.setTimeout(100, sendBindphrase)
  end
end

local function sendBindTx()
  uidText = "Sending bind command..."
  CRSF.sendBind(CRSF.CONST.ADDRESS_TX_MODULE)
  Defer.setTimeout(100, function()
    uidText = "Sent"
  end)
end

local function sendBindRx()
  uidText = "Sending unbind to RX..."
  CRSF.sendBind(CRSF.CONST.ADDRESS_RX)
  Defer.setTimeout(100, function()
    uidText = "Sent"
  end)
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
local function history_remove(id)
  History.remove(id)
end

rebuildUi = function()
  lvgl.clear()

  local pg = lvgl.page({
    title = "ExpressLRS Bind Phrase",
    subtitle = function()
      return uidText
    end,
  })

  local tbox = pg:box({
    w = lvgl.PERCENT_SIZE + 100,
    flexFlow = lvgl.FLOW_COLUMN,
  })

  -- ***** Bind Phrase label + text edit + Set button *****
  tbox:setting({
    w = lvgl.PERCENT_SIZE + 100,
    title = "Bind phrase",
    children = {
      {
        type = lvgl.BOX,
        x = 120 * lvgl.LCD_SCALE,
        flexFlow = lvgl.FLOW_ROW,
        flexPad = lvgl.PAD_MEDIUM,
        children = {
          {
            type = lvgl.TEXT_EDIT,
            w = 250 * lvgl.LCD_SCALE,
            value = bindPhrase,
            length = 52, -- packet is only so big and can't span
            set = function(v)
              bindPhrase = v
            end,
            active = isTargetReachableOrBoth,
          },
          {
            type = lvgl.BUTTON,
            text = "Set",
            press = sendBindphrase,
            active = function()
              return isTargetReachableOrBoth() and bindPhrase ~= ""
            end,
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
        type = lvgl.BOX,
        x = 120 * lvgl.LCD_SCALE,
        flexFlow = lvgl.FLOW_ROW,
        flexPad = lvgl.PAD_MEDIUM,
        children = {
          {
            type = lvgl.CHOICE,
            title = "Select Target",
            values = { "Transmitter", "Receiver", "Both" },
            get = function()
              return targetIdx
            end,
            set = function(n)
              targetIdx = n
            end,
          },
          {
            type = lvgl.BUTTON,
            text = "Request UID",
            press = requestUid,
            active = isTargetReachable,
          },
          {
            type = lvgl.BUTTON,
            text = "Unbind",
            press = sendBindRx,
            -- Visible if RX
            visible = function()
              return targetIdx == 2
            end,
            -- Active if RX and is connected
            active = function()
              return targetIdx == 2 and CRSF.isConnected
            end,
          },
        },
      },
    },
  })

  -- ***** Show Bind button if RX target selected and no RX connected *****
  pg:box({
    w = lvgl.PERCENT_SIZE + 100,
    y = 2 * lvgl.UI_ELEMENT_HEIGHT + 4 * lvgl.PAD_MEDIUM,
    flexFlow = lvgl.FLOW_ROW,
    flexPad = lvgl.PAD_MEDIUM,
    align = LEFT,
    visible = function()
      return targetIdx == 2 and not CRSF.isConnected
    end,
    children = {
      {
        type = lvgl.LABEL,
        w = 4 + lvgl.LCD_SCALE * (120 + 250),
        text = " No receiver connected.\n Use Bind to set bindphrase if RX in bind mode",
      },
      {
        type = lvgl.BUTTON,
        text = "Bind",
        press = sendBindTx,
      },
    },
  })

  -- ***** Bind Phrase History *****
  local histSection = pg:box({
    w = lvgl.PERCENT_SIZE + 100,
    y = 2 * lvgl.UI_ELEMENT_HEIGHT + 4 * lvgl.PAD_MEDIUM,
    flexFlow = lvgl.FLOW_COLUMN,
    flexPad = 0,
    -- visible if there is history and TX selected or RX selected and isConnected
    visible = function()
      return #History.vals > 0 and isTargetReachableOrBoth()
    end,
  })
  histSection:label({ text = "Bind Phrase History" })
  for i = 1, History.MAX do
    local row = histSection:box({
      w = lvgl.PERCENT_SIZE + 100,
      flexFlow = lvgl.FLOW_ROW,
      flexPad = lvgl.PAD_SMALL,
      visible = function()
        return history_visible(i)
      end,
    })
    -- Button containing a history item with its value
    row:button({
      w = lvgl.PERCENT_SIZE + 80,
      text = function()
        return history_text(i) or ""
      end,
      press = function()
        return history_press(i)
      end,
    })
    -- Button X to delete an item
    row:button({
      text = "X",
      textColor = COLOR_THEME_WARNING,
      press = function()
        return history_remove(i)
      end,
    })
  end
end

local function init()
  if lvgl == nil then
    return
  end

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
