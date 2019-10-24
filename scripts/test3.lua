session:answer()

package.path = package.path .. ";/usr/share/freeswitch/scripts/xmlSimple.lua"
--freeswitch.consoleLog("INFO", "Called extension is '".. argv[1]"'\n")
welcome = "ivr/ivr-welcome_to_freeswitch.wav"
--
--[[
grammar = "hello"
no_input_timeout = 5000
recognition_timeout = 10000

local xml_parse = require("xmlSimple.lua").newParser()

-- session:set_tts_params("unimrcp", "fduxiaowen")
session:sleep(1000)
]]

local dest_context = session:getVariable("context")
local dest_number = session:getVariable("destination_number")
local cid_name = session:getVariable("caller_id_name")
local cid_number = session:getVariable("caller_id_number")
local ani = session:getVariable("ani")
local uuid = session:getVariable("uuid")
local dialplan = session:getVariable("dialplan")
local sip_from_uri = session:getVariable("sip_from_uri")
local sip_contact_params = session:getVariable("sip_contact_params")
local sip_contact_user = session:getVariable("sip_contact_user")
local switch_r_sdp = session:getVariable("switch_r_sdp")
local sip_contact_port = session:getVariable("sip_contact_port")
local switch_r_sdp = session:getVariable("switch_r_sdp")
local sip_contact_uri = session:getVariable("sip_contact_uri")
local sip_contact_host = session:getVariable("sip_contact_host")
local sip_from_user_stripped = session:getVariable("sip_from_user_stripped")
local sip_full_from = session:getVariable("sip_full_from")
--local sip_h_P-Key-Flags = session:getVariable("sip_h_P-Key-Flags")
local sip_received_ip = session:getVariable("sip_received_ip")
local sip_received_port = session:getVariable("sip_received_port")
local sip_authorized = session:getVariable("sip_authorized")
local sip_mailbox = session:getVariable("sip_mailbox")
local sip_auth_username = session:getVariable("sip_auth_username")
local sip_auth_realm = session:getVariable("sip_auth_realm")
local mailbox = session:getVariable("mailbox")
local user_name = session:getVariable("user_name")
local domain_name = session:getVariable("domain_name")
local record_stereo = session:getVariable("record_stereo")
local accountcode = session:getVariable("accountcode")
local user_context = session:getVariable("user_context")
local effective_caller_id_name = session:getVariable("effective_caller_id_name")
local effective_caller_id_number = session:getVariable("effective_caller_id_number")
local caller_domain = session:getVariable("caller_domain")
local sip_from_user = session:getVariable("sip_from_user")
local sip_from_uri = session:getVariable("sip_from_uri")
local sip_from_host = session:getVariable("sip_from_host")
local sip_from_tag = session:getVariable("sip_from_tag")
local sofia_profile_name = session:getVariable("sofia_profile_name")
local sofia_profile_domain_name = session:getVariable("sofia_profile_domain_name")
local sip_req_params = session:getVariable("sip_req_params")
local sip_h_hehe = session:getVariable("sip_h_X-hehe")
local Im_header = session:getVariable("sip_h_X-Im-header")
local hehe = session:getVariable("hehe")
--local state = session:getVariable("state")
--local destination = session:getVariable("destination")
freeswitch.consoleLog("CRIT"," ------------------------------------------------- \n")
if(switch_r_sdp ~= nil) then
	freeswitch.consoleLog("CRIT"," switch_r_sdp = " .. switch_r_sdp .. "\n")
end
if(sip_from_uri ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_from_uri = " .. sip_from_uri .. "\n")
end
if(sip_from_user_stripped ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_from_user_stripped = " .. sip_from_user_stripped .. "\n")
end
if(sip_full_from ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_full_from = " .. sip_full_from .. "\n")
end

if(sip_contact_user ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_contact_user = " .. sip_contact_user .. "\n")
end
if(sip_contact_params ~= nil) then 
	freeswitch.consoleLog("CRIT"," sip_contact_params = " .. sip_contact_params .. "\n")
end
if(sip_contact_port ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_contact_port = " .. sip_contact_port .. "\n")
end
if(sip_contact_uri ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_contact_uri = " .. sip_contact_uri .. "\n")
end
if(sip_contact_host ~= nil) then
	freeswitch.consoleLog("CRIT"," sip_contact_host = " .. sip_contact_host .. "\n")
end

if(dialplan ~= nil) then
freeswitch.consoleLog("CRIT"," dialplan = " .. dialplan .. "\n")
end

--freeswitch.consoleLog("CRIT"," state = " .. state .. "\n")
--freeswitch.consoleLog("CRIT"," destination = " .. destination .. "\n")
if(dest_context ~= nil) then
freeswitch.consoleLog("CRIT"," dest_context = " .. dest_context .. "\n")
end
if(dest_number ~= nil) then
freeswitch.consoleLog("CRIT"," dest_number = " .. dest_number .. "\n")
end
if(cid_name ~= nil) then
freeswitch.consoleLog("CRIT"," cid_name = " .. cid_name .. "\n")
end
if(cid_number ~= nil) then
freeswitch.consoleLog("CRIT"," cid_number = " .. cid_number .. "\n")
end
if(ani ~= nil) then
freeswitch.consoleLog("CRIT"," ani = " .. ani .. "\n")
end
if(uuid ~= nil) then
freeswitch.consoleLog("CRIT"," uuid = " .. uuid .. "\n")
end

if(sip_h_hehe ~= nil) then
 freeswitch.consoleLog("CRIT", " sip_h_hehe = " .. sip_h_hehe .. "\n")
end 

if(hehe ~= nil) then
	freeswitch.consoleLog("CRIT"," hehe = " .. hehe .. "\n")
end

if(Im_header ~= nil) then
	freeswitch.consoleLog("CRIT"," Im_header = " .. Im_header .. "\n")
end
freeswitch.consoleLog("CRIT"," ------------------------------------------------- \n")
--[[
tryagain = 1
while (tryagain == 1) do
--
    -- session:execute("play_and_detect_speech",welcome .. "detect:unimrcp {start-input-timers=true"..",no-input-timeout=" .. no_input_timeout .. ",recognition-timeout=" .. recognition_timeout .. "}" .. grammar)
    session:execute("detect_speech","unimrcp hello /usr/share/freeswitch/grammer/")
    xml = session:getVariable('detect_speech_result')
 --
    if (xml == nil) then
        freeswitch.consoleLog("CRIT","Result is 'nil'\n")
	tryagain = 0
    else
	parseXml = xml_parse:ParseXmlText(xml)
        freeswitch.consoleLog("CRIT","Result is '\n" .. xml .. "'\n")
        freeswitch.consoleLog("CRIT","xml parse result is xml_parse='" .. parseXml.result.asr:value() .. "'\n")
	-- session:speak(parseXml.result.asr:value())
    end
end
]]
--
-- put logic to forward call here
--
session:sleep(250)
session:hangup()


