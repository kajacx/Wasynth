local module = {}

local bit = require("bit")
-- local ffi = require("ffi")

local function identity(x) return x end

local u32 = identity -- ffi.typeof("uint32_t")
local u64 = identity -- ffi.typeof("uint64_t")
local i64 = identity -- ffi.typeof("int64_t")

local math_ceil = math.ceil
local math_floor = math.floor
local to_number = tonumber
-- local to_signed = bit.tobit

local i32_to_u32 = bit.i32_to_u32
local u32_to_i32 = bit.u32_to_i32
local i64_to_u64 = bit.i64_to_u64
local u64_to_i64 = bit.u64_to_i64

local extract_bytes = bit.extract_bytes
local extract_bytes_signed = bit.extract_bytes_signed
local set_bytes = bit.set_bytes
local set_bytes_signed = bit.set_bytes_signed

local f32_from_bits = bit.f32_from_bits
local f32_to_bits = bit.f32_to_bits
local f64_from_bits = bit.f64_from_bits
local f64_to_bits = bit.f64_to_bits

-- local NUM_ZERO = i64(0)
-- local NUM_ONE = i64(1)

local function truncate_f64(num)
	if num >= 0 then
		return (math_floor(num))
	else
		return (math_ceil(num))
	end
end

do
	local add = {}
	local sub = {}
	local mul = {}
	local div = {}
	local rem = {}
	local neg = {}
	local min = {}
	local max = {}
	local copysign = {}
	local nearest = {}

	local math_abs = math.abs
	local math_min = math.min
	local math_max = math.max

	-- local RE_INSTANCE = ffi.new([[union {
	-- 	double f64;
	-- 	struct { int32_t a32, b32; };
	-- }]])

	local function round(num)
		if num >= 0 then
			return (math_floor(num + 0.5))
		else
			return (math_ceil(num - 0.5))
		end
	end

	function add.i32(lhs, rhs)
		return (lhs + rhs)
	end

	function sub.i32(lhs, rhs)
		return (lhs - rhs)
	end

	function mul.i32(lhs, rhs)
		return lhs * rhs
	end

	function div.i32(lhs, rhs)
		assert(rhs ~= 0, "division by zero")

		return lhs / rhs
	end

	function div.u32(lhs, rhs)
		assert(rhs ~= 0, "division by zero")

		return math_floor(lhs / rhs)
	end

	function rem.u32(lhs, rhs)
		assert(rhs ~= 0, "division by zero")

		return (lhs % rhs)
	end

	function div.u64(lhs, rhs)
		assert(rhs ~= 0, "division by zero")

		-- return (i64(u64(lhs) / u64(rhs)))
		return lhs / rhs
	end

	function rem.u64(lhs, rhs)
		assert(rhs ~= 0, "division by zero")

		-- return (i64(u64(lhs) % u64(rhs)))
		return lhs % rhs
	end

	function neg.f32(num)
		return -num
	end

	function min.f32(lhs, rhs)
		if lhs ~= lhs then
			return lhs
		elseif rhs ~= rhs then
			return rhs
		else
			return math_min(lhs, rhs)
		end
	end

	function max.f32(lhs, rhs)
		if lhs ~= lhs then
			return lhs
		elseif rhs ~= rhs then
			return rhs
		else
			return math_max(lhs, rhs)
		end
	end

	function copysign.f32(lhs, rhs)
		if rhs >= 0 then
			return math_abs(lhs)
		else
			return -math_abs(lhs)
		end
	end

	function nearest.f32(num)
		local result = round(num)

		if (math_abs(num) + 0.5) % 2 == 1 then
			if result >= 0 then
				result = result - 1
			else
				result = result + 1
			end
		end

		return result
	end

	neg.f64 = neg.f32
	min.f64 = min.f32
	max.f64 = max.f32
	copysign.f64 = copysign.f32
	nearest.f64 = nearest.f32

	module.add = add
	module.sub = sub
	module.mul = mul
	module.div = div
	module.rem = rem
	module.min = min
	module.max = max
	module.neg = neg
	module.copysign = copysign
	module.nearest = nearest
end

do
	local clz = {}
	local ctz = {}
	local popcnt = {}

	local bit_and = bit.band
	local bit_lshift = bit.lshift
	local bit_rshift = bit.rshift

	function clz.i32(num)
		if num == 0 then
			return 32
		end

		local count = 0

		if bit_rshift(num, 16) == 0 then
			num = bit_lshift(num, 16)
			count = count + 16
		end

		if bit_rshift(num, 24) == 0 then
			num = bit_lshift(num, 8)
			count = count + 8
		end

		if bit_rshift(num, 28) == 0 then
			num = bit_lshift(num, 4)
			count = count + 4
		end

		if bit_rshift(num, 30) == 0 then
			num = bit_lshift(num, 2)
			count = count + 2
		end

		if bit_rshift(num, 31) == 0 then
			count = count + 1
		end

		return count
	end

	function ctz.i32(num)
		if num == 0 then
			return 32
		end

		local count = 0

		if bit_lshift(num, 16) == 0 then
			num = bit_rshift(num, 16)
			count = count + 16
		end

		if bit_lshift(num, 24) == 0 then
			num = bit_rshift(num, 8)
			count = count + 8
		end

		if bit_lshift(num, 28) == 0 then
			num = bit_rshift(num, 4)
			count = count + 4
		end

		if bit_lshift(num, 30) == 0 then
			num = bit_rshift(num, 2)
			count = count + 2
		end

		if bit_lshift(num, 31) == 0 then
			count = count + 1
		end

		return count
	end

	function popcnt.i32(num)
		local count = 0

		while num ~= 0 do
			num = bit_and(num, num - 1)
			count = count + 1
		end

		return count
	end

	function clz.i64(num)
		if num == 0 then
			return 64 * NUM_ONE
		end

		local count = NUM_ZERO

		if bit_rshift(num, 32) == NUM_ZERO then
			num = bit_lshift(num, 32)
			count = count + 32
		end

		if bit_rshift(num, 48) == NUM_ZERO then
			num = bit_lshift(num, 16)
			count = count + 16
		end

		if bit_rshift(num, 56) == NUM_ZERO then
			num = bit_lshift(num, 8)
			count = count + 8
		end

		if bit_rshift(num, 60) == NUM_ZERO then
			num = bit_lshift(num, 4)
			count = count + 4
		end

		if bit_rshift(num, 62) == NUM_ZERO then
			num = bit_lshift(num, 2)
			count = count + 2
		end

		if bit_rshift(num, 63) == NUM_ZERO then
			count = count + NUM_ONE
		end

		return count
	end

	function ctz.i64(num)
		if num == 0 then
			return 64 * NUM_ONE
		end

		local count = NUM_ZERO

		if bit_lshift(num, 32) == NUM_ZERO then
			num = bit_rshift(num, 32)
			count = count + 32
		end

		if bit_lshift(num, 48) == NUM_ZERO then
			num = bit_rshift(num, 16)
			count = count + 16
		end

		if bit_lshift(num, 56) == NUM_ZERO then
			num = bit_rshift(num, 8)
			count = count + 8
		end

		if bit_lshift(num, 60) == NUM_ZERO then
			num = bit_rshift(num, 4)
			count = count + 4
		end

		if bit_lshift(num, 62) == NUM_ZERO then
			num = bit_rshift(num, 2)
			count = count + 2
		end

		if bit_lshift(num, 63) == NUM_ZERO then
			count = count + NUM_ONE
		end

		return count
	end

	function popcnt.i64(num)
		local count = NUM_ZERO

		while num ~= NUM_ZERO do
			num = bit_and(num, num - NUM_ONE)
			count = count + NUM_ONE
		end

		return count
	end

	module.clz = clz
	module.ctz = ctz
	module.popcnt = popcnt
end

do
	local le = {}
	local lt = {}
	local ge = {}
	local gt = {}

	function le.u32(lhs, rhs)
		return u32(lhs) <= u32(rhs)
	end

	function lt.u32(lhs, rhs)
		return u32(lhs) < u32(rhs)
	end

	function ge.u32(lhs, rhs)
		return u32(lhs) >= u32(rhs)
	end

	function gt.u32(lhs, rhs)
		return u32(lhs) > u32(rhs)
	end

	function le.u64(lhs, rhs)
		return u64(lhs) <= u64(rhs)
	end

	function lt.u64(lhs, rhs)
		return u64(lhs) < u64(rhs)
	end

	function ge.u64(lhs, rhs)
		return u64(lhs) >= u64(rhs)
	end

	function gt.u64(lhs, rhs)
		return u64(lhs) > u64(rhs)
	end

	module.le = le
	module.lt = lt
	module.ge = ge
	module.gt = gt
