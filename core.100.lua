-- ObjecX Core Framework v1.0.0 (FINAL + GRINDSTONE)
-- Type: LocalScript | Parent: StarterPlayer.StarterPlayerScripts

-- Old C functions backup
local oldIsFolder = isfolder
local oldIsFile = isfile
local oldMakeFolder = makefolder
local oldReadFile = readfile
local oldWriteFile = writefile
local oldDelFile = delfile
local oldDelFolder = delfolder

-- Environment Variables
local CVersion = 100
local DefGcomptable = {100}
local SelfScript = ""
local CACHE_MISS = 0
local HARD_SHUTDOWN = 0
local CRASH_DETECTED = 0

-- GitHub Repository Configuration
local GITHUB_REPO = "https://raw.githubusercontent.com/ruptorx-sourcer/ObjecX/main/"

-- Cached network data to avoid duplicate calls
local cachedGuiVersion = nil
local cachedGuiList = nil

-- StarterGui for Roblox notifications
local StarterGui = game:GetService("StarterGui")

-- ========================================
-- GRINDSTONE HASH SYSTEM
-- ========================================
local Grindstone = {}

-- Constants
local SALT = 0x9e3779b9
local PEPPER = 0x517cc1b7
local primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}
local fib = {1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610}

local function avalanche(hash)
    hash = bit32.bxor(hash, bit32.rshift(hash, 16))
    hash = (hash * 0x85ebca6b) % 0xFFFFFFFF
    hash = bit32.bxor(hash, bit32.rshift(hash, 13))
    hash = (hash * 0xc2b2ae35) % 0xFFFFFFFF
    hash = bit32.bxor(hash, bit32.rshift(hash, 16))
    return hash
end

