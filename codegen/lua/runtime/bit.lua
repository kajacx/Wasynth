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

return {
    extract_bytes = extract_bytes,
    extract_bytes_signed = extract_bytes_signed,
    set_bytes = set_bytes,
    set_bytes_signed = set_bytes_signed,
}
