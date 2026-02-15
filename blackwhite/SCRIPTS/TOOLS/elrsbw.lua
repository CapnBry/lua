-- TNS|ELRBW|TNE
---- #########################################################################
---- #                                                                       #
---- # Copyright (C) OpenTX, adapted for ExpressLRS                          #
-----#                                                                       #
---- # License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               #
---- #                                                                       #
---- # BW version for EdgeTX (no LVGL required)                              #
---- #########################################################################
local VERSION = "r1 BW"

-- ============================================================================
-- Compat Layer: table.concat polyfill for BW radios
-- ============================================================================

local tableConcat
if table and table.concat then
  tableConcat = table.concat
else
  tableConcat = function(t, sep, i, j)
    i = i or 1
    j = j or #t
    if i > j then
      return ""
    end
    local r = t[i] or ""
    for k = i + 1, j do
      if sep then
        r = r .. sep
      end
      r = r .. (t[k] or "")
    end
    return r
  end
end

-- ============================================================================
-- Forward declarations for modules (needed for cross-references)
-- ============================================================================

local Navigation
local Protocol
local UI

-- Popup compatibility wrapper (set in UI.init)
local popupCompat

-- ============================================================================
-- App Module: Application state and coordinators
-- ============================================================================

local App = {
  -- Module check
  crsfModuleChecked = false,
  crsfModuleFound = false,

  -- Exit
  shouldExit = false,
}

-- Reset App to initial values
function App.reset()
  App.crsfModuleChecked = false
  App.crsfModuleFound = false
  App.shouldExit = false
  Protocol.reset()
end

-- Module check (caches result to avoid repeated checks)
function App.checkCrsfModule()
  if App.crsfModuleChecked then
    return App.crsfModuleFound
  end

  App.crsfModuleChecked = true
  App.crsfModuleFound = Protocol.hasCrsfModule()
  return App.crsfModuleFound
end

--- Active device announced/re-announced. Resets navigation (field tree rebuilding).
function App.loadDevice(device)
  if Protocol.setDevice(device) then
    Navigation.reset()
    UI.lineIndex = 1
    UI.pageOffset = 0
    UI.invalidate()
  end
end

--- User picked a different device from "Other Devices" list.
--- Pushes a navigation entry so Back returns to previous device.
function App.userSwitchDevice(deviceId)
  local device = Protocol.getDevice(deviceId)
  if not device then
    return
  end
  local prevDeviceId = Protocol.deviceId
  if Protocol.setDevice(device) then
    Navigation.openDevice(device.name, prevDeviceId)
    UI.lineIndex = 1
    UI.pageOffset = 0
    UI.invalidate()
  end
end

-- Coordinator: opens a folder, loads its children, and refreshes UI
function App.openFolder(folderId, folderName)
  Protocol.flushPendingSaves()
  Navigation.openFolder(folderId, folderName)
  Protocol.loadFolderChildren(folderId)
  UI.lineIndex = 1
  UI.pageOffset = 0
  return UI.invalidate()
end

-- Back button handler: navigate back or reload at root
function App.handleBack()
  Protocol.flushPendingSaves()
  if Navigation.isAtRoot() then
    -- At root: reload everything (like original elrs.lua)
    if Protocol.deviceId ~= Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER then
      local txDevice = Protocol.getDevice(Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER)
      if txDevice then
        App.loadDevice(txDevice)
      end
    else
      Protocol.allocateFields()
      Protocol.reloadAllFields()
    end
    Protocol.push(Protocol.CRSF.FRAMETYPE_DEVICE_PING,
      { Protocol.CRSF.ADDRESS_BROADCAST, Protocol.CRSF.ADDRESS_RADIO_TRANSMITTER })
  else
    local entry = Navigation.goBack()
    if entry then
      UI.lineIndex = entry.li or 1
      UI.pageOffset = entry.po or 0
      if entry.type == Navigation.TYPE_DEVICE and entry.prevDeviceId then
        local prevDevice = Protocol.getDevice(entry.prevDeviceId)
        if prevDevice then
          Protocol.setDevice(prevDevice)
        end
      end
    end
  end
  UI.invalidate()
end

-- ============================================================================
-- Navigation Module: Folder navigation stack and methods
-- ============================================================================

Navigation = {
  stack = {},
  -- Navigation entry type constants (integers to save RAM vs strings)
  TYPE_FOLDER = 0,
  TYPE_DEVICE = 1,
  -- Synthetic folder IDs
  FOLDER_OTHER_DEVICES = -1,
}

