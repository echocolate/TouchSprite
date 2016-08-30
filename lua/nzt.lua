local nzt = {}

local gvar = require "gvar"

nzt.bid = "NZT"

local rect_newMachine = {
    p1 = { x = 396, y = 800 },
    p2 = { x = 580, y = 845 },
}

local rect_record = {
    p1 = { x = 45, y = 935 },
    p2 = { x = 240, y = 985 },
}

local btn_newMachine = { x = 450, y = 820 }
local btn_newMachine_4s = { x = 483, y = 743 }
local btn_record = { x = 120, y = 950 }
local btn_record_4s = { x = 140, y = 860 }
local btn_back = { x = 40, y = 86 }
local btn_back_4s = { x = 45, y = 80 }
local sel_find_region = {
    p1 = { x = 564, y = 120 },
    p2 = { x = 630, y = 1136 },
}
local sel_find_region_4s = {
    p1 = { x = 564, y = 120 },
    p2 = { x = 630, y = 960 },
}

function nzt.tapNewMachine()
    local tbl = btn_newMachine
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tbl = btn_newMachine_4s
    end
    tap(tbl.x, tbl.y)
end

function nzt.tapRecord()
    local tbl = btn_record
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tbl = btn_record_4s
    end
    tap(tbl.x, tbl.y)
end

function nzt.tapRecordBack()
    local tbl = btn_back
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tbl = btn_back_4s
    end
    tap(tbl.x, tbl.y)
end

-- 每次向上滑动5条记录
function nzt.slideUp()
    touchDown(1, 320, 960);
    mSleep(30);
    step=10
    y=1130
    while true do
        y=y-step
        if y<=530 then 
            touchMove(1, 320, y);
            break 
        end
        touchMove(1, 320, y);
        mSleep(30);
    end
    touchUp(1, 320, y);
    mSleep(1*1000);
end

function nzt.showRename(x, y)
    ctouchmove({x=480, y=y}, {x=170, y=y})
end

function nzt.tapRename(x, y)
    local _x = x
    if gvar.getDevice() == gvar.DEVICE.I4S then
        _x = 320
    end
    tap(_x, y)
end

function nzt.tapInput()
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(230, 290)
    else
        tap(230, 380)
    end
end

function nzt.clearInput()
    for ii=1,30 do
        --inputText("\b")
        keyDown("DeleteOrBackspace")
        mSleep(30)
        keyUp("DeleteOrBackspace")
    end
end

--[[
-- 假设名字只有数字、字母和连接符"-"
--]]
function nzt.inputName(_name)
    charInput(_name)
end

function nzt.tapInputConfirm()
    if gvar.getDevice() == gvar.DEVICE.I4S then
        tap(460, 380)
    else
        tap(460, 485)
    end
end

--[[
-- 如果找到，返回图片左上角坐标; 否则返回 -1, -1
--]]
function nzt.findSel()
    local pic = "ui_nzt_sel.png"
    local pregion = sel_find_region
    if gvar.getDevice() == gvar.DEVICE.I4S then
        pregion = sel_find_region_4s
        pic = "ui_nzt_sel_4s.png"
    end
    local x, y = findImageInRegionFuzzy(pic, 70, 
                                        pregion.p1.x, 
                                        pregion.p1.y, 
                                        pregion.p2.x, 
                                        pregion.p2.y, 
                                        0x0);
    return x, y
end

--[[
-- 假设向上滑动loop_count次，一定能滑到最低端
--]]
function nzt.findSelLoop(loop_count)
    local _count = loop_count
    while _count > 0 do
        local x, y = nzt.findSel()
        if x ~= -1 and y ~= -1 then
            return x, y
        end
        nzt.slideUp()
        _count = _count - 1
    end
    return -1, -1
end

return nzt
