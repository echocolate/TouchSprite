--[[
--在执行前会先把login.txt文件导入到触动精灵res文件下，login.txt文件的格式是一行一条qq，字段分别为：nzt重命名名称   qq账号  qq密码
--具体实施步骤：1、检查是否有login.txt文件，若有的话，读出有多少行；2、循环每一行的内容，完成重命名、切换语言、登录qq的过程【注意：nzt重命名
--名称的格式是01-22，前两位是顺序，是从01开始，顺序往下排，此处要求必须从01顺序，每一行加1，后两位是qq账号的末两位】
--]]
local RootPath = "/var/mobile/Media/TouchSprite/"
require "comm.functions"
local gvar = require "gvar"
local record = require "record"
local nzt = require "nzt"
local qq = require "qq"
--require "TSLib"
--require "TSLibEx"
--local sz = require "sz"
--local ocr = require "cloudOcr"

local bid_NZT = nzt.bid
local bid_QQ = qq.bid
local errorFile = RootPath .. "res/failed.txt"

local function nztloop(param)
    init(bid_NZT, 0)
    while true do
        local _bid = frontAppBid()
        if _bid == bid_NZT then
            break
        end
        runApp(bid_NZT)
        mSleep(500)
    end
    mSleep(3*1000)
    nzt.tapNewMachine()
    mSleep(2*1000);
    nzt.tapRecord()
    mSleep(3*1000)
    local x, y = nzt.findSelLoop(30)
    if x == -1 or y == -1 then
        dialog("not found this record.", 0)
        lua_exit()
    end
    nzt.showRename(x, y)
    mSleep(2*1000)
    nzt.tapRename(x, y)
    mSleep(2*1000)
    nzt.tapInput()
    mSleep(1000)
    nzt.clearInput()
    mSleep(3*1000)
    nzt.inputName(param.name)
    --nzt.inputName("test-name")
    mSleep(1*1000)
    nzt.tapInputConfirm()
    mSleep(2*1000)
    nzt.tapRecordBack()
end

local function qqloop(param)
    init(bid_QQ, 0);
    while true do
        local _bid = frontAppBid()
        if _bid == bid_QQ then
            break
        end
        runApp(bid_QQ)
        mSleep(500)
    end
    mSleep(3*1000);
    local loops = 0
    while true do
        --if loops > 3 then break end
        local _ui = qq.getCurrentUI();
        if _ui == qq.WHICH_UI.WELCOME_1 then
            loops = 0
            ctouchmove({x=520,y=640}, {x=280,y=640});
        elseif _ui == qq.WHICH_UI.WELCOME_2 then
            loops = 0
            --tap(320, 990)
            qq.tapEntryQQ()
        elseif _ui == qq.WHICH_UI.INCORRECT then  -- 登录失败，记录
            toast("Incorrect acct passwd:" .. param.acct, 1)
            writeFailed(errorFile, param, "invalid")
            break
        elseif _ui == qq.WHICH_UI.VERIFY then  -- 需要手机验证，记录
            toast("need phone verify:" .. param.acct, 1)
            writeFailed(errorFile, param, "verify")
            break
        elseif _ui == qq.WHICH_UI.LOGIN then
            --toast("current login")
            mSleep(1500)
            --tap(560, 67)
            if not qq.isUI_LOGIN_EN() then  -- 不是英文，切换到英文
                --toast("current not en")
                tap(560, 67)
                mSleep(1500)
                tap(85, 246)
                mSleep(500)
                tap(560, 86)
            else
                --toast("current en")
                qq.doLogin(param.acct, param.passwd)
                mSleep(6*1000)
            end
        --elseif _ui == qq.WHICH_UI.LANG_CN then
        --    tap(85, 246)
        --    mSleep(50)
        --    tap(560, 86)
        elseif _ui == qq.WHICH_UI.LANG_EN then
            -- 已经是英文了，直接返回
            tap(65, 86)
        --elseif _ui == qq.WHICH_UI.LOGIN_EN then
        --     qq.doLogin(param.acct, param.passwd)
        --    --tap(320, 367)
        elseif _ui == qq.WHICH_UI.INSERTCODE then
            if not param.dama then
                param.dama = true
                snapshot(param.acct .. ".png", 188, 145, 452, 256);
                local  rk = require "ruokuai.ruokuai"
                local cfgruokuai = require "cfgruokuai"
                rk.initFromCfg(cfgruokuai)
                local rkParam = {
                    file = RootPath .. "res/" .. param.acct .. ".png",
                }
                toast("auto dama ing....", 1)
                local result = rk.create(rkParam)
                if not result or result.Error then
                    dialog("dama failed. please input manually", 0)
                else
                    qq.tapInsertCode(result.Result)
                end
            end
            mSleep(6*1000);
        elseif _ui == qq.WHICH_UI.CHAT then  -- 已经成功登陆qq, 记录下来, 否则一直循环,等待人工辅助
            writeFailed(errorFile, param, "success")
            break
        else
            --loops = loops + 1
        end
        mSleep(3*1000);
    end
    mSleep(6*1000)
end

local function main()
    -- 获取设备类型，假定只有5C和4S
    local w, h = getScreenSize()
    if w == 640 and h == 960 then
        gvar.setDevice(gvar.DEVICE.I4S)
    elseif w == 640 and h == 1136 then
        gvar.setDevice(gvar.DEVICE.I5C)
    end
    -- 读取历史错误记录
    local err_records = {}
    if io.exists(errorFile) then
        local efile, eerr = io.open(errorFile, "r")
        if efile == nil then
            dialog("open res/failed.txt failed! " .. eerr, 0)
            lua_exit()
        end
        for lline in efile:lines() do
            aarr = string.split(lline, ",")
            local _rec = record.new(aarr[1], aarr[2], aarr[3], aarr[4])
            err_records[#err_records+1] = _rec
        end
        io.close(efile)
    end
    -- 读取账户文件
    local records = {}
    local file, err = io.open("/var/mobile/Media/TouchSprite/res/login.txt", "r")
    if file == nil then
        dialog("open login.txt failed! " .. err, 0)
        lua_exit()
    end
    for line in file:lines() do
        arr = string.split(line, ",")
        local _rec = record.new(arr[1], arr[2], arr[3], arr[4])
        if not isErrRec(err_records, _rec) then
            records[#records+1] = _rec
        end
    end
    io.close(file)
    for ii=1,#records do
        changeIP();
        mSleep(5*1000)
        nztloop(records[ii]);
        mSleep(2*1000);
        qqloop(records[ii]);
    end
    mSleep(2*1000);
    toast("scripts end.", 1)
    mSleep(3*1000);
end

main();
--init(bid_QQ, 0);
--snapshot("ui_sel.png", 577, 617, 613, 647);
--mSleep(3*1000);
--toast("scripts end.", 1);