end

do
	local wrap = {}
	local truncate = {}
	local saturate = {}
	local extend = {}
	local convert = {}
	local promote = {}
	local demote = {}
	local reinterpret = {}

	local bit_and = bit.band

	local NUM_MIN_I64 = -2 ^ 63
	local NUM_MAX_I64 = 2 ^ 63 - 1 -- TODO: "- 1" will be ignored because of floating point loss?
	local NUM_MAX_U64 = 2 ^ 64 - 1

	-- This would surely be an issue in a multi-thread environment...
	-- ... thankfully this isn't one.
	-- local RE_INSTANCE = ffi.new([[union {
	-- 	int32_t i32;
	-- 	int64_t i64;
	-- 	float f32;
	-- 	double f64;
	-- }]])

	-- function wrap.i32_i64(num)
	-- 	RE_INSTANCE.i64 = num

	-- 	return RE_INSTANCE.i32
	-- end

	truncate.i32_f32 = truncate_f64
	truncate.i32_f64 = truncate_f64

	function truncate.u32_f32(num)
		return (to_signed(truncate_f64(num)))
	end

	truncate.u32_f64 = truncate.u32_f32

	truncate.i64_f32 = i64
	truncate.i64_f64 = i64
	truncate.u64_f32 = i64

	function truncate.u64_f64(num)
		return (i64(u64(num)))
	end

	truncate.f32 = truncate_f64
	truncate.f64 = truncate_f64

	function saturate.i32_f32(num)
		if num <= -0x80000000 then
			return -0x80000000
		elseif num >= 0x7FFFFFFF then
			return 0x7FFFFFFF
		else
			return to_signed(truncate_f64(num))
		end
	end

	saturate.i32_f64 = saturate.i32_f32

	function saturate.u32_f32(num)
		if num <= 0 then
			return 0
		elseif num >= 0xFFFFFFFF then
			return -1
		else
			return to_signed(truncate_f64(num))
		end
	end

	saturate.u32_f64 = saturate.u32_f32

	function saturate.i64_f32(num)
		if num >= 2 ^ 63 - 1 then
			return NUM_MAX_I64
		elseif num <= -2 ^ 63 then
			return NUM_MIN_I64
		elseif num ~= num then
			return NUM_ZERO
		else
			return i64(num)
		end
	end

	saturate.i64_f64 = saturate.i64_f32

	function saturate.u64_f32(num)
		if num >= 2 ^ 64 then
			return NUM_MAX_U64
		elseif num <= 0 or num ~= num then
			return NUM_ZERO
		else
			return i64(u64(num))
		end
	end

	saturate.u64_f64 = saturate.u64_f32

	function extend.i32_n8(num)
		num = bit_and(num, 0xFF)

		if num >= 0x80 then
			return num - 0x100
		else
			return num
		end
	end

	function extend.i32_n16(num)
		num = bit_and(num, 0xFFFF)

		if num >= 0x8000 then
			return num - 0x10000
		else
			return num
		end
	end

	function extend.i64_n8(num)
		num = bit_and(num, 0xFF * NUM_ONE)

		if num >= 0x80 then
			return num - 0x100
		else
			return num
		end
	end

	function extend.i64_n16(num)
		num = bit_and(num, 0xFFFF * NUM_ONE)

		if num >= 0x8000 then
			return num - 0x10000
		else
			return num
		end
	end

	function extend.i64_n32(num)
		num = bit_and(num, 0xFFFFFFFF * NUM_ONE)

		if num >= 0x80000000 then
			return num - 0x100000000
		else
			return num
		end
	end

	extend.i64_i32 = i64

	function extend.i64_u32(num)
		-- RE_INSTANCE.i64 = NUM_ZERO
		-- RE_INSTANCE.i32 = num

		-- return RE_INSTANCE.i64
		return num
	end

	function convert.f32_i32(num)
		return num
	end

	function convert.f32_u32(num)
		return (to_number(u32(num)))
	end

	function convert.f32_u64(num)
		return (to_number(u64(num)))
	end

	convert.f64_i32 = convert.f32_i32
	convert.f64_u32 = convert.f32_u32
	convert.f64_u64 = convert.f32_u64

	function demote.f32_f64(num)
		return num
	end

	promote.f64_f32 = demote.f32_f64

	function reinterpret.i32_f32(num)
		-- RE_INSTANCE.f32 = num
		-- return RE_INSTANCE.i32

		return f32_to_bits(num)
	end

	function reinterpret.i64_f64(num)
		-- RE_INSTANCE.f64 = num
		-- return RE_INSTANCE.i64

		return f64_to_bits(num)
	end

	function reinterpret.f32_i32(num)
		-- RE_INSTANCE.i32 = num
		-- return RE_INSTANCE.f32

		return f32_from_bits(num)
	end

	function reinterpret.f64_i64(num)
		-- RE_INSTANCE.i64 = num
		-- return RE_INSTANCE.f64

		return f64_from_bits(num)
	end

	module.wrap = wrap
	module.truncate = truncate
	module.saturate = saturate
	module.extend = extend
	module.convert = convert
	module.demote = demote
	module.promote = promote
	module.reinterpret = reinterpret
