
local Logon = {}
Logon.__index = Logon

function Logon:new()
    local self = setmetatable({}, Logon)
    self.senderCompId = ""
    self.targetCompId = ""
    self.heartBtInt = 0
    self.prtclVersion = ""
    self.tradeDate = 0
    self.qsize = 0
    return self
end

local function writeFixedString(str, len)
    str = str or ""
    if #str > len then
        str = str:sub(1, len)
    end
    return str .. string.rep("\0", len - #str)
end

local function readFixedString(buf, pos, len)
    local str = string.sub(buf, pos, pos + len - 1)
    return (str:match("^(.-)%z*$") or "")
end

local function writeShort(n)
    return string.char(math.floor(n / 256), n % 256)
end

local function readShort(buf, pos)
    local b1,b2 = buf:byte(pos,pos+1)
    return b1*256 + b2
end

local function writeInt(n)
    return string.char(
        math.floor(n / 16777216) % 256,
        math.floor(n / 65536) % 256,
        math.floor(n / 256) % 256,
        n % 256
    )
end

local function readInt(buf, pos)
    local b1,b2,b3,b4 = buf:byte(pos,pos+3)
    return b1*16777216 + b2*65536 + b3*256 + b4
end

function Logon:encode()
    local buf = ""
    buf = buf .. writeFixedString(self.senderCompId, 32)
    buf = buf .. writeFixedString(self.targetCompId, 32)
    buf = buf .. writeShort(self.heartBtInt)
    buf = buf .. writeFixedString(self.prtclVersion, 8)
    buf = buf .. writeInt(self.tradeDate)
    buf = buf .. writeInt(self.qsize)
    return buf
end

function Logon:decode(bin)
    local pos = 1
    self.senderCompId = readFixedString(bin, pos, 32); pos = pos + 32
    self.targetCompId = readFixedString(bin, pos, 32); pos = pos + 32
    self.heartBtInt = readShort(bin, pos); pos = pos + 2
    self.prtclVersion = readFixedString(bin, pos, 8); pos = pos + 8
    self.tradeDate = readInt(bin, pos); pos = pos + 4
    self.qsize = readInt(bin, pos); pos = pos + 4
end

function Logon:equals(other)
    local function trim(s) return (s or ""):match("^(.-)%z*$") end
    return trim(self.senderCompId) == trim(other.senderCompId)
       and trim(self.targetCompId) == trim(other.targetCompId)
       and self.heartBtInt == other.heartBtInt
       and trim(self.prtclVersion) == trim(other.prtclVersion)
       and self.tradeDate == other.tradeDate
       and self.qsize == other.qsize
end

function Logon:__tostring()
    return string.format(
        "Logon [senderCompId=%s, targetCompId=%s, heartBtInt=%d, prtclVersion=%s, tradeDate=%d, qsize=%d]",
        self.senderCompId, self.targetCompId, self.heartBtInt, self.prtclVersion, self.tradeDate, self.qsize
    )
end

return Logon
