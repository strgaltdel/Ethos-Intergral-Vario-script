--- The lua script "integral vario" is licensed under the 3-clause BSD license (aka "new BSD")
---
-- Copyright (c) 2024, Udo Nowakowksi
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--	 * Redistributions of source code must retain the above copyright
--	   notice, this list of conditions and the following disclaimer.
--	 * Redistributions in binary form must reproduce the above copyright
--	   notice, this list of conditions and the following disclaimer in the
--	   documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL SPEEDATA GMBH BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- Revisions
-- 0.8	240131 initial beta roll out
-- 0.81	240101 added functionality for simple sensor "unit translation" without ringbuffer


-- *****************************************
-- user personalized config / customizing
-- *****************************************
local sensor 					= "Altitude"	-- please change in case altitude sensor has another label
--local sensor 					= "RSSI"		-- just an example in case you want to convert the unit in realtime

local RECORDduration <const> 	= 20			-- duration in seconds for building average
local RESOLUTION <const> 		= 1			-- save/datapoint-interval in seconds; set to -1 let ruun in realtime "unit conversion"


-- *****************************************
-- naming
local translations = {en="integr. Vario", de="integral Vario"}


-- constants:
local debugSW <const> 			= false				-- print debug info
local debugSW2 <const> 			= true	
local debugTele <const>        	= false
local debugAtti <const> 		= true				-- print tx attitude 

local SIM <const> 				= false				-- standard: false; sim mode: true
local DIVISOR <const>			= 1024/ 10			-- sim range +/- 10m



-- **********************
-- don't change:
-- **********************

local input 							-- input/source (aka alti)
local timeNext= os.clock() + RESOLUTION	-- timestamp for next cycle
--local timeLast							-- timestamp last saved item 
local ring = {}							-- value array ("ringbuffer")
local readPtr = 1						-- array readPtr
local writePtr =0
local NUMentries <const> = math.floor(RECORDduration / RESOLUTION+0.5)

local onFirstRun = true			-- flag very first run


for i = 1,NUMentries do				-- init ringbuffer
	ring[i] = 0
end


-- **********************
-- here we go
-- **********************

local function name(widget)
  local locale = system.getLocale()
  return translations[locale] or translations["en"]
end


---------------
--  init source variable, used to control two LSW's
---------------
local function sourceInit(source)
	source:value(0)
	source:decimals(1)
	source:unit(UNIT_METER_PER_SECOND)

	if SIM then
		input = system.getSource({ name = "Throttle"})
	else
		input = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, name = sensor})
	end

 end

---------------
--  determine new pointer
---------------
local function newPointer(readP)
	readP = readP + 1

	if readP > NUMentries then
		readP = 1
	end
	local writeP = readP -1
	if writeP == 0 then
		writeP = NUMentries
	end
	return readP, writeP
end
 


---------------
--  main handler
---------------
local function sourceWakeup(source)
	local now = os.clock()

	if RESOLUTION > 0 then
		if now >= timeNext then							-- .. and action:
			timeNext = now + RESOLUTION
			readPtr,writePtr 	= newPointer(readPtr)

			local altiNew 		= input:value()	
			if SIM then
				altiNew = (1024/DIVISOR) + altiNew /DIVISOR
			end
			local altiOld 		= ring[readPtr]			-- historical altitude
			ring[writePtr]		= altiNew				-- save new altitude
			--print(readPtr, writePtr, altiOld,altiNew)
			local delta 		= altiNew-altiOld
			source:value(delta /RECORDduration )		-- calculate average climb last x seconds; 

			print(altiOld,altiNew, "  srcVal:",source:value(),"delta:",delta)
		end
	else
		local sensVal 		= input:value()
		source:value(sensVal * 1.0)
	end
	

end

local function init()
  system.registerSource({key="avgVar1", name=name, init=sourceInit, wakeup=sourceWakeup})
end

return {init=init}