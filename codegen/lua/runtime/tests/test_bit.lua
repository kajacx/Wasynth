local bit = require('bit')

local function assert_equals(value, expected)
    if value ~= expected then
        error("Assertion failed, expected " .. expected .. " but got " .. value .. "instead.")
    end
end

local value = 258
assert_equals(bit.extract_bytes(value, 0, 1), 2)
assert_equals(bit.extract_bytes(value, 1, 2), 1)
assert_equals(bit.extract_bytes(value, 0, 2), 258)

print("Tests passed successfully.")
