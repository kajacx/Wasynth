local bit = require('bit')
-- local bit = require('codegen/lua/runtime/bit')

describe("Busted unit testing framework", function()
    describe("should be awesome", function()
        it("should be easy to use", function()
            assert.truthy(0)
        end)

        it("should have lots of features", function()
            -- deep check comparisons!
            assert.are.same({ table = "great" }, { table = "great" })

            -- or check by reference!
            assert.are_not.equal({ table = "great" }, { table = "great" })

            assert.truthy("this is a string") -- truthy: not false or nil

            assert.True(1 == 1)
            assert.is_true(1 == 1)

            assert.falsy(nil)
            assert.has_error(function() error("Wat") end, "Wat")
        end)

        it("should provide some shortcuts to common functions", function()
            assert.are.unique({ { thing = 1 }, { thing = 2 }, { thing = 3 } })
        end)
    end)
end)

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

local value = 5 * (256 ^ 0) + 8 * (256 ^ 1) + 240 * (256 ^ 2) + 11 * (256 ^ 3)
assert_equals(bit.extract_bytes(value, 0, 1), 5)
assert_equals(bit.extract_bytes(value, 1, 1), 8)
assert_equals(bit.extract_bytes(value, 2, 1), 240)
assert_equals(bit.extract_bytes(value, 3, 1), 11)
assert_equals(bit.extract_bytes(value, 0, 2), 5 + 8 * 256)
assert_equals(bit.extract_bytes(value, 1, 2), 8 + 240 * 256)
assert_equals(bit.extract_bytes(value, 2, 2), 240 + 11 * 256)
assert_equals(bit.extract_bytes(value, 0, 4), value)

local new_value

-- single byte at start
new_value = bit.set_bytes(value, 0, 1, 55)
assert_equals(bit.extract_bytes(new_value, 0, 1), 55)
assert_equals(bit.extract_bytes(new_value, 1, 3), 8 * (256 ^ 0) + 240 * (256 ^ 1) + 11 * (256 ^ 2))

-- single byte in the middle
new_value = bit.set_bytes(value, 1, 1, 88)
assert_equals(bit.extract_bytes(new_value, 0, 1), 5)
assert_equals(bit.extract_bytes(new_value, 1, 1), 88)
assert_equals(bit.extract_bytes(new_value, 2, 2), 240 + 11 * 256)

-- single byte at end
new_value = bit.set_bytes(value, 3, 1, 111)
assert_equals(bit.extract_bytes(new_value, 0, 3), 5 * (256 ^ 0) + 8 * (256 ^ 1) + 240 * (256 ^ 2))
assert_equals(bit.extract_bytes(new_value, 3, 1), 111)


-- double byte at start
new_value = bit.set_bytes(value, 0, 2, 55 + 88 * 256)
assert_equals(bit.extract_bytes(new_value, 0, 2), 55 + 88 * 256)
assert_equals(bit.extract_bytes(new_value, 2, 2), 240 + 11 * 256)

-- double byte in middle
new_value = bit.set_bytes(value, 1, 2, 88 + 250 * 256)
assert_equals(bit.extract_bytes(new_value, 0, 1), 5)
assert_equals(bit.extract_bytes(new_value, 1, 2), 88 + 250 * 256)
assert_equals(bit.extract_bytes(new_value, 3, 1), 11)

-- double byte at end
new_value = bit.set_bytes(value, 2, 2, 250 + 111 * 256)
assert_equals(bit.extract_bytes(new_value, 0, 2), 5 + 8 * 256)
assert_equals(bit.extract_bytes(new_value, 2, 2), 250 + 111 * 256)


-- full set_bytes
local new_value_num = 55 * (256 ^ 0) + 88 * (256 ^ 1) + 250 * (256 ^ 2) + 111 * (256 ^ 3)
new_value = bit.set_bytes(value, 0, 4, new_value_num)
assert_equals(bit.extract_bytes(new_value, 0, 4), new_value_num)


-- argument checking
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
expect_error(function() bit.set_bytes(value, 0, 1, -1) end, "negative number")
expect_error(function() bit.set_bytes(value, 0, 1, 0.5) end, "floating point number")

-- signed values
local signed_value = 0
signed_value = bit.set_bytes_signed(signed_value, 0, 1, -50)
assert_equals(bit.extract_bytes_signed(signed_value, 0, 1), -50)
assert_equals(bit.extract_bytes(signed_value, 0, 1), 206)


print("Tests passed successfully.")
