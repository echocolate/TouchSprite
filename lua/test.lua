init(0)
mSleep(2000)
local rk = require "ruokuai.ruokuai"
local cfgruokuai = require "cfgruokuai"
rk.initFromCfg(cfgruokuai)

local RootPath = "/var/mobile/Media/TouchSprite/"

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

local URL_CREATE = "http://api.ruokuai.com/create.json"

local param = {
    file = RootPath .. "res/1.png",
}

local result = rk.create(param)

if not result then
    dialog("no response")
    os.exit(1)
end

if result.Error then
    dialog("Error_Code:" .. result.Error_Code)
    dialog("Error:" .. result.Error)
else
    dialog("Result:" .. result.Result)
    dialog("Id:" .. result.Id)
    if string.lower(string.trim(result.Result)) ~= "bcwa" then
        local result2 = rk.reportError({id = result.Id})
        if result2.Error then
            dialog("Error_Code:" .. result2.Error_Code)
            dialog("Error:" .. result2.Error)
        else
            dialog("Result:" .. result2.Result)
        end
    end
end
toast("script end...........")
mSleep(5000)
