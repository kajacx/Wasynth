local function extract_bytes(number, byte_start, byte_length)
    local shifted = math.floor(number / 256 ^ byte_start)
    local trimmed = shifted % 256 ^ byte_length
    return trimmed
end

return {
    extract_bytes = extract_bytes
}