local function generateFromSeed(data)
    local len = #data
    if len == 0 then return "" end
    
    local seed1, seed2, seed3 = 0, 0, 0
    
    for i = 1, len do
        local byte = string.byte(data, i)
        seed1 = (seed1 * 31 + byte) % 0xFFFFFFFF
        seed2 = bit32.bxor(seed2, bit32.lrotate(byte, i % 13))
        seed3 = (seed3 + byte * i) % 0xFFFFFFFF
    end
    
    seed1 = bit32.bxor(seed1, SALT)
    seed2 = bit32.bxor(seed2, PEPPER)
    seed3 = bit32.bxor(seed3, bit32.bxor(SALT, PEPPER))
    
    local a = 1103515245
    local c = 12345
    local m = 0xFFFFFFFF
    
    local generated = {}
    local state = bit32.bxor(seed1, bit32.lrotate(seed2, 16))
    state = bit32.bxor(state, seed3)
    
    local targetLen = len * 8
    for i = 1, targetLen do
        state = (a * state + c) % m
        
        local prime = primes[(i % #primes) + 1]
        local f = fib[(i % #fib) + 1]
        
        local mixed = bit32.bxor(state, seed1 * prime)
        mixed = bit32.bxor(mixed, bit32.lrotate(seed2, i % 17))
        mixed = bit32.bxor(mixed, bit32.rrotate(seed3, i % 23))
        mixed = (mixed + f) % 0xFFFFFFFF
        
        local byte = bit32.band(bit32.rshift(mixed, (i % 4) * 8), 0xFF)
        
        table.insert(generated, string.char(byte))
    end
    
    return table.concat(generated)
end

local function compressHash(data)
    local len = #data
    if len == 0 then return "00000000" end
    
    local expanded = generateFromSeed(data)
    expanded = generateFromSeed(expanded)
    expanded = generateFromSeed(expanded)
    local expandedLen = #expanded
    
    local temp_xor = 0
    for i = 1, expandedLen do
        temp_xor = bit32.bxor(temp_xor, string.byte(expanded, i))
    end
    
    local temp_and = 0xFF
    for i = 1, expandedLen do
        temp_and = bit32.band(temp_and, string.byte(expanded, i))
    end
    
    local q1, q2, q3, q4, q5, q6, q7, q8 = 0, 0, 0, 0, 0, 0, 0, 0
    local eighth = math.floor(expandedLen / 8)
    
    for i = 1, math.max(1, eighth) do
        local byte = string.byte(expanded, i)
        local prime = primes[(i % #primes) + 1]
        local f = fib[(i % #fib) + 1]
        q1 = bit32.bxor(q1, bit32.lrotate(byte, i % 8))
        q1 = (q1 + byte * prime * f) % 0xFFFFFFFF
    end
    
    for i = eighth + 1, math.max(eighth + 1, eighth * 2) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            local prime = primes[(i % #primes) + 1]
            q2 = bit32.bxor(q2, bit32.rrotate(byte, i % 8))
            q2 = (q2 + byte * prime) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 2 + 1, math.max(eighth * 2 + 1, eighth * 3) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            local f = fib[(i % #fib) + 1]
            q3 = bit32.bxor(q3, bit32.lrotate(byte, (expandedLen - i) % 8))
            q3 = (q3 + byte * f) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 3 + 1, math.max(eighth * 3 + 1, eighth * 4) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            q4 = bit32.bxor(q4, bit32.rrotate(byte, (expandedLen - i) % 8))
            q4 = (q4 + byte * 43) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 4 + 1, math.max(eighth * 4 + 1, eighth * 5) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            local prime = primes[(i % #primes) + 1]
            q5 = bit32.bxor(q5, bit32.lrotate(byte, i % 11))
            q5 = (q5 + byte * prime) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 5 + 1, math.max(eighth * 5 + 1, eighth * 6) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            local f = fib[(i % #fib) + 1]
            q6 = bit32.bxor(q6, bit32.rrotate(byte, i % 7))
            q6 = (q6 + byte * f) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 6 + 1, math.max(eighth * 6 + 1, eighth * 7) do
        if i <= expandedLen then
            local byte = string.byte(expanded, i)
            q7 = bit32.bxor(q7, bit32.lrotate(byte, (expandedLen - i) % 9))
            q7 = (q7 + byte * 61) % 0xFFFFFFFF
        end
    end
    
    for i = eighth * 7 + 1, expandedLen do
        local byte = string.byte(expanded, i)
        local prime = primes[(i % #primes) + 1]
        local f = fib[(i % #fib) + 1]
        q8 = bit32.bxor(q8, bit32.rrotate(byte, (expandedLen - i) % 8))
        q8 = (q8 + byte * prime * f) % 0xFFFFFFFF
    end
    
    local hash1 = bit32.bxor(temp_xor, q1)
    hash1 = bit32.bxor(hash1, bit32.lrotate(temp_and, 8))
    hash1 = bit32.bxor(hash1, q5)
    hash1 = (hash1 + len * 47) % 0xFFFFFFFF
    
    local hash2 = bit32.bxor(q2, q3)
    hash2 = bit32.bxor(hash2, bit32.rrotate(temp_xor, 16))
    hash2 = bit32.bxor(hash2, q6)
    hash2 = (hash2 + len * 53) % 0xFFFFFFFF
    
    local hash3 = bit32.bxor(q4, temp_and)
    hash3 = bit32.bxor(hash3, bit32.lrotate(q1, 12))
    hash3 = bit32.bxor(hash3, q7)
    hash3 = (hash3 + len * 59) % 0xFFFFFFFF
    
    local hash4 = bit32.bxor(q1, q4)
    hash4 = bit32.bxor(hash4, bit32.rrotate(q2, 20))
    hash4 = bit32.bxor(hash4, q3)
    hash4 = bit32.bxor(hash4, q8)
    
    local final1 = avalanche(bit32.bxor(hash1, hash2))
    local final2 = avalanche(bit32.bxor(hash3, hash4))
    local final3 = avalanche(bit32.bxor(hash1, hash3))
    local final4 = avalanche(bit32.bxor(hash2, hash4))
    
    final1 = avalanche(final1)
    final2 = avalanche(final2)
    final3 = avalanche(final3)
    final4 = avalanche(final4)
    
    return string.format("%08x%08x%08x%08x", final1, final2, final3, final4)
end

function Grindstone.hash(filepath)
    if not oldIsFile(filepath) then
        return nil
    end
    
    local content = oldReadFile(filepath)
    local hash = compressHash(content)
    
    return {
        hash = hash,
        size = #content,
        path = filepath
    }
end

function Grindstone.verify(filepath, expectedSize, expectedHash)
    if not oldIsFile(filepath) then
        return false, "FILE_NOT_FOUND"
    end
    
    local content = oldReadFile(filepath)
    local actualSize = #content
    local actualHash = compressHash(content)
    
    if expectedSize ~= 0 and actualSize ~= expectedSize then
        return false, "SIZE_MISMATCH"
    end
    
    if actualHash ~= expectedHash then
        return false, "HASH_MISMATCH"
    end
    
    return true, "VERIFIED"
end

function Grindstone.verifyData(data, expectedHash)
    local actualHash = compressHash(data)
    return actualHash == expectedHash, actualHash
end

-- ========================================
-- END GRINDSTONE
-- ========================================

-- Helper Functions
local function sendRobloxNotification(title, text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 5
		})
	end)
end

local function logError(errorMsg)
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local logEntry = timestamp .. ": " .. tostring(errorMsg) .. "\n"
	local existingLog = ""
	if oldIsFile("ObjecX/crash.log") then
		existingLog = oldReadFile("ObjecX/crash.log")
	end
	oldWriteFile("ObjecX/crash.log", existingLog .. logEntry)
	warn(errorMsg)
end

local function traceback(functionName, reason)
	local traceMsg = "[TRACEBACK] Function: " .. functionName .. " | Reason: " .. reason
	logError(traceMsg)
	return traceMsg
end

local function getfile(url, timeout)
	timeout = timeout or 15
	local success, result = pcall(function()
		local startTime = tick()
		local data
		local thread = coroutine.create(function()
			data = game:HttpGet(url)
		end)
		coroutine.resume(thread)
		while coroutine.status(thread) ~= "dead" and (tick() - startTime) < timeout do
			task.wait(0.1)
		end
		if coroutine.status(thread) ~= "dead" then
			traceback("getfile", "Timeout after " .. tostring(timeout) .. "s for URL: " .. url)
			return nil, "TIMEOUT"
		end
		return data
	end)
	if success and result then
		return result
	else
		if result and string.find(tostring(result), "404") then
			return nil, "404"
		end
		traceback("getfile", "HTTP request failed for URL: " .. url .. " | Error: " .. tostring(result))
		return nil
	end
end

local function isGameFrozen()
	local success, fps = pcall(function()
		local stats = game:GetService("Stats")
		return stats.FrameRateManager:GetRenderAverage()
	end)
	if not success then
		return false
	end
	return fps < 5
end

local function shutdown()
	print("[SYSMAINT] Shutdown initiated")
	if oldIsFile("ObjecX/.loggedin") then
		oldDelFile("ObjecX/.loggedin")
		print("[SYSMAINT] Deleted .loggedin")
	end
	if oldIsFile("ObjecX/increment.lock") then
		oldWriteFile("ObjecX/increment.lock", "0")
		print("[SYSMAINT] Reset increment.lock to 0")
	end
	while true do
		task.wait(1)
	end
end

local function restart()
	print("[SYSMAINT] Restart initiated")
	if oldIsFile("ObjecX/.loggedin") then
		oldDelFile("ObjecX/.loggedin")
		print("[SYSMAINT] Deleted .loggedin")
	end
	if oldIsFile("ObjecX/increment.lock") then
		oldWriteFile("ObjecX/increment.lock", "0")
		print("[SYSMAINT] Reset increment.lock to 0")
	end
	task.wait(0.5)
	if oldIsFile("ObjecX/mainscript.luau") then
		local scriptContent = oldReadFile("ObjecX/mainscript.luau")
		loadstring(scriptContent)()
	end
	while true do
		task.wait(1)
	end
end

local function getCompatibleGuiVersion()
	if cachedGuiVersion and cachedGuiList then
		return tonumber(cachedGuiVersion)
	else
		local compatData, err = getfile(GITHUB_REPO .. "compatibility.list", 15)
		
		if err == "404" then
			warn("[SYSMAINT] compatibility.list not found (404)")
			traceback("getCompatibleGuiVersion", "compatibility.list returned 404")
			return nil
		end
		
		if err == "TIMEOUT" then
			warn("[SYSMAINT] compatibility.list request timed out")
			sendRobloxNotification("ObjecX Warning", "Update check timed out. Will retry later.", 5)
			traceback("getCompatibleGuiVersion", "compatibility.list request timed out")
			return nil
		end
		
		if not compatData then
			warn("[SYSMAINT] Failed to fetch compatibility.list")
			traceback("getCompatibleGuiVersion", "Failed to fetch compatibility.list")
			return nil
		end
		
		local HttpService = game:GetService("HttpService")
		local success, compatList = pcall(function()
			return HttpService:JSONDecode(compatData)
		end)
		
		if not success then
			warn("[SYSMAINT] Failed to decode compatibility.list JSON")
			traceback("getCompatibleGuiVersion", "Failed to decode compatibility.list JSON. Error: " .. tostring(compatList))
			return nil
		end
		
		local compatibleVersions = {}
		for _, entry in ipairs(compatList.compatibility) do
			if entry.core == CVersion then
				table.insert(compatibleVersions, entry.gui)
			end
		end
		
		if #compatibleVersions == 0 then
			warn("[SYSMAINT] No compatible GUI versions found for CVersion " .. tostring(CVersion))
			traceback("getCompatibleGuiVersion", "No compatible GUI versions found for CVersion " .. tostring(CVersion))
			for _, version in ipairs(DefGcomptable) do
				table.insert(compatibleVersions, version)
			end
		end
		
		table.sort(compatibleVersions, function(a, b) return a > b end)
		cachedGuiVersion = tostring(compatibleVersions[1])
		return compatibleVersions[1]
	end
end

local function checkCacheIntegrity()
	if not oldIsFolder("ObjecX/libraries") then
		warn("[SYSMAINT] Libraries folder missing")
		traceback("checkCacheIntegrity", "Libraries folder missing")
		return false
	end
	print("[SYSMAINT] Verified directory: ObjecX/libraries")
	
	local requiredGuiVersion = getCompatibleGuiVersion()
	if not requiredGuiVersion then
		warn("[SYSMAINT] Could not determine required GUI version")
		traceback("checkCacheIntegrity", "Could not determine required GUI version")
		return false
	end
	
	local requiredFile = "ObjecX/libraries/gui." .. tostring(requiredGuiVersion) .. ".lua"
	if not oldIsFile(requiredFile) then
		warn("[SYSMAINT] Required GUI file missing: " .. requiredFile)
		traceback("checkCacheIntegrity", "Required GUI file missing: " .. requiredFile)
		return false
	end
	print("[SYSMAINT] Verified file: " .. requiredFile)
	
	local fileContent = oldReadFile(requiredFile)
	if not fileContent or #fileContent < 10 then
		warn("[SYSMAINT] Required GUI file is empty or corrupted: " .. requiredFile)
		traceback("checkCacheIntegrity", "Required GUI file is empty or corrupted: " .. requiredFile)
		oldDelFile(requiredFile)
		return false
	end
	
	return true
end

local function cleanOldGuiFiles(keepVersion)
	local files = listfiles("ObjecX/libraries")
	for _, file in ipairs(files) do
		local version = string.match(file, "gui%.(%d+)%.lua$")
		if version and tonumber(version) ~= keepVersion then
			pcall(function()
				oldDelFile(file)
				print("[SYSMAINT] Removed old GUI file: " .. file)
			end)
		end
	end
end

local function loadGuiFromCache()
	local guiFile
	local guiVersion
	for _, file in ipairs(listfiles("ObjecX/libraries")) do
		local version = string.match(file, "gui%.(%d+)%.lua$")
		if version then
			guiFile = file
			guiVersion = tonumber(version)
			break
		end
	end
	
	if not guiFile or not oldIsFile(guiFile) then
		warn("[SYSMAINT] No GUI file found in cache")
		traceback("loadGuiFromCache", "No GUI file found in cache")
		return nil
	end
	
	print("[SYSMAINT] Loading GUI from cache: gui." .. tostring(guiVersion) .. ".lua")
	
	local fileContent = oldReadFile(guiFile)
	if not fileContent or #fileContent < 10 then
		warn("[SYSMAINT] Cached GUI file is empty or corrupted")
		traceback("loadGuiFromCache", "Cached GUI file is empty or corrupted")
		pcall(function()
			oldDelFile(guiFile)
		end)
		return nil
	end
	
	local loadFunc = loadstring(fileContent)
	if not loadFunc then
		warn("[SYSMAINT] loadstring returned nil for cached GUI")
		traceback("loadGuiFromCache", "loadstring returned nil for cached GUI")
		return nil
	end
	
	local loadSuccess, loadResult = pcall(loadFunc)
	if loadSuccess and loadResult then
		return loadResult
	else
		warn("[SYSMAINT] Failed to execute cached GUI")
		traceback("loadGuiFromCache", "Failed to execute cached GUI. Error: " .. tostring(loadResult))
		return nil
	end
end

local function fetchAndLoadGui()
	local newgui = getCompatibleGuiVersion()
	if not newgui then
		warn("[SYSMAINT] Cannot fetch GUI without compatible version")
		traceback("fetchAndLoadGui", "Cannot fetch GUI without compatible version")
		return nil
	end
	
	print("[SYSMAINT] Fetching GUI: gui." .. tostring(newgui) .. ".lua")
	
	-- Fetch GUI file
	local guiScriptData, err = getfile(GITHUB_REPO .. "gui." .. tostring(newgui) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] GUI file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI v" .. tostring(newgui) .. " not found on server (404)", 10)
		traceback("fetchAndLoadGui", "GUI file returned 404")
		return nil
	end
	
	if err == "TIMEOUT" then
		warn("[SYSMAINT] GUI file request timed out")
		sendRobloxNotification("ObjecX Warning", "GUI download timed out. Using cache if available.", 5)
		traceback("fetchAndLoadGui", "GUI file request timed out")
		return nil
	end
	
	if not guiScriptData or #guiScriptData < 10 then
		warn("[SYSMAINT] Failed to fetch GUI script or script is too small")
		traceback("fetchAndLoadGui", "Failed to fetch GUI script or script is too small")
		return nil
	end
	
	-- Fetch GUI hash
	local guiHashData, hashErr = getfile(GITHUB_REPO .. "gui." .. tostring(newgui) .. ".gri", 10)
	if hashErr == "404" then
		warn("[SYSMAINT] GUI hash file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI hash file not found (404)", 10)
		traceback("fetchAndLoadGui", "GUI hash file returned 404")
		return nil
	end
	
	if hashErr == "TIMEOUT" then
		warn("[SYSMAINT] GUI hash request timed out")
		sendRobloxNotification("ObjecX Warning", "Hash verification timed out. Using cache if available.", 5)
		traceback("fetchAndLoadGui", "GUI hash request timed out")
		return nil
	end
	
	if not guiHashData then
		warn("[SYSMAINT] Failed to fetch GUI hash")
		traceback("fetchAndLoadGui", "Failed to fetch GUI hash")
		return nil
	end
	
	local expectedHash = guiHashData:match("^%s*(.-)%s*$") -- Trim whitespace
	
	-- Verify hash
	print("[SYSMAINT] Verifying GUI integrity...")
	local isValid, actualHash = Grindstone.verifyData(guiScriptData, expectedHash)
	
	if not isValid then
		warn("[SYSMAINT] GUI hash verification FAILED - file may be tampered!")
		warn(string.format("[SYSMAINT] Expected: %s | Got: %s", expectedHash, actualHash))
		sendRobloxNotification("ObjecX Security Warning", "GUI update failed integrity check - possibly tampered!", 15)
		traceback("fetchAndLoadGui", "GUI hash mismatch - Expected: " .. expectedHash .. " | Got: " .. actualHash)
		return nil
	end
	
	print("[SYSMAINT] GUI integrity verified successfully")
	
	local savePath = "ObjecX/libraries/gui." .. tostring(newgui) .. ".lua"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
	end)
	
	if not saveSuccess then
		warn("[SYSMAINT] Failed to save GUI script to filesystem")
		traceback("fetchAndLoadGui", "Failed to save GUI script to filesystem")
	else
		print("[SYSMAINT] Saved GUI script: " .. savePath)
		cleanOldGuiFiles(newgui)
	end
	
	local loadFunc = loadstring(guiScriptData)
	if not loadFunc then
		warn("[SYSMAINT] loadstring returned nil for fetched GUI")
		traceback("fetchAndLoadGui", "loadstring returned nil for fetched GUI")
		return nil
	end
	
	local loadSuccess, loadResult = pcall(loadFunc)
	if loadSuccess and loadResult then
		return loadResult
	else
		warn("[SYSMAINT] Failed to execute fetched GUI")
		traceback("fetchAndLoadGui", "Failed to execute fetched GUI. Error: " .. tostring(loadResult))
		return nil
	end
end

local function getCurrentGuiVersion()
	local guiFile
	for _, file in ipairs(listfiles("ObjecX/libraries")) do
		local version = string.match(file, "gui%.(%d+)%.lua$")
		if version then
			return tonumber(version)
		end
	end
	return nil
end

local function installCoreUpdate(newVersion)
	print("[SYSMAINT] Installing core update: v" .. tostring(newVersion))
	
	-- Fetch core file
	local newCoreData, err = getfile(GITHUB_REPO .. "core." .. tostring(newVersion) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] Core file not found (404)")
		sendRobloxNotification("ObjecX Error", "Core v" .. tostring(newVersion) .. " not found on server (404)", 10)
		traceback("installCoreUpdate", "Core file returned 404")
		return false
	end
	
	if err == "TIMEOUT" then
		warn("[SYSMAINT] Core file request timed out")
		sendRobloxNotification("ObjecX Warning", "Core update timed out. Will retry later.", 5)
		traceback("installCoreUpdate", "Core file request timed out")
		return false
	end
	
	if not newCoreData then
		warn("[SYSMAINT] Failed to fetch core update v" .. tostring(newVersion))
		traceback("installCoreUpdate", "Failed to fetch core update v" .. tostring(newVersion))
		return false
	end
	
	-- Fetch core hash
	local coreHashData, hashErr = getfile(GITHUB_REPO .. "core." .. tostring(newVersion) .. ".gri", 10)
	if hashErr == "404" then
		warn("[SYSMAINT] Core hash file not found (404)")
		sendRobloxNotification("ObjecX Error", "Core hash file not found (404)", 10)
		traceback("installCoreUpdate", "Core hash file returned 404")
		return false
	end
	
	if hashErr == "TIMEOUT" then
		warn("[SYSMAINT] Core hash request timed out")
		sendRobloxNotification("ObjecX Warning", "Hash verification timed out. Update cancelled.", 5)
		traceback("installCoreUpdate", "Core hash request timed out")
		return false
	end
	
	if not coreHashData then
		warn("[SYSMAINT] Failed to fetch core hash")
		traceback("installCoreUpdate", "Failed to fetch core hash")
		return false
	end
	
	local expectedHash = coreHashData:match("^%s*(.-)%s*$")
	
	-- Verify hash
	print("[SYSMAINT] Verifying Core integrity...")
	local isValid, actualHash = Grindstone.verifyData(newCoreData, expectedHash)
	
	if not isValid then
		warn("[SYSMAINT] Core hash verification FAILED - file may be tampered!")
		warn(string.format("[SYSMAINT] Expected: %s | Got: %s", expectedHash, actualHash))
		sendRobloxNotification("ObjecX Security Warning", "Core update failed integrity check - possibly tampered!", 15)
		traceback("installCoreUpdate", "Core hash mismatch - Expected: " .. expectedHash .. " | Got: " .. actualHash)
		return false
	end
	
	print("[SYSMAINT] Core integrity verified successfully")
	
	oldWriteFile("ObjecX/mainscript.luau", newCoreData)
	print("[SYSMAINT] Installed core update: v" .. tostring(newVersion))
	return true
end

local function installGuiUpdate(newVersion)
	print("[SYSMAINT] Installing GUI update: v" .. tostring(newVersion))
	
	-- Fetch GUI file
	local guiScriptData, err = getfile(GITHUB_REPO .. "gui." .. tostring(newVersion) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] GUI file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI v" .. tostring(newVersion) .. " not found on server (404)", 10)
		traceback("installGuiUpdate", "GUI file returned 404")
		return false
	end
	
	if err == "TIMEOUT" then
		warn("[SYSMAINT] GUI file request timed out")
		sendRobloxNotification("ObjecX Warning", "GUI update timed out. Will retry later.", 5)
		traceback("installGuiUpdate", "GUI file request timed out")
		return false
	end
	
	if not guiScriptData or #guiScriptData < 10 then
		warn("[SYSMAINT] Failed to fetch GUI script")
		traceback("installGuiUpdate", "Failed to fetch GUI script")
		return false
	end
	
	-- Fetch GUI hash
	local guiHashData, hashErr = getfile(GITHUB_REPO .. "gui." .. tostring(newVersion) .. ".gri", 10)
	if hashErr == "404" then
		warn("[SYSMAINT] GUI hash file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI hash file not found (404)", 10)
		traceback("installGuiUpdate", "GUI hash file returned 404")
		return false
	end
	
	if hashErr == "TIMEOUT" then
		warn("[SYSMAINT] GUI hash request timed out")
		sendRobloxNotification("ObjecX Warning", "Hash verification timed out. Update cancelled.", 5)
		traceback("installGuiUpdate", "GUI hash request timed out")
		return false
	end
	
	if not guiHashData then
		warn("[SYSMAINT] Failed to fetch GUI hash")
		traceback("installGuiUpdate", "Failed to fetch GUI hash")
		return false
	end
	
	local expectedHash = guiHashData:match("^%s*(.-)%s*$")
	
	-- Verify hash
	print("[SYSMAINT] Verifying GUI integrity...")
	local isValid, actualHash = Grindstone.verifyData(guiScriptData, expectedHash)
	
	if not isValid then
		warn("[SYSMAINT] GUI hash verification FAILED - file may be tampered!")
		warn(string.format("[SYSMAINT] Expected: %s | Got: %s", expectedHash, actualHash))
		sendRobloxNotification("ObjecX Security Warning", "GUI update failed integrity check - possibly tampered!", 15)
		traceback("installGuiUpdate", "GUI hash mismatch - Expected: " .. expectedHash .. " | Got: " .. actualHash)
		return false
	end
	
	print("[SYSMAINT] GUI integrity verified successfully")
	
	local savePath = "ObjecX/libraries/gui." .. tostring(newVersion) .. ".lua"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
	end)
	if saveSuccess then
		cleanOldGuiFiles(newVersion)
		print("[SYSMAINT] Installed GUI update: v" .. tostring(newVersion))
		return true
	end
	
	warn("[SYSMAINT] Failed to install GUI update v" .. tostring(newVersion))
	traceback("installGuiUpdate", "Failed to install GUI update v" .. tostring(newVersion))
	return false
end

-- Primary FileSystem Wizard
local fsStartTime = tick()
print("[SYSMAINT] Fs verification...")

if not oldIsFolder("ObjecX") then
	oldMakeFolder("ObjecX")
	print("[SYSMAINT] Created directory: ObjecX")
else
	print("[SYSMAINT] Verified directory: ObjecX")
end

if not oldIsFile("ObjecX/mainscript.luau") then
	oldWriteFile("ObjecX/mainscript.luau", SelfScript)
	print("[SYSMAINT] Created file: ObjecX/mainscript.luau")
else
	print("[SYSMAINT] Verified file: ObjecX/mainscript.luau")
end

if not oldIsFolder("ObjecX/versions") then
	oldMakeFolder("ObjecX/versions")
	print("[SYSMAINT] Created directory: ObjecX/versions")
else
	print("[SYSMAINT] Verified directory: ObjecX/versions")
end

if not oldIsFile("ObjecX/versions/" .. tostring(CVersion) .. ".lua") then
	oldWriteFile("ObjecX/versions/" .. tostring(CVersion) .. ".lua", SelfScript)
	print("[SYSMAINT] Created file: ObjecX/versions/" .. tostring(CVersion) .. ".lua")
else
	print("[SYSMAINT] Verified file: ObjecX/versions/" .. tostring(CVersion) .. ".lua")
end

if not oldIsFolder("ObjecX/libraries") then
	oldMakeFolder("ObjecX/libraries")
	print("[SYSMAINT] Created directory: ObjecX/libraries")
	CACHE_MISS = 1
else
	print("[SYSMAINT] Verified directory: ObjecX/libraries")
	if not checkCacheIntegrity() then
		CACHE_MISS = 1
	end
end

local fsElapsed = tick() - fsStartTime
print(string.format("[SYSMAINT] Finished: %.3fs", fsElapsed))

-- Login check for hard crash detection
if oldIsFile("ObjecX/.loggedin") then
	print("[SYSMAINT] Detected existing .loggedin file")
	if oldIsFile("ObjecX/increment.lock") then
		print("[SYSMAINT] Checking increment.lock for activity")
		local lockValue = tonumber(oldReadFile("ObjecX/increment.lock")) or 0
		task.wait(1.5)
		local newLockValue = tonumber(oldReadFile("ObjecX/increment.lock")) or 0
		
		if newLockValue > lockValue then
			traceback("LoginCheck", "Another instance is already running, stopping")
			return
		else
			print("[SYSMAINT] Hard crash detected, continuing with recovery")
			traceback("LoginCheck", "Hard crash detected, continuing with recovery")
			HARD_SHUTDOWN = 1
		end
	else
		print("[SYSMAINT] Hard crash detected (no increment.lock)")
		traceback("LoginCheck", "Hard crash detected (no increment.lock), continuing with recovery")
		HARD_SHUTDOWN = 1
	end
end

oldWriteFile("ObjecX/.loggedin", tostring(os.time()))
print("[SYSMAINT] Created .loggedin file")

-- Crash counter check
local crashCount = 0
if oldIsFile("ObjecX/.crashcount") then
	local crashData = oldReadFile("ObjecX/.crashcount")
	local crashTime = tonumber(string.match(crashData, "time:(%d+)")) or 0
	crashCount = tonumber(string.match(crashData, "count:(%d+)")) or 0
	
	local timeSinceLastCrash = os.time() - crashTime
	if timeSinceLastCrash > 300 then
		crashCount = 0
	end
	
	crashCount = crashCount + 1
	if crashCount >= 3 then
		logError("CRITICAL: Too many crashes detected (" .. tostring(crashCount) .. "), giving up")
		oldWriteFile("ObjecX/CRITICAL_FAILURE.txt", "System failed after " .. tostring(crashCount) .. " crash attempts")
		oldDelFile("ObjecX/.crashcount")
		shutdown()
		return
	end
	oldWriteFile("ObjecX/.crashcount", "count:" .. tostring(crashCount) .. " time:" .. tostring(os.time()))
	print("[SYSMAINT] Updated .crashcount: " .. tostring(crashCount))
else
	oldWriteFile("ObjecX/.crashcount", "count:1 time:" .. tostring(os.time()))
	print("[SYSMAINT] Created .crashcount file")
end

-- GUI Loading Logic
local cacheStartTime = tick()
print("[SYSMAINT] Cache loading...")

local guiModule

if CACHE_MISS == 1 then
	guiModule = fetchAndLoadGui()
else
	guiModule = loadGuiFromCache()
	
	if not guiModule then
		guiModule = fetchAndLoadGui()
	end
end

if not guiModule then
	warn("[SYSMAINT] All GUI loading attempts failed")
	traceback("GUILoader", "All GUI loading attempts failed, trying cache as last resort")
	guiModule = loadGuiFromCache()
end

local cacheElapsed = tick() - cacheStartTime
print(string.format("[SYSMAINT] Finished: %.3fs", cacheElapsed))

-- If GUI still failed to load, send Roblox notification
if not guiModule then
	sendRobloxNotification("ObjecX Critical Error", "GUI failed to load. Check crash.log for details.", 10)
	warn("[SYSMAINT] GUI module is completely unavailable")
	traceback("GUILoader", "GUI module is completely unavailable")
end

-- Logon check
if oldIsFile("ObjecX/increment.lock") then
	print("[SYSMAINT] Checking increment.lock")
	local lockValue = oldReadFile("ObjecX/increment.lock")
	if lockValue ~= "0" and HARD_SHUTDOWN == 0 then
		oldWriteFile("ObjecX/increment.lock", "0")
		print("[SYSMAINT] Reset increment.lock to 0")
		HARD_SHUTDOWN = 1
	else
		print("[SYSMAINT] Verified increment.lock")
	end
else
	oldWriteFile("ObjecX/increment.lock", "0")
	print("[SYSMAINT] Created increment.lock")
end

-- Check for .STOP file
if oldIsFile("ObjecX/.STOP") then
	print("[SYSMAINT] Detected .STOP file")
	if HARD_SHUTDOWN == 1 then
		oldDelFile("ObjecX/.STOP")
		print("[SYSMAINT] Deleted .STOP file")
	else
		shutdown()
		return
	end
end

-- Check for .UNINSTALL file
if oldIsFile("ObjecX/.UNINSTALL") then
	print("[SYSMAINT] Detected .UNINSTALL file, removing ObjecX")
	if oldIsFolder("ObjecX") then
		oldDelFolder("ObjecX")
	end
	return
end

-- Update check
local updateStartTime = tick()
print("[SYSMAINT] Update check...")

local shouldCheckCoreUpdate = false
local currentTime = os.time()

if oldIsFile("ObjecX/.lastchecked") then
	local lastChecked = tonumber(oldReadFile("ObjecX/.lastchecked")) or 0
	local timeDiff = currentTime - lastChecked
	if timeDiff > 60 and timeDiff < 31536000 then
		shouldCheckCoreUpdate = true
	end
else
	shouldCheckCoreUpdate = true
end

if shouldCheckCoreUpdate then
	local cversionData, err = getfile(GITHUB_REPO .. "cLatest.version", 15)
	if err == "404" then
		warn("[SYSMAINT] cLatest.version not found (404)")
		sendRobloxNotification("ObjecX Error", "Version file not found on server (404)", 10)
	elseif err == "TIMEOUT" then
		warn("[SYSMAINT] cLatest.version request timed out")
		sendRobloxNotification("ObjecX Warning", "Update check timed out. Will retry later.", 5)
	elseif cversionData then
		oldWriteFile("ObjecX/.lastchecked", tostring(currentTime))
		print("[SYSMAINT] Updated .lastchecked")
		local latestCVersion = tonumber(cversionData)
		if latestCVersion and latestCVersion > CVersion then
			print("[SYSMAINT] Core update available: v" .. tostring(CVersion) .. " -> v" .. tostring(latestCVersion))
			if installCoreUpdate(latestCVersion) then
				print("[SYSMAINT] Core updated, restarting...")
				restart()
				return
			end
		else
			print("[SYSMAINT] Core | Current: v" .. tostring(CVersion) .. " | Latest: v" .. tostring(latestCVersion or CVersion))
			print("[SYSMAINT] Up to date, skipped installing")
		end
	end
end

local updateElapsed = tick() - updateStartTime
print(string.format("[SYSMAINT] Finished: %.3fs", updateElapsed))

-- Logon system (increment.lock updater)
task.spawn(function()
	print("[SYSMAINT] Starting increment.lock updater")
	local counter = 0
	while true do
		if oldIsFile("ObjecX/.STOP") then
			shutdown()
			break
		end
		counter = counter + 1
		pcall(function()
			oldWriteFile("ObjecX/increment.lock", tostring(counter))
		end)
		task.wait(0.1)
	end
end)

-- Background Update Checker (every 1 minute)
task.spawn(function()
	task.wait(60)
	print("[SYSMAINT] Background updater started")
	
	while true do
		local bgUpdateStartTime = tick()
		print("[SYSMAINT] Update check...")
		
		local coreUpdateAvailable = false
		local guiUpdateAvailable = false
		local newCoreVersion = nil
		local newGuiVersion = nil
		
		local cversionData, coreErr = getfile(GITHUB_REPO .. "cLatest.version", 15)
		if coreErr == "404" then
			warn("[SYSMAINT] cLatest.version not found (404)")
		elseif coreErr == "TIMEOUT" then
			warn("[SYSMAINT] cLatest.version request timed out")
			sendRobloxNotification("ObjecX Warning", "Update check timed out. Will retry later.", 5)
		elseif cversionData then
			local latestCVersion = tonumber(cversionData)
			print("[SYSMAINT] Core | Current: v" .. tostring(CVersion) .. " | Latest: v" .. tostring(latestCVersion or "unknown"))
			if latestCVersion and latestCVersion > CVersion then
				coreUpdateAvailable = true
				newCoreVersion = latestCVersion
				print("[SYSMAINT] Core update available")
			else
				print("[SYSMAINT] Core up to date, skipped installing")
			end
		else
			warn("[SYSMAINT] Failed to fetch core version")
		end
		
		cachedGuiVersion = nil
		cachedGuiList = nil
		local latestGuiVersion = getCompatibleGuiVersion()
		local currentGuiVersion = getCurrentGuiVersion()
		
		if latestGuiVersion and currentGuiVersion then
			print("[SYSMAINT] GUI | Current: v" .. tostring(currentGuiVersion) .. " | Latest: v" .. tostring(latestGuiVersion))
			if latestGuiVersion > currentGuiVersion then
				guiUpdateAvailable = true
				newGuiVersion = latestGuiVersion
				print("[SYSMAINT] GUI update available")
			else
				print("[SYSMAINT] GUI up to date, skipped installing")
			end
		else
			warn("[SYSMAINT] Failed to check GUI version")
		end
		
		if coreUpdateAvailable or guiUpdateAvailable then
			local notifTitle = ""
			local notifDesc = ""
			local notifType = "working"
			local useRobloxNotif = false
			
			if coreUpdateAvailable and guiUpdateAvailable then
				notifTitle = "Systemic Update Available"
				notifDesc = "Core v" .. tostring(newCoreVersion) .. " and GUI v" .. tostring(newGuiVersion) .. " are available. Click to install."
			elseif coreUpdateAvailable then
				notifTitle = "Core Update Available"
				notifDesc = "Version " .. tostring(newCoreVersion) .. " is available. Click to install and restart."
			elseif guiUpdateAvailable then
				notifTitle = "GUI Update Available"
				notifDesc = "Version " .. tostring(newGuiVersion) .. " is available. Click to install and restart."
				if not guiModule then
					useRobloxNotif = true
				end
			end
			
			if guiModule and not useRobloxNotif then
				local success = pcall(function()
					guiModule.registerCallback("objecx_update_install", function()
						print("[SYSMAINT] User initiated update installation")
						local installSuccess = true
						
						if coreUpdateAvailable then
							if not installCoreUpdate(newCoreVersion) then
								installSuccess = false
							end
						end
						
						if guiUpdateAvailable then
							if not installGuiUpdate(newGuiVersion) then
								installSuccess = false
							end
						end
						
						if installSuccess then
							pcall(function()
								guiModule.closeNotif("objecx_update_notif")
							end)
							task.wait(1)
							restart()
						else
							warn("[SYSMAINT] Update installation failed")
							traceback("UpdateInstaller", "Update installation failed")
							pcall(function()
								guiModule.closeNotif("objecx_update_notif")
								guiModule.add.notification("objecx_update_failed", {
									title = "Update Failed",
									desc = "Failed to install updates. Check crash.log for details.",
									timeout = 5,
									notificationType = "error",
									closeable = true
								})
							end)
						end
					end)
					
					guiModule.add.notification("objecx_update_notif", {
						title = notifTitle,
						desc = notifDesc,
						timeout = 0,
						notificationType = notifType,
						closeable = true,
						clickable = true,
						onClick = "objecx_update_install"
					})
				end)
				
				if not success then
					useRobloxNotif = true
				end
			else
				useRobloxNotif = true
			end
			
			if useRobloxNotif then
				if guiUpdateAvailable then
					sendRobloxNotification("ObjecX Update", "GUI v" .. tostring(newGuiVersion) .. " available. Reinstall script to update.", 10)
				end
				if coreUpdateAvailable then
					sendRobloxNotification("ObjecX Update", "Core v" .. tostring(newCoreVersion) .. " available. Reinstall script to update.", 10)
				end
			end
		end
		
		local bgUpdateElapsed = tick() - bgUpdateStartTime
		print(string.format("[SYSMAINT] Finished: %.3fs", bgUpdateElapsed))
		task.wait(60) -- Check every 1 minute
	end
end)

-- Auxiliary Failsafe Watchdog
task.spawn(function()
	task.wait(2)
	print("[SYSMAINT] Starting failsafe watchdog")
	if not oldIsFile("ObjecX/increment.lock") then
		return
	end
	
	local lastValue = tonumber(oldReadFile("ObjecX/increment.lock")) or 0
	local failCount = 0
	local checkStartTime = tick()
	
	while true do
		task.wait(1)
		
		if not oldIsFile("ObjecX/increment.lock") then
			return
		end
		
		local currentValue = tonumber(oldReadFile("ObjecX/increment.lock")) or 0
		
		if isGameFrozen() then
			lastValue = currentValue
			failCount = 0
			checkStartTime = tick()
		elseif currentValue == lastValue then
			failCount = failCount + 1
			if failCount >= 3 and (tick() - checkStartTime) < 15 then
				print("[SYSMAINT] Watchdog triggered: script freeze detected")
				traceback("Watchdog", "Script freeze detected, triggering restart")
				oldWriteFile("ObjecX/.STOP", "Watchdog triggered")
				task.wait(5)
				if oldIsFile("ObjecX/mainscript.luau") then
					local scriptContent = oldReadFile("ObjecX/mainscript.luau")
					loadstring(scriptContent)()
				end
				return
			end
		else
			lastValue = currentValue
			failCount = 0
			checkStartTime = tick()
		end
	end
end)

-- Shutdown monitor
task.spawn(function()
	print("[SYSMAINT] Starting shutdown monitor")
	while true do
		task.wait(0.3)
		if oldIsFile("ObjecX/.STOP") then
			shutdown()
			break
		end
	end
end)

-- Successful startup - clear crash counter after delay
task.spawn(function()
	task.wait(10)
	if oldIsFile("ObjecX/.crashcount") then
		oldDelFile("ObjecX/.crashcount")
		print("[SYSMAINT] Cleared .crashcount after successful uptime")
	end
end)

-- Main execution
local success, err = pcall(function()
	if guiModule then
		print("ObjecX Core v" .. tostring(CVersion) .. " loaded successfully")
	else
		warn("[SYSMAINT] GUI module is nil, couldn't load GUI")
		traceback("MainExecution", "GUI module is nil, couldn't load GUI")
		warn("ObjecX Core loaded but GUI module failed to load")
	end
end)

if not success then
	traceback("MainExecution", "Main execution error: " .. tostring(err))
	logError("Main execution error: " .. tostring(err))
end
