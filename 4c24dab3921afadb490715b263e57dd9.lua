-- This file is licensed with Luarmor. You must use the actual loadstring to execute this script.
-- Do not run this file directly. Always use the loadstring.

local licenseMessage = "This file is licensed with Luarmor. You must use the actual loadstring to execute this script. Do not run this file directly. Always use the loadstring."
local scriptID = "4c24dab3921afadb490715b263e57dd9"
local scriptURL = "https://api.luarmor.net/files/v3/l/" .. scriptID .. ".lua"
local cacheFileName = scriptID .. "-cache.lua"
local errorLogFile = "lrm-err-loader-log-httpresp.txt"

-- Function to handle loading and caching of the script
local function handleScriptLoading(mode)
    if mode == "flush" then
        wait(0.03)
        local retryDelay = 2
        local scriptContent, success, errorMsg

        local function fetchAndCacheScript()
            scriptContent, success = pcall(function()
                local content = game:HttpGet(scriptURL)
                pcall(writefile, cacheFileName, "-- " .. licenseMessage .. "\n\n if not is_from_loader then warn('Use the loadstring, do not run this directly') return end;\n " .. content)
                return loadstring(content)
            end)
            if not success then
                pcall(writefile, errorLogFile, tostring(scriptContent))
                warn("Error while executing loader. Err: " .. tostring(errorMsg) .. " See " .. errorLogFile .. " in your workspace.")
                return nil
            end
            return scriptContent
        end

        local scriptFunc = fetchAndCacheScript()
        if scriptFunc then
            scriptFunc(is_from_loader)
        end
    elseif mode == "rl" then
        pcall(writefile, cacheFileName, "recache required")
        wait(0.2)
        pcall(delfile, cacheFileName)
    end
end

-- Attempt to load the cached script
local cachedScript, success = pcall(function()
    return readfile(cacheFileName)
end)

if not success or not cachedScript or #cachedScript < 5 then
    handleScriptLoading("flush")
else
    local scriptFunc = loadstring(cachedScript)
    if scriptFunc then
        scriptFunc(is_from_loader)
    else
        handleScriptLoading("flush")
    end
end
