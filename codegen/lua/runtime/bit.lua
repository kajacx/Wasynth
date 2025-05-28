local function extract_bytes(number, byte_start, byte_length)
    if (byte_start < 0 or byte_length < 0 or (byte_start + byte_length) > 4) then
        error("Extract bytes indexes out of range: " .. byte_start .. ", " .. byte_length)
    end

    local shifted = math.floor(number / 256 ^ byte_start)
    local trimmed = shifted % 256 ^ byte_length
    return trimmed
end

local function extract_bytes_signed(number, byte_start, byte_length)
    local result = extract_bytes(number, byte_start, byte_length)
    if result >= 256 ^ byte_length / 2 then
        result = result - 256 ^ byte_length
    end
    return result
end

local function set_bytes(number, byte_start, byte_length, value)
    if (byte_start < 0 or byte_length < 0 or (byte_start + byte_length) > 4) then
        error("Set bytes indexes out of range: " .. byte_start .. ", " .. byte_length)
    end
    if (value < 0 or value >= 256 ^ byte_length or math.floor(value) ~= value) then
        error("Set bytes value is out of range: " .. value .. ", length: " .. byte_length)
    end

    local byte_end = byte_start + byte_length
    local before = number % 256 ^ byte_start
    local after = math.floor(number / 256 ^ byte_end)
    return before + value * 256 ^ byte_start + after * 256 ^ byte_end
end

local function set_bytes_signed(number, byte_start, byte_length, value)
    if value < 0 then
        value = value + 256 ^ byte_length
    end
    return set_bytes(number, byte_start, byte_length, value)
end

local function u32_to_i32(value)
    if value >= 2 ^ 31 then
        return value - 2 ^ 32
    end
    return value
end

local function i32_to_u32(value)
    if value < 0 then
        return value + 2 ^ 32
    end
    return value
end

local function u64_to_i64(value)
    if value >= 2 ^ 63 then
        return value - 2 ^ 64
    end
    return value
end

local function i64_to_u64(value)
    if value < 0 then
        return value + 2 ^ 64
    end
    return value
end

local function f32_to_bits(value)
    return string.unpack("f", string.pack("I32", value))
end

local function f32_from_bits(bits)
    return string.unpack("I32", string.pack("f", bits))
end

local function f64_to_bits(value)
    return string.unpack("d", string.pack("I64", value))
end

local function f64_from_bits(bits)
    return string.unpack("I64", string.pack("d", bits))
end

local function identity(x) return x end

return {
    extract_bytes = extract_bytes,
    extract_bytes_signed = extract_bytes_signed,
    set_bytes = set_bytes,
    set_bytes_signed = set_bytes_signed,

    i32_to_u32 = i32_to_u32,
    u32_to_i32 = u32_to_i32,
    i64_to_u64 = i64_to_u64,
    u64_to_i64 = u64_to_i64,

    f32_to_bits = f32_to_bits,
    f32_from_bits = f32_from_bits,
    f64_to_bits = f64_to_bits,
    f64_from_bits = f64_from_bits,

    band = identity,
    lshift = identity,
    rshift = identity,
}
