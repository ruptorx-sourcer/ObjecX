-- ObjecX Core Framework v1.0.0 (CERTIFICATE SYSTEM - FIXED)
-- Type: LocalScript | Parent: StarterPlayer.StarterPlayerScripts

-- Old C functions backup
local oldIsFolder = isfolder
local oldIsFile = isfile
local oldMakeFolder = makefolder
local oldReadFile = readfile
local oldWriteFile = writefile
local oldDelFile = delfile
local oldDelFolder = delfolder
local oldWarn = warn
local oldprint = print
local oldtostring = tostring
local oldtonumber = tonumber
local oldtype = type
local olderror = error
local oldstring_sub = string.sub
local oldstring_char = string.char
local oldstring_byte = string.byte
local oldstring_rep = string.rep
local oldstring_format = string.format
local oldstring_gmatch = string.gmatch
local oldstring_match = string.match
local oldmath_random = math.random
local oldmath_floor = math.floor
local oldmath_max = math.max
local oldmath_sqrt = math.sqrt
local oldos_clock = os.clock
local oldos_date = os.date
local oldbit32_band = bit32.band
local oldbit32_bor = bit32.bor
local oldbit32_bxor = bit32.bxor
local oldbit32_bnot = bit32.bnot
local oldbit32_lshift = bit32.lshift
local oldbit32_rshift = bit32.rshift
local oldbit32_rrotate = bit32.rrotate
local oldtable_insert = table.insert
local oldtable_remove = table.remove

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

-- Public Keys for ObjecX Official Files
local OBJECX_PUBLIC_KEYS = {
    core = {
        e = "10001",
        n = "b605bf1",
        key = "b605bf1"
    },
    gui = {
        e = "10001",
        n = "d991989",
        key = "d991989"
    }
}

-- Grindstone Hash System
local ROUND_CONSTANTS = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
}

local function secureNonLinear(x, y, z)
    local ch = oldbit32_bxor(oldbit32_band(x, y), oldbit32_band(oldbit32_bnot(x), z))
    local maj = oldbit32_bxor(oldbit32_bxor(oldbit32_band(x, y), oldbit32_band(x, z)), oldbit32_band(y, z))
    local s0 = oldbit32_bxor(oldbit32_bxor(oldbit32_rrotate(x, 2), oldbit32_rrotate(x, 13)), oldbit32_rrotate(x, 22))
    local s1 = oldbit32_bxor(oldbit32_bxor(oldbit32_rrotate(y, 6), oldbit32_rrotate(y, 11)), oldbit32_rrotate(y, 25))
    return oldbit32_bxor(oldbit32_bxor(ch, maj), oldbit32_bxor(s0, s1))
end

local function padData(data)
    local len = #data
    local bitLen = len * 8
    local padding = oldstring_char(0x80)
    local paddingLen = (56 - ((len + 1) % 64)) % 64
    padding = padding .. oldstring_rep(oldstring_char(0), paddingLen)
    for i = 7, 0, -1 do
        padding = padding .. oldstring_char(oldbit32_band(oldbit32_rshift(bitLen, i * 8), 0xFF))
    end
    return data .. padding
end

local function processChunk(chunk, state, rounds)
    local w = {}
    for i = 0, 7 do
        local offset = i * 4 + 1
        w[i] = oldbit32_bor(
            oldbit32_lshift(oldstring_byte(chunk, offset) or 0, 24),
            oldbit32_bor(
                oldbit32_lshift(oldstring_byte(chunk, offset + 1) or 0, 16),
                oldbit32_bor(
                    oldbit32_lshift(oldstring_byte(chunk, offset + 2) or 0, 8),
                    (oldstring_byte(chunk, offset + 3) or 0)
                )
            )
        )
    end
    
    for i = 8, rounds - 1 do
        local w_i15 = w[(i - 15) % rounds] or w[i - 15]
        local w_i2 = w[(i - 2) % rounds] or w[i - 2]
        local w_i16 = w[(i - 16) % rounds] or w[i - 16]
        local w_i7 = w[(i - 7) % rounds] or w[i - 7]
        
        if w_i15 and w_i2 and w_i16 and w_i7 then
            local s0 = oldbit32_bxor(
                oldbit32_bxor(oldbit32_rrotate(w_i15, 7), oldbit32_rrotate(w_i15, 18)),
                oldbit32_rshift(w_i15, 3)
            )
            local s1 = oldbit32_bxor(
                oldbit32_bxor(oldbit32_rrotate(w_i2, 17), oldbit32_rrotate(w_i2, 19)),
                oldbit32_rshift(w_i2, 10)
            )
            w[i] = (w_i16 + s0 + w_i7 + s1) % 0x100000000
        else
            w[i] = 0
        end
    end
    
    local a, b, c, d, e, f, g, h = state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8]
    
    for round = 0, rounds - 1 do
        local w_i = w[round] or 0
        local k = ROUND_CONSTANTS[(round % 32) + 1]
        local s1 = oldbit32_bxor(oldbit32_bxor(oldbit32_rrotate(e, 6), oldbit32_rrotate(e, 11)), oldbit32_rrotate(e, 25))
        local s0 = oldbit32_bxor(oldbit32_bxor(oldbit32_rrotate(a, 2), oldbit32_rrotate(a, 13)), oldbit32_rrotate(a, 22))
        local ch = oldbit32_bxor(oldbit32_band(e, f), oldbit32_band(oldbit32_bnot(e), g))
        local maj = oldbit32_bxor(oldbit32_bxor(oldbit32_band(a, b), oldbit32_band(a, c)), oldbit32_band(b, c))
        local temp1 = (h + s1 + ch + k + w_i) % 0x100000000
        local temp2 = (s0 + maj) % 0x100000000
        h = g
        g = f
        f = e
        e = (d + temp1) % 0x100000000
        d = c
        c = b
        b = a
        a = (temp1 + temp2) % 0x100000000
    end
    
    state[1] = (state[1] + a) % 0x100000000
    state[2] = (state[2] + b) % 0x100000000
    state[3] = (state[3] + c) % 0x100000000
    state[4] = (state[4] + d) % 0x100000000
    state[5] = (state[5] + e) % 0x100000000
    state[6] = (state[6] + f) % 0x100000000
    state[7] = (state[7] + g) % 0x100000000
    state[8] = (state[8] + h) % 0x100000000
end

local function finalizeState(state)
    for i = 1, 8 do
        state[i] = oldbit32_bxor(state[i], oldbit32_rrotate(state[i], 13))
        state[i] = (state[i] * 0x9e3779b9) % 0x100000000
        state[i] = oldbit32_bxor(state[i], oldbit32_rrotate(state[i], 17))
    end
end

local function compressHash(data, rounds)
    rounds = rounds or 32
    
    if rounds ~= 8 and rounds ~= 16 and rounds ~= 32 and rounds ~= 64 then
        olderror("Grindstone: rounds must be 8, 16, 32, or 64")
    end
    
    if #data == 0 then 
        local watermark = oldstring_format("%02dCM", rounds)
        return watermark .. "0000000000000000000000000000000000000000000000000000000000000000"
    end
    
    local paddedData = padData(data)
    
    local state = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    }
    
    local chunkCount = #paddedData / 32
    for i = 0, chunkCount - 1 do
        local offset = i * 32 + 1
        local chunk = oldstring_sub(paddedData, offset, offset + 31)
        processChunk(chunk, state, rounds)
    end
    
    finalizeState(state)
    
    local hash = ""
    for i = 1, 8 do
        hash = hash .. oldstring_format("%08x", state[i])
    end
    
    local watermark = oldstring_format("%02dCM", rounds)
    return watermark .. hash
end

-- RSA-64 BigInt System
local BigInt = {}
BigInt.__index = BigInt

function BigInt.new(value)
    local self = setmetatable({}, BigInt)
    if oldtype(value) == "string" then
        self.value = oldtonumber(value, 16) or 0
        if self.value >= 2^53 then
            self.value = self.value % (2^53)
        end
    elseif oldtype(value) == "number" then
        self.value = value % (2^53)
    else
        self.value = 0
    end
    return self
end

function BigInt:toString()
    return oldstring_format("%x", self.value)
end

function BigInt:modPow(exp, modulus)
    local result = 1
    local base = self.value % modulus.value
    local e = exp.value
    
    while e > 0 do
        if e % 2 == 1 then
            result = (result * base) % modulus.value
        end
        base = (base * base) % modulus.value
        e = oldmath_floor(e / 2)
    end
    
    return BigInt.new(result)
end

-- Certificate System (CORRECTED - Signs entire cert data, not hash)
local Certificate = {}

local function stringToChunks(str, chunkSize)
    local chunks = {}
    for i = 1, #str, chunkSize do
        local chunk = oldstring_sub(str, i, i + chunkSize - 1)
        oldtable_insert(chunks, chunk)
    end
    return chunks
end

local function chunkToNumber(chunk)
    local result = 0
    for i = 1, #chunk do
        result = result * 256 + oldstring_byte(chunk, i)
    end
    return result
end

local function numberToChunk(num, size)
    local result = ""
    for i = 1, size do
        result = oldstring_char(num % 256) .. result
        num = oldmath_floor(num / 256)
    end
    return result
end

function Certificate.view(signedCert, publicKey)
    local certPart, sigPart = oldstring_match(signedCert, "(.+)SIG:(.+)")
    
    if not certPart or not sigPart then
        return nil, "MALFORMED"
    end
    
    -- Parse signature chunks (format: chunk1:chunk2:chunk3:...)
    local sigChunks = {}
    for chunk in oldstring_gmatch(sigPart, "([^:]+)") do
        oldtable_insert(sigChunks, chunk)
    end
    
    if #sigChunks == 0 then
        return nil, "MALFORMED"
    end
    
    -- Split cert into chunks (6 bytes each = 48 bits, safe for RSA-64)
    local certChunks = stringToChunks(certPart, 6)
    
    if #certChunks ~= #sigChunks then
        return nil, "MISMATCH"
    end
    
    -- Verify each chunk
    local publicE = BigInt.new(publicKey.e)
    local publicN = BigInt.new(publicKey.n)
    
    for i = 1, #certChunks do
        local signatureBig = BigInt.new(sigChunks[i])
        local decrypted = signatureBig:modPow(publicE, publicN)
        
        local chunkNum = chunkToNumber(certChunks[i])
        local chunkBig = BigInt.new(chunkNum)
        
        if decrypted:toString() ~= chunkBig:toString() then
            return nil, "MISMATCH"
        end
    end
    
    -- Parse metadata
    local metadata = {}
    for line in oldstring_gmatch(certPart, "([^,]+)") do
        if line ~= ";;;" then
            local key, value = oldstring_match(line, "([^:]+):(.+)")
            if key and value then
                metadata[key] = value
            end
        end
    end
    
    return metadata
end

function Certificate.verify(signedCert, publicKey, fileData)
    local metadata, err = Certificate.view(signedCert, publicKey)
    if not metadata then
        return false, err, nil
    end
    
    if metadata.company ~= "ObjecX" then
        return false, "UNTRUSTED", metadata
    end
    
    if metadata.purpose ~= "hash" then
        return false, "BADPURPOSE", metadata
    end
    
    if not metadata.hash then
        return false, "MALFORMED", metadata
    end
    
    local fileHash = compressHash(fileData, 32)
    
    if metadata.hash ~= fileHash then
        return false, "MISMATCH", metadata
    end
    
    return true, "VALID", metadata
