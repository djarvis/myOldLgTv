-- new
local capabilities = require "st.capabilities"
local utils = require('st.utils')
local neturl = require('net.url')
local log = require('log')
local json = require('dkjson')
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
local ltn12 = require('ltn12')


-- old
-- local http = require("socket.http")
-- local ltn12 = require "ltn12"
-- local https = require ('ssl.https')

function authenticate()
    log.debug("authenticate(): begin");

    http.TIMEOUT = tonumber(TheDevice.preferences.httpTimeout)

    local res_payload = {}
    local url = 'http://' .. TheDevice.preferences.ipAddress .. ':8080/roap/api/auth'
    log.debug("authenticate(): url is " .. url)
    local authBody = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><auth><type>AuthReq</type><value>464855</value></auth>'
    -- local authBody = '<auth><type>AuthReq</type><value>464855</value></auth>'
    log.debug("authenticate(): body is " .. authBody)
    local _, code = http.request({
        url = url,
        sink = ltn12.sink.table(res_payload),
        method='POST',
        source = ltn12.source.string(authBody),
        headers = {
            ["content-type"] = "application/atom+xml",
            ["connection"] = 'Keep-Alive',
            ["content-length"] = tostring(#authBody)
        },
    })

    log.debug("authenticate(): got code of " .. code);

    -- local inspectTheResult = inspect.inspect(res_payload)
    -- print "inspectTheResult:"
    -- print (inspectTheResult)

    local resultString = table.concat(res_payload);
    -- print ("Made the auth call and got code:" .. code)
    print ("authenticate(): and got data: " .. resultString);

    -- -- try to parse...
    -- local resultTable = xmlParser.parse(resultString)
    -- local inspectString = inspect.inspect(resultTable.children[1].children[1].children[1].text)
    -- print "inspectString:"
    -- print (inspectString)

    return (code==200)
end


return {

    
    pingTheTv = function()
        http.TIMEOUT = tonumber(TheDevice.preferences.httpTimeout)
        log.debug("pingTheTv(): begin");
        local res_payload = {}
        local url = 'http://' .. TheDevice.preferences.ipAddress .. ':8080';
        log.debug("pingTheTv(): url is " .. url)
        local _, code = http.request({
            url = url,
            sink = ltn12.sink.table(res_payload),
            method='GET',
        })
        if (code == 404) then
          log.debug("pingTheTv(): TV is on")
          if (TvOnOrOff == false) then
              TvOnOrOff = true;
              log.debug("pingTheTv(): emitting device switch to ON")
              TheDevice:emit_event(capabilities.switch.switch.on())
              log.debug("pingTheTv(): and also calling authenticate()");
              authenticate();
          end
          return true
        else
            log.debug("pingTheTv(): TV is off, code was " .. code);
            if (TvOnOrOff == true) then
                TvOnOrOff = false;
                log.debug("pingTheTv(): emitting device switch to OFF")
                TheDevice:emit_event(capabilities.switch.switch.off())
            end
            return false;
        end
    end,




    



    powerTheTv = function()
        
        log.debug("powerTheTv(): begin")

        http.TIMEOUT = tonumber(TheDevice.preferences.httpTimeout)

        local powerBody = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><command><value>1</value><name>HandleKeyInput</name></command>'
        local res_payload = {}
        local url = 'http://' .. TheDevice.preferences.ipAddress .. ':8080/roap/api/command'
        log.debug("powerTheTv(): url is [" .. url .. "]")
        log.debug("powerTheTv(): powerBody is " .. powerBody);
        local _, code = http.request({
            url = url,
            sink = ltn12.sink.table(res_payload),
            method='POST',
            source = ltn12.source.string(powerBody),
            headers = {
                ["content-type"] = "application/atom+xml",
                ["connection"] = 'Keep-Alive',
                ["content-length"] = tostring(#powerBody)
            },
        })
        -- local resultString = table.concat(res_payload);
        log.debug("powerTheTv(): Made the power call and got code:" .. code)
        -- print ("and got data: " .. resultString);
        return (code==200)
    end,




    muteTheTv = function()
        http.TIMEOUT = tonumber(TheDevice.preferences.httpTimeout)
        log.debug("muteTheTv(): begin")

        local muteBody = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><command><value>26</value><name>HandleKeyInput</name></command>'
        local res_payload = {}
        local _, code = http.request({
            url = 'http://' .. TheDevice.preferences.ipAddress .. ':8080/roap/api/command',
            sink = ltn12.sink.table(res_payload),
            method='POST',
            source = ltn12.source.string(muteBody),
            headers = {
                ["content-type"] = "application/atom+xml",
                ["connection"] = 'Keep-Alive',
                ["content-length"] = tostring(#muteBody)
            },
        })
        -- local resultString = table.concat(res_payload);
        log.debug("Made the mute call and got code:" .. code)
        -- print ("and got data: " .. resultString);
        return (code==200)
    end,






    -- turnItOff = function(d)
    --     log.debug("turnItOff(): begin");
    --     local res_payload = {}
    --     local _, code = http.request({
    --         url = 'http://192.168.1.2:3333/light',
    --         sink = ltn12.sink.table(res_payload),
    --         method='POST',
    --         source = ltn12.source.string(d),
    --         headers = {
    --             ["content-type"] = "application/json", -- change if you're not sending JSON
    --             ["content-length"] = tostring(#d)
    --         },
    --     })

    --     local resultString = table.concat(res_payload);
    --     log.debug("callLight(): made the call to http://192.168.1.2:3333/light, response was:");
    --     log.debug(string.format("code=[%s]", code))
    --     log.debug("callLight(): " .. resultString)

    --     print(table.concat(res_payload))
    -- end

}