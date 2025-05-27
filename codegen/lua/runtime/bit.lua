local function extract_bytes(number, byte_start, byte_length)
    local shifted = math.floor(number / 256 ^ byte_start)
    local trimmed = shifted % 256 ^ byte_length
    return trimmed
end

local function set_bytes(number, byte_start, byte_length, value)
    local byte_end = byte_start + byte_length
    local before = number % 256 ^ byte_start
    local after = math.floor(number / 256 ^ byte_end)
    return before + value * 256 ^ byte_start + after * 256 ^ byte_end
end

return {
    extract_bytes = extract_bytes,
    set_bytes = set_bytes,
}
