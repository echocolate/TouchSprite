local rk = require "ruokuai"

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
    file = "1.png",
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
