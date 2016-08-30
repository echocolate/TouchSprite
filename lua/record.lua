local record = {}

--record.seq = 0
--record.name = ""
--record.acct = ""
--record.passwd = ""

function record.new(seq, name, acct, passwd)
    local _rec = {}
    _rec.seq = seq
    _rec.name = name
    _rec.acct = acct
    _rec.passwd = passwd
    return _rec
end

return record
