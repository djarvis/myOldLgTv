local log = require "log"
local capabilities = require "st.capabilities"
local oldLgTv = require "oldlgtv"
local command_handlers = {}

-- callback to handle an `on` capability command
function command_handlers.switch_on(driver, device, command)
  log.debug("switch_on(): begin.  Can't do anything here.");

  
  --
  -- If the TV is off we cannot really power the TV
  --

  -- device:emit_event(capabilities.switch.switch.on())
end

-- callback to handle an `off` capability command
function command_handlers.switch_off(driver, device, command)
  log.debug("switch_off(): begin");

  log.debug("calling powerTheTv()")
  local res = oldLgTv.powerTheTv();
  -- local res = oldLgTv.authenticate();
  -- local res = authenticate();
  if (res == true) then
    log.debug("switch_off(): called powerTheTv() and it was successful")
    device:emit_event(capabilities.switch.switch.off())
    TvOnOrOff = false;
  else
    log.debug("switch_off() tried calling powerTheTv() but it was just not successful")
  end
  
end

return command_handlers