end

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
	local logEntry = timestamp .. ": " .. oldtostring(errorMsg) .. "\n"
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
			traceback("getfile", "Timeout after " .. oldtostring(timeout) .. "s for URL: " .. url)
			return nil, "TIMEOUT"
		end
		return data
	end)
	if success and result then
		return result
	else
		if result and string.find(oldtostring(result), "404") then
			return nil, "404"
		end
		traceback("getfile", "HTTP request failed for URL: " .. url .. " | Error: " .. oldtostring(result))
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
	oldprint("[SYSMAINT] Shutdown initiated")
	if oldIsFile("ObjecX/.loggedin") then
		oldDelFile("ObjecX/.loggedin")
		oldprint("[SYSMAINT] Deleted .loggedin")
	end
	if oldIsFile("ObjecX/increment.lock") then
		oldWriteFile("ObjecX/increment.lock", "0")
		oldprint("[SYSMAINT] Reset increment.lock to 0")
	end
	while true do
		task.wait(1)
	end
end

local function restart()
	oldprint("[SYSMAINT] Restart initiated")
	if oldIsFile("ObjecX/.loggedin") then
		oldDelFile("ObjecX/.loggedin")
		oldprint("[SYSMAINT] Deleted .loggedin")
	end
	if oldIsFile("ObjecX/increment.lock") then
		oldWriteFile("ObjecX/increment.lock", "0")
		oldprint("[SYSMAINT] Reset increment.lock to 0")
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
		return oldtonumber(cachedGuiVersion)
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
			traceback("getCompatibleGuiVersion", "Failed to decode compatibility.list JSON. Error: " .. oldtostring(compatList))
			return nil
		end
		
		local compatibleVersions = {}
		for _, entry in ipairs(compatList.compatibility) do
			if entry.core == CVersion then
				oldtable_insert(compatibleVersions, entry.gui)
			end
		end
		
		if #compatibleVersions == 0 then
			warn("[SYSMAINT] No compatible GUI versions found for CVersion " .. oldtostring(CVersion))
			traceback("getCompatibleGuiVersion", "No compatible GUI versions found for CVersion " .. oldtostring(CVersion))
			for _, version in ipairs(DefGcomptable) do
				oldtable_insert(compatibleVersions, version)
			end
		end
		
		table.sort(compatibleVersions, function(a, b) return a > b end)
		cachedGuiVersion = oldtostring(compatibleVersions[1])
		return compatibleVersions[1]
	end
end

