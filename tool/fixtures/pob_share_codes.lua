-- Используем обработчики вкладки импорта и экспорта закреплённого PoB.
-- Фоновый wrapper MCP оставляет Deflate и Inflate заглушками.
local ffi = require("ffi")
local json = require("dkjson")
local source = assert(json.decode(io.read("*a")))
dofile(POB_MCP_PACKAGE_DIR .. "/lua/headless_bootstrap.lua")

ffi.cdef[[
unsigned long compressBound(unsigned long sourceLen);
int compress(unsigned char *dest, unsigned long *destLen, const char *source, unsigned long sourceLen);
int uncompress(unsigned char *dest, unsigned long *destLen, const char *source, unsigned long sourceLen);
]]
local library = ffi.os == "Windows" and POB_MCP_RUNTIME_DIR .. "/zlib1.dll"
    or ffi.os == "OSX" and "/usr/lib/libz.1.dylib" or "libz.so.1"
local zlib = ffi.load(library)

local function convert(operation, data, capacity)
    local output = ffi.new("unsigned char[?]", capacity)
    local size = ffi.new("unsigned long[1]", capacity)
    assert(operation(output, size, data, #data) == 0, "Ошибка zlib")
    return ffi.string(output, tonumber(size[0]))
end

function Deflate(data)
    return convert(zlib.compress, data, tonumber(zlib.compressBound(#data)))
end

function Inflate(data)
    return convert(zlib.uncompress, data, 16 * 1024 * 1024)
end

local results = {}
for index, fixture in ipairs(source) do
    loadBuildFromXML(fixture.xml, "Fixture")
    local tab = assert(build.importTab)
    if fixture.code then
        tab.controls.importCodeIn:SetText(fixture.code, true)
        assert(tab.importCodeValid and tab.importCodeXML, "PoB отклонил код")
        tab.controls.importCodeMode.selIndex = 2
        tab.controls.importCodeGo.onClick()
        runCallback("OnFrame")
        results[index] = assert(build:SaveDB("Fixture"))
    else
        tab.controls.generateCode.onClick()
        results[index] = tab.controls.generateCodeOut.buf
    end
end
io.write(json.encode(results))
