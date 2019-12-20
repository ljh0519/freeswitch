-- asr text for one round
session:setAutoHangup(false)
local asr_text = [[<?xml version="1.0" encoding="UTF-8" ?>
<result>
	<asr confidence="100">你好</asr>
</result>
]]

package.path = ";/usr/share/freeswitch/scripts/xmlSimple.lua;;"
local xml_parse = require("xmlSimple.lua").newParser()
package.path ="/usr/share/freeswitch/scripts/json.lua;;"
local json = require("json.lua")

local uuid = session:getVariable("uuid")
local NLP_sessionId = session:getVariable("sip_h_X-NLP-sessionId")
local NLP_phoneNo = session:getVariable("sip_h_X-NLP-phoneNo")
local NLP_idSubTask = session:getVariable("sip_h_X-NLP-idSubTask")
local NLP_obScene = session:getVariable("sip_h_X-NLP-obScene")

-- if(uuid ~= nil) then 
-- 	freeswitch.consoleLog("CRIT", "uuid: " .. uuid)
-- end
-- if(NLP_sessionId ~= nil) then 
-- 	freeswitch.consoleLog("CRIT", "NLP_sessionId : " .. NLP_sessionId)
-- end
-- if(NLP_phoneNo ~= nil) then 
-- 	freeswitch.consoleLog("CRIT", "NLP_phoneNo : " .. NLP_phoneNo)
-- end
-- if(NLP_idSubTask ~= nil) then 
-- 	freeswitch.consoleLog("CRIT", "NLP_idSubTask : " .. NLP_idSubTask)
-- end
-- if(NLP_obScene ~= nil) then 
-- 	freeswitch.consoleLog("CRIT", "NLP_obScene : " .. NLP_obScene)
-- end


function SipRobotInstance() 
	obj = {}

	obj.___sessionId = NLP_sessionId ~= nil and NLP_sessionId or os.time()
	obj.___requestId = 1
	obj.___phoneNo = NLP_phoneNo ~= nil and NLP_phoneNo or "13800010002"
	obj.___idSubTask = NLP_idSubTask ~= nil and NLP_idSubTask or "text2"
	obj.___obScene = NLP_obScene ~= nil and NLP_obScene or "8905"
	
	if(uuid ~= nil) then
		obj.___sessionId = uuid
	end

	obj.cLog = function (level, log_str)
		freeswitch.consoleLog(level, log_str .. "\n")
	end
	
	obj.cLog_c = function (log_str)
		obj.cLog("CRIT", log_str)
	end
	
	obj.ttsSpeak = function (speak_tts)
		session:speak(speak_tts)
	end
	
	obj.buildJsonReq = function (content)
	    local table_req = {}
	    
	    table_req["requestId"] = obj.___sessionId .. obj.___requestId
		obj.___requestId = obj.___requestId + 1
	
	    table_req["sessionId"] = obj.___sessionId
	    table_req["phoneNo"] = obj.___phoneNo
	    table_req["idSubTask"] = obj.___idSubTask
	    table_req["obScene"] = obj.___obScene
	    table_req["content"] = content ~= nil and content or "no%20result"
	    
	    local json_req = json.encode(table_req)
	    
	    -- local json_cmd = "http://localhost:3005/ content-type application/json post "
	    local json_cmd = "https://voice-analysis.zgpajf.com.cn/dialogue/IvrForCmp/phoneticRecognition content-type application/json post "
	
	    return json_cmd .. json_req
	end
	
	obj.handleResponse = function (response)
		local states = "continue"
		if (response == nil or response == "") then 
			states = "repeat"	
			return states
		end
	
		repeat
	    		-- 一定可以解析出来，如果待解析的字符串格式有问题，会直接报错
	    		local json_ = json.decode(response) 
	    	
	    		-- code == 0 表示响应成功
	    		if (json_["code"] == nil or json_["code"] ~= "0") then
				obj.cLog_c("NLP 响应错误 ： " .. response)
				states = "repeat"
				break
	    		end
	
			states = obj.handleNLPResponse(json_["data"])
		until(0)
	
		return states
	end
	
	
	obj.handleNLPResponse = function (json_data)
		local states = "continue"
		if(json_data == nil or json_data == "") then
			states = "repeat"
			return states	
		end
	
		repeat
	    		if (json_data["nextAction"] == "HANG_UP") then
				states = "hangup"
	    		end
	
	    		if (json_data["voiceList"] ~= nil and type(json_data["voiceList"]) == "table") then
				obj.handleVoiceList(json_data["voiceList"])	
	    		else
				obj.cLog_c("NLP 接口响应报文参数错误 : " .. json_data)
				states = "repeat"
				break
	    		end
		until(0)
	    
		return states
	end 
	
	
	obj.handleVoiceList = function (voice_list)
		local states = "continue"
		if(voice_list == nil or type(voice_list) ~= "table") then
			states = "repeat"
			return states
		end
	
		for i = 1, #voice_list do       
			if (type(voice_list[i]) == "table") then
			    	if (voice_list[i]["voiceType"] ~= nil and voice_list[i]["voiceType"] == "AF") then
					local record_name = ""
					if(voice_list[i]["voice"] ~= nil) then
						record_name = voice_list[i]["voice"]
					end
					session:execute("playback", "/usr/share/freeswitch/sounds/nlp_wav/" .. record_name)
			    	elseif (voice_list[i]["voiceType"] ~= nil and voice_list[i]["voiceType"] == "TT") then
					local tts_str = ""
					if(voice_list[i]["voice"] ~= nil) then
					    tts_str = voice_list[i]["voice"] 
					    tts_str = string.gsub(tts_str, "{clientName}", "王先生") 
					    tts_str = string.gsub(tts_str, "{diagnosisDate}", "感冒") 
					    tts_str = string.gsub(tts_str, "{hosName}", "第一人民医院") 
					    tts_str = string.gsub(tts_str, "{patAmt}", "398") 
					    tts_str = string.gsub(tts_str, "{patAmt}", "298") 
					    tts_str = string.gsub(tts_str, "{birthDate}", "一九八九年十一月一日") 
					    tts_str = string.gsub(tts_str, "{sex}", "男") 
					end
					obj.ttsSpeak(tts_str)
				else 
					states = "repeat"
				end
	    		end
		end
		return states
	end

	return obj