function Navigation.getCurrent()
  local top = Navigation.stack[#Navigation.stack]
  return top and top.id or nil
end

function Navigation.isAtRoot()
  return #Navigation.stack == 0
end

function Navigation.hasDeviceEntry()
  for _, entry in ipairs(Navigation.stack) do
    if entry.type == Navigation.TYPE_DEVICE then
      return true
    end
  end
  return false
end

function Navigation.openFolder(folderId, folderName)
  local baseName = folderName
  if folderName then
    baseName = string.match(folderName, "^(.-)%s*%(.*%)$") or folderName
  end
  Navigation.stack[#Navigation.stack + 1] = {
    type = Navigation.TYPE_FOLDER,
    id = folderId,
    name = baseName,
    li = UI.lineIndex,
    po = UI.pageOffset,
  }
end

function Navigation.openDevice(deviceName, prevDeviceId)
  Navigation.stack[#Navigation.stack + 1] = {
    type = Navigation.TYPE_DEVICE,
    id = nil,
    name = deviceName,
    prevDeviceId = prevDeviceId,
    li = UI.lineIndex,
    po = UI.pageOffset,
  }
end

function Navigation.goBack()
  if #Navigation.stack > 0 then
    local entry = Navigation.stack[#Navigation.stack]
    Navigation.stack[#Navigation.stack] = nil
    return entry
  end
  return nil
end

function Navigation.reset()
  Navigation.stack = {}
end

-- ============================================================================
-- Protocol Module: CRSF constants, parsing, and field operations
-- (Ported from expresslrs.lua with concat polyfill and collectgarbage)
-- ============================================================================

Protocol = {
  -- EdgeTX module type for CRSF/ELRS
  MODULE_TYPE_CROSSFIRE = 5,

  -- CRSF Field Type Constants
  CRSF = {
    UINT8          = 0,
    INT8           = 1,
    UINT16         = 2,
    INT16          = 3,
    UINT32         = 4,
    INT32          = 5,
    UINT64         = 6,
    INT64          = 7,
    FLOAT          = 8,
    TEXT_SELECTION = 9,
    STRING         = 10,
    FOLDER         = 11,
    INFO           = 12,
    COMMAND        = 13,
    -- Internal/extended types (not in official CRSF protocol)
    DEVICE         = 15,
    DEVICE_FOLDER  = 16,

    -- Frame types
    FRAMETYPE_DEVICE_PING              = 0x28,
    FRAMETYPE_DEVICE_INFO              = 0x29,
    FRAMETYPE_PARAMETER_SETTINGS_ENTRY = 0x2B,
    FRAMETYPE_PARAMETER_READ           = 0x2C,
    FRAMETYPE_PARAMETER_WRITE          = 0x2D,
    FRAMETYPE_ELRS_STATUS              = 0x2E,

    -- Addresses
    ADDRESS_BROADCAST          = 0x00,
    ADDRESS_RADIO_TRANSMITTER  = 0xEA,
    ADDRESS_CRSF_RECEIVER      = 0xEC,
    ADDRESS_CRSF_TRANSMITTER   = 0xEE,
    ADDRESS_ELRS_LUA           = 0xEF,

    -- ELRS identification
    ELRS_SERIAL_ID             = 0x454C5253,

    -- ELRS flags
    ELRS_FLAGS_STATUS_MASK = 0x03,
    ELRS_FLAGS_WARNING_THRESHOLD = 0x1F,

    -- Command steps
    CMD_IDLE       = 0,
    CMD_CLICK      = 1,
    CMD_EXECUTING  = 2,
    CMD_ASKCONFIRM = 3,
    CMD_CONFIRMED  = 4,
    CMD_CANCEL     = 5,
    CMD_QUERY      = 6,
  },

  -- Handlers dispatch table (populated after function definitions)
  handlers = {},

  -- Device identity
  deviceId = 0xEE,
  handsetId = 0xEF,
  deviceName = nil,
  deviceIsELRS_TX = nil,

  -- Fields collection
  fields = {},
  fieldsCount = 0,
  fieldPopup = nil,

  -- Devices collection
  devices = {},
  devicesRefreshTimeout = 50,

  -- Status/flags
  elrsFlags = 0,
  elrsFlagsInfo = "",
  receivedPackets = nil,
  lostPackets = nil,

  -- Protocol timing
  linkstatTimeout = 100,

  -- Communication state
  fieldTimeout = 0,
  fieldChunk = 0,
  fieldData = nil,
  loadQueue = {},
  expectChunksRemain = -1,
  backgroundLoading = false,

  -- Debounce: deferred saves for continuous controls
  DEBOUNCE_SAVE_DELAY = 30,
  pendingSaves = {},

  -- Connection transition tracking
  wasConnected = false,
}

-- Reset Protocol state
function Protocol.reset()
  Protocol.deviceId = Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER
  Protocol.handsetId = Protocol.CRSF.ADDRESS_ELRS_LUA
  Protocol.deviceName = nil
  Protocol.deviceIsELRS_TX = nil

  Protocol.fields = {}
  Protocol.fieldsCount = 0
  Protocol.fieldPopup = nil

  Protocol.devices = {}
  Protocol.devicesRefreshTimeout = 50

  Protocol.elrsFlags = 0
  Protocol.elrsFlagsInfo = ""
  Protocol.receivedPackets = nil
  Protocol.lostPackets = nil

  Protocol.linkstatTimeout = 100

  Protocol.fieldTimeout = 0
  Protocol.fieldChunk = 0
  Protocol.fieldData = nil
  Protocol.loadQueue = {}
  Protocol.expectChunksRemain = -1
  Protocol.backgroundLoading = false
  Protocol.pendingSaves = {}
  Protocol.wasConnected = false
end

-- Default telemetry wrappers (replaced by setMock in simulator)
function Protocol.pop()
  return crossfireTelemetryPop()
end

function Protocol.push(command, data)
  return crossfireTelemetryPush(command, data)
end

function Protocol.isConnected()
  return bit32.btest(Protocol.elrsFlags, 1)
end

function Protocol.fieldResponseTimeout()
  return Protocol.deviceIsELRS_TX and 50 or 500
end

function Protocol.hasCrsfModule()
  for modIdx = 0, 1 do
    local mod = model.getModule(modIdx)
    if mod and (mod.Type == nil or mod.Type == Protocol.MODULE_TYPE_CROSSFIRE) then
      return true
    end
  end
  return false
end

function Protocol.setDevice(device)
  if not device then
    return false
  end
  if Protocol.deviceId == device.id and Protocol.fieldsCount == device.fieldCount then
    return false
  end

  Protocol.deviceId = device.id
  Protocol.elrsFlags = 0
  Protocol.deviceName = device.name
  Protocol.fieldsCount = device.fieldCount
  Protocol.deviceIsELRS_TX = device.isElrs and device.id == Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER or nil
  Protocol.handsetId = Protocol.deviceIsELRS_TX and Protocol.CRSF.ADDRESS_ELRS_LUA or Protocol.CRSF.ADDRESS_RADIO_TRANSMITTER

  Protocol.allocateFields()
  Protocol.reloadAllFields()
  return true
end

-- ============================================================================
-- Protocol: Field management functions
-- ============================================================================

function Protocol.allocateFields()
  Protocol.fields = {}
  Protocol.fields[0] = {}
  for i = 1, Protocol.fieldsCount do
    Protocol.fields[i] = {}
  end
end

function Protocol.isFolderLoaded(folderId)
  local folder = Protocol.fields[folderId or 0]
  if not folder or not folder.children then
    return false
  end
  for _, childId in ipairs(folder.children) do
    local child = Protocol.fields[childId]
    if not child or not child.name or child.nameStale then
      return false
    end
  end
  return true
end

function Protocol.getFolderLoadProgress(folderId)
  local folder = Protocol.fields[folderId or 0]
  if not folder or not folder.children then
    return nil
  end
  local total = #folder.children
  local loaded = 0
  for _, childId in ipairs(folder.children) do
    local child = Protocol.fields[childId]
    if child and child.name then
      loaded = loaded + 1
    end
  end
  return loaded, total
end

function Protocol.reloadAllFields()
  Protocol.fieldTimeout = 0
  Protocol.fieldChunk = 0
  Protocol.fieldData = nil
  Protocol.loadQueue = {}
  Protocol.loadQueue[1] = 0
end

function Protocol.getFieldsInFolder(folderId)
  local folder = Protocol.fields[folderId or 0]
  if not folder or not folder.children then
    return {}
  end
  local result = {}
  for _, childId in ipairs(folder.children) do
    local child = Protocol.fields[childId]
    if child and child.name and not child.hidden then
      result[#result + 1] = child
    end
  end
  return result
end

function Protocol.getDevice(id)
  for _, device in ipairs(Protocol.devices) do
    if device.id == id then
      return device
    end
  end
end

function Protocol.reloadCurField(field)
  Protocol.fieldTimeout = 0
  Protocol.fieldChunk = 0
  Protocol.fieldData = nil
  Protocol.loadQueue[#Protocol.loadQueue + 1] = field.id
end

function Protocol.loadFolderChildren(folderId)
  local folder = Protocol.fields[folderId]
  if not folder or not folder.children then
    return
  end
  for i = #folder.children, 1, -1 do
    local childId = folder.children[i]
    local child = Protocol.fields[childId]
    if child and not child.name then
      Protocol.loadQueue[#Protocol.loadQueue + 1] = childId
    end
  end
  if #Protocol.loadQueue > 0 then
    Protocol.fieldTimeout = 0
  end
end

function Protocol.startBackgroundLoad()
  Protocol.backgroundLoading = true
  for i = 1, #Protocol.fields do
    local field = Protocol.fields[i]
    if field.type == Protocol.CRSF.FOLDER and field.children then
      for j = #field.children, 1, -1 do
        local childId = field.children[j]
        local child = Protocol.fields[childId]
        if child and not child.name then
          Protocol.loadQueue[#Protocol.loadQueue + 1] = childId
        end
      end
    end
  end
  if #Protocol.loadQueue > 0 then
    Protocol.fieldTimeout = 0
  end
end

-- ============================================================================
-- Protocol: Field data helpers
-- ============================================================================

function Protocol.fieldGetStrOrOpts(data, offset, last, isOpts)
  local r = last or (isOpts and {})
  local optParts = {}
  local vcnt = 0
  repeat
    local b = data[offset]
    offset = offset + 1

    if not last then
      if r and (b == 59 or b == 0) then
        r[#r + 1] = tableConcat(optParts)
        if #optParts > 0 then
          vcnt = vcnt + 1
          optParts = {}
        end
      elseif b ~= 0 then
        optParts[#optParts + 1] = ({
          [192] = CHAR_UP or (__opentx and __opentx.CHAR_UP),
          [193] = CHAR_DOWN or (__opentx and __opentx.CHAR_DOWN)
        })[b] or string.char(b)
      end
    end
  until b == 0

  return (r or tableConcat(optParts)), offset, vcnt
end

function Protocol.fieldGetValue(data, offset, size)
  local result = 0
  for i = 0, size - 1 do
    result = bit32.lshift(result, 8) + data[offset + i]
  end
  return result
end

-- ============================================================================
-- Protocol: Field load functions
-- ============================================================================

local function fieldUnsignedLoad(field, data, offset, size, unitoffset)
  field.value = Protocol.fieldGetValue(data, offset, size)
  field.min = Protocol.fieldGetValue(data, offset + size, size)
  field.max = Protocol.fieldGetValue(data, offset + 2 * size, size)
  field.unit = Protocol.fieldGetStrOrOpts(data, offset + (unitoffset or (4 * size)), field.unit)
  if size ~= 1 then
    field.size = size
  end
end

local function fieldUnsignedToSigned(field, size)
  local bandval = bit32.lshift(0x80, (size - 1) * 8)
  field.value = field.value - bit32.band(field.value, bandval) * 2
  field.min = field.min - bit32.band(field.min, bandval) * 2
  field.max = field.max - bit32.band(field.max, bandval) * 2
end

local function fieldSignedLoad(field, data, offset, size, unitoffset)
  fieldUnsignedLoad(field, data, offset, size, unitoffset)
  fieldUnsignedToSigned(field, size)
  field.size = -size
end

function Protocol.fieldIntLoad(field, data, offset)
  local loadFn = (field.type % 2 == 0) and fieldUnsignedLoad or fieldSignedLoad
  return loadFn(field, data, offset, math.floor(field.type / 2) + 1)
end

function Protocol.fieldFloatLoad(field, data, offset)
  fieldSignedLoad(field, data, offset, 4, 21)
  field.prec = data[offset + 16]
  if field.prec > 3 then
    field.prec = 3
  end
  field.step = Protocol.fieldGetValue(data, offset + 17, 4)
  field.fmt = "%." .. tostring(field.prec) .. "f" .. field.unit
  field.prec = 10 ^ field.prec
end

function Protocol.fieldTextSelLoad(field, data, offset)
  local vcnt
  local cached = field.dirty == nil and field.values
  field.values, offset, vcnt = Protocol.fieldGetStrOrOpts(data, offset, cached, true)
  if not cached then
    field.disabled = vcnt <= 1
  end
  field.value = data[offset]
  field.unit = Protocol.fieldGetStrOrOpts(data, offset + 4)
  field.dirty = nil
end

function Protocol.fieldStringLoad(field, data, offset)
  field.value, offset = Protocol.fieldGetStrOrOpts(data, offset)
  if #data >= offset then
    field.maxlen = data[offset]
  end
end

function Protocol.fieldCommandLoad(field, data, offset)
  field.status = data[offset]
  field.timeout = data[offset + 1]
  field.info = Protocol.fieldGetStrOrOpts(data, offset + 2)
  if field.status == Protocol.CRSF.CMD_IDLE then
    Protocol.fieldPopup = nil
  end
end

function Protocol.fieldFolderLoad(field, data, offset)
  field.children = {}
  while data[offset] and data[offset] ~= 0xFF do
    field.children[#field.children + 1] = data[offset]
    offset = offset + 1
  end
end

-- ============================================================================
-- Protocol: Field save functions
-- ============================================================================

function Protocol.fieldIntSave(field)
  local value = field.value
  local size = field.size or 1
  if size < 0 then
    size = -size
    if value < 0 then
      value = bit32.lshift(0x100, (size - 1) * 8) + value
    end
  end

  local frame = { Protocol.deviceId, Protocol.handsetId, field.id }
  for i = size - 1, 0, -1 do
    frame[#frame + 1] = bit32.rshift(value, 8 * i) % 256
  end
  Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, frame)
end

-- ============================================================================
-- Protocol: Related fields reload
-- ============================================================================

function Protocol.reloadParentFolder(field)
  if field.parent and Protocol.fields[field.parent] then
    Protocol.fields[field.parent].nameStale = true
    Protocol.loadQueue[#Protocol.loadQueue + 1] = field.parent
    local minTimeout = getTime() + Protocol.fieldResponseTimeout()
    if Protocol.fieldTimeout < minTimeout then
      Protocol.fieldTimeout = minTimeout
    end
  end
end

function Protocol.debounceSave(field)
  Protocol.pendingSaves[field.id] = { field = field, timeout = getTime() + Protocol.DEBOUNCE_SAVE_DELAY }
end

function Protocol.flushPendingSaves()
  for id, ps in pairs(Protocol.pendingSaves) do
    Protocol.pendingSaves[id] = nil
    Protocol.fieldIntSave(ps.field)
    Protocol.reloadParentFolder(ps.field)
  end
end

function Protocol.reloadRelatedFields(field)
  Protocol.reloadParentFolder(field)

  for fieldId = Protocol.fieldsCount, 1, -1 do
    local sibling = Protocol.fields[fieldId]
    local siblingType = sibling.type or 99
    if fieldId ~= field.id
      and sibling.parent == field.parent
      and (siblingType < Protocol.CRSF.FOLDER or siblingType == Protocol.CRSF.INFO) then
      sibling.dirty = true
      sibling.name = nil
      Protocol.loadQueue[#Protocol.loadQueue + 1] = fieldId
    end
  end

  field.dirty = true
  field.name = nil
  Protocol.loadQueue[#Protocol.loadQueue + 1] = field.id
  Protocol.fieldTimeout = getTime() + 20
  Protocol.linkstatTimeout = Protocol.fieldTimeout + 100
end

function Protocol.handleCommandSave(field)
  Protocol.reloadCurField(field)

  if field.status ~= nil then
    if field.status < Protocol.CRSF.CMD_CONFIRMED then
      field.status = Protocol.CRSF.CMD_CLICK
      Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, { Protocol.deviceId, Protocol.handsetId, field.id, field.status })
      Protocol.fieldPopup = field
      Protocol.fieldPopup.lastStatus = Protocol.CRSF.CMD_IDLE
      Protocol.fieldTimeout = getTime() + field.timeout
    end
  end
end

function Protocol.commandConfirm()
  if Protocol.fieldPopup then
    Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, { Protocol.deviceId, Protocol.handsetId, Protocol.fieldPopup.id, Protocol.CRSF.CMD_CONFIRMED })
    Protocol.fieldTimeout = getTime() + Protocol.fieldPopup.timeout
    Protocol.fieldPopup.status = Protocol.CRSF.CMD_CONFIRMED
  end
end

function Protocol.commandCancel()
  if Protocol.fieldPopup then
    Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, { Protocol.deviceId, Protocol.handsetId, Protocol.fieldPopup.id, Protocol.CRSF.CMD_CANCEL })
    Protocol.fieldPopup = nil
  end
end

-- ============================================================================
-- Protocol: Handlers dispatch table
-- ============================================================================

Protocol.handlers = {
  [Protocol.CRSF.UINT8 + 1]          = { load = Protocol.fieldIntLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.INT8 + 1]           = { load = Protocol.fieldIntLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.UINT16 + 1]         = { load = Protocol.fieldIntLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.INT16 + 1]          = { load = Protocol.fieldIntLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.UINT32 + 1]         = nil,
  [Protocol.CRSF.INT32 + 1]          = nil,
  [Protocol.CRSF.UINT64 + 1]         = nil,
  [Protocol.CRSF.INT64 + 1]          = nil,
  [Protocol.CRSF.FLOAT + 1]          = { load = Protocol.fieldFloatLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.TEXT_SELECTION + 1]  = { load = Protocol.fieldTextSelLoad, save = Protocol.fieldIntSave },
  [Protocol.CRSF.STRING + 1]         = { load = Protocol.fieldStringLoad, save = nil },
  [Protocol.CRSF.FOLDER + 1]         = { load = Protocol.fieldFolderLoad, save = nil },
  [Protocol.CRSF.INFO + 1]           = { load = Protocol.fieldStringLoad, save = nil },
  [Protocol.CRSF.COMMAND + 1]        = { load = Protocol.fieldCommandLoad, save = Protocol.handleCommandSave },
}

-- ============================================================================
-- Protocol: CRSF message parsing
-- ============================================================================

function Protocol.parseDeviceInfoMessage(data)
  local id = data[2]
  local newName, offset = Protocol.fieldGetStrOrOpts(data, 3)
  local device = Protocol.getDevice(id)
  local isNew = (device == nil)
  if isNew then
    device = { id = id }
    Protocol.devices[#Protocol.devices + 1] = device
  end
  device.name = newName
  device.fieldCount = data[offset + 12]
  device.isElrs = Protocol.fieldGetValue(data, offset, 4) == Protocol.CRSF.ELRS_SERIAL_ID
  return device, isNew
end

function Protocol.parseParameterInfoMessage(data)
  local fieldId = (Protocol.fieldPopup and Protocol.fieldPopup.id) or Protocol.loadQueue[#Protocol.loadQueue]
  if data[2] ~= Protocol.deviceId or data[3] ~= fieldId then
    Protocol.fieldData = nil
    Protocol.fieldChunk = 0
    return false
  end
  local field = Protocol.fields[fieldId]
  local chunksRemain = data[4]
  if not field or (Protocol.fieldData and chunksRemain ~= Protocol.expectChunksRemain) then
    return false
  end

  local offset
  if chunksRemain > 0 or Protocol.fieldChunk > 0 then
    Protocol.fieldData = Protocol.fieldData or {}
    for i = 5, #data do
      Protocol.fieldData[#Protocol.fieldData + 1] = data[i]
      data[i] = nil
    end
    offset = 1
  else
    Protocol.fieldData = data
    offset = 5
  end

  if chunksRemain > 0 then
    Protocol.fieldChunk = Protocol.fieldChunk + 1
    Protocol.expectChunksRemain = chunksRemain - 1
    return false
  else
    Protocol.loadQueue[#Protocol.loadQueue] = nil

    if #Protocol.fieldData > (offset + 2) then
      field.id = fieldId
      field.parent = (Protocol.fieldData[offset] ~= 0) and Protocol.fieldData[offset] or nil
      field.type = bit32.band(Protocol.fieldData[offset + 1], 0x7f)
      field.hidden = bit32.btest(Protocol.fieldData[offset + 1], 0x80) or nil
      local cachedName = (not field.nameStale) and field.name or nil
      field.name, offset = Protocol.fieldGetStrOrOpts(Protocol.fieldData, offset + 2, cachedName)
      field.nameStale = nil
      local handler = Protocol.handlers[field.type + 1]
      if handler and handler.load then
        handler.load(field, Protocol.fieldData, offset)
      end
      if field.min == 0 then
        field.min = nil
      end
      if field.max == 0 then
        field.max = nil
      end

      if field.type == Protocol.CRSF.FOLDER and field.children
          and (fieldId == 0 or Protocol.backgroundLoading) then
        for i = #field.children, 1, -1 do
          Protocol.loadQueue[#Protocol.loadQueue + 1] = field.children[i]
        end
      end
    end

    Protocol.fieldChunk = 0
    Protocol.fieldData = nil

    return Protocol.deviceId ~= Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER or #Protocol.loadQueue == 0
  end
end

function Protocol.parseElrsInfoMessage(data)
  if data[2] ~= Protocol.deviceId then
    Protocol.fieldData = nil
    Protocol.fieldChunk = 0
    return
  end

  Protocol.lostPackets = data[3]
  Protocol.receivedPackets = (data[4] * 256) + data[5]
  local newFlags = data[6]
  Protocol.elrsFlags = newFlags
  Protocol.elrsFlagsInfo = Protocol.fieldGetStrOrOpts(data, 7)
end

function Protocol.parseElrsV1Message(data)
  if (data[1] ~= Protocol.CRSF.ADDRESS_RADIO_TRANSMITTER) or (data[2] ~= Protocol.CRSF.ADDRESS_CRSF_TRANSMITTER) then
    return
  end
  Protocol.elrsV1Detected = true
end

-- ============================================================================
-- Protocol: Main CRSF communication loop
-- ============================================================================

function Protocol.poll()
  local command, data
  local targetDevice = nil
  local anyNewDevice = false

  repeat
    command, data = Protocol.pop()
    if command == Protocol.CRSF.FRAMETYPE_DEVICE_INFO then
      local device, isNew = Protocol.parseDeviceInfoMessage(data)
      if device.id == Protocol.deviceId then
        targetDevice = device
      end
      if isNew then
        anyNewDevice = true
      end
    elseif command == Protocol.CRSF.FRAMETYPE_PARAMETER_SETTINGS_ENTRY then
      Protocol.parseParameterInfoMessage(data)
      if #Protocol.loadQueue > 0 then
        Protocol.fieldTimeout = 0
      elseif Protocol.fieldPopup then
        Protocol.fieldTimeout = getTime() + Protocol.fieldPopup.timeout
      end
    elseif command == Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE then
      Protocol.parseElrsV1Message(data)
    elseif command == Protocol.CRSF.FRAMETYPE_ELRS_STATUS then
      Protocol.parseElrsInfoMessage(data)
    end
  until command == nil

  return targetDevice, anyNewDevice
end

function Protocol.tick()
  -- Auto-discover other devices when link transitions to connected
  local connected = Protocol.isConnected()
  if connected and not Protocol.wasConnected and #Protocol.devices <= 1 then
    Protocol.push(Protocol.CRSF.FRAMETYPE_DEVICE_PING, { Protocol.CRSF.ADDRESS_BROADCAST, Protocol.CRSF.ADDRESS_RADIO_TRANSMITTER })
    Protocol.devicesRefreshTimeout = getTime() + 100
  end
  Protocol.wasConnected = connected

  local time = getTime()
  -- Flush any debounced saves whose timer has expired
  for id, ps in pairs(Protocol.pendingSaves) do
    if time > ps.timeout then
      Protocol.pendingSaves[id] = nil
      Protocol.fieldIntSave(ps.field)
      Protocol.reloadParentFolder(ps.field)
    end
  end

  if Protocol.fieldPopup then
    if time > Protocol.fieldTimeout and Protocol.fieldPopup.status ~= Protocol.CRSF.CMD_ASKCONFIRM then
      Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, { Protocol.deviceId, Protocol.handsetId, Protocol.fieldPopup.id, Protocol.CRSF.CMD_QUERY })
      Protocol.fieldTimeout = time + Protocol.fieldPopup.timeout
    end
  elseif time > Protocol.devicesRefreshTimeout and #Protocol.devices == 0 then
    Protocol.devicesRefreshTimeout = time + 100
    Protocol.push(Protocol.CRSF.FRAMETYPE_DEVICE_PING, { Protocol.CRSF.ADDRESS_BROADCAST, Protocol.CRSF.ADDRESS_RADIO_TRANSMITTER })
  elseif time > Protocol.linkstatTimeout then
    if Protocol.deviceIsELRS_TX then
      Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE, { Protocol.deviceId, Protocol.handsetId, 0x0, 0x0 })
    else
      Protocol.receivedPackets = nil
      Protocol.lostPackets = nil
    end
    Protocol.linkstatTimeout = time + 100
  elseif time > Protocol.fieldTimeout and Protocol.fieldsCount ~= 0 then
    if #Protocol.loadQueue > 0 then
      Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_READ, { Protocol.deviceId, Protocol.handsetId, Protocol.loadQueue[#Protocol.loadQueue], Protocol.fieldChunk })
      Protocol.fieldTimeout = time + Protocol.fieldResponseTimeout()
    else
      Protocol.backgroundLoading = false
    end
  end
end

-- ============================================================================
-- UI Module: BW LCD rendering (extracted from elrs.lua)
-- ============================================================================

UI = {
  -- Cursor/selection state
  lineIndex = 1,
  pageOffset = 0,
  edit = nil,

  -- Visible field list (rebuilt on invalidate)
  visibleFields = nil,

  -- Layout constants (set in UI.init)
  COL1 = 0,
  COL2 = 70,
  maxLineIndex = 6,
  textSize = 8,
  textYoffset = 3,

  -- Redraw state
  forceRedraw = true,
  folderWasReady = false,

  -- Warning flashing
  titleShowWarn = nil,
  titleShowWarnTimeout = 100,

  -- Command popup spinner
  commandRunningIndicator = 1,
}

function UI.invalidate()
  UI.forceRedraw = true
  UI.visibleFields = nil
end

-- ============================================================================
-- UI: Initialization (BW-only LCD setup from elrs.lua setLCDvar)
-- ============================================================================

function UI.init()
  if LCD_W == 212 then
    UI.COL2 = 110
  else
    UI.COL2 = 70
  end
  if LCD_H == 96 then
    UI.maxLineIndex = 9
  else
    UI.maxLineIndex = 6
  end
  UI.COL1 = 0
  UI.textYoffset = 3
  UI.textSize = 8

  -- Determine popupConfirmation argument count
  local _, _, major = getVersion()
  if major ~= 1 then
    popupCompat = popupConfirmation
  else
    popupCompat = function(t, m, e)
      return popupConfirmation(t, e)
    end
  end
end

-- ============================================================================
-- UI: Build visible field list for current navigation state
-- ============================================================================

function UI.buildVisibleFields()
  local currentFolder = Navigation.getCurrent()
  local vf = {}

  if currentFolder == Navigation.FOLDER_OTHER_DEVICES then
    -- Device entries
    for _, device in ipairs(Protocol.devices) do
      if device.id ~= Protocol.deviceId then
        vf[#vf + 1] = { id = device.id, name = device.name, type = Protocol.CRSF.DEVICE }
      end
    end
  else
    -- Real fields in current folder
    local fields = Protocol.getFieldsInFolder(currentFolder)
    for _, field in ipairs(fields) do
      vf[#vf + 1] = field
    end

    -- "Other Devices" entry at root with multiple devices
    if currentFolder == nil and #Protocol.devices > 1 and not Navigation.hasDeviceEntry() then
      vf[#vf + 1] = { name = "Other Devices", type = Protocol.CRSF.DEVICE_FOLDER }
    end
  end

  UI.visibleFields = vf
end

function UI.getField(line)
  if not UI.visibleFields then
    UI.buildVisibleFields()
  end
  return UI.visibleFields[line]
end

function UI.getFieldCount()
  if not UI.visibleFields then
    UI.buildVisibleFields()
  end
  return #UI.visibleFields
end

-- Total selectable rows: all fields + the back/exit widget
function UI.getSelectableCount()
  return UI.getFieldCount() + 1
end

-- Whether the cursor is on the back/exit widget row
function UI.isOnBackExit()
  return UI.lineIndex > UI.getFieldCount()
end

-- The label for the back/exit widget
function UI.getBackExitLabel()
  if Navigation.isAtRoot() then
    return "-- EXIT (" .. VERSION .. ") --"
  else
    return "----BACK----"
  end
end

-- ============================================================================
-- UI: Field value increment (from elrs.lua incrField, expresslrs.lua incrField)
-- ============================================================================

function UI.incrField(step)
  local field = UI.getField(UI.lineIndex)
  if not field then
    return
  end
  local min, max = 0, 0
  if field.type <= Protocol.CRSF.FLOAT then
    min = field.min or 0
    max = field.max or 0
    step = (field.step or 1) * step
  elseif field.type == Protocol.CRSF.TEXT_SELECTION then
    min = 0
    max = #field.values - 1
  end

  local newval = field.value
  repeat
    newval = newval + step
    if newval < min then
      newval = min
    elseif newval > max then
      newval = max
    end

    if field.values == nil or #field.values[newval + 1] ~= 0 then
      field.value = newval
      return
    end
  until (newval == min or newval == max)
end

-- ============================================================================
-- UI: Field selection navigation (from elrs.lua selectField)
-- ============================================================================

function UI.selectField(step)
  local count = UI.getSelectableCount()
  if count == 0 then
    return
  end
  local fieldCount = UI.getFieldCount()
  local newLineIndex = UI.lineIndex
  repeat
    newLineIndex = newLineIndex + step
    if newLineIndex <= 0 then
      newLineIndex = count
    elseif newLineIndex > count then
      newLineIndex = 1
      UI.pageOffset = 0
    end
    -- Back/exit row is always selectable; for fields, skip unnamed ones
    if newLineIndex > fieldCount then
      break
    end
    local field = UI.getField(newLineIndex)
    if field and field.name then
      break
    end
  until newLineIndex == UI.lineIndex
  UI.lineIndex = newLineIndex
  if UI.lineIndex > UI.maxLineIndex + UI.pageOffset then
    UI.pageOffset = UI.lineIndex - UI.maxLineIndex
  elseif UI.lineIndex <= UI.pageOffset then
    UI.pageOffset = UI.lineIndex - 1
  end
end

-- ============================================================================
-- UI: BW field display functions (from elrs.lua)
-- ============================================================================

local function fieldIntDisplay(field, y, attr)
  lcd.drawText(UI.COL2, y, field.value .. field.unit, attr)
end

local function fieldFloatDisplay(field, y, attr)
  lcd.drawText(UI.COL2, y, string.format(field.fmt, field.value / field.prec), attr)
end

local function fieldTextSelDisplay(field, y, attr)
  lcd.drawText(UI.COL2, y, (field.values[field.value + 1] or "ERR") .. field.unit, attr)
end

local function fieldStringDisplay(field, y, attr)
  lcd.drawText(UI.COL2, y, field.value or "", attr)
end

local function fieldFolderDisplay(field, y, attr)
  lcd.drawText(UI.COL1, y, "> " .. field.name, attr + BOLD)
end

local function fieldCommandDisplay(field, y, attr)
  lcd.drawText(10, y, "[" .. field.name .. "]", attr + BOLD)
end

-- Display handler table: maps field type to display function
local displayHandlers = {}
displayHandlers[Protocol.CRSF.UINT8]          = fieldIntDisplay
displayHandlers[Protocol.CRSF.INT8]           = fieldIntDisplay
displayHandlers[Protocol.CRSF.UINT16]         = fieldIntDisplay
displayHandlers[Protocol.CRSF.INT16]          = fieldIntDisplay
displayHandlers[Protocol.CRSF.FLOAT]          = fieldFloatDisplay
displayHandlers[Protocol.CRSF.TEXT_SELECTION]  = fieldTextSelDisplay
displayHandlers[Protocol.CRSF.STRING]         = fieldStringDisplay
displayHandlers[Protocol.CRSF.INFO]           = fieldStringDisplay
displayHandlers[Protocol.CRSF.FOLDER]         = fieldFolderDisplay
displayHandlers[Protocol.CRSF.COMMAND]        = fieldCommandDisplay
displayHandlers[Protocol.CRSF.DEVICE]         = fieldCommandDisplay
displayHandlers[Protocol.CRSF.DEVICE_FOLDER]  = fieldFolderDisplay

-- ============================================================================
-- UI: Title bar drawing (from elrs.lua lcd_title_bw)
-- ============================================================================

function UI.drawTitle()
  local barHeight = 9
  local goodBadPkt = ""
  if Protocol.receivedPackets then
    local state = Protocol.isConnected() and "C" or "-"
    goodBadPkt = string.format("%u/%u   %s", Protocol.lostPackets, Protocol.receivedPackets, state)
  end

  local loaded, total = Protocol.getFolderLoadProgress(Navigation.getCurrent())
  if not UI.titleShowWarn then
    lcd.drawText(LCD_W - 1, 1, goodBadPkt, RIGHT)
    lcd.drawLine(LCD_W - 10, 0, LCD_W - 10, barHeight - 1, SOLID, INVERS)
  end

  if loaded and total and total > 0 and loaded < total then
    lcd.drawFilledRectangle(UI.COL2, 0, LCD_W, barHeight, GREY_DEFAULT)
    lcd.drawGauge(0, 0, UI.COL2, barHeight, loaded, total, 0)
  else
    lcd.drawFilledRectangle(0, 0, LCD_W, barHeight, GREY_DEFAULT)
    if UI.titleShowWarn then
      lcd.drawText(UI.COL1, 1, Protocol.elrsFlagsInfo, INVERS)
    else
      lcd.drawText(UI.COL1, 1, Protocol.deviceName or "Searching...", INVERS)
    end
  end
end

-- ============================================================================
-- UI: Warning display (from elrs.lua lcd_warn)
-- ============================================================================

function UI.drawWarning()
  lcd.drawText(UI.COL1, UI.textSize * 2, "Error:")
  lcd.drawText(UI.COL1, UI.textSize * 3, Protocol.elrsFlagsInfo)
  lcd.drawText(LCD_W / 2, UI.textSize * 5, "[OK]", BLINK + INVERS + CENTER)
end

-- ============================================================================
-- UI: Event handling (from elrs.lua handleDevicePageEvent, adapted for modules)
-- ============================================================================

function UI.handleEvent(event)
  if UI.getSelectableCount() == 0 then
    return
  end

  if event == EVT_VIRTUAL_EXIT then
    if UI.edit then
      UI.edit = nil
      local field = UI.getField(UI.lineIndex)
      if field and field.id then
        Protocol.reloadCurField(field)
      end
    else
      App.handleBack()
    end
  elseif event == EVT_VIRTUAL_ENTER then
    if Protocol.elrsFlags > Protocol.CRSF.ELRS_FLAGS_WARNING_THRESHOLD then
      -- Dismiss critical warning
      Protocol.elrsFlags = 0
      Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE,
        { Protocol.deviceId, Protocol.handsetId, 0x2E, 0x00 })
    elseif UI.isOnBackExit() then
      if Navigation.isAtRoot() then
        App.shouldExit = true
      else
        App.handleBack()
      end
    else
      local field = UI.getField(UI.lineIndex)
      if field and field.name then
        local ft = field.type

        if ft == Protocol.CRSF.FOLDER then
          App.openFolder(field.id, field.name)
        elseif ft == Protocol.CRSF.DEVICE_FOLDER then
          App.openFolder(Navigation.FOLDER_OTHER_DEVICES, "Other Devices")
        elseif ft == Protocol.CRSF.DEVICE then
          App.userSwitchDevice(field.id)
        elseif ft == Protocol.CRSF.COMMAND then
          Protocol.handleCommandSave(field)
        elseif not field.disabled and ft <= Protocol.CRSF.TEXT_SELECTION then
          -- Editable value fields
          UI.edit = not UI.edit
          if not UI.edit then
            Protocol.fieldIntSave(field)
            Protocol.reloadRelatedFields(field)
          end
        end
      end
    end
  elseif UI.edit then
    if event == EVT_VIRTUAL_NEXT then
      UI.incrField(1)
    elseif event == EVT_VIRTUAL_PREV then
      UI.incrField(-1)
    end
  else
    if event == EVT_VIRTUAL_NEXT then
      UI.selectField(1)
    elseif event == EVT_VIRTUAL_PREV then
      UI.selectField(-1)
    end
  end
end

-- ============================================================================
-- UI: Main page rendering (from elrs.lua runDevicePage)
-- ============================================================================

function UI.drawPage(event)
  UI.handleEvent(event)

  lcd.clear()
  UI.drawTitle()

  -- Show "Other Devices" folder by checking device count
  -- (handled via visibleFields list)

  if Protocol.elrsFlags > Protocol.CRSF.ELRS_FLAGS_WARNING_THRESHOLD then
    UI.drawWarning()
  else
    local totalCount = UI.getSelectableCount()
    for y = 1, UI.maxLineIndex + 1 do
      local idx = UI.pageOffset + y
      if idx > totalCount then
        break
      end
      local yPos = y * UI.textSize + UI.textYoffset
      local isSelected = (UI.lineIndex == idx)
      local attr = isSelected and ((UI.edit and BLINK or 0) + INVERS) or 0

      if idx > UI.getFieldCount() then
        -- Back/exit widget row
        lcd.drawText(10, yPos, "[" .. UI.getBackExitLabel() .. "]", attr + BOLD)
      else
        local field = UI.getField(idx)
        if field and field.name then
          local ft = field.type
          -- Draw field name for value/info fields (not folder, command, synthetic)
          if ft < Protocol.CRSF.FOLDER or ft == Protocol.CRSF.INFO then
            lcd.drawText(UI.COL1, yPos, field.name, 0)
          end
          -- Draw field value/display
          local displayFn = displayHandlers[ft]
          if displayFn then
            displayFn(field, yPos, attr)
          end
        end
      end
    end
  end
end

-- ============================================================================
-- UI: Command popup rendering (from elrs.lua runPopupPage)
-- ============================================================================

function UI.drawPopup(event)
  if event == EVT_VIRTUAL_EXIT then
    Protocol.push(Protocol.CRSF.FRAMETYPE_PARAMETER_WRITE,
      { Protocol.deviceId, Protocol.handsetId, Protocol.fieldPopup.id, Protocol.CRSF.CMD_CANCEL })
    Protocol.fieldTimeout = getTime() + 200
  end

  if Protocol.fieldPopup.status == Protocol.CRSF.CMD_IDLE and Protocol.fieldPopup.lastStatus ~= Protocol.CRSF.CMD_IDLE then
    popupCompat(Protocol.fieldPopup.info, "Stopped!", event)
    Protocol.reloadAllFields()
    Protocol.fieldPopup = nil
  elseif Protocol.fieldPopup.status == Protocol.CRSF.CMD_ASKCONFIRM then
    local result = popupCompat(Protocol.fieldPopup.info, "PRESS [OK] to confirm", event)
    Protocol.fieldPopup.lastStatus = Protocol.fieldPopup.status
    if result == "OK" then
      Protocol.commandConfirm()
    elseif result == "CANCEL" then
      Protocol.fieldPopup = nil
    end
  elseif Protocol.fieldPopup.status == Protocol.CRSF.CMD_EXECUTING then
    if Protocol.fieldChunk == 0 then
      UI.commandRunningIndicator = (UI.commandRunningIndicator % 4) + 1
    end
    local result = popupCompat(
      Protocol.fieldPopup.info .. " [" .. string.sub("|/-\\", UI.commandRunningIndicator, UI.commandRunningIndicator) .. "]",
      "Press [RTN] to exit",
      event)
    Protocol.fieldPopup.lastStatus = Protocol.fieldPopup.status
    if result == "CANCEL" then
      Protocol.commandCancel()
    end
  end
end

-- ============================================================================
-- No Module screen (from elrs.lua checkCrsfModule error display)
-- ============================================================================

local function drawNoModule()
  lcd.clear()
  local y = 0
  lcd.drawText(2, y, "  No ExpressLRS", MIDSIZE)
  y = y + (UI.textSize * 2) - 2
  local msgs = {
    " Enable a CRSF Internal",
    "   or External module in",
    "       Model settings",
    "  If module is internal",
    " also set Internal RF to",
    " CRSF in SYS->Hardware",
  }
  for i, msg in ipairs(msgs) do
    lcd.drawText(2, y, msg)
    y = y + UI.textSize
    if i == 3 then
      lcd.drawLine(0, y, LCD_W, y, SOLID, INVERS)
      y = y + 2
    end
  end
end

-- ============================================================================
-- Mock data for simulator
-- ============================================================================

local function setMock()
  local _, rv = getVersion()
  if string.sub(rv, -5) ~= "-simu" then
    return
  end
  local mockModule = loadScript("/SCRIPTS/CRSFSimulator/csrfsimulator.lua")
  if mockModule == nil then
    return
  end
  local mock = mockModule()
  Protocol.pop = mock.pop
  Protocol.push = mock.push
  Protocol.hasCrsfModule = function()
    return mock.moduleFound
  end
end

-- ============================================================================
-- Init
-- ============================================================================

local function init()
  UI.init()
  setMock()
end

-- ============================================================================
-- Run (main coordinator)
-- ============================================================================

local function run(event, touchState)
  if event == nil then
    return 2
  end

  -- Check for CRSF module
  if not App.checkCrsfModule() then
    drawNoModule()
    return 0
  end

  -- CRSF polling
  local targetDevice, anyNewDevice = Protocol.poll()
  Protocol.tick()

  -- Check for ELRS 1.x firmware (unsupported)
  if Protocol.elrsV1Detected then
    lcd.clear()
    lcd.drawText(2, 0, "Unsupported Firmware", MIDSIZE)
    lcd.drawText(2, UI.textSize * 3, "ELRS 1.x firmware detected.")
    lcd.drawText(2, UI.textSize * 4, "Please update to 3.x.")
    return 0
  end

  -- Activate the target device if it announced/re-announced this cycle
  if targetDevice then
    App.loadDevice(targetDevice)
  end
  -- Refresh UI if a new device appeared
  if anyNewDevice then
    UI.invalidate()
  end

  -- Warning flashing timer
  local time = getTime()
  if time > UI.titleShowWarnTimeout then
    UI.titleShowWarn = (Protocol.elrsFlags > Protocol.CRSF.ELRS_FLAGS_STATUS_MASK and not UI.titleShowWarn) or nil
    UI.titleShowWarnTimeout = time + 100
    UI.forceRedraw = true
  end

  -- Folder ready detection + GC
  local currentFolder = Navigation.getCurrent()
  local folderReady = Protocol.isFolderLoaded(currentFolder)
  if folderReady and not UI.folderWasReady then
    collectgarbage("collect")
    UI.invalidate()
    if currentFolder == nil and not Protocol.backgroundLoading then
      Protocol.startBackgroundLoad()
    end
  end
  UI.folderWasReady = folderReady

  -- Force redraw during loading to show progress bar
  if #Protocol.loadQueue > 0 then
    UI.forceRedraw = true
  end

  -- Render: command popup or normal page
  if Protocol.fieldPopup ~= nil then
    UI.drawPopup(event)
  elseif event ~= 0 or UI.forceRedraw or UI.edit then
    UI.drawPage(event)
    UI.forceRedraw = false
  end

  if App.shouldExit then
    return 2
  end

  return 0
end

-- ============================================================================
-- Return
-- ============================================================================

return { init = init, run = run }
