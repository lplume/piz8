local socket = require("socket")

local states = {
    WAIT = 0,
    READY = 1,
    ERROR = 2,
    END = 3
}

local piz8 = {
    stack = {},
    bytecode = {},
    pc = 1,
    state = states.WAIT
}

local function unsigned_to_signed(hex_value)
    if hex_value >= 128 then
        return hex_value - 256
    else
        return hex_value
    end
end

local function wrap_around(value)
    if value > 0xff then
        value = value - 256
    end
    return math.floor(value)
end

local opcodes = {
    [0x00] = function() -- DAT VALUE: PUSH OP INTO THE STACK
        local value = piz8.bytecode[piz8.pc + 1]
        table.insert(piz8.stack, wrap_around(value))
        piz8.pc_inc(2)
    end,
    [0x01] = function() -- INC: INCREMENT BY 1 THE ELEMENT ON THE TOP OF THE STACK
        piz8.stack[#piz8.stack] = wrap_around(piz8.stack[#piz8.stack] + 1)
        piz8.pc_inc(1)
    end,
    [0x02] = function() -- POP: POP THE TOP ELEMENT FROM THE TOP OF THE STACK
        table.remove(piz8.stack)
        piz8.pc_inc(1)
    end,
    [0x03] = function() -- SWP: SWAP TWO ELEMENTS ON THE TOP OF THE STACK
        local top = piz8.stack[#piz8.stack]
        local next = piz8.stack[#piz8.stack - 1]
        piz8.stack[#piz8.stack] = next
        piz8.stack[#piz8.stack - 1] = top
        piz8.pc_inc(1)
    end,
    [0x04] = function() -- ROT: ROTATER THREE VALUES AT THE TOP OF THE STACK, TO THE LEFT, WRAPPING AROUND.
        local first = piz8.stack[#piz8.stack]
        local third = piz8.stack[#piz8.stack - 2]
        piz8.stack[#piz8.stack] = third
        piz8.stack[#piz8.stack - 2] = first
        piz8.pc_inc(1)
    end,
    [0x05] = function() -- DUP: DUPLICATE THE TOP ELEMENT AND PUT IT ON THE TOP OF THE STACK
        local top = piz8.stack[#piz8.stack]
        table.insert(piz8.stack, top)
        piz8.pc_inc(1)
    end,
    [0x06] = function() -- OVR: DUPLICATE THE SECOND ELEMENT IN THE STACK AND PUT IT ON THE TOP OF THE STACK
        local value = piz8.stack[#piz8.stack - 1]
        table.insert(piz8.stack, value)
        piz8.pc_inc(1)
    end,
    [0x10] = function() -- EQU: PUSH 01 ON THE TOP OF THE STACK IF THE TWO VALUES ON THE TOP OF THE STACK ARE EQUAL, 00 OTHERWISE
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = (top == next) and 1 or 0
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x11] = function() -- NEQ: PUSH 01 ON THE TOP OF THE STACK IF THE TWO VALUES ON THE TOP OF THE STACK ARE NOT EQUAL, 00 OTHERWISE
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = (top ~= next) and 1 or 0
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x12] = function() -- GTH: PUSH 01 TO THE STACK IF THE SECOND VALUE AT THE TOP OF THE STACK IS GREATER THAN THE VALUE AT THE TOP OF THE STACK, 00 OTHERWISE.
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = (next > top) and 1 or 0
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x13] = function() -- LTH: PUSH 01 TO THE STACK IF THE SECOND VALUE AT THE TOP OF THE STACK IS LESS THAN THE VALUE AT THE TOP OF THE STACK, 00 OTHERWISE.
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = (next < top) and 1 or 0
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x20] = function() -- ADD: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next + top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x21] = function() -- SUB: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next - top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x22] = function() -- MUL: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next * top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x23] = function() -- DIV: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next / top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x30] = function() -- AND: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next & top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x31] = function() -- OOR: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next | top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x32] = function() -- XOR: XXX
        local top, next = table.remove(piz8.stack), table.remove(piz8.stack)
        local result = wrap_around(next ~ top)
        table.insert(piz8.stack, result)
        piz8.pc_inc(1)
    end,
    [0x40] = function() -- END: XXX
        piz8.state = states.END
    end,
    [0x41] = function() -- JMP: XXX
        local value = table.remove(piz8.stack)
        piz8.pc_inc(value)
    end,
    [0x42] = function() -- JIT: XXX
        local jump, cond = table.remove(piz8.stack), table.remove(piz8.stack)
        jump = unsigned_to_signed(jump)
        if cond ~= 0 then
            piz8.pc_inc(jump)
        else
            piz8.pc_inc(1)
        end
    end,
    [0x99] = function() -- XXX: XXX
        piz8.pc_inc(1)
    end
}

piz8.pc_inc = function (inc)
    piz8.pc = piz8.pc + inc

    if piz8.pc > #piz8.bytecode then
        piz8.state = states.WAIT
    end
end

piz8.load = function(bytecode)
    local pc = 1

    while pc <= #bytecode do
        local ins = string.byte(bytecode, pc)
        table.insert(piz8.bytecode, ins)
        pc = pc + 1
    end

    piz8.state = states.READY
end

local function is_jump(ins)
    return ins == 0x41 or  ins == 0x42
end

piz8.eval = function ()
    while piz8.state ~= states.END do
        if piz8.state == states.READY then
            local ins = piz8.bytecode[piz8.pc]
            local next_jump = is_jump(piz8.bytecode[piz8.pc + 1])
            local opcode = opcodes[ins]

            if next_jump then
                table.insert(piz8.stack, ins)
                piz8.pc_inc(1)
            elseif opcode then
                opcode()
            else
                piz8.state = states.ERROR
            end
        else
            piz8.state = states.END
            socket.sleep(1)
            print("Ending...")
        end
    end
end

return piz8