-- local bit = require('bit')
local bit = require('codegen/lua/runtime/bit')

local function assert_equals(value, expected)
    if value ~= expected then
        error("Assertion failed, expected " .. expected .. " but got " .. value .. "instead.")
    end
end

local function expect_error(callback, descr)
    if pcall(callback) then
        error("Function did not throw an error: " .. descr)
    end
end

local value = 5 * (256 ^ 0) + 8 * (256 ^ 1) + 240 * (256 ^ 2) + 50 * (256 ^ 3)
assert_equals(bit.extract_bytes(value, 0, 1), 5)
assert_equals(bit.extract_bytes(value, 1, 1), 8)
assert_equals(bit.extract_bytes(value, 2, 1), 240)
assert_equals(bit.extract_bytes(value, 3, 1), 50)
assert_equals(bit.extract_bytes(value, 0, 2), 5 + 8 * 256)
assert_equals(bit.extract_bytes(value, 1, 2), 8 + 240 * 256)
assert_equals(bit.extract_bytes(value, 2, 2), 240 + 50 * 256)
assert_equals(bit.extract_bytes(value, 0, 4), value)

local new_value

-- single byte at start
new_value = bit.set_bytes(value, 0, 1, 55)
assert_equals(bit.extract_bytes(new_value, 0, 1), 55)
assert_equals(bit.extract_bytes(new_value, 1, 3), 8 * (256 ^ 0) + 240 * (256 ^ 1) + 50 * (256 ^ 2))

-- single byte in the middle
new_value = bit.set_bytes(value, 1, 1, 88)
assert_equals(bit.extract_bytes(new_value, 0, 1), 5)
assert_equals(bit.extract_bytes(new_value, 1, 1), 88)
assert_equals(bit.extract_bytes(new_value, 2, 2), 240 + 50 * 256)

-- single byte at end
new_value = bit.set_bytes(value, 3, 1, 250)
assert_equals(bit.extract_bytes(new_value, 0, 3), 5 * (256 ^ 0) + 8 * (256 ^ 1) + 240 * (256 ^ 2))
assert_equals(bit.extract_bytes(new_value, 3, 1), 250)

expect_error(function() bit.extract_bytes(value, -5, 2) end, "start byte negative")
expect_error(function() bit.extract_bytes(value, 5, 2) end, "start byte too large")
expect_error(function() bit.extract_bytes(value, 0, -2) end, "length negative")
expect_error(function() bit.extract_bytes(value, 2, 3) end, "length too large")

expect_error(function() bit.set_bytes(value, -5, 2, 1) end, "start byte negative")
expect_error(function() bit.set_bytes(value, 5, 2, 1) end, "start byte too large")
expect_error(function() bit.set_bytes(value, 0, -2, 1) end, "length negative")
expect_error(function() bit.set_bytes(value, 2, 3, 1) end, "length too large")

expect_error(function() bit.set_bytes(value, 0, 1, 257) end, "byte overflow")
expect_error(function() bit.set_bytes(value, 0, 1, 256) end, "exact byte overflow")

print("Tests passed successfully.")
