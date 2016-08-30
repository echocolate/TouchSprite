-- Quite minimal for now, I know ;)

local ltn12 = require "ltn12"
local H = (require "socket.http").request
local mp = (require "multipart-post").gen_request

--local J
--do -- Find a JSON parser
--    local ok, json = pcall(require, "cjson")
--    if not ok then ok, json = pcall(require, "json") end
--    J = json.decode
--    assert(ok and J, "no JSON parser found :(")
--end
--

local lunajson = require"lunajson"

--local post_file = "/Users/chockly/Downloads/code1.png"
local post_file = "1.png"
local file, err = io.open(post_file, "rb")
if not file then
    print("open file failed:",err)
    os.exit(1)
end
local post_data = file:read("*a")
local data_len = file:seek("end")
io.close(file)

print("filesize:", data_len)

local r = {}
local rq = mp{
    image = {name = "1.png", filename="1.png", data = post_data},
    username = "ffddr2",
    password = "123465b",
    typeid = "3040",
    timeout = "60",
    softid = "66040",
    softkey = "4443cb6dbb9f4a8d882d57c5d47f45b3",
    --image = post_data,
}
--rq.url = "http://httpbin.org/post"
rq.url = "http://api.ruokuai.com/create.json"
rq.sink = ltn12.sink.table(r)
local b, c, h = H(rq)
print("========================b c h==================")
print(b, c, h)
print("========================b c h==================")

local ret1 = lunajson.decode(r[1])
if not ret1.Error then
    print("ret1 ok:", ret1.Result, ret1.Id)
else
    print("ret1 err:", ret1.Error, ret1.Error_Code)
end

--r = J(table.concat(r))

--T:eq( r.files, {myfile = "some data"} )
--T:eq( r.form, {foo = "bar"} )

--T:done()