end

do
	local load = {}
	local store = {}
	local allocator = {}

	-- ffi.cdef([[
	-- union Any {
	-- 	int8_t i8;
	-- 	int16_t i16;
	-- 	int32_t i32;
	-- 	int64_t i64;

	-- 	uint8_t u8;
	-- 	uint16_t u16;
	-- 	uint32_t u32;
	-- 	uint64_t u64;

	-- 	float f32;
	-- 	double f64;
	-- };

	-- struct Memory {
	-- 	uint32_t min;
	-- 	uint32_t max;
	-- 	union Any *data;
	-- };

	-- void *calloc(size_t num, size_t size);
	-- void *realloc(void *ptr, size_t size);
	-- void free(void *ptr);
	-- ]])

	-- local alias_t = ffi.typeof("uint8_t *")
	-- local any_t = ffi.typeof("union Any *")
	-- local cast = ffi.cast

	local function by_offset(pointer, offset)
		-- local aliased = cast(alias_t, pointer)

		-- return cast(any_t, aliased + offset)
	end


	-- local function load_byte(memory, addr)
	-- 	local offset = addr % 4
	-- 	return bit32.rshift(memory.data[(addr - offset) / 4] or 0, 8 * offset)
	-- end

	-- local function store_byte(memory, addr, value)
	-- 	local offset = addr % 4
	-- 	local base = (addr - offset) / 4
	-- 	local old = clear_byte(memory.data[base] or 0, offset)
	-- 	memory.data[base] = bit32.bor(old, bit32.lshift(value, 8 * offset))
	-- end

	function load.i32_i8(memory, addr)
		local offset = addr % 4
		return extract_bytes_signed(memory[(addr - offset) / 4], offset, 1)
	end

	function load.i32_u8(memory, addr)
		local offset = addr % 4
		return extract_bytes(memory[(addr - offset) / 4], offset, 1)
	end

	function load.i32_i16(memory, addr)
		if (addr % 2 ~= 0) then
			error("Unaligned read in load.i32_i16: " .. addr)
		end
		local offset = addr % 4
		return extract_bytes_signed(memory[(addr - offset) / 4], offset, 2)
	end

	function load.i32_u16(memory, addr)
		if (addr % 2 ~= 0) then
			error("Unaligned read in load.i32_u16: " .. addr)
		end
		local offset = addr % 4
		return extract_bytes(memory[(addr - offset) / 4], offset, 2)
	end

	function load.i32(memory, addr)
		if (addr % 4 ~= 0) then
			error("Unaligned read in load.i32: " .. addr)
		end
		return u32_to_i32(memory[addr / 4])
	end

	load.i64_i8 = load.i32_i8
	load.i64_u8 = load.i32_u8
	load.i64_i16 = load.i32_i16
	load.i64_u16 = load.i32_u16

	load.i64_i32 = load.i32

	function load.i64_u32(memory, addr)
		if (addr % 4 ~= 0) then
			error("Unaligned read in load.i64_u32: " .. addr)
		end
		return memory[addr / 4]
	end

	function load.i64(memory, addr)
		if (addr % 4 ~= 0) then
			error("Unaligned read in load.i64: " .. addr)
		end
		local low = memory[addr / 4]
		local high = memory[addr / 4 + 1]
		return low + high * 2 ^ 32
	end

	function load.f32(memory, addr)
		if (addr % 4 ~= 0) then
			error("Unaligned read in load.f32: " .. addr)
		end
		return f32_from_bits(memory[addr / 4])
	end

	function load.f64(memory, addr)
		if (addr % 4 ~= 0) then
			error("Unaligned read in load.f64: " .. addr)
		end
		local low = memory[addr / 4]
		local high = memory[addr / 4 + 1]
		return f64_from_bits(low + high * 2 ^ 32)
	end

	function load.string(memory, addr, len)
		-- local start = cast(alias_t, memory) + addr

		-- return ffi.string(start, len)
	end

	function store.i32_n8(memory, addr, value)
		local offset = addr % 4
		local mem_addr = (addr - offset) - 4
		memory[mem_addr] = set_bytes(memory[mem_addr], offset, 1, value)
	end

	function store.i32_n16(memory, addr, value)
		if (addr % 2 ~= 0) then
			error("Unaligned write in store.i32_n16: " .. addr)
		end

		local offset = addr % 4
		local mem_addr = (addr - offset) - 4
		memory[mem_addr] = set_bytes(memory[mem_addr], offset, 2, value)
	end

	function store.i32(memory, addr, value)
		if (addr % 4 ~= 0) then
			error("Unaligned write in store.i32: " .. addr)
		end

		memory[addr / 4] = i32_to_u32(value)
	end

	store.i64_n8 = store.i32_n8
	store.i64_n16 = store.i32_n16

	function store.i64_n32(memory, addr, value)
		if (addr % 4 ~= 0) then
			error("Unaligned write in store.i64_n32: " .. addr)
		end

		local unsigned = i64_to_u64(value)
		memory[addr / 4] = unsigned % 2 ^ 32
	end

	function store.i64(memory, addr, value)
		if (addr % 4 ~= 0) then
			error("Unaligned write in store.i64: " .. addr)
		end

		local unsigned = i64_to_u64(value)
		memory[addr / 4] = unsigned % 2 ^ 32
		memory[addr / 4 + 1] = math.floor(unsigned / 2 ^ 32)
	end

	function store.f32(memory, addr, value)
		if (addr % 4 ~= 0) then
			error("Unaligned write in store.f32: " .. addr)
		end

		memory[addr / 4] = f32_to_bits(value)
	end

	function store.f64(memory, addr, value)
		if (addr % 4 ~= 0) then
			error("Unaligned write in store.f64: " .. addr)
		end

		local raw_bits = f64_to_bits(value)
		memory[addr / 4] = raw_bits % 2 ^ 32
		memory[addr / 4 + 1] = math.floor(raw_bits / 2 ^ 32)
	end

	function store.string(memory, addr, data, len)
		-- local start = by_offset(memory, addr)

		for i = 1, #data do
			local code = string.byte(data, i)

			local byte_addr = addr + i - 1
			local offset = byte_addr % 4
			local mem_addr = (byte_addr - offset) / 4

			memory[mem_addr] = set_bytes(memory[mem_addr] or 0, offset, 1, code)
		end
		-- ffi.copy(start, data, len or #data)
	end

	function store.copy(memory_1, addr_1, memory_2, addr_2, len)
		local start_1 = by_offset(memory_1.data, addr_1)
		local start_2 = by_offset(memory_2.data, addr_2)

		-- ffi.copy(start_1, start_2, len)
	end

	function store.fill(memory, addr, len, value)
		local start = by_offset(memory, addr)

		-- ffi.fill(start, len, value)
	end

	local WASM_PAGE_SIZE = 65536

	local function finalizer(memory)
		-- ffi.C.free(memory)
	end

	local function grow_unchecked(memory, old, new)
		-- memory = ffi.C.realloc(memory, new)

		-- assert(memory ~= nil, "failed to reallocate")

		-- ffi.fill(by_offset(memory, old), new - old, 0)
	end

	function allocator.new(min, max)
		-- local data = ffi.C.calloc(min, WASM_PAGE_SIZE)

		-- assert(data ~= nil, "failed to allocate")

		-- local memory = ffi.new("struct Memory", min, max, data)

		-- return ffi.gc(memory, finalizer)

		local memory = {}
		for i = min, max do
			memory[i] = 0
		end

		return memory
	end

	function allocator.grow(memory, num)
		if num == 0 then
			return memory.min
		end

		local old = memory.min
		local new = old + num

		if new > memory.max then
			return -1
		else
			grow_unchecked(memory, old * WASM_PAGE_SIZE, new * WASM_PAGE_SIZE)
			memory.min = new

			return old
		end
	end

	module.load = load
	module.store = store
	module.allocator = allocator
end

return module
