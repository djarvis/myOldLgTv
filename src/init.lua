-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local oldLgTv = require "oldlgtv"
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
local ltn12 = require('ltn12')

-- require custom handlers from driver package
local command_handlers = require "command_handlers"
local discovery = require "discovery"

-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding my old LG TV device")

  -- set a default or queried state for each capability attribute
  -- device:emit_event(capabilities.switch.switch.on())
end

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing my old LG TV device")

  -- mark device as online so it can be controlled from the app
  device:online()

  -- set a global
  TheDevice = device;

  -- set the device to OFF to start with
  log.debug("setting the device to OFF to start with:");
  TheDevice:emit_event(capabilities.switch.switch.on())

  -- 
  -- Kick off the polling timer
  --
  log.debug("kicking off the polling timer...")
  log.debug("device preferences refreshInterval is " .. device.preferences.refreshInterval)
  local num = tonumber(device.preferences.refreshInterval);
  log.debug("the number is " .. num);

   PollingTimer = driver:call_on_schedule(
    num,
    oldLgTv.pingTheTv,
    "pingTheTvTimer")

  --
  -- TEMP
  --
  -- log.debug("***********************************")
  -- log.debug("**********************************")
  -- local res_payload = {}
  --   local url1 = 'http://' .. TheDevice.preferences.ipAddress .. ':8080/roap/api/auth'
  --   log.debug("**************(): url is " .. url1)
  --   local authBody = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><auth><type>AuthReq</type><value>464855</value></auth>'
  --   -- local authBody = '<auth><type>AuthReq</type><value>464855</value></auth>'
  --   log.debug("****************(): body is " .. authBody)
  --   local _, code = http.request({
  --       url = url1,
  --       sink = ltn12.sink.table(res_payload),
  --       method='POST',
  --       source = ltn12.source.string(authBody),
  --       headers = {
  --           ["content-type"] = "application/atom+xml",
  --           ["connection"] = 'Keep-Alive',
  --           ["content-length"] = tostring(#authBody)
  --       },
  --   })

    -- log.debug("*******************(): got code of " .. code);

end

-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  log.info("[" .. device.id .. "] Removing my old LG TV device")
  log.debug("killing the PollingTimer")
  if (PollingTimer ~= nil) then
    driver:cancel_timer(PollingTimer)
    PollingTimer = nil
  end
end

-- create the driver object
local hello_world_driver = Driver("myoldlgtv", {
  discovery = discovery.handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = command_handlers.switch_on,
      [capabilities.switch.commands.off.NAME] = command_handlers.switch_off,
    },
  }
})

-- Globals
TvOnOrOff = false;






-- run the driver
log.debug("Running the driver..");
hello_world_driver:run()
