session:answer()

--freeswitch.consoleLog("INFO", "Called extension is '".. argv[1]"'\n")
welcome = "ivr/ivr-welcome_to_freeswitch.wav"
--
package.path = ";/usr/share/freeswitch/scripts/xmlSimple.lua;;"
local xml_parse = require("xmlSimple.lua").newParser()

grammar = "hello"
no_input_timeout = 5000
recognition_timeout = 5000
--
--[[
session:set_tts_params("unimrcp", "default")
session:speak("这是一个测试")
session:sleep(1000)
]]


tryagain = 1
while (tryagain == 1) do
--
    session:execute("play_and_detect_speech",welcome .. "detect:unimrcp {start-input-timers=false,no-input-timeout=" .. no_input_timeout .. ",recognition-timeout=" .. recognition_timeout .. "}" .. grammar)
    xml = session:getVariable('detect_speech_result')
 --
    if (xml == nil) then
        freeswitch.consoleLog("CRIT","Result is 'nil'\n")
        tryagain = 0
    else
        freeswitch.consoleLog("CRIT","Result is '" .. xml .. "'\n")

		local parseXml = xml_parse:ParseXmlText(asr_text)
		if ((parseXml.result ~= nil) and (parseXml.result.asr ~= nil)) then
			local asr_result = parseXml.result.asr:value()
			session:speak(asr_result)
		end
    end
end
--
-- put logic to forward call here
--
session:sleep(250)
session:hangup()