end

local SipRobot = SipRobotInstance()

-- This is the input callback used by dtmf or any other events on this session such as ASR.
function onInput(s, type, obj)
    -- freeswitch.consoleLog("info", "Callback with type " .. type .. "\n");
    if (type == "dtmf") then
        SipRobot.cLog("info", "DTMF Digit: " .. obj.digit);
    elseif (type == "event") then
        local event = obj:getHeader("Speech-Type");
        if (event == "begin-speaking") then
            SipRobot.cLog("info", "speaking=" .. obj:serialize());
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
	
-- local vars = {
--     "destination_number", "caller_id_name", "caller_id_number",
--     "network_addr", "uuid"
-- };
-- 
-- for k, v in pairs(vars) do
--     print(v .. ": " .. session:getVariable(v));
-- end

function handleNLP2TTS(asr_result)
	local states = "continue"
	local bNError = true
	local json_req = SipRobot.buildJsonReq(asr_result)

	SipRobot.cLog_c("Json Req = " .. json_req)
	session:execute("curl", json_req)

    	local json_response = session:getVariable("curl_response_data")
	SipRobot.cLog_c("Json Response = " .. json_response)

	bNError,states = pcall(SipRobot.handleResponse,json_response)
	if not(bNError) then
		SipRobot.cLog_c("handleNLP2TTS failed : " .. states)
		states = "repeat"
	end

	return states
end

-- Define the TTS engine
session:set_tts_params("unimrcp", "fduxiaowen")
-- Register the input callback
session:setInputCallback("onInput");
-- Sleep a little bit to get media time to be fully up
session:execute("detect_speech", "unimrcp hello hello");
session:sleep(100);
-- local caller_id_number = session:getVariable("caller_id_number");

-- keep the thread alive
while ( session:ready() == true ) do 
    if ( asr_text == nil ) then
        session:sleep(20);
    else
	local states = "continue"
        -- do your NLU here ?

	repeat
        	-- echo back the recognition result
    		-- SipRobot:cLog_c("Result is '\n" .. asr_text .. "'\n")
		
		local first_pos = string.find(asr_text,"Completion%-Cause")

		if (first_pos ~= nil or asr_text == "") then
			states = handleNLP2TTS()
		else
			parseXml = xml_parse:ParseXmlText(asr_text)
			if(parseXml.result == nil) then
				break
			end

			local asr_value = parseXml.result.asr:value()

			if (asr_value ~= nil) then
    				SipRobot.cLog_c("xml parse result is xml_parse=" .. asr_value)
				states = handleNLP2TTS(asr_value)
			end
		end
	until(0)

	if(states ~= nil and states == "hangup") then
		SipRobot.ttsSpeak("通话结束")
		break
	elseif (states ~= nil and states == "repeat") then
		asr_text = ""
	else
        	asr_text = nil;
        	session:execute("detect_speech", "resume");
	end
    end
end


-- stop the detect_speech and hangup
session:execute("detect_speech", "stop");
session:sleep(500);
session:hangup();