local function checkCacheIntegrity()
	if not oldIsFolder("ObjecX/libraries") then
		warn("[SYSMAINT] Libraries folder missing")
		traceback("checkCacheIntegrity", "Libraries folder missing")
		return false
	end
	oldprint("[SYSMAINT] Verified directory: ObjecX/libraries")
	
	local requiredGuiVersion = getCompatibleGuiVersion()
	if not requiredGuiVersion then
		warn("[SYSMAINT] Could not determine required GUI version")
		traceback("checkCacheIntegrity", "Could not determine required GUI version")
		return false
	end
	
	local requiredFile = "ObjecX/libraries/gui." .. oldtostring(requiredGuiVersion) .. ".lua"
	if not oldIsFile(requiredFile) then
		warn("[SYSMAINT] Required GUI file missing: " .. requiredFile)
		traceback("checkCacheIntegrity", "Required GUI file missing: " .. requiredFile)
		return false
	end
	oldprint("[SYSMAINT] Verified file: " .. requiredFile)
	
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
		if version and oldtonumber(version) ~= keepVersion then
			pcall(function()
				oldDelFile(file)
				oldprint("[SYSMAINT] Removed old GUI file: " .. file)
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
			guiVersion = oldtonumber(version)
			break
		end
	end
	
	if not guiFile or not oldIsFile(guiFile) then
		warn("[SYSMAINT] No GUI file found in cache")
		traceback("loadGuiFromCache", "No GUI file found in cache")
		return nil
	end
	
	oldprint("[SYSMAINT] Loading GUI from cache: gui." .. oldtostring(guiVersion) .. ".lua")
	
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
		traceback("loadGuiFromCache", "Failed to execute cached GUI. Error: " .. oldtostring(loadResult))
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
	
	oldprint("[SYSMAINT] Fetching GUI: gui." .. oldtostring(newgui) .. ".lua")
	
	local guiScriptData, err = getfile(GITHUB_REPO .. "gui." .. oldtostring(newgui) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] GUI file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI v" .. oldtostring(newgui) .. " not found on server (404)", 10)
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
	
	local guiCertData, certErr = getfile(GITHUB_REPO .. "gui." .. oldtostring(newgui) .. ".coc", 10)
	if certErr == "404" then
		warn("[SYSMAINT] GUI certificate file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI certificate file not found (404)", 10)
		traceback("fetchAndLoadGui", "GUI certificate file returned 404")
		return nil
	end
	
	if certErr == "TIMEOUT" then
		warn("[SYSMAINT] GUI certificate request timed out")
		sendRobloxNotification("ObjecX Warning", "Certificate verification timed out. Using cache if available.", 5)
		traceback("fetchAndLoadGui", "GUI certificate request timed out")
		return nil
	end
	
	if not guiCertData then
		warn("[SYSMAINT] Failed to fetch GUI certificate")
		traceback("fetchAndLoadGui", "Failed to fetch GUI certificate")
		return nil
	end
	
	oldprint("[SYSMAINT] Verifying GUI certificate...")
	local isValid, message, metadata = Certificate.verify(guiCertData, OBJECX_PUBLIC_KEYS.gui, guiScriptData)
	
	if not isValid then
		warn("[SYSMAINT] GUI certificate verification FAILED: " .. message)
		sendRobloxNotification("ObjecX Security Warning", "GUI update failed certificate check - " .. message, 15)
		traceback("fetchAndLoadGui", "GUI certificate invalid: " .. message)
		return nil
	end
	
	oldprint("[SYSMAINT] GUI certificate verified successfully")
	if metadata then
		oldprint("[SYSMAINT] Certificate ID: " .. (metadata.certifID or "unknown"))
		oldprint("[SYSMAINT] Algorithm: " .. (metadata.algo or "unknown"))
	end
	
	local savePath = "ObjecX/libraries/gui." .. oldtostring(newgui) .. ".lua"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
	end)
	
	if not saveSuccess then
		warn("[SYSMAINT] Failed to save GUI script to filesystem")
		traceback("fetchAndLoadGui", "Failed to save GUI script to filesystem")
	else
		oldprint("[SYSMAINT] Saved GUI script: " .. savePath)
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
		traceback("fetchAndLoadGui", "Failed to execute fetched GUI. Error: " .. oldtostring(loadResult))
		return nil
	end
end

local function getCurrentGuiVersion()
	for _, file in ipairs(listfiles("ObjecX/libraries")) do
		local version = string.match(file, "gui%.(%d+)%.lua$")
		if version then
			return oldtonumber(version)
		end
	end
	return nil
end

local function installCoreUpdate(newVersion)
	oldprint("[SYSMAINT] Installing core update: v" .. oldtostring(newVersion))
	
	local newCoreData, err = getfile(GITHUB_REPO .. "core." .. oldtostring(newVersion) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] Core file not found (404)")
		sendRobloxNotification("ObjecX Error", "Core v" .. oldtostring(newVersion) .. " not found on server (404)", 10)
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
		warn("[SYSMAINT] Failed to fetch core update v" .. oldtostring(newVersion))
		traceback("installCoreUpdate", "Failed to fetch core update v" .. oldtostring(newVersion))
		return false
	end
	
	local coreCertData, certErr = getfile(GITHUB_REPO .. "core." .. oldtostring(newVersion) .. ".coc", 10)
	if certErr == "404" then
		warn("[SYSMAINT] Core certificate file not found (404)")
		sendRobloxNotification("ObjecX Error", "Core certificate file not found (404)", 10)
		traceback("installCoreUpdate", "Core certificate file returned 404")
		return false
	end
	
	if certErr == "TIMEOUT" then
		warn("[SYSMAINT] Core certificate request timed out")
		sendRobloxNotification("ObjecX Warning", "Certificate verification timed out. Update cancelled.", 5)
		traceback("installCoreUpdate", "Core certificate request timed out")
		return false
	end
	
	if not coreCertData then
		warn("[SYSMAINT] Failed to fetch core certificate")
		traceback("installCoreUpdate", "Failed to fetch core certificate")
		return false
	end
	
	oldprint("[SYSMAINT] Verifying Core certificate...")
	local isValid, message, metadata = Certificate.verify(coreCertData, OBJECX_PUBLIC_KEYS.core, newCoreData)
	
	if not isValid then
		warn("[SYSMAINT] Core certificate verification FAILED: " .. message)
		sendRobloxNotification("ObjecX Security Warning", "Core update failed certificate check - " .. message, 15)
		traceback("installCoreUpdate", "Core certificate invalid: " .. message)
		return false
	end
	
	oldprint("[SYSMAINT] Core certificate verified successfully")
	if metadata then
		oldprint("[SYSMAINT] Certificate ID: " .. (metadata.certifID or "unknown"))
		oldprint("[SYSMAINT] Algorithm: " .. (metadata.algo or "unknown"))
	end
	
	oldWriteFile("ObjecX/mainscript.luau", newCoreData)
	oldprint("[SYSMAINT] Installed core update: v" .. oldtostring(newVersion))
	return true
