-- asr text for one round
local asr_text = nil;

package.path = ";/usr/share/freeswitch/scripts/xmlSimple.lua;;"
local xml_parse = require("xmlSimple.lua").newParser()
package.path ="/usr/share/freeswitch/scripts/json/json.lua;;"
local json = require("json.lua")

local uuid = session:getVariable("uuid")

local ___sessionId = os.time()
local ___requestId = 1

if(uuid ~= nil) then
	___sessionId = uuid
end


function cLog(level, log_str)
	freeswitch.consoleLog(level, log_str .. "\n")
end

function cLog_c(log_str)
	cLog("CRIT", log_str)
end

-- This is the input callback used by dtmf or any other events on this session such as ASR.
function onInput(s, type, obj)
    -- freeswitch.consoleLog("info", "Callback with type " .. type .. "\n");
    if (type == "dtmf") then
        cLog("info", "DTMF Digit: " .. obj.digit);
    elseif (type == "event") then
        local event = obj:getHeader("Speech-Type");
        if (event == "begin-speaking") then
            cLog("info", "speaking=" .. obj:serialize());
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

function ttsSpeak(speak_tts)
	session:speak(speak_tts)
end

function buildJsonReq(table)
    local table_req = {}
    
    table_req["requestId"] = table["requestId"] ~= nil and table["requestId"] or ("text" .. ___requestId)
	___requestId = ___requestId + 1

    table_req["sessionId"] = table["sessionId"] ~= nil and table["sessionId"] or ___sessionId
    table_req["phoneNo"] = table["phoneNo"] ~= nil and table["phoneNo"] or "13800010002"
    table_req["idSubTask"] = table["idSubTask"] ~= nil and table["idSubTask"] or "text2"
    table_req["obScene"] = table["obScene"] ~= nil and table["obScene"] or "8905"
    table_req["content"] = table["content"] ~= nil and table["content"] or ""
    
    local json_req = json.encode(table_req)
    
    -- local json_cmd = "http://localhost:3005/ content-type application/json post "
    local json_cmd = "https://voice-analysis.zgpajf.com.cn/dialogue/IvrForCmp/phoneticRecognition content-type application/json post "

    return json_cmd .. json_req
end

function handleResponse(response)
    assert(response ~= nil and response ~= "", "reponse body == nil or \"\"")  
	local states = "continue"

	repeat
    	--local response_body = string.match(response, "%c+({.+})", 1)
		--if (response_body == nil or response_body == "") then
		--	freeswitch.consoleLog("CRIT", "NLP没有相应任何有价值内容")
		--	states = "continue"
		--	break
		--end

    	-- 一定可以解析出来，如果待解析的字符串格式有问题，会直接报错
    	local json_ = json.decode(response) 
    	
    	-- code == 0 表示响应成功
    	if (json_["code"] == nil or json_["code"] ~= "0") then
			cLog_c("NLP 响应错误 ： " .. response)
			___sessionId = ___sessionId + 1
			states = "continue"
			break
    	end

		states = handleNLPResponse(json_["data"])
	until(0)

	return states
end


function handleNLPResponse(json_data)
    assert(json_data ~= nil and json_data ~= "", "json data == nil or \"\"") 

    local states = "continue"

	repeat
    	if (json_data["nextAction"] == "HANG_UP") then
			states = "hangup"
    	-- else if (json_data["nextAction"] == "HANG_UP") then
		-- 	states = "hangup"	
    	-- else 
		-- 	states = "hangup"
    	end

    	if (json_data["voiceList"] ~= nil and type(json_data["voiceList"]) == "table") then
			handleVoiceList(json_data["voiceList"])	
    	else
			cLog_c("NLP 接口响应报文参数错误 : " .. json_data)
			ttsSpeak("NLP接口响应报文参数错误")	
			states = "continue"
			break
    	end

	until(0)
    
    return states
end 


function handleVoiceList(voice_list)
    assert(voice_list ~= nil and type(voice_list) == "table", "voiceList == nil or voiceList ~= table")

    for i = 1, #voice_list do       
		if (type(voice_list[i]) == "table") then
		    if (voice_list[i]["voiceType"] ~= nil and voice_list[i]["voiceType"] == "AF") then
				-- ttsSpeak("此处应该播放一段音频")
				local record_name = ""
				if(voice_list[i]["voice"] ~= nil) then
					record_name = voice_list[i]["voice"]
				end
				session:execute("playback", "/usr/share/freeswitch/sounds/nlp_wav/" .. record_name)
		    else if (voice_list[i]["voiceType"] ~= nil and voice_list[i]["voiceType"] == "TT") then
				local tts_str = ""
				if(voice_list[i]["voice"] ~= nil) then
				    tts_str = voice_list[i]["voice"] 
				    tts_str = string.gsub(tts_str, "{.+}", "插插插") 
				end
				ttsSpeak(tts_str)
			end
			end
    	end
	end
end

-- local vars = {
--     "destination_number", "caller_id_name", "caller_id_number",
--     "network_addr", "uuid"
-- };
-- 
-- for k, v in pairs(vars) do
--     print(v .. ": " .. session:getVariable(v));
-- end

function handleNLP2TTS(table_req)
	local states = "continue"
	local json_req = buildJsonReq(table_req)

	cLog_c("Json Req = " .. json_req)
	session:execute("curl", json_req)

    local json_response = session:getVariable("curl_response_data")
	cLog_c("Json Response = " .. json_response)

	states = handleResponse(json_response)

	return states
end

-- Define the TTS engine
session:set_tts_params("unimrcp", "fduxiaowen")
-- Register the input callback
session:setInputCallback("onInput");
-- Sleep a little bit to get media time to be fully up
session:sleep(100);
session:execute("detect_speech", "unimrcp hello hello");
-- local caller_id_number = session:getVariable("caller_id_number");

if ( session:ready() == true ) then
	handleNLP2TTS({})
end

-- keep the thread alive
while ( session:ready() == true ) do
    if ( asr_text == nil ) then
        session:sleep(20);
    else
		local states = "continue"
        -- do your NLU here ?

        -- echo back the recognition result
    	cLog_c("Result is '\n" .. asr_text .. "'\n")

		parseXml = xml_parse:ParseXmlText(asr_text)
		if ((parseXml.result ~= nil) and (parseXml.result.asr ~= nil)) then
    	    cLog_c("xml parse result is xml_parse=" .. parseXml.result.asr:value())
		
			local asr_result = parseXml.result.asr:value()

			states = handleNLP2TTS({content = asr_result})
			if(states ~= nil and states == "hangup") then
				ttsSpeak("通话结束，祝您愉快，再见！")
				break
			end
		end

        asr_text = nil;

        session:execute("detect_speech", "resume");
    end
end


-- stop the detect_speech and hangup
session:execute("detect_speech", "stop");
session:sleep(1000);
session:hangup();
