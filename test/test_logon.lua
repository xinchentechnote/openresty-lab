package.path = "./lua/?.lua;./third_party/luaunit/?.lua;" .. package.path

local luaunit = require("luaunit")
local Logon = require("sse_bin.logon")

TestLogon = {}

function TestLogon:testEncodeDecode()
    local logon1 = Logon:new()
    logon1.senderCompId = "SENDER"
    logon1.targetCompId = "TARGET"
    logon1.heartBtInt = 30
    logon1.prtclVersion = "1.00"
    logon1.tradeDate = 20251204
    logon1.qsize = 100

    local bin = logon1:encode()
    luaunit.assertEquals(#bin, 32+32+2+8+4+4)

    local logon2 = Logon:new()
    logon2:decode(bin)
    luaunit.assertTrue(logon1:equals(logon2))
end

os.exit(luaunit.LuaUnit.run())
