pp = require("pprint")
-- utils

local function jump_resolver(from_address, to_address)
    local relative_jump = nil
    if from_address > to_address then
        relative_jump = -(from_address - to_address)
    else
        relative_jump = to_address - from_address
    end
    if relative_jump < -128 or relative_jump > 127 then
        print("Jump at " .. to_address .. " is out of range")
        os.exit()
    end

    return tonumber(relative_jump) -- math.floor(relative_jump) -- why did i floor before?
end

local function signed_to_unsigned(signed_value)
    if signed_value < 0 then
        return signed_value + 256
    else
        return signed_value
    end
end

local function unsigned_to_signed(hex_value) -- mmmm
    if hex_value >= 128 then
        return hex_value - 256
    else
        return hex_value
    end
end


local opcodes = {
    DAT = 0x00,
    INC = 0x01,
    POP = 0x02,
    SWP = 0x03,
    ROT = 0x04,
    DUP = 0x05,
    OVR = 0x06,
    EQU = 0x10,
    NEQ = 0x11,
    GTH = 0x12,
    LTH = 0x13,
    ADD = 0x20,
    SUB = 0x21,
    MUL = 0x22,
    DIV = 0x23,
    AND = 0x30,
    OOR = 0x31,
    XOR = 0x32,
    END = 0X40,
    JMP = 0X41,
    JIT = 0X42,
}


local source, source_error = io.open(arg[1], 'r')
local listing = ""
if(source and io.type(source) == "file") then
	listing = source:read( "*a" )
    source:close()
else
	print("Failed to open \"" .. arg[1] .. "\"")
    print(source_error)
    os.exit()
end

local destination_str = arg[2] or "output.rom"
local destination, destination_error = io.open(destination_str, "wb")
if(not destination) then
	print("Failed to open \"" .. destination_str .. "\"")
    print(destination_error)
    os.exit()
end

local bytecode = {}
local address = 1
local labels = {}

for token in string.gmatch(listing, "[^%s]+") do
    local current = nil
    if string.sub(token, -1) == ':' then -- label definition
        local label = string.sub(token, 1, #token - 1)
        if labels[label] then
            local relative_jump = jump_resolver(labels[label], address)
            bytecode[labels[label]] = signed_to_unsigned(relative_jump) - 1
            labels[label] = nil
        else
            labels[label] = address
        end
    elseif string.sub(token, 1, 1) == ':' then
        local label = string.sub(token, 2)
        if labels[label]  then
            local relative_jump = jump_resolver(address, labels[label])
            current = signed_to_unsigned(relative_jump) - 1 -- JUMP BEHIND
            labels[label] = nil
        else
            labels[label] = address
            --current = unsigned_to_signed(address) -- this one should not be here?
        end
    elseif opcodes[token] then
        current = opcodes[token]
    elseif tonumber(token) then
        current = tonumber(token)
    else
        print('Unrecognized token "' .. token .. '"')
        destination:close()
        os.exit(1)
    end
    if current then
        address = address + 1
        table.insert(bytecode, current)
    end
end

print("Bytecode generated:")
pp.pprint(bytecode)

destination:write(string.char(table.unpack(bytecode)))
destination:close()
