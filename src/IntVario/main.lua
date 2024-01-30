-- *****************************************
-- user personalized config / customizing
-- *****************************************
local sensor 					= "Altitude"	-- please change in case altitude sensor has another label
local RECORDduration <const> 	= 20			-- duration in seconds for building average
local RESOLUTION <const> 		= 1				-- save/datapoint-interval in seconds


-- *****************************************
-- naming
local translations = {en="integr. Vario", de="integral Vario"}


-- constants:
local debugSW <const> 			= false				-- print debug info
local debugSW2 <const> 			= true	
local debugTele <const>         = false
local debugAtti <const> 		= true				-- print tx attitude 




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

	input = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, name = sensor})
--	input = system.getSource({ name = "Throttle"})

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

	if now >= timeNext then							-- .. and action:
		timeNext = now + RESOLUTION
		readPtr,writePtr 	= newPointer(readPtr)

		local altiNew 		= input:value()	
		local altiOld 		= ring[readPtr]			-- historical altitude
		ring[writePtr]		= altiNew				-- save new altitude
		print(readPtr, writePtr, altiOld,altiNew)
		local delta 		= altiNew-altiOld
		source:value(delta /RECORDduration )		-- calculate average climb last x seconds; 

		print(" ", "  ", "  srcVal:",source:value(),"delta:",delta)
	end


end

local function init()
  system.registerSource({key="avgVar1", name=name, init=sourceInit, wakeup=sourceWakeup})
end

return {init=init}