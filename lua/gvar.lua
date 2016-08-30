local gvar = {}

local DEVICE = {
    I5C = "5C",
    I4S = "4S",
}
gvar.DEVICE = DEVICE

local mdevice = DEVICE.I5C

function gvar.setDevice(which)
    if which == DEVICE.I5C then
        mdevice = which
    elseif which == DEVICE.I4S then
        mdevice = which
    end
end

function gvar.getDevice()
    return mdevice
end

return gvar
