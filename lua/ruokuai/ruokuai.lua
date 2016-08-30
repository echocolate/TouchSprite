local rk = {}

local sz = require"sz"
--local socket = require"szocket"
local http = require"szocket.http"
local lunajson = require"lunajson"

local username = "ffddr2"
local password = "123465b"
local v1 = "4443cb6db"
local typeid = "3040"
local v3 = "882d57c5"
local timeout = "90"
local softid = "66040"
local v2 = "b9f4a8d"
local softkey = v1 .. v2 .. v3 .. "d47f45b3"

local URL_CREATE = "http://api.ruokuai.com/create.json"
local URL_REPORT = "http://api.ruokuai.com/reporterror.json"

--print(socket.gettime())

local function getFileData(filePath)
    local file, err = io.open(filePath, "rb")
    if not file then
        dialog("open file failed:" .. err)
        lua_exit()
    end
    local data = file:read("*a")
    io.close(file)
    return data
end

function rk.initFromCfg(_cfg)
    if type(_cfg) ~= "table" or not _cfg.username or not _cfg.password then
        dialog("配置文件错误.", 0)
        lua_exit()
    end
    username = _cfg.username
    password = _cfg.password
    typeid = _cfg.typeid or "3040"
    timeout = _cfg.timeout or "60"
end

function rk.create(param)
    local ltn12 = require "ltn12"
    local H = (require "szocket.http").request
    local mp = (require "mpost").gen_request
    local rsp = {}
    local rq = mp{
        image = { name = param.file, filename=param.file, data = getFileData(param.file) },
        username = param.username or username,
        password = param.password or password,
        typeid = param.typeid or typeid,
        timeout = param.timeout or timeout,
        softid = softid,
        softkey = softkey,
    }
    rq.url = URL_CREATE
    rq.sink = ltn12.sink.table(rsp)
    local res, code, response_headers = H(rq)
    if code == 200 then
        --{"Result":"uudv","Id":"1de08c4e-e2c7-4d4a-b526-073e34edc4aa"}
        --{"Error":"没有image数据,请确定POST格式是否正确.err:http: no such file","Error_Code":"10111","Request":""}
        local _r = lunajson.decode(rsp[1])
        return _r
    else
        return nil
    end
end

function rk.reportError(param)
    local ltn12 = require "ltn12"
    local H = (require "szocket.http").request
    local mp = (require "mpost").gen_request
    local rsp = {}
    local rq = mp{
        username = param.username or username,
        password = param.password or password,
        softid = param.softid or softid,
        softkey = softkey,
        id = param.id,
    }
    rq.url = URL_REPORT
    rq.sink = ltn12.sink.table(rsp)
    local res, code, response_headers = H(rq)
    if code == 200 then
        --{"Result":"uudv","Id":"1de08c4e-e2c7-4d4a-b526-073e34edc4aa"}
        --{"Error":"没有image数据,请确定POST格式是否正确.err:http: no such file","Error_Code":"10111","Request":""}
        local _r = lunajson.decode(rsp[1])
        return _r
    else
        return nil
    end
end

return rk
