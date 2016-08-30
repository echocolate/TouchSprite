local qq = {}

local RootPath = "/var/mobile/Media/TouchSprite/"
local gvar = require "gvar"

qq.bid = "com.tencent.mQQi"

local WHICH_UI = {
    NOT_FOUND = 0,
    WELCOME_1 = 1,
    WELCOME_2 = 2,
    LOGIN_CN = 3,
    LOGIN_EN = 4,
    LANG_CN = 5,
    LANG_EN = 6,
    INSERTCODE = 7,
    LOGIN = 8,
    CHAT = 9,
    INCORRECT = 10,   -- 登陆失败
    VERIFY = 11,      -- 需要手机验证
}
qq.WHICH_UI = WHICH_UI

local w1_points = {
    [1] = { x=342, y=242, color="0xFCBB4C" },
    [2] = { x=250, y=270, color="0xCA9947" },
    [3] = { x=290, y=290, color="0x7D6B4F" },
    [4] = { x=493, y=300, color="0x758083" },
    color = 0xFCBB4C,
    x1 = 210,
    y1 = 210,
    x2 = 500,
    y2 = 320,
}
local w1_points_4s = {
    [1] = { x=342, y=242, color="0xFCBB4C" },
    [2] = { x=250, y=270, color="0xCA9947" },
    [3] = { x=290, y=290, color="0x7D6B4F" },
    [4] = { x=493, y=300, color="0x758083" },
    color = 0xFCBB4C,
    x1 = 200,
    y1 = 200,
    x2 = 520,
    y2 = 350,
}
--[[
-- 5C p1(342, 242) p2(250, 270)  p3(290, 290) p4(493, 300)
-- x,y = findMultiColorInRegionFuzzy( 0xfcbb4c, "53|-6|0xca9947,104|20|0x7d6b4f,-26|-25|0x758083", 90, 0, 0, 0, 0)
--]]
function qq.isUI_WELCOME_1()
    local posandcolor = ""
    local tbl = w1_points
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tbl = w1_points_4s
    end
    for ii=2,4 do
        posandcolor = posandcolor .. (tbl[ii].x-tbl[1].x) .. "|" .. (tbl[ii].y-tbl[1].y) .. "|" .. tbl[ii].color
        if ii < 4 then
            posandcolor = posandcolor .. ","
        end
    end
    local x, y = findMultiColorInRegionFuzzy(tbl.color, posandcolor, 100, tbl.x1, tbl.y1, tbl.x2, tbl.y2); 
    --if gvar.getDevice() == gvar.DEVICE.I4S then
    --    x, y = findMultiColorInRegionFuzzy( 0xFCBB4C, "53|-6|0xCA9947,104|20|0x7D6B4F,-26|-25|0x758083", 90, 200, 200, 520, 350)
    --end
    if x ~= -1 and y~= -1 then
        return true
    end
    return false
end

--[[
-- 5C p1(86, 297) p2(117, 308)  p3(162, 355) p4(420, 340)
--]]
local w2_points = {
    [1] = { x=86, y=297, color="0xFF9751" },
    [2] = { x=117, y=308, color="0x67CDB6" },
    [3] = { x=162, y=355, color="0x321A13" },
    [4] = { x=420, y=340, color="0x59BBc1" },
}
function qq.isUI_WELCOME_2()
    local posandcolor = ""
    local tbl = w2_points
    for ii=2,4 do
        posandcolor = posandcolor .. (tbl[ii].x-tbl[1].x) .. "|" .. (tbl[ii].y-tbl[1].y) .. "|" .. tbl[ii].color
        if ii < 4 then
            posandcolor = posandcolor .. ","
        end
    end
    local x, y = findMultiColorInRegionFuzzy(0xFF9751, posandcolor, 100, 80, 280, 450, 380); 
    if gvar.getDevice() == gvar.DEVICE.I4S then
        x, y = findMultiColorInRegionFuzzy( 0xff9751, "26|19|0x67cdb6,80|52|0x321a13,337|37|0x59bbc1", 90, 30, 250, 610, 520)
    end
    if x ~= -1 and y~= -1 then
        return true
    end
    return false
end

local login_points = {
    [1] = { x=260, y=215, color="0x212126" },
    [2] = { x=300, y=250, color="0xFEBE1A" },
    [3] = { x=317, y=268, color="0x913101" },
    [4] = { x=320, y=288, color="0xE72F14" },
}
function qq.isUI_LOGIN()
    local posandcolor = ""
    local tbl = login_points
    for ii=2,4 do
        posandcolor = posandcolor .. (tbl[ii].x-tbl[1].x) .. "|" .. (tbl[ii].y-tbl[1].y) .. "|" .. tbl[ii].color
        if ii < 4 then
            posandcolor = posandcolor .. ","
        end
    end
    local x, y = findMultiColorInRegionFuzzy(0x212126, posandcolor, 100, 230, 200, 405, 300); 
    if gvar.getDevice() == gvar.DEVICE.I4S then
        x, y = findMultiColorInRegionFuzzy( 0x222227, "42|54|0xffbf1b,51|72|0x913101,54|90|0xe72f14", 90, 235, 140, 400, 300)
    end
    if x ~= -1 and y~= -1 then
        return true
    end
    return false
end

function qq.isUI_LOGIN_CN()
    local ret = ocrText(285, 1005, 358, 1045, 1)
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "注册" then
        return true
    end
    return false
end

function qq.isUI_LANG_CN()
    local x, y = findImageInRegionFuzzy("ui_lang_cn.png", 70, 540, 310, 590, 355, 0x0);
    if x ~= -1 and y~= -1 then
        return true
    end
    return false
end

function qq.isUI_LANG_EN()
    local x, y = findImageInRegionFuzzy("ui_lang_cn.png", 70, 537, 215, 605, 275, 0x0);
    if x ~= -1 and y~= -1 then
        return true
    end
    return false
end

function qq.isUI_LOGIN_EN()
    local ret
    if gvar.getDevice() == gvar.DEVICE.I4S then
        ret = ocrText(264, 826, 330, 870, 0)
    else
        ret = ocrText(264, 1005, 330, 1045, 0)
    end
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "Sign" then
        return true
    end
    return false
end

function qq.isUI_CHAT()
    local ret
    if gvar.getDevice() == gvar.DEVICE.I4S then
        ret = ocrText(505, 927, 560, 952, 0)
    else
        ret = ocrText(505, 1104, 560, 1130, 0)
    end
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "More" then
        return true
    end
    return false
end

function qq.isUI_INCORRECT()
    local ret
    if gvar.getDevice() == gvar.DEVICE.I4S then
        ret = ocrText(84, 418, 213, 451, 0)
    else
        ret = ocrText(84, 418, 213, 451, 0)
    end
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "Incorrect" then
        return true
    end
    return false
end

function qq.isUI_VERIFY()
    local ret
    if gvar.getDevice() == gvar.DEVICE.I4S then
        ret = ocrText(113, 598, 212, 628, 0)
    else
        ret = ocrText(113, 598, 212, 628, 0)
    end
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "number" then
        return true
    end
    return false
end

--[[
-- 输入验证码界面
--]]
function qq.isUI_INSERTCODE()
    local ret
    if gvar.getDevice() == gvar.DEVICE.I4S then
        --ret = ocrText(241, 276, 282, 298, 0)
        ret = ocrText(342, 278, 356, 299, 0)
    else
        ret = ocrText(241, 277, 282, 298, 0)
    end
    mSleep(1000)
    toast("识别文字：" .. ret)
    if ret == "F" or ret == "Not" then
        return true
    end
    return false
end

function qq.tapEntryQQ()
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(320, 810)
    else
        tap(320, 990)
    end
end

function qq.tapInsertCode(_code)
    --::inputcode::
    --local input_code = dialogInput("input the code above", "input:", "ok")
    local input_code = _code
    mSleep(1.5*1000)
    input_code = string.trim(input_code)
    if input_code == "" then
        dialog("input code is empty, please input manually.", 0)
        mSleep(1000)
        return
        --goto inputcode
    end
    -- 点击输入框
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(300, 366)
    else
        tap(300, 366)
    end
    mSleep(1000)
    qq.clearInput()
    mSleep(1000)
    inputText(input_code)
    mSleep(2*1000)
    -- 点击完成按钮Done
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(557, 86)
    else
        tap(557, 86)
    end
    mSleep(4*1000)
end

function qq.clearInput()
    for ii=1,30 do
        inputText("\b")
    end
end

function qq.doLogin(acct, passwd)
    tap(320, 367)
    mSleep(1*1000)
    qq.clearInput()
    mSleep(1*1000)
    inputText(acct)
    mSleep(2*1000)
    tap(320, 440)
    mSleep(1*1000)
    qq.clearInput()
    mSleep(1*1000)
    inputText(string.rtrim(passwd))
    mSleep(2*1000)
    -- 键盘挡住了登陆按钮，需要点击空白区域，隐藏键盘
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(320, 80)
        mSleep(1.5*1000)
    end
    tap(310, 565)
end

function qq.getCurrentUI()
    if qq.isUI_WELCOME_1() then
        return WHICH_UI.WELCOME_1
    elseif qq.isUI_WELCOME_2() then
        return WHICH_UI.WELCOME_2
    elseif qq.isUI_LOGIN() then
        return WHICH_UI.LOGIN
    --elseif qq.isUI_LANG_CN() then
    --    return WHICH_UI.LANG_CN
    elseif qq.isUI_LANG_EN() then
        return WHICH_UI.LANG_EN
    --elseif qq.isUI_LOGIN_EN() then
    --    return WHICH_UI.LOGIN_EN
    elseif qq.isUI_INSERTCODE() then
        return WHICH_UI.INSERTCODE
    elseif qq.isUI_CHAT() then
        return WHICH_UI.CHAT
    elseif qq.isUI_INCORRECT() then
        return WHICH_UI.INCORRECT
    elseif qq.isUI_VERIFY() then
        return WHICH_UI.VERIFY
    end
    return WHICH_UI.NOT_FOUND
end

return qq