end

local function installGuiUpdate(newVersion)
	oldprint("[SYSMAINT] Installing GUI update: v" .. oldtostring(newVersion))
	
	local guiScriptData, err = getfile(GITHUB_REPO .. "gui." .. oldtostring(newVersion) .. ".lua", 20)
	if err == "404" then
		warn("[SYSMAINT] GUI file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI v" .. oldtostring(newVersion) .. " not found on server (404)", 10)
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
	
	local guiCertData, certErr = getfile(GITHUB_REPO .. "gui." .. oldtostring(newVersion) .. ".coc", 10)
	if certErr == "404" then
		warn("[SYSMAINT] GUI certificate file not found (404)")
		sendRobloxNotification("ObjecX Error", "GUI certificate file not found (404)", 10)
		traceback("installGuiUpdate", "GUI certificate file returned 404")
		return false
	end
	
	if certErr == "TIMEOUT" then
		warn("[SYSMAINT] GUI certificate request timed out")
		sendRobloxNotification("ObjecX Warning", "Certificate verification timed out. Update cancelled.", 5)
		traceback("installGuiUpdate", "GUI certificate request timed out")
		return false
	end
	
	if not guiCertData then
		warn("[SYSMAINT] Failed to fetch GUI certificate")
		traceback("installGuiUpdate", "Failed to fetch GUI certificate")
		return false
	end
	
	oldprint("[SYSMAINT] Verifying GUI certificate...")
	local isValid, message, metadata = Certificate.verify(guiCertData, OBJECX_PUBLIC_KEYS.gui, guiScriptData)
	
	if not isValid then
		warn("[SYSMAINT] GUI certificate verification FAILED: " .. message)
		sendRobloxNotification("ObjecX Security Warning", "GUI update failed certificate check - " .. message, 15)
		traceback("installGuiUpdate", "GUI certificate invalid: " .. message)
		return false
	end
	
	oldprint("[SYSMAINT] GUI certificate verified successfully")
	if metadata then
		oldprint("[SYSMAINT] Certificate ID: " .. (metadata.certifID or "unknown"))
		oldprint("[SYSMAINT] Algorithm: " .. (metadata.algo or "unknown"))
	end
	
	local savePath = "ObjecX/libraries/gui." .. oldtostring(newVersion) .. ".lua"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
	end)
	if saveSuccess then
		cleanOldGuiFiles(newVersion)
		oldprint("[SYSMAINT] Installed GUI update: v" .. oldtostring(newVersion))
		return true
	end
	
	warn("[SYSMAINT] Failed to install GUI update v" .. oldtostring(newVersion))
	traceback("installGuiUpdate", "Failed to install GUI update v" .. oldtostring(newVersion))
	return false
end

-- (Rest of ObjecX framework continues with filesystem checks, startup, etc...)
-- I'll truncate here since the key fix is the certificate signing system

oldprint("[SYSMAINT] ObjecX Core Framework loaded with corrected certificate system")
