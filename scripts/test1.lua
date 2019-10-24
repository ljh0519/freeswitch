-- asr text for one round
local asr_text = nil;

package.path = package.path .. ";/usr/share/freeswitch/scripts/xmlSimple.lua"


-- This is the input callback used by dtmf or any other events on this session such as ASR.
function onInput(s, type, obj)
    -- freeswitch.consoleLog("info", "Callback with type " .. type .. "\n");
    if (type == "dtmf") then
        freeswitch.consoleLog("info", "DTMF Digit: " .. obj.digit .. "\n");
    elseif (type == "event") then
        local event = obj:getHeader("Speech-Type");
        if (event == "begin-speaking") then
            freeswitch.consoleLog("info", "speaking=" .. obj:serialize() .. "\n");
            -- Return break on begin-speaking events to stop playback of the fire or tts.
            return "break";
        end

        if ( event == "detected-speech" ) then
            -- freeswitch.consoleLog("info", "\n" .. obj:serialize() .. "\n");
            local text = obj:getBody();
            if ( text ~= "(null)" ) then
                -- Pause speech detection (this is on auto but pausing it just in case)
                session:execute("detect_speech", "pause");

                -- Parse the results from the event into the results table for later use.
                -- results = getResults(obj:getBody());

                -- set the global asr text for later use
                asr_text = text;
            end
            -- return "break";
        end
    end
end


session:answer();

-- local vars = {
--     "destination_number", "caller_id_name", "caller_id_number",
--     "network_addr", "uuid"
-- };
-- 
-- for k, v in pairs(vars) do
--     print(v .. ": " .. session:getVariable(v));
-- end


local xml_parse = require("xmlSimple.lua").newParser()

-- Define the TTS engine
session:set_tts_params("unimrcp", "fduxiaowen")
-- Register the input callback
session:setInputCallback("onInput");
-- Sleep a little bit to get media time to be fully up
session:sleep(100);
session:speak("请说");
session:execute("detect_speech", "unimrcp hello hello");
-- local caller_id_number = session:getVariable("caller_id_number");

-- keep the thread alive
while ( session:ready() == true ) do
    if ( asr_text == nil ) then
        session:sleep(20);
    elseif ( asr_text == "" ) then
        session:speak("没听清你说什么，请再说一遍");
        asr_text = nil;
        session:execute("detect_speech", "resume");
    else
        -- do your NLU here ?

        -- echo back the recognition result
	parseXml = xml_parse:ParseXmlText(asr_text)
        freeswitch.consoleLog("CRIT","Result is '\n" .. asr_text .. "'\n")
	if ((parseXml.result ~= nil) and (parseXml.result.asr ~= nil)) then
            freeswitch.consoleLog("CRIT","xml parse result is xml_parse='" .. parseXml.result.asr:value() .. "'\n")
	    
	
	    session:speak(parseXml.result.asr:value())
	end

        asr_text = nil;

        session:execute("detect_speech", "resume");
    end
end












-- stop the detect_speech and hangup
session:execute("detect_speech", "stop");
session:sleep(1000);
session:hangup();
