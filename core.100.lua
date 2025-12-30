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
        n = "188e8d63",
        key = "188e8d63"
    },
    gui = {
        e = "10001",
        n = "66355255",
        key = "66355255"
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
    oldprint("[CERT] Starting certificate verification...")
    oldprint("[CERT] Certificate size: " .. oldtostring(#signedCert) .. " bytes")
    
    local certPart, sigPart = oldstring_match(signedCert, "(.+)SIG:(.+)")
    
    if not certPart or not sigPart then
        oldprint("[CERT] FAIL: Could not parse SIG: delimiter")
        return nil, "MALFORMED"
    end
    
    oldprint("[CERT] Certificate part size: " .. oldtostring(#certPart) .. " bytes")
    oldprint("[CERT] Signature part size: " .. oldtostring(#sigPart) .. " bytes")
    oldprint("[CERT] Certificate content: " .. certPart)
    
    local sigChunks = {}
    for chunk in oldstring_gmatch(sigPart, "([^:]+)") do
        oldtable_insert(sigChunks, chunk)
    end
    
    if #sigChunks == 0 then
        oldprint("[CERT] FAIL: No signature chunks found")
        return nil, "MALFORMED"
    end
    
    oldprint("[CERT] Signature chunks: " .. oldtostring(#sigChunks))
    
    local certChunks = stringToChunks(certPart, 6)
    oldprint("[CERT] Certificate chunks: " .. oldtostring(#certChunks))
    
    if #certChunks ~= #sigChunks then
        oldprint("[CERT] FAIL: Chunk count mismatch!")
        oldprint("[CERT]   Cert chunks: " .. oldtostring(#certChunks))
        oldprint("[CERT]   Sig chunks: " .. oldtostring(#sigChunks))
        return nil, "MISMATCH"
    end
    
    oldprint("[CERT] Chunk counts match, verifying signatures...")
    
    local publicE = BigInt.new(publicKey.e)
    local publicN = BigInt.new(publicKey.n)
    
    oldprint("[CERT] Public key e: " .. publicKey.e)
    oldprint("[CERT] Public key n: " .. publicKey.n)
    
    for i = 1, #certChunks do
        local signatureBig = BigInt.new(sigChunks[i])
        local decrypted = signatureBig:modPow(publicE, publicN)
        
        local chunkNum = chunkToNumber(certChunks[i])
        local chunkBig = BigInt.new(chunkNum)
        
        if decrypted:toString() ~= chunkBig:toString() then
            oldprint("[CERT] FAIL: Signature verification failed at chunk " .. oldtostring(i))
            oldprint("[CERT]   Cert chunk (string): '" .. certChunks[i] .. "'")
            oldprint("[CERT]   Cert chunk (hex): " .. chunkBig:toString())
            oldprint("[CERT]   Signature (hex): " .. sigChunks[i])
            oldprint("[CERT]   Decrypted sig (hex): " .. decrypted:toString())
            oldprint("[CERT]   Expected (hex): " .. chunkBig:toString())
            return nil, "MISMATCH"
        end
        
        if i == 1 or i == #certChunks then
            oldprint("[CERT] Chunk " .. oldtostring(i) .. " verified OK")
        end
    end
    
    oldprint("[CERT] All " .. oldtostring(#certChunks) .. " signature chunks verified successfully")
    
    local metadata = {}
    for line in oldstring_gmatch(certPart, "([^,]+)") do
        if line ~= ";;;" then
            local key, value = oldstring_match(line, "([^:]+):(.+)")
            if key and value then
                metadata[key] = value
            end
        end
    end
    
    oldprint("[CERT] Parsed metadata:")
    for k, v in pairs(metadata) do
        if k == "hash" then
            oldprint("[CERT]   " .. k .. ": " .. oldstring_sub(v, 1, 20) .. "... (" .. oldtostring(#v) .. " chars)")
        else
            oldprint("[CERT]   " .. k .. ": " .. v)
        end
    end
    
    return metadata
end

function Certificate.verify(signedCert, publicKey, fileData)
    oldprint("[VERIFY] Starting certificate verification...")
    oldprint("[VERIFY] File size: " .. oldtostring(#fileData) .. " bytes")
    oldprint("[VERIFY] Certificate size: " .. oldtostring(#signedCert) .. " bytes")
    
    local metadata, err = Certificate.view(signedCert, publicKey)
    if not metadata then
        oldprint("[VERIFY] FAIL: Certificate.view failed - " .. err)
        return false, err, nil
    end
    
    oldprint("[VERIFY] Certificate signature verified OK")
    
    if metadata.company ~= "ObjecX" then
        oldprint("[VERIFY] FAIL: Company mismatch")
        oldprint("[VERIFY]   Expected: ObjecX")
        oldprint("[VERIFY]   Got: " .. oldtostring(metadata.company))
        return false, "UNTRUSTED", metadata
    end
    
    oldprint("[VERIFY] Company check OK: " .. metadata.company)
    
    if metadata.purpose ~= "hash" then
        oldprint("[VERIFY] FAIL: Purpose mismatch")
        oldprint("[VERIFY]   Expected: hash")
        oldprint("[VERIFY]   Got: " .. oldtostring(metadata.purpose))
        return false, "BADPURPOSE", metadata
    end
    
    oldprint("[VERIFY] Purpose check OK: " .. metadata.purpose)
    
    if not metadata.hash then
        oldprint("[VERIFY] FAIL: No hash in certificate")
        return false, "MALFORMED", metadata
    end
    
    oldprint("[VERIFY] Certificate hash: " .. oldstring_sub(metadata.hash, 1, 20) .. "... (" .. oldtostring(#metadata.hash) .. " chars)")
    oldprint("[VERIFY] Hashing downloaded file with Grindstone (32 rounds)...")
    
    local fileHash = compressHash(fileData, 32)
    
    oldprint("[VERIFY] Computed file hash: " .. oldstring_sub(fileHash, 1, 20) .. "... (" .. oldtostring(#fileHash) .. " chars)")
    oldprint("[VERIFY] Full cert hash: " .. metadata.hash)
    oldprint("[VERIFY] Full file hash: " .. fileHash)
    
    if metadata.hash ~= fileHash then
        oldprint("[VERIFY] FAIL: Hash mismatch!")
        oldprint("[VERIFY]   Certificate contains: " .. metadata.hash)
        oldprint("[VERIFY]   File computed to:     " .. fileHash)
        oldprint("[VERIFY]   File size: " .. oldtostring(#fileData) .. " bytes")
        
        local matchCount = 0
        for i = 1, oldmath_max(#metadata.hash, #fileHash) do
            if oldstring_sub(metadata.hash, i, i) == oldstring_sub(fileHash, i, i) then
                matchCount = matchCount + 1
            else
                break
            end
        end
        oldprint("[VERIFY]   Matching prefix: " .. oldtostring(matchCount) .. " characters")
        
        return false, "MISMATCH", metadata
    end
    
    oldprint("[VERIFY] Hash verification SUCCESS")
    oldprint("[VERIFY] All checks passed!")
    
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
		local certVersion = string.match(file, "gui%.(%d+)%.coc$")
		if certVersion and oldtonumber(certVersion) ~= keepVersion then
			pcall(function()
				oldDelFile(file)
				oldprint("[SYSMAINT] Removed old certificate file: " .. file)
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
	
	local certFile = "ObjecX/libraries/gui." .. oldtostring(guiVersion) .. ".coc"
	if not oldIsFile(certFile) then
		warn("[SYSMAINT] Cached certificate missing, cache invalid")
		traceback("loadGuiFromCache", "Cached certificate missing for gui." .. oldtostring(guiVersion))
		pcall(function()
			oldDelFile(guiFile)
		end)
		return nil
	end
	
	oldprint("[SYSMAINT] Verifying cached GUI certificate...")
	local certData = oldReadFile(certFile)
	local isValid, message, metadata = Certificate.verify(certData, OBJECX_PUBLIC_KEYS.gui, fileContent)
	
	if not isValid then
		warn("[SYSMAINT] Cached GUI certificate verification FAILED: " .. message)
		traceback("loadGuiFromCache", "Cached certificate invalid: " .. message)
		pcall(function()
			oldDelFile(guiFile)
			oldDelFile(certFile)
		end)
		return nil
	end
	
	oldprint("[SYSMAINT] Cached GUI certificate verified successfully")
	
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
	oldprint("[SYSMAINT] GUI file size: " .. oldtostring(#guiScriptData) .. " bytes")
	oldprint("[SYSMAINT] GUI cert size: " .. oldtostring(#guiCertData) .. " bytes")
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
	local certPath = "ObjecX/libraries/gui." .. oldtostring(newgui) .. ".coc"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
		oldWriteFile(certPath, guiCertData)
	end)
	
	if not saveSuccess then
		warn("[SYSMAINT] Failed to save GUI script to filesystem")
		traceback("fetchAndLoadGui", "Failed to save GUI script to filesystem")
	else
		oldprint("[SYSMAINT] Saved GUI script: " .. savePath)
		oldprint("[SYSMAINT] Saved GUI certificate: " .. certPath)
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
	oldprint("[SYSMAINT] GUI file size: " .. oldtostring(#guiScriptData) .. " bytes")
	oldprint("[SYSMAINT] GUI cert size: " .. oldtostring(#guiCertData) .. " bytes")
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
	local certPath = "ObjecX/libraries/gui." .. oldtostring(newVersion) .. ".coc"
	local saveSuccess = pcall(function()
		oldWriteFile(savePath, guiScriptData)
		oldWriteFile(certPath, guiCertData)
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

-- Primary FileSystem Wizard
local fsStartTime = tick()
oldprint("[SYSMAINT] Fs verification...")

if not oldIsFolder("ObjecX") then
	oldMakeFolder("ObjecX")
	oldprint("[SYSMAINT] Created directory: ObjecX")
else
	oldprint("[SYSMAINT] Verified directory: ObjecX")
end

if not oldIsFile("ObjecX/mainscript.luau") then
	oldWriteFile("ObjecX/mainscript.luau", SelfScript)
	oldprint("[SYSMAINT] Created file: ObjecX/mainscript.luau")
else
	oldprint("[SYSMAINT] Verified file: ObjecX/mainscript.luau")
end

if not oldIsFolder("ObjecX/versions") then
	oldMakeFolder("ObjecX/versions")
	oldprint("[SYSMAINT] Created directory: ObjecX/versions")
else
	oldprint("[SYSMAINT] Verified directory: ObjecX/versions")
end

if not oldIsFile("ObjecX/versions/" .. oldtostring(CVersion) .. ".lua") then
	oldWriteFile("ObjecX/versions/" .. oldtostring(CVersion) .. ".lua", SelfScript)
	oldprint("[SYSMAINT] Created file: ObjecX/versions/" .. oldtostring(CVersion) .. ".lua")
else
	oldprint("[SYSMAINT] Verified file: ObjecX/versions/" .. oldtostring(CVersion) .. ".lua")
end

if not oldIsFolder("ObjecX/libraries") then
	oldMakeFolder("ObjecX/libraries")
	oldprint("[SYSMAINT] Created directory: ObjecX/libraries")
	CACHE_MISS = 1
else
	oldprint("[SYSMAINT] Verified directory: ObjecX/libraries")
	if not checkCacheIntegrity() then
		CACHE_MISS = 1
	end
end

local fsElapsed = tick() - fsStartTime
oldprint(oldstring_format("[SYSMAINT] Finished: %.3fs", fsElapsed))

-- Login check for hard crash detection
if oldIsFile("ObjecX/.loggedin") then
	oldprint("[SYSMAINT] Detected existing .loggedin file")
	if oldIsFile("ObjecX/increment.lock") then
		oldprint("[SYSMAINT] Checking increment.lock for activity")
		local lockValue = oldtonumber(oldReadFile("ObjecX/increment.lock")) or 0
		task.wait(1.5)
		local newLockValue = oldtonumber(oldReadFile("ObjecX/increment.lock")) or 0
		
		if newLockValue > lockValue then
			traceback("LoginCheck", "Another instance is already running, stopping")
			return
		else
			oldprint("[SYSMAINT] Hard crash detected, continuing with recovery")
			traceback("LoginCheck", "Hard crash detected, continuing with recovery")
			HARD_SHUTDOWN = 1
		end
	else
		oldprint("[SYSMAINT] Hard crash detected (no increment.lock)")
		traceback("LoginCheck", "Hard crash detected (no increment.lock), continuing with recovery")
		HARD_SHUTDOWN = 1
	end
end

oldWriteFile("ObjecX/.loggedin", oldtostring(os.time()))
oldprint("[SYSMAINT] Created .loggedin file")

-- Crash counter check
local crashCount = 0
if oldIsFile("ObjecX/.crashcount") then
	local crashData = oldReadFile("ObjecX/.crashcount")
	local crashTime = oldtonumber(string.match(crashData, "time:(%d+)")) or 0
	crashCount = oldtonumber(string.match(crashData, "count:(%d+)")) or 0
	
	local timeSinceLastCrash = os.time() - crashTime
	if timeSinceLastCrash > 300 then
		crashCount = 0
	end
	
	crashCount = crashCount + 1
	if crashCount >= 3 then
		logError("CRITICAL: Too many crashes detected (" .. oldtostring(crashCount) .. "), giving up")
		oldWriteFile("ObjecX/CRITICAL_FAILURE.txt", "System failed after " .. oldtostring(crashCount) .. " crash attempts")
		oldDelFile("ObjecX/.crashcount")
		shutdown()
		return
	end
	oldWriteFile("ObjecX/.crashcount", "count:" .. oldtostring(crashCount) .. " time:" .. oldtostring(os.time()))
	oldprint("[SYSMAINT] Updated .crashcount: " .. oldtostring(crashCount))
else
	oldWriteFile("ObjecX/.crashcount", "count:1 time:" .. oldtostring(os.time()))
	oldprint("[SYSMAINT] Created .crashcount file")
end

-- GUI Loading Logic
local cacheStartTime = tick()
oldprint("[SYSMAINT] Cache loading...")

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
oldprint(oldstring_format("[SYSMAINT] Finished: %.3fs", cacheElapsed))

if not guiModule then
	sendRobloxNotification("ObjecX Critical Error", "GUI failed to load. Check crash.log for details.", 10)
	warn("[SYSMAINT] GUI module is completely unavailable")
	traceback("GUILoader", "GUI module is completely unavailable")
end

-- Logon check
if oldIsFile("ObjecX/increment.lock") then
	oldprint("[SYSMAINT] Checking increment.lock")
	local lockValue = oldReadFile("ObjecX/increment.lock")
	if lockValue ~= "0" and HARD_SHUTDOWN == 0 then
		oldWriteFile("ObjecX/increment.lock", "0")
		oldprint("[SYSMAINT] Reset increment.lock to 0")
		HARD_SHUTDOWN = 1
	else
		oldprint("[SYSMAINT] Verified increment.lock")
	end
else
	oldWriteFile("ObjecX/increment.lock", "0")
	oldprint("[SYSMAINT] Created increment.lock")
end

if oldIsFile("ObjecX/.STOP") then
	oldprint("[SYSMAINT] Detected .STOP file")
	if HARD_SHUTDOWN == 1 then
		oldDelFile("ObjecX/.STOP")
		oldprint("[SYSMAINT] Deleted .STOP file")
	else
		shutdown()
		return
	end
end

if oldIsFile("ObjecX/.UNINSTALL") then
	oldprint("[SYSMAINT] Detected .UNINSTALL file, removing ObjecX")
	if oldIsFolder("ObjecX") then
		oldDelFolder("ObjecX")
	end
	return
end

-- Update check
local updateStartTime = tick()
oldprint("[SYSMAINT] Update check...")

local shouldCheckCoreUpdate = false
local currentTime = os.time()

if oldIsFile("ObjecX/.lastchecked") then
	local lastChecked = oldtonumber(oldReadFile("ObjecX/.lastchecked")) or 0
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
		oldWriteFile("ObjecX/.lastchecked", oldtostring(currentTime))
		oldprint("[SYSMAINT] Updated .lastchecked")
		local latestCVersion = oldtonumber(cversionData)
		if latestCVersion and latestCVersion > CVersion then
			oldprint("[SYSMAINT] Core update available: v" .. oldtostring(CVersion) .. " -> v" .. oldtostring(latestCVersion))
			if installCoreUpdate(latestCVersion) then
				oldprint("[SYSMAINT] Core updated, restarting...")
				restart()
				return
			end
		else
			oldprint("[SYSMAINT] Core | Current: v" .. oldtostring(CVersion) .. " | Latest: v" .. oldtostring(latestCVersion or CVersion))
			oldprint("[SYSMAINT] Up to date, skipped installing")
		end
	end
end

local updateElapsed = tick() - updateStartTime
oldprint(oldstring_format("[SYSMAINT] Finished: %.3fs", updateElapsed))

-- Logon system (increment.lock updater)
task.spawn(function()
	oldprint("[SYSMAINT] Starting increment.lock updater")
	local counter = 0
	while true do
		if oldIsFile("ObjecX/.STOP") then
			shutdown()
			break
		end
		counter = counter + 1
		pcall(function()
			oldWriteFile("ObjecX/increment.lock", oldtostring(counter))
		end)
		task.wait(0.1)
	end
end)

-- Background Update Checker (every 1 minute)
task.spawn(function()
	task.wait(60)
	oldprint("[SYSMAINT] Background updater started")
	
	while true do
		local bgUpdateStartTime = tick()
		oldprint("[SYSMAINT] Update check...")
		
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
			local latestCVersion = oldtonumber(cversionData)
			oldprint("[SYSMAINT] Core | Current: v" .. oldtostring(CVersion) .. " | Latest: v" .. oldtostring(latestCVersion or "unknown"))
			if latestCVersion and latestCVersion > CVersion then
				coreUpdateAvailable = true
				newCoreVersion = latestCVersion
				oldprint("[SYSMAINT] Core update available")
			else
				oldprint("[SYSMAINT] Core up to date, skipped installing")
			end
		else
			warn("[SYSMAINT] Failed to fetch core version")
		end
		
		cachedGuiVersion = nil
		cachedGuiList = nil
		local latestGuiVersion = getCompatibleGuiVersion()
		local currentGuiVersion = getCurrentGuiVersion()
		
		if latestGuiVersion and currentGuiVersion then
			oldprint("[SYSMAINT] GUI | Current: v" .. oldtostring(currentGuiVersion) .. " | Latest: v" .. oldtostring(latestGuiVersion))
			if latestGuiVersion > currentGuiVersion then
				guiUpdateAvailable = true
				newGuiVersion = latestGuiVersion
				oldprint("[SYSMAINT] GUI update available")
			else
				oldprint("[SYSMAINT] GUI up to date, skipped installing")
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
				notifDesc = "Core v" .. oldtostring(newCoreVersion) .. " and GUI v" .. oldtostring(newGuiVersion) .. " are available. Click to install."
			elseif coreUpdateAvailable then
				notifTitle = "Core Update Available"
				notifDesc = "Version " .. oldtostring(newCoreVersion) .. " is available. Click to install and restart."
			elseif guiUpdateAvailable then
				notifTitle = "GUI Update Available"
				notifDesc = "Version " .. oldtostring(newGuiVersion) .. " is available. Click to install and restart."
				if not guiModule then
					useRobloxNotif = true
				end
			end
			
			if guiModule and not useRobloxNotif then
				local success = pcall(function()
					guiModule.registerCallback("objecx_update_install", function()
						oldprint("[SYSMAINT] User initiated update installation")
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
					sendRobloxNotification("ObjecX Update", "GUI v" .. oldtostring(newGuiVersion) .. " available. Reinstall script to update.", 10)
				end
				if coreUpdateAvailable then
					sendRobloxNotification("ObjecX Update", "Core v" .. oldtostring(newCoreVersion) .. " available. Reinstall script to update.", 10)
				end
			end
		end
		
		local bgUpdateElapsed = tick() - bgUpdateStartTime
		oldprint(oldstring_format("[SYSMAINT] Finished: %.3fs", bgUpdateElapsed))
		task.wait(60)
	end
end)

-- Auxiliary Failsafe Watchdog
task.spawn(function()
	task.wait(2)
	oldprint("[SYSMAINT] Starting failsafe watchdog")
	if not oldIsFile("ObjecX/increment.lock") then
		return
	end
	
	local lastValue = oldtonumber(oldReadFile("ObjecX/increment.lock")) or 0
	local failCount = 0
	local checkStartTime = tick()
	
	while true do
		task.wait(1)
		
		if not oldIsFile("ObjecX/increment.lock") then
			return
		end
		
		local currentValue = oldtonumber(oldReadFile("ObjecX/increment.lock")) or 0
		
		if isGameFrozen() then
			lastValue = currentValue
			failCount = 0
			checkStartTime = tick()
		elseif currentValue == lastValue then
			failCount = failCount + 1
			if failCount >= 3 and (tick() - checkStartTime) < 15 then
				oldprint("[SYSMAINT] Watchdog triggered: script freeze detected")
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
	oldprint("[SYSMAINT] Starting shutdown monitor")
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
		oldprint("[SYSMAINT] Cleared .crashcount after successful uptime")
	end
end)

-- Main execution
local success, err = pcall(function()
	if guiModule then
		oldprint("ObjecX Core v" .. oldtostring(CVersion) .. " loaded successfully with Certificate verification")
	else
		warn("[SYSMAINT] GUI module is nil, couldn't load GUI")
		traceback("MainExecution", "GUI module is nil, couldn't load GUI")
		warn("ObjecX Core loaded but GUI module failed to load")
	end
end)

if not success then
	traceback("MainExecution", "Main execution error: " .. oldtostring(err))
	logError("Main execution error: " .. oldtostring(err))
end
