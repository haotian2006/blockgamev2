--!native
--!optimize 2
--!nocheck

-- stylua: ignore start
---@diagnostic disable: undefined-type

local function readu24(b: buffer, offset: number)
	return buffer.readu8(b, offset) + buffer.readu16(b, offset + 1) * 256
end

local function writeu24(b: buffer, offset: number, value: number)
	buffer.writeu8(b, offset, value)
	buffer.writeu16(b, offset + 1, value // 256)
end

--- @class bitbuffer
local bitbuffer = {}

do -- main
	do -- uint
		do -- write
			--- Writes a 1 bit unsigned integer [0, 1]
			function bitbuffer.writeu1(b: buffer, byte: number, bit: number, value: number)
				buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 1))
			end

			--- Writes a 2 bit unsigned integer [0, 3]
			function bitbuffer.writeu2(b: buffer, byte: number, bit: number, value: number)
				if bit > 6 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 2))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 2))
				end
			end

			--- Writes a 3 bit unsigned integer [0, 7]
			function bitbuffer.writeu3(b: buffer, byte: number, bit: number, value: number)
				if bit > 5 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 3))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 3))
				end
			end

			--- Writes a 4 bit unsigned integer [0, 15]
			function bitbuffer.writeu4(b: buffer, byte: number, bit: number, value: number)
				if bit > 4 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 4))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 4))
				end
			end

			--- Writes a 5 bit unsigned integer [0, 31]
			function bitbuffer.writeu5(b: buffer, byte: number, bit: number, value: number)
				if bit > 3 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 5))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 5))
				end
			end

			--- Writes a 6 bit unsigned integer [0, 63]
			function bitbuffer.writeu6(b: buffer, byte: number, bit: number, value: number)
				if bit > 2 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 6))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 6))
				end
			end

			--- Writes a 7 bit unsigned integer [0, 127]
			function bitbuffer.writeu7(b: buffer, byte: number, bit: number, value: number)
				if bit > 1 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 7))
				else
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value, bit, 7))
				end
			end

			--- Writes a 8 bit unsigned integer [0, 255]
			function bitbuffer.writeu8(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 8))
				else
					buffer.writeu8(b, byte, value)
				end
			end

			--- Writes a 9 bit unsigned integer [0, 511]
			function bitbuffer.writeu9(b: buffer, byte: number, bit: number, value: number)
				buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 9))
			end

			--- Writes a 10 bit unsigned integer [0, 1023]
			function bitbuffer.writeu10(b: buffer, byte: number, bit: number, value: number)
				if bit > 6 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 10))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 10))
				end
			end

			--- Writes a 11 bit unsigned integer [0, 2047]
			function bitbuffer.writeu11(b: buffer, byte: number, bit: number, value: number)
				if bit > 5 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 11))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 11))
				end
			end

			--- Writes a 12 bit unsigned integer [0, 4095]
			function bitbuffer.writeu12(b: buffer, byte: number, bit: number, value: number)
				if bit > 4 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 12))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 12))
				end
			end

			--- Writes a 13 bit unsigned integer [0, 8191]
			function bitbuffer.writeu13(b: buffer, byte: number, bit: number, value: number)
				if bit > 3 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 13))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 13))
				end
			end

			--- Writes a 14 bit unsigned integer [0, 16383]
			function bitbuffer.writeu14(b: buffer, byte: number, bit: number, value: number)
				if bit > 2 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 14))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 14))
				end
			end

			--- Writes a 15 bit unsigned integer [0, 32767]
			function bitbuffer.writeu15(b: buffer, byte: number, bit: number, value: number)
				if bit > 1 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 15))
				else
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value, bit, 15))
				end
			end

			--- Writes a 16 bit unsigned integer [0, 65535]
			function bitbuffer.writeu16(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 16))
				else
					buffer.writeu16(b, byte, value)
				end
			end

			--- Writes a 17 bit unsigned integer [0, 131071]
			function bitbuffer.writeu17(b: buffer, byte: number, bit: number, value: number)
				writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 17))
			end

			--- Writes a 18 bit unsigned integer [0, 262143]
			function bitbuffer.writeu18(b: buffer, byte: number, bit: number, value: number)
				if bit > 6 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 18))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 18))
				end
			end

			--- Writes a 19 bit unsigned integer [0, 524287]
			function bitbuffer.writeu19(b: buffer, byte: number, bit: number, value: number)
				if bit > 5 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 19))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 19))
				end
			end

			--- Writes a 20 bit unsigned integer [0, 1048575]
			function bitbuffer.writeu20(b: buffer, byte: number, bit: number, value: number)
				if bit > 4 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 20))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 20))
				end
			end

			--- Writes a 21 bit unsigned integer [0, 2097151]
			function bitbuffer.writeu21(b: buffer, byte: number, bit: number, value: number)
				if bit > 3 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 21))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 21))
				end
			end

			--- Writes a 22 bit unsigned integer [0, 4194303]
			function bitbuffer.writeu22(b: buffer, byte: number, bit: number, value: number)
				if bit > 2 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 22))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 22))
				end
			end

			--- Writes a 23 bit unsigned integer [0, 8388607]
			function bitbuffer.writeu23(b: buffer, byte: number, bit: number, value: number)
				if bit > 1 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 23))
				else
					writeu24(b, byte, bit32.replace(readu24(b, byte), value, bit, 23))
				end
			end

			--- Writes a 24 bit unsigned integer [0, 16777215]
			function bitbuffer.writeu24(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
				else
					writeu24(b, byte, value)
				end
			end

			--- Writes a 25 bit unsigned integer [0, 33554431]
			function bitbuffer.writeu25(b: buffer, byte: number, bit: number, value: number)
				buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 25))
			end

			--- Writes a 26 bit unsigned integer [0, 67108863]
			function bitbuffer.writeu26(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 6 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 2))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 2))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 26))
				end
			end

			--- Writes a 27 bit unsigned integer [0, 134217727]
			function bitbuffer.writeu27(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 5 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 3))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 3))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 27))
				end
			end

			--- Writes a 28 bit unsigned integer [0, 268435455]
			function bitbuffer.writeu28(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 4 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 4))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 4))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 28))
				end
			end

			--- Writes a 29 bit unsigned integer [0, 536870911]
			function bitbuffer.writeu29(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 3 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 5))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 5))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 29))
				end
			end

			--- Writes a 30 bit unsigned integer [0, 1073741823]
			function bitbuffer.writeu30(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 2 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 6))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 6))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 30))
				end
			end

			--- Writes a 31 bit unsigned integer [0, 2147483647]
			function bitbuffer.writeu31(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 1 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 7))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000, bit, 7))
					end
				else
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, 0, 31))
				end
			end

			--- Writes a 32 bit unsigned integer [0, 4294967295]
			function bitbuffer.writeu32(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 8))
				else
					buffer.writeu32(b, byte, value)
				end
			end

			--- Writes a 33 bit unsigned integer [0, 8589934591]
			function bitbuffer.writeu33(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 9))
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 1))
				end
			end

			--- Writes a 34 bit unsigned integer [0, 17179869183]
			function bitbuffer.writeu34(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 6 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 10))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 10))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 2))
				end
			end

			--- Writes a 35 bit unsigned integer [0, 34359738367]
			function bitbuffer.writeu35(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 5 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 11))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 11))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 3))
				end
			end

			--- Writes a 36 bit unsigned integer [0, 68719476735]
			function bitbuffer.writeu36(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 4 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 12))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 12))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 4))
				end
			end

			--- Writes a 37 bit unsigned integer [0, 137438953471]
			function bitbuffer.writeu37(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 3 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 13))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 13))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 5))
				end
			end

			--- Writes a 38 bit unsigned integer [0, 274877906943]
			function bitbuffer.writeu38(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 2 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 14))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 14))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 6))
				end
			end

			--- Writes a 39 bit unsigned integer [0, 549755813887]
			function bitbuffer.writeu39(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 1 then
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 15))
					else
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000, bit, 15))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x100000000, 0, 7))
				end
			end

			--- Writes a 40 bit unsigned integer [0, 1099511627775]
			function bitbuffer.writeu40(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 16))
				else
					buffer.writeu32(b, byte, value)
					buffer.writeu8(b, byte + 4, value // 0x100000000)
				end
			end

			--- Writes a 41 bit unsigned integer [0, 2199023255551]
			function bitbuffer.writeu41(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 17))
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 9))
				end
			end

			--- Writes a 42 bit unsigned integer [0, 4398046511103]
			function bitbuffer.writeu42(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 6 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 18))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 18))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 10))
				end
			end

			--- Writes a 43 bit unsigned integer [0, 8796093022207]
			function bitbuffer.writeu43(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 5 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 19))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 19))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 11))
				end
			end

			--- Writes a 44 bit unsigned integer [0, 17592186044415]
			function bitbuffer.writeu44(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 4 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 20))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 20))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 12))
				end
			end

			--- Writes a 45 bit unsigned integer [0, 35184372088831]
			function bitbuffer.writeu45(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 3 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 21))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 21))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 13))
				end
			end

			--- Writes a 46 bit unsigned integer [0, 70368744177663]
			function bitbuffer.writeu46(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 2 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 22))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 22))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 14))
				end
			end

			--- Writes a 47 bit unsigned integer [0, 140737488355327]
			function bitbuffer.writeu47(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					if bit > 1 then
						buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 23))
					else
						writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x1000000, bit, 23))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x100000000, 0, 15))
				end
			end

			--- Writes a 48 bit unsigned integer [0, 281474976710655]
			function bitbuffer.writeu48(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
				else
					buffer.writeu32(b, byte, value)
					buffer.writeu16(b, byte + 4, value // 0x100000000)
				end
			end

			--- Writes a 49 bit unsigned integer [0, 562949953421311]
			function bitbuffer.writeu49(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
					byte += 3
					buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000000000, bit, 1))
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x100000000, 0, 17))
				end
			end

			--- Writes a 50 bit unsigned integer [0, 1125899906842623]
			function bitbuffer.writeu50(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
					byte += 3
					if bit > 6 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000000000, bit, 2))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000000000, bit, 2))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x100000000, 0, 18))
				end
			end

			--- Writes a 51 bit unsigned integer [0, 2251799813685247]
			function bitbuffer.writeu51(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
					byte += 3
					if bit > 5 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000000000, bit, 3))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000000000, bit, 3))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x100000000, 0, 19))
				end
			end

			--- Writes a 52 bit unsigned integer [0, 4503599627370495]
			function bitbuffer.writeu52(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
					byte += 3
					if bit > 4 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000000000, bit, 4))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000000000, bit, 4))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x100000000, 0, 20))
				end
			end

			--- Writes a 53 bit unsigned integer [0, 9007199254740991]
			function bitbuffer.writeu53(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value, bit, 24))
					byte += 3
					buffer.writeu32(b, byte, bit32.replace(buffer.readu32(b, byte), value // 0x1000000, bit, 24))
					byte += 3
					if bit > 3 then
						buffer.writeu16(b, byte, bit32.replace(buffer.readu16(b, byte), value // 0x1000000000000, bit, 5))
					else
						buffer.writeu8(b, byte, bit32.replace(buffer.readu8(b, byte), value // 0x1000000000000, bit, 5))
					end
				else
					buffer.writeu32(b, byte, value)
					byte += 4
					writeu24(b, byte, bit32.replace(readu24(b, byte), value // 0x100000000, 0, 21))
				end
			end
		end
		do -- read
			--- Reads a 1 bit unsigned integer [0, 1]
			function bitbuffer.readu1(b: buffer, byte: number, bit: number): number
				return bit32.extract(buffer.readu8(b, byte), bit, 1)
			end

			--- Reads a 2 bit unsigned integer [0, 3]
			function bitbuffer.readu2(b: buffer, byte: number, bit: number): number
				return if bit > 6
					then bit32.extract(buffer.readu16(b, byte), bit, 2)
					else bit32.extract(buffer.readu8(b, byte), bit, 2)
			end

			--- Reads a 3 bit unsigned integer [0, 7]
			function bitbuffer.readu3(b: buffer, byte: number, bit: number): number
				return if bit > 5
					then bit32.extract(buffer.readu16(b, byte), bit, 3)
					else bit32.extract(buffer.readu8(b, byte), bit, 3)
			end

			--- Reads a 4 bit unsigned integer [0, 15]
			function bitbuffer.readu4(b: buffer, byte: number, bit: number): number
				return if bit > 4
					then bit32.extract(buffer.readu16(b, byte), bit, 4)
					else bit32.extract(buffer.readu8(b, byte), bit, 4)
			end

			--- Reads a 5 bit unsigned integer [0, 31]
			function bitbuffer.readu5(b: buffer, byte: number, bit: number): number
				return if bit > 3
					then bit32.extract(buffer.readu16(b, byte), bit, 5)
					else bit32.extract(buffer.readu8(b, byte), bit, 5)
			end

			--- Reads a 6 bit unsigned integer [0, 63]
			function bitbuffer.readu6(b: buffer, byte: number, bit: number): number
				return if bit > 2
					then bit32.extract(buffer.readu16(b, byte), bit, 6)
					else bit32.extract(buffer.readu8(b, byte), bit, 6)
			end

			--- Reads a 7 bit unsigned integer [0, 127]
			function bitbuffer.readu7(b: buffer, byte: number, bit: number): number
				return if bit > 1
					then bit32.extract(buffer.readu16(b, byte), bit, 7)
					else bit32.extract(buffer.readu8(b, byte), bit, 7)
			end

			--- Reads a 8 bit unsigned integer [0, 255]
			function bitbuffer.readu8(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then bit32.extract(buffer.readu16(b, byte), bit, 8)
					else buffer.readu8(b, byte)
			end

			--- Reads a 9 bit unsigned integer [0, 511]
			function bitbuffer.readu9(b: buffer, byte: number, bit: number): number
				return bit32.extract(buffer.readu16(b, byte), bit, 9)
			end

			--- Reads a 10 bit unsigned integer [0, 1023]
			function bitbuffer.readu10(b: buffer, byte: number, bit: number): number
				return if bit > 6
					then bit32.extract(readu24(b, byte), bit, 10)
					else bit32.extract(buffer.readu16(b, byte), bit, 10)
			end

			--- Reads a 11 bit unsigned integer [0, 2047]
			function bitbuffer.readu11(b: buffer, byte: number, bit: number): number
				return if bit > 5
					then bit32.extract(readu24(b, byte), bit, 11)
					else bit32.extract(buffer.readu16(b, byte), bit, 11)
			end

			--- Reads a 12 bit unsigned integer [0, 4095]
			function bitbuffer.readu12(b: buffer, byte: number, bit: number): number
				return if bit > 4
					then bit32.extract(readu24(b, byte), bit, 12)
					else bit32.extract(buffer.readu16(b, byte), bit, 12)
			end

			--- Reads a 13 bit unsigned integer [0, 8191]
			function bitbuffer.readu13(b: buffer, byte: number, bit: number): number
				return if bit > 3
					then bit32.extract(readu24(b, byte), bit, 13)
					else bit32.extract(buffer.readu16(b, byte), bit, 13)
			end

			--- Reads a 14 bit unsigned integer [0, 16383]
			function bitbuffer.readu14(b: buffer, byte: number, bit: number): number
				return if bit > 2
					then bit32.extract(readu24(b, byte), bit, 14)
					else bit32.extract(buffer.readu16(b, byte), bit, 14)
			end

			--- Reads a 15 bit unsigned integer [0, 32767]
			function bitbuffer.readu15(b: buffer, byte: number, bit: number): number
				return if bit > 1
					then bit32.extract(readu24(b, byte), bit, 15)
					else bit32.extract(buffer.readu16(b, byte), bit, 15)
			end

			--- Reads a 16 bit unsigned integer [0, 65535]
			function bitbuffer.readu16(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then bit32.extract(readu24(b, byte), bit, 16)
					else buffer.readu16(b, byte)
			end

			--- Reads a 17 bit unsigned integer [0, 131071]
			function bitbuffer.readu17(b: buffer, byte: number, bit: number): number
				return bit32.extract(readu24(b, byte), bit, 17)
			end

			--- Reads a 18 bit unsigned integer [0, 262143]
			function bitbuffer.readu18(b: buffer, byte: number, bit: number): number
				return if bit > 6
					then bit32.extract(buffer.readu32(b, byte), bit, 18)
					else bit32.extract(readu24(b, byte), bit, 18)
			end

			--- Reads a 19 bit unsigned integer [0, 524287]
			function bitbuffer.readu19(b: buffer, byte: number, bit: number): number
				return if bit > 5
					then bit32.extract(buffer.readu32(b, byte), bit, 19)
					else bit32.extract(readu24(b, byte), bit, 19)
			end

			--- Reads a 20 bit unsigned integer [0, 1048575]
			function bitbuffer.readu20(b: buffer, byte: number, bit: number): number
				return if bit > 4
					then bit32.extract(buffer.readu32(b, byte), bit, 20)
					else bit32.extract(readu24(b, byte), bit, 20)
			end

			--- Reads a 21 bit unsigned integer [0, 2097151]
			function bitbuffer.readu21(b: buffer, byte: number, bit: number): number
				return if bit > 3
					then bit32.extract(buffer.readu32(b, byte), bit, 21)
					else bit32.extract(readu24(b, byte), bit, 21)
			end

			--- Reads a 22 bit unsigned integer [0, 4194303]
			function bitbuffer.readu22(b: buffer, byte: number, bit: number): number
				return if bit > 2
					then bit32.extract(buffer.readu32(b, byte), bit, 22)
					else bit32.extract(readu24(b, byte), bit, 22)
			end

			--- Reads a 23 bit unsigned integer [0, 8388607]
			function bitbuffer.readu23(b: buffer, byte: number, bit: number): number
				return if bit > 1
					then bit32.extract(buffer.readu32(b, byte), bit, 23)
					else bit32.extract(readu24(b, byte), bit, 23)
			end

			--- Reads a 24 bit unsigned integer [0, 16777215]
			function bitbuffer.readu24(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then bit32.extract(buffer.readu32(b, byte), bit, 24)
					else readu24(b, byte)
			end

			--- Reads a 25 bit unsigned integer [0, 33554431]
			function bitbuffer.readu25(b: buffer, byte: number, bit: number): number
				return bit32.extract(buffer.readu32(b, byte), bit, 25)
			end

			--- Reads a 26 bit unsigned integer [0, 67108863]
			function bitbuffer.readu26(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 6
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 2)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 2)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x4000000
				end
			end

			--- Reads a 27 bit unsigned integer [0, 134217727]
			function bitbuffer.readu27(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 5
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 3)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 3)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x8000000
				end
			end

			--- Reads a 28 bit unsigned integer [0, 268435455]
			function bitbuffer.readu28(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 4
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 4)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 4)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x10000000
				end
			end

			--- Reads a 29 bit unsigned integer [0, 536870911]
			function bitbuffer.readu29(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 3
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 5)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 5)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x20000000
				end
			end

			--- Reads a 30 bit unsigned integer [0, 1073741823]
			function bitbuffer.readu30(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 2
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 6)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 6)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x40000000
				end
			end

			--- Reads a 31 bit unsigned integer [0, 2147483647]
			function bitbuffer.readu31(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 1
								then bit32.extract(buffer.readu16(b, byte + 3), bit, 7)
								else bit32.extract(buffer.readu8(b, byte + 3), bit, 7)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x80000000
				end
			end

			--- Reads a 32 bit unsigned integer [0, 4294967295]
			function bitbuffer.readu32(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu16(b, byte + 3), bit, 8) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
				end
			end

			--- Reads a 33 bit unsigned integer [0, 8589934591]
			function bitbuffer.readu33(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu16(b, byte + 3), bit, 9) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x2 * 0x100000000
				end
			end

			--- Reads a 34 bit unsigned integer [0, 17179869183]
			function bitbuffer.readu34(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 6
								then bit32.extract(readu24(b, byte + 3), bit, 10)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 10)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x4 * 0x100000000
				end
			end

			--- Reads a 35 bit unsigned integer [0, 34359738367]
			function bitbuffer.readu35(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 5
								then bit32.extract(readu24(b, byte + 3), bit, 11)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 11)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x8 * 0x100000000
				end
			end

			--- Reads a 36 bit unsigned integer [0, 68719476735]
			function bitbuffer.readu36(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 4
								then bit32.extract(readu24(b, byte + 3), bit, 12)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 12)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x10 * 0x100000000
				end
			end

			--- Reads a 37 bit unsigned integer [0, 137438953471]
			function bitbuffer.readu37(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 3
								then bit32.extract(readu24(b, byte + 3), bit, 13)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 13)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x20 * 0x100000000
				end
			end

			--- Reads a 38 bit unsigned integer [0, 274877906943]
			function bitbuffer.readu38(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 2
								then bit32.extract(readu24(b, byte + 3), bit, 14)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 14)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x40 * 0x100000000
				end
			end

			--- Reads a 39 bit unsigned integer [0, 549755813887]
			function bitbuffer.readu39(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 1
								then bit32.extract(readu24(b, byte + 3), bit, 15)
								else bit32.extract(buffer.readu16(b, byte + 3), bit, 15)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) % 0x80 * 0x100000000
				end
			end

			--- Reads a 40 bit unsigned integer [0, 1099511627775]
			function bitbuffer.readu40(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(readu24(b, byte + 3), bit, 16) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu8(b, byte + 4) * 0x100000000
				end
			end

			--- Reads a 41 bit unsigned integer [0, 2199023255551]
			function bitbuffer.readu41(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(readu24(b, byte + 3), bit, 17) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x200 * 0x100000000
				end
			end

			--- Reads a 42 bit unsigned integer [0, 4398046511103]
			function bitbuffer.readu42(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 6
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 18)
								else bit32.extract(readu24(b, byte + 3), bit, 18)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x400 * 0x100000000
				end
			end

			--- Reads a 43 bit unsigned integer [0, 8796093022207]
			function bitbuffer.readu43(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 5
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 19)
								else bit32.extract(readu24(b, byte + 3), bit, 19)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x800 * 0x100000000
				end
			end

			--- Reads a 44 bit unsigned integer [0, 17592186044415]
			function bitbuffer.readu44(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 4
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 20)
								else bit32.extract(readu24(b, byte + 3), bit, 20)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x1000 * 0x100000000
				end
			end

			--- Reads a 45 bit unsigned integer [0, 35184372088831]
			function bitbuffer.readu45(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 3
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 21)
								else bit32.extract(readu24(b, byte + 3), bit, 21)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x2000 * 0x100000000
				end
			end

			--- Reads a 46 bit unsigned integer [0, 70368744177663]
			function bitbuffer.readu46(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 2
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 22)
								else bit32.extract(readu24(b, byte + 3), bit, 22)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x4000 * 0x100000000
				end
			end

			--- Reads a 47 bit unsigned integer [0, 140737488355327]
			function bitbuffer.readu47(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ (
							if bit > 1
								then bit32.extract(buffer.readu32(b, byte + 3), bit, 23)
								else bit32.extract(readu24(b, byte + 3), bit, 23)
						) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) % 0x8000 * 0x100000000
				end
			end

			--- Reads a 48 bit unsigned integer [0, 281474976710655]
			function bitbuffer.readu48(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ buffer.readu16(b, byte + 4) * 0x100000000
				end
			end

			--- Reads a 49 bit unsigned integer [0, 562949953421311]
			function bitbuffer.readu49(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
						+ bit32.extract(buffer.readu8(b, byte + 6), bit, 1) * 0x1000000000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ readu24(b, byte + 4) % 0x20000 * 0x100000000
				end
			end

			--- Reads a 50 bit unsigned integer [0, 1125899906842623]
			function bitbuffer.readu50(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
						+ (
							if bit > 6
								then bit32.extract(buffer.readu16(b, byte + 6), bit, 2)
								else bit32.extract(buffer.readu8(b, byte + 6), bit, 2)
						) * 0x1000000000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ readu24(b, byte + 4) % 0x40000 * 0x100000000
				end
			end

			--- Reads a 51 bit unsigned integer [0, 2251799813685247]
			function bitbuffer.readu51(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
						+ (
							if bit > 5
								then bit32.extract(buffer.readu16(b, byte + 6), bit, 3)
								else bit32.extract(buffer.readu8(b, byte + 6), bit, 3)
						) * 0x1000000000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ readu24(b, byte + 4) % 0x80000 * 0x100000000
				end
			end

			--- Reads a 52 bit unsigned integer [0, 4503599627370495]
			function bitbuffer.readu52(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
						+ (
							if bit > 4
								then bit32.extract(buffer.readu16(b, byte + 6), bit, 4)
								else bit32.extract(buffer.readu8(b, byte + 6), bit, 4)
						) * 0x1000000000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ readu24(b, byte + 4) % 0x100000 * 0x100000000
				end
			end

			--- Reads a 53 bit unsigned integer [0, 9007199254740991]
			function bitbuffer.readu53(b: buffer, byte: number, bit: number): number
				if bit > 0 then
					return bit32.extract(buffer.readu32(b, byte), bit, 24)
						+ bit32.extract(buffer.readu32(b, byte + 3), bit, 24) * 0x1000000
						+ (
							if bit > 3
								then bit32.extract(buffer.readu16(b, byte + 6), bit, 5)
								else bit32.extract(buffer.readu8(b, byte + 6), bit, 5)
						) * 0x1000000000000
				else
					return buffer.readu32(b, byte) % 0x100000000
						+ readu24(b, byte + 4) % 0x200000 * 0x100000000
				end
			end
		end
		bitbuffer.readu = { bitbuffer.readu1, bitbuffer.readu2, bitbuffer.readu3, bitbuffer.readu4, bitbuffer.readu5, bitbuffer.readu6, bitbuffer.readu7, bitbuffer.readu8, bitbuffer.readu9, bitbuffer.readu10, bitbuffer.readu11, bitbuffer.readu12, bitbuffer.readu13, bitbuffer.readu14, bitbuffer.readu15, bitbuffer.readu16, bitbuffer.readu17, bitbuffer.readu18, bitbuffer.readu19, bitbuffer.readu20, bitbuffer.readu21, bitbuffer.readu22, bitbuffer.readu23, bitbuffer.readu24, bitbuffer.readu25, bitbuffer.readu26, bitbuffer.readu27, bitbuffer.readu28, bitbuffer.readu29, bitbuffer.readu30, bitbuffer.readu31, bitbuffer.readu32, bitbuffer.readu33, bitbuffer.readu34, bitbuffer.readu35, bitbuffer.readu36, bitbuffer.readu37, bitbuffer.readu38, bitbuffer.readu39, bitbuffer.readu40, bitbuffer.readu41, bitbuffer.readu42, bitbuffer.readu43, bitbuffer.readu44, bitbuffer.readu45, bitbuffer.readu46, bitbuffer.readu47, bitbuffer.readu48, bitbuffer.readu49, bitbuffer.readu50, bitbuffer.readu51, bitbuffer.readu52, bitbuffer.readu53 }
		bitbuffer.writeu = { bitbuffer.writeu1, bitbuffer.writeu2, bitbuffer.writeu3, bitbuffer.writeu4, bitbuffer.writeu5, bitbuffer.writeu6, bitbuffer.writeu7, bitbuffer.writeu8, bitbuffer.writeu9, bitbuffer.writeu10, bitbuffer.writeu11, bitbuffer.writeu12, bitbuffer.writeu13, bitbuffer.writeu14, bitbuffer.writeu15, bitbuffer.writeu16, bitbuffer.writeu17, bitbuffer.writeu18, bitbuffer.writeu19, bitbuffer.writeu20, bitbuffer.writeu21, bitbuffer.writeu22, bitbuffer.writeu23, bitbuffer.writeu24, bitbuffer.writeu25, bitbuffer.writeu26, bitbuffer.writeu27, bitbuffer.writeu28, bitbuffer.writeu29, bitbuffer.writeu30, bitbuffer.writeu31, bitbuffer.writeu32, bitbuffer.writeu33, bitbuffer.writeu34, bitbuffer.writeu35, bitbuffer.writeu36, bitbuffer.writeu37, bitbuffer.writeu38, bitbuffer.writeu39, bitbuffer.writeu40, bitbuffer.writeu41, bitbuffer.writeu42, bitbuffer.writeu43, bitbuffer.writeu44, bitbuffer.writeu45, bitbuffer.writeu46, bitbuffer.writeu47, bitbuffer.writeu48, bitbuffer.writeu49, bitbuffer.writeu50, bitbuffer.writeu51, bitbuffer.writeu52, bitbuffer.writeu53 }
	end

	do -- int
		do -- write
			--- Writes a 1 bit signed integer [-1, 0]
			function bitbuffer.writei1(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu1(b, byte, bit, (value + 2) % 2)
			end

			--- Writes a 2 bit signed integer [-2, 1]
			function bitbuffer.writei2(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu2(b, byte, bit, (value + 4) % 4)
			end

			--- Writes a 3 bit signed integer [-4, 3]
			function bitbuffer.writei3(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu3(b, byte, bit, (value + 8) % 8)
			end

			--- Writes a 4 bit signed integer [-8, 7]
			function bitbuffer.writei4(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu4(b, byte, bit, (value + 16) % 16)
			end

			--- Writes a 5 bit signed integer [-16, 15]
			function bitbuffer.writei5(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu5(b, byte, bit, (value + 32) % 32)
			end

			--- Writes a 6 bit signed integer [-32, 31]
			function bitbuffer.writei6(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu6(b, byte, bit, (value + 64) % 64)
			end

			--- Writes a 7 bit signed integer [-64, 63]
			function bitbuffer.writei7(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu7(b, byte, bit, (value + 128) % 128)
			end

			--- Writes a 8 bit signed integer [-128, 127]
			function bitbuffer.writei8(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					bitbuffer.writeu8(b, byte, bit, (value + 256) % 256)
				else
					buffer.writei8(b, byte, value)
				end
			end

			--- Writes a 9 bit signed integer [-256, 255]
			function bitbuffer.writei9(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu9(b, byte, bit, (value + 512) % 512)
			end

			--- Writes a 10 bit signed integer [-512, 511]
			function bitbuffer.writei10(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu10(b, byte, bit, (value + 1024) % 1024)
			end

			--- Writes a 11 bit signed integer [-1024, 1023]
			function bitbuffer.writei11(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu11(b, byte, bit, (value + 2048) % 2048)
			end

			--- Writes a 12 bit signed integer [-2048, 2047]
			function bitbuffer.writei12(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu12(b, byte, bit, (value + 4096) % 4096)
			end

			--- Writes a 13 bit signed integer [-4096, 4095]
			function bitbuffer.writei13(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu13(b, byte, bit, (value + 8192) % 8192)
			end

			--- Writes a 14 bit signed integer [-8192, 8191]
			function bitbuffer.writei14(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu14(b, byte, bit, (value + 16384) % 16384)
			end

			--- Writes a 15 bit signed integer [-16384, 16383]
			function bitbuffer.writei15(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu15(b, byte, bit, (value + 32768) % 32768)
			end

			--- Writes a 16 bit signed integer [-32768, 32767]
			function bitbuffer.writei16(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					bitbuffer.writeu16(b, byte, bit, (value + 65536) % 65536)
				else
					buffer.writei16(b, byte, value)
				end
			end

			--- Writes a 17 bit signed integer [-65536, 65535]
			function bitbuffer.writei17(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu17(b, byte, bit, (value + 131072) % 131072)
			end

			--- Writes a 18 bit signed integer [-131072, 131071]
			function bitbuffer.writei18(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu18(b, byte, bit, (value + 262144) % 262144)
			end

			--- Writes a 19 bit signed integer [-262144, 262143]
			function bitbuffer.writei19(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu19(b, byte, bit, (value + 524288) % 524288)
			end

			--- Writes a 20 bit signed integer [-524288, 524287]
			function bitbuffer.writei20(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu20(b, byte, bit, (value + 1048576) % 1048576)
			end

			--- Writes a 21 bit signed integer [-1048576, 1048575]
			function bitbuffer.writei21(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu21(b, byte, bit, (value + 2097152) % 2097152)
			end

			--- Writes a 22 bit signed integer [-2097152, 2097151]
			function bitbuffer.writei22(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu22(b, byte, bit, (value + 4194304) % 4194304)
			end

			--- Writes a 23 bit signed integer [-4194304, 4194303]
			function bitbuffer.writei23(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu23(b, byte, bit, (value + 8388608) % 8388608)
			end

			--- Writes a 24 bit signed integer [-8388608, 8388607]
			function bitbuffer.writei24(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu24(b, byte, bit, (value + 16777216) % 16777216)
			end

			--- Writes a 25 bit signed integer [-16777216, 16777215]
			function bitbuffer.writei25(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu25(b, byte, bit, (value + 33554432) % 33554432)
			end

			--- Writes a 26 bit signed integer [-33554432, 33554431]
			function bitbuffer.writei26(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu26(b, byte, bit, (value + 67108864) % 67108864)
			end

			--- Writes a 27 bit signed integer [-67108864, 67108863]
			function bitbuffer.writei27(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu27(b, byte, bit, (value + 134217728) % 134217728)
			end

			--- Writes a 28 bit signed integer [-134217728, 134217727]
			function bitbuffer.writei28(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu28(b, byte, bit, (value + 268435456) % 268435456)
			end

			--- Writes a 29 bit signed integer [-268435456, 268435455]
			function bitbuffer.writei29(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu29(b, byte, bit, (value + 536870912) % 536870912)
			end

			--- Writes a 30 bit signed integer [-536870912, 536870911]
			function bitbuffer.writei30(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu30(b, byte, bit, (value + 1073741824) % 1073741824)
			end

			--- Writes a 31 bit signed integer [-1073741824, 1073741823]
			function bitbuffer.writei31(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu31(b, byte, bit, (value + 2147483648) % 2147483648)
			end

			--- Writes a 32 bit signed integer [-2147483648, 2147483647]
			function bitbuffer.writei32(b: buffer, byte: number, bit: number, value: number)
				if bit > 0 then
					bitbuffer.writeu32(b, byte, bit, (value + 4294967296) % 4294967296)
				else
					buffer.writei32(b, byte, value)
				end
			end

			--- Writes a 33 bit signed integer [-4294967296, 4294967295]
			function bitbuffer.writei33(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu33(b, byte, bit, (value + 8589934592) % 8589934592)
			end

			--- Writes a 34 bit signed integer [-8589934592, 8589934591]
			function bitbuffer.writei34(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu34(b, byte, bit, (value + 17179869184) % 17179869184)
			end

			--- Writes a 35 bit signed integer [-17179869184, 17179869183]
			function bitbuffer.writei35(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu35(b, byte, bit, (value + 34359738368) % 34359738368)
			end

			--- Writes a 36 bit signed integer [-34359738368, 34359738367]
			function bitbuffer.writei36(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu36(b, byte, bit, (value + 68719476736) % 68719476736)
			end

			--- Writes a 37 bit signed integer [-68719476736, 68719476735]
			function bitbuffer.writei37(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu37(b, byte, bit, (value + 137438953472) % 137438953472)
			end

			--- Writes a 38 bit signed integer [-137438953472, 137438953471]
			function bitbuffer.writei38(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu38(b, byte, bit, (value + 274877906944) % 274877906944)
			end

			--- Writes a 39 bit signed integer [-274877906944, 274877906943]
			function bitbuffer.writei39(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu39(b, byte, bit, (value + 549755813888) % 549755813888)
			end

			--- Writes a 40 bit signed integer [-549755813888, 549755813887]
			function bitbuffer.writei40(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu40(b, byte, bit, (value + 1099511627776) % 1099511627776)
			end

			--- Writes a 41 bit signed integer [-1099511627776, 1099511627775]
			function bitbuffer.writei41(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu41(b, byte, bit, (value + 2199023255552) % 2199023255552)
			end

			--- Writes a 42 bit signed integer [-2199023255552, 2199023255551]
			function bitbuffer.writei42(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu42(b, byte, bit, (value + 4398046511104) % 4398046511104)
			end

			--- Writes a 43 bit signed integer [-4398046511104, 4398046511103]
			function bitbuffer.writei43(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu43(b, byte, bit, (value + 8796093022208) % 8796093022208)
			end

			--- Writes a 44 bit signed integer [-8796093022208, 8796093022207]
			function bitbuffer.writei44(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu44(b, byte, bit, (value + 17592186044416) % 17592186044416)
			end

			--- Writes a 45 bit signed integer [-17592186044416, 17592186044415]
			function bitbuffer.writei45(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu45(b, byte, bit, (value + 35184372088832) % 35184372088832)
			end

			--- Writes a 46 bit signed integer [-35184372088832, 35184372088831]
			function bitbuffer.writei46(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu46(b, byte, bit, (value + 70368744177664) % 70368744177664)
			end

			--- Writes a 47 bit signed integer [-70368744177664, 70368744177663]
			function bitbuffer.writei47(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu47(b, byte, bit, (value + 140737488355328) % 140737488355328)
			end

			--- Writes a 48 bit signed integer [-140737488355328, 140737488355327]
			function bitbuffer.writei48(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu48(b, byte, bit, (value + 281474976710656) % 281474976710656)
			end

			--- Writes a 49 bit signed integer [-281474976710656, 281474976710655]
			function bitbuffer.writei49(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu49(b, byte, bit, (value + 562949953421312) % 562949953421312)
			end

			--- Writes a 50 bit signed integer [-562949953421312, 562949953421311]
			function bitbuffer.writei50(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu50(b, byte, bit, (value + 1125899906842624) % 1125899906842624)
			end

			--- Writes a 51 bit signed integer [-1125899906842624, 1125899906842623]
			function bitbuffer.writei51(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu51(b, byte, bit, (value + 2251799813685248) % 2251799813685248)
			end

			--- Writes a 52 bit signed integer [-2251799813685248, 2251799813685247]
			function bitbuffer.writei52(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu52(b, byte, bit, (value + 4503599627370496) % 4503599627370496)
			end

			--- Writes a 53 bit signed integer [-4503599627370496, 4503599627370495]
			--- (note this format doesn't match two's complement)
			function bitbuffer.writei53(b: buffer, byte: number, bit: number, value: number)
				bitbuffer.writeu53(b, byte, bit, value + 4503599627370496)
			end
		end
		do -- read
			--- Reads a 1 bit signed integer [-1, 0]
			function bitbuffer.readi1(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu1(b, byte, bit) + 1 ) % 2 - 1
			end

			--- Reads a 2 bit signed integer [-2, 1]
			function bitbuffer.readi2(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu2(b, byte, bit) + 2 ) % 4 - 2
			end

			--- Reads a 3 bit signed integer [-4, 3]
			function bitbuffer.readi3(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu3(b, byte, bit) + 4 ) % 8 - 4
			end

			--- Reads a 4 bit signed integer [-8, 7]
			function bitbuffer.readi4(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu4(b, byte, bit) + 8 ) % 16 - 8
			end

			--- Reads a 5 bit signed integer [-16, 15]
			function bitbuffer.readi5(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu5(b, byte, bit) + 16 ) % 32 - 16
			end

			--- Reads a 6 bit signed integer [-32, 31]
			function bitbuffer.readi6(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu6(b, byte, bit) + 32 ) % 64 - 32
			end

			--- Reads a 7 bit signed integer [-64, 63]
			function bitbuffer.readi7(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu7(b, byte, bit) + 64 ) % 128 - 64
			end

			--- Reads a 8 bit signed integer [-128, 127]
			function bitbuffer.readi8(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then ( bitbuffer.readu8(b, byte, bit) + 128 ) % 256 - 128
					else buffer.readi8(b, byte)
			end

			--- Reads a 9 bit signed integer [-256, 255]
			function bitbuffer.readi9(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu9(b, byte, bit) + 256 ) % 512 - 256
			end

			--- Reads a 10 bit signed integer [-512, 511]
			function bitbuffer.readi10(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu10(b, byte, bit) + 512 ) % 1024 - 512
			end

			--- Reads a 11 bit signed integer [-1024, 1023]
			function bitbuffer.readi11(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu11(b, byte, bit) + 1024 ) % 2048 - 1024
			end

			--- Reads a 12 bit signed integer [-2048, 2047]
			function bitbuffer.readi12(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu12(b, byte, bit) + 2048 ) % 4096 - 2048
			end

			--- Reads a 13 bit signed integer [-4096, 4095]
			function bitbuffer.readi13(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu13(b, byte, bit) + 4096 ) % 8192 - 4096
			end

			--- Reads a 14 bit signed integer [-8192, 8191]
			function bitbuffer.readi14(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu14(b, byte, bit) + 8192 ) % 16384 - 8192
			end

			--- Reads a 15 bit signed integer [-16384, 16383]
			function bitbuffer.readi15(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu15(b, byte, bit) + 16384 ) % 32768 - 16384
			end

			--- Reads a 16 bit signed integer [-32768, 32767]
			function bitbuffer.readi16(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then ( bitbuffer.readu16(b, byte, bit) + 32768 ) % 65536 - 32768
					else buffer.readi16(b, byte)
			end

			--- Reads a 17 bit signed integer [-65536, 65535]
			function bitbuffer.readi17(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu17(b, byte, bit) + 65536 ) % 131072 - 65536
			end

			--- Reads a 18 bit signed integer [-131072, 131071]
			function bitbuffer.readi18(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu18(b, byte, bit) + 131072 ) % 262144 - 131072
			end

			--- Reads a 19 bit signed integer [-262144, 262143]
			function bitbuffer.readi19(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu19(b, byte, bit) + 262144 ) % 524288 - 262144
			end

			--- Reads a 20 bit signed integer [-524288, 524287]
			function bitbuffer.readi20(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu20(b, byte, bit) + 524288 ) % 1048576 - 524288
			end

			--- Reads a 21 bit signed integer [-1048576, 1048575]
			function bitbuffer.readi21(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu21(b, byte, bit) + 1048576 ) % 2097152 - 1048576
			end

			--- Reads a 22 bit signed integer [-2097152, 2097151]
			function bitbuffer.readi22(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu22(b, byte, bit) + 2097152 ) % 4194304 - 2097152
			end

			--- Reads a 23 bit signed integer [-4194304, 4194303]
			function bitbuffer.readi23(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu23(b, byte, bit) + 4194304 ) % 8388608 - 4194304
			end

			--- Reads a 24 bit signed integer [-8388608, 8388607]
			function bitbuffer.readi24(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu24(b, byte, bit) + 8388608 ) % 16777216 - 8388608
			end

			--- Reads a 25 bit signed integer [-16777216, 16777215]
			function bitbuffer.readi25(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu25(b, byte, bit) + 16777216 ) % 33554432 - 16777216
			end

			--- Reads a 26 bit signed integer [-33554432, 33554431]
			function bitbuffer.readi26(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu26(b, byte, bit) + 33554432 ) % 67108864 - 33554432
			end

			--- Reads a 27 bit signed integer [-67108864, 67108863]
			function bitbuffer.readi27(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu27(b, byte, bit) + 67108864 ) % 134217728 - 67108864
			end

			--- Reads a 28 bit signed integer [-134217728, 134217727]
			function bitbuffer.readi28(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu28(b, byte, bit) + 134217728 ) % 268435456 - 134217728
			end

			--- Reads a 29 bit signed integer [-268435456, 268435455]
			function bitbuffer.readi29(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu29(b, byte, bit) + 268435456 ) % 536870912 - 268435456
			end

			--- Reads a 30 bit signed integer [-536870912, 536870911]
			function bitbuffer.readi30(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu30(b, byte, bit) + 536870912 ) % 1073741824 - 536870912
			end

			--- Reads a 31 bit signed integer [-1073741824, 1073741823]
			function bitbuffer.readi31(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu31(b, byte, bit) + 1073741824 ) % 2147483648 - 1073741824
			end

			--- Reads a 32 bit signed integer [-2147483648, 2147483647]
			function bitbuffer.readi32(b: buffer, byte: number, bit: number): number
				return if bit > 0
					then ( bitbuffer.readu32(b, byte, bit) + 2147483648 ) % 4294967296 - 2147483648
					else buffer.readi32(b, byte)
			end

			--- Reads a 33 bit signed integer [-4294967296, 4294967295]
			function bitbuffer.readi33(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu33(b, byte, bit) + 4294967296 ) % 8589934592 - 4294967296
			end

			--- Reads a 34 bit signed integer [-8589934592, 8589934591]
			function bitbuffer.readi34(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu34(b, byte, bit) + 8589934592 ) % 17179869184 - 8589934592
			end

			--- Reads a 35 bit signed integer [-17179869184, 17179869183]
			function bitbuffer.readi35(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu35(b, byte, bit) + 17179869184 ) % 34359738368 - 17179869184
			end

			--- Reads a 36 bit signed integer [-34359738368, 34359738367]
			function bitbuffer.readi36(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu36(b, byte, bit) + 34359738368 ) % 68719476736 - 34359738368
			end

			--- Reads a 37 bit signed integer [-68719476736, 68719476735]
			function bitbuffer.readi37(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu37(b, byte, bit) + 68719476736 ) % 137438953472 - 68719476736
			end

			--- Reads a 38 bit signed integer [-137438953472, 137438953471]
			function bitbuffer.readi38(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu38(b, byte, bit) + 137438953472 ) % 274877906944 - 137438953472
			end

			--- Reads a 39 bit signed integer [-274877906944, 274877906943]
			function bitbuffer.readi39(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu39(b, byte, bit) + 274877906944 ) % 549755813888 - 274877906944
			end

			--- Reads a 40 bit signed integer [-549755813888, 549755813887]
			function bitbuffer.readi40(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu40(b, byte, bit) + 549755813888 ) % 1099511627776 - 549755813888
			end

			--- Reads a 41 bit signed integer [-1099511627776, 1099511627775]
			function bitbuffer.readi41(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu41(b, byte, bit) + 1099511627776 ) % 2199023255552 - 1099511627776
			end

			--- Reads a 42 bit signed integer [-2199023255552, 2199023255551]
			function bitbuffer.readi42(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu42(b, byte, bit) + 2199023255552 ) % 4398046511104 - 2199023255552
			end

			--- Reads a 43 bit signed integer [-4398046511104, 4398046511103]
			function bitbuffer.readi43(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu43(b, byte, bit) + 4398046511104 ) % 8796093022208 - 4398046511104
			end

			--- Reads a 44 bit signed integer [-8796093022208, 8796093022207]
			function bitbuffer.readi44(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu44(b, byte, bit) + 8796093022208 ) % 17592186044416 - 8796093022208
			end

			--- Reads a 45 bit signed integer [-17592186044416, 17592186044415]
			function bitbuffer.readi45(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu45(b, byte, bit) + 17592186044416 ) % 35184372088832 - 17592186044416
			end

			--- Reads a 46 bit signed integer [-35184372088832, 35184372088831]
			function bitbuffer.readi46(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu46(b, byte, bit) + 35184372088832 ) % 70368744177664 - 35184372088832
			end

			--- Reads a 47 bit signed integer [-70368744177664, 70368744177663]
			function bitbuffer.readi47(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu47(b, byte, bit) + 70368744177664 ) % 140737488355328 - 70368744177664
			end

			--- Reads a 48 bit signed integer [-140737488355328, 140737488355327]
			function bitbuffer.readi48(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu48(b, byte, bit) + 140737488355328 ) % 281474976710656 - 140737488355328
			end

			--- Reads a 49 bit signed integer [-281474976710656, 281474976710655]
			function bitbuffer.readi49(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu49(b, byte, bit) + 281474976710656 ) % 562949953421312 - 281474976710656
			end

			--- Reads a 50 bit signed integer [-562949953421312, 562949953421311]
			function bitbuffer.readi50(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu50(b, byte, bit) + 562949953421312 ) % 1125899906842624 - 562949953421312
			end

			--- Reads a 51 bit signed integer [-1125899906842624, 1125899906842623]
			function bitbuffer.readi51(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu51(b, byte, bit) + 1125899906842624 ) % 2251799813685248 - 1125899906842624
			end

			--- Reads a 52 bit signed integer [-2251799813685248, 2251799813685247]
			function bitbuffer.readi52(b: buffer, byte: number, bit: number): number
				return ( bitbuffer.readu52(b, byte, bit) + 2251799813685248 ) % 4503599627370496 - 2251799813685248
			end

			--- Reads a 53 bit signed integer [-4503599627370496, 4503599627370495]
			--- (note this format doesn't match two's complement)
			function bitbuffer.readi53(b: buffer, byte: number, bit: number): number
				return bitbuffer.readu53(b, byte, bit) - 4503599627370496
			end
		end
		bitbuffer.readi = { bitbuffer.readi1, bitbuffer.readi2, bitbuffer.readi3, bitbuffer.readi4, bitbuffer.readi5, bitbuffer.readi6, bitbuffer.readi7, bitbuffer.readi8, bitbuffer.readi9, bitbuffer.readi10, bitbuffer.readi11, bitbuffer.readi12, bitbuffer.readi13, bitbuffer.readi14, bitbuffer.readi15, bitbuffer.readi16, bitbuffer.readi17, bitbuffer.readi18, bitbuffer.readi19, bitbuffer.readi20, bitbuffer.readi21, bitbuffer.readi22, bitbuffer.readi23, bitbuffer.readi24, bitbuffer.readi25, bitbuffer.readi26, bitbuffer.readi27, bitbuffer.readi28, bitbuffer.readi29, bitbuffer.readi30, bitbuffer.readi31, bitbuffer.readi32, bitbuffer.readi33, bitbuffer.readi34, bitbuffer.readi35, bitbuffer.readi36, bitbuffer.readi37, bitbuffer.readi38, bitbuffer.readi39, bitbuffer.readi40, bitbuffer.readi41, bitbuffer.readi42, bitbuffer.readi43, bitbuffer.readi44, bitbuffer.readi45, bitbuffer.readi46, bitbuffer.readi47, bitbuffer.readi48, bitbuffer.readi49, bitbuffer.readi50, bitbuffer.readi51, bitbuffer.readi52, bitbuffer.readi53 }
		bitbuffer.writei = { bitbuffer.writei1, bitbuffer.writei2, bitbuffer.writei3, bitbuffer.writei4, bitbuffer.writei5, bitbuffer.writei6, bitbuffer.writei7, bitbuffer.writei8, bitbuffer.writei9, bitbuffer.writei10, bitbuffer.writei11, bitbuffer.writei12, bitbuffer.writei13, bitbuffer.writei14, bitbuffer.writei15, bitbuffer.writei16, bitbuffer.writei17, bitbuffer.writei18, bitbuffer.writei19, bitbuffer.writei20, bitbuffer.writei21, bitbuffer.writei22, bitbuffer.writei23, bitbuffer.writei24, bitbuffer.writei25, bitbuffer.writei26, bitbuffer.writei27, bitbuffer.writei28, bitbuffer.writei29, bitbuffer.writei30, bitbuffer.writei31, bitbuffer.writei32, bitbuffer.writei33, bitbuffer.writei34, bitbuffer.writei35, bitbuffer.writei36, bitbuffer.writei37, bitbuffer.writei38, bitbuffer.writei39, bitbuffer.writei40, bitbuffer.writei41, bitbuffer.writei42, bitbuffer.writei43, bitbuffer.writei44, bitbuffer.writei45, bitbuffer.writei46, bitbuffer.writei47, bitbuffer.writei48, bitbuffer.writei49, bitbuffer.writei50, bitbuffer.writei51, bitbuffer.writei52, bitbuffer.writei53 }
	end

	do -- float
		do -- write
			--- Writes a half-precision IEEE 754 number
			function bitbuffer.writef16(b: buffer, byte: number, bit: number, value: number)
				local mantissa, exponent, sign = 0, 0, 0
				if math.abs(value) > 65504 then
					exponent, sign = 0b11111, if value < 0 then 0x8000 else 0
				elseif value ~= value then
					mantissa, exponent, sign = 1, 0b11111, 0x8000
				elseif value ~= 0 then
					local absValue = math.abs(value)
					local interval = math.ldexp(1, math.floor(math.log(absValue, 2)) - 10)
					absValue = math.floor(absValue / interval) * interval

					mantissa, exponent = math.frexp(absValue)
					exponent += 14

					mantissa = math.round(if exponent <= 0
						then mantissa * 0x400 / math.ldexp(1, math.abs(exponent))
						else mantissa * 0x800)
					exponent = math.max(exponent, 0)
					sign = if value < 0 then 0x8000 else 0
				end

				bitbuffer.writeu16(b, byte, bit, mantissa % 0x400
					+ exponent * 0x400
					+ sign)
			end
			--- Writes a single-precision IEEE 754 number
			function bitbuffer.writef32(b: buffer, byte: number, bit: number, value: number)
				if bit == 0 then
					buffer.writef32(b, byte, value)
					return
				end

				local mantissa, exponent, sign = 0, 0, 0
				if math.abs(value) > 3.4028234663852886e+38 then
					exponent, sign = 0b11111111, if value < 0 then 0x80000000 else 0
				elseif value ~= value then
					mantissa, exponent, sign = 1, 0b11111111, 0x80000000
				elseif value ~= 0 then
					local absValue = math.abs(value)
					local interval = math.ldexp(1, math.floor(math.log(absValue, 2)) - 23)
					absValue = math.floor(absValue / interval) * interval

					mantissa, exponent = math.frexp(absValue)
					exponent += 126

					mantissa = math.round(if exponent <= 0
						then mantissa * 0x800000 / math.ldexp(1, math.abs(exponent))
						else mantissa * 0x1000000)
					exponent = math.max(exponent, 0)
					sign = if value < 0 then 0x80000000 else 0
				end

				bitbuffer.writeu32(b, byte, bit, mantissa % 0x800000
					+ exponent * 0x800000
					+ sign)
			end
			--- Writes a double-precision IEEE 754 number
			function bitbuffer.writef64(b: buffer, byte: number, bit: number, value: number)
				if bit == 0 then
					buffer.writef64(b, byte, value)
					return
				end

				local mantissa, exponent, sign = 0, 0, 0
				if math.abs(value) >= math.huge then
					exponent, sign = 0b11111111111, if value < 0 then 0x80000000 else 0
				elseif value ~= value then
					mantissa, exponent, sign = 1, 0b11111111111, 0x80000000
				elseif value ~= 0 then
					local absValue = math.abs(value)
					mantissa, exponent = math.frexp(absValue)
					exponent += 1022

					mantissa = math.round(if exponent <= 0
						then mantissa * 0x10000000000000 / math.ldexp(1, math.abs(exponent))
						else mantissa * 0x20000000000000)
					exponent = math.max(exponent, 0)
					sign = if value < 0 then 0x80000000 else 0
				end

				bitbuffer.writeu32(b, byte, bit, mantissa % 0x100000000)
				bitbuffer.writeu32(b, byte + 4, bit, mantissa // 0x100000000 % 0x100000
					+ exponent * 0x100000
					+ sign)
			end
		end
		do -- read
			--- Reads a half-precision IEEE 754 number
			function bitbuffer.readf16(b: buffer, byte: number, bit: number): number
				local uintForm = bitbuffer.readu16(b, byte, bit)
				local exponent_mantissa = uintForm % 0x8000

				if exponent_mantissa == 0b11111_0000000000 then
					return if uintForm // 0x8000 == 1 then -math.huge else math.huge
				elseif exponent_mantissa == 0b11111_0000000001 then
					return 0 / 0
				elseif exponent_mantissa == 0b00000_0000000000 then
					return 0
				else
					local mantissa = exponent_mantissa % 0x400
					local exponent = exponent_mantissa // 0x400
					local sign = uintForm // 0x8000 == 1
					mantissa = if exponent == 0
						then mantissa / 0x400
						else mantissa / 0x800 + 0.5
					
					local value = math.ldexp(mantissa, exponent - 14)
					return if sign then -value else value
				end
			end

			--- Reads a single-precision IEEE 754 number
			function bitbuffer.readf32(b: buffer, byte: number, bit: number): number
				if bit == 0 then
					return buffer.readf32(b, byte)
				end

				local uintForm = bitbuffer.readu32(b, byte, bit)
				local exponent_mantissa = uintForm % 0x80000000

				if exponent_mantissa == 0b11111111_00000000000000000000000 then
					return if uintForm // 0x80000000 == 1 then -math.huge else math.huge
				elseif exponent_mantissa == 0b11111111_00000000000000000000001 then
					return 0 / 0
				elseif exponent_mantissa == 0b00000000_00000000000000000000000 then
					return 0
				else
					local mantissa = exponent_mantissa % 0x800000
					local exponent = exponent_mantissa // 0x800000
					local sign = uintForm // 0x80000000 == 1
					mantissa = if exponent == 0
						then mantissa / 0x800000
						else mantissa / 0x1000000 + 0.5
					
					local value = math.ldexp(mantissa, exponent - 126)
					return if sign then -value else value
				end
			end

			--- Reads a double-precision IEEE 754 number
			function bitbuffer.readf64(b: buffer, byte: number, bit: number): number
				if bit == 0 then
					return buffer.readf64(b, byte)
				end

				local mantissa = bitbuffer.readu52(b, byte, bit)
				local offset = byte * 8 + bit + 52
				local exponent = bitbuffer.readu11(b, offset // 8, offset % 8)
				offset += 11
				local sign = bitbuffer.readu1(b, offset // 8, offset % 8) == 1
				
				if mantissa == 0 and exponent == 11111111111 then
					return if sign then -math.huge else math.huge
				elseif mantissa == 1 and exponent == 11111111111 then
					return 0 / 0
				elseif mantissa == 0 and exponent == 0 then
					return 0
				else
					mantissa = if exponent == 0
						then mantissa / 0x10000000000000
						else mantissa / 0x20000000000000 + 0.5
					
					local value = math.ldexp(mantissa, exponent - 1022)
					return if sign then -value else value
				end
			end
		end
	end

	do -- string
		--- Used to read a string of length ‘count’ from the buffer at specified offset.
		function bitbuffer.readstring(b: buffer, byte: number, bit: number, count: number): string
			if bit == 0 then
				return buffer.readstring(b, byte, count)
			else
				local output = buffer.create(count)
				bitbuffer.copy(output, 0, 0, b, byte, bit, count * 8)
				return buffer.tostring(output)
			end
		end

		--[=[
			Used to write data from a string into the buffer at a specified offset.

			If an optional ‘count’ is specified, only ‘count’ bytes are taken from the string.

			Count cannot be larger than the string length.
		]=]
		function bitbuffer.writestring(b: buffer, byte: number, bit: number, value: string, count: number?)
			if bit == 0 then
				buffer.writestring(b, byte, value, count)
			else
				local input = buffer.fromstring(value)
				bitbuffer.copy(b, byte, bit, input, 0, 0, ( count or #value ) * 8)
			end
		end
	end

	do -- other
		local POWERS_OF_TWO = { [0] = 1, [1] = 2, [2] = 4, [3] = 8, [4] = 16, [5] = 32, [6] = 64, [7] = 128, [8] = 256 }

		--[=[
			Sets the `count` bits in the buffer starting at the specified ‘offset’ to the ‘value’.

			If `count` is ‘nil’ or is omitted, all bytes from the specified offset until the end of the buffer are set.
		]=]
		function bitbuffer.fill(b: buffer, byte: number, bit: number, value: number, count: number?)
			local count: number = count or (buffer.len(b) - byte) * 8 - bit

			if bit == 0 and count % 8 == 0 then
				buffer.fill(b, byte, value, count // 8)
			elseif count <= 8 then
				bitbuffer.writeu[count](b, byte, bit, value)
			elseif count <= 53 and (value == 0 or value == 255) then
				bitbuffer.writeu[count](b, byte, bit, if value == 255 then 2 ^ count - 1 else 0)
			else
				local preWidth = 8 - bit
				local postWidth = (count + bit) % 8

				local mid = value
				if value ~= 0 and value ~= 255 then
					local a = POWERS_OF_TWO[preWidth]
					mid = (value // a) + (value % a * POWERS_OF_TWO[bit]) -- i.e., ABCDE-FGH -> FGH-ABCDE when `bit` is `3`
				end

				bitbuffer.writeu8(b, byte, bit, value) -- writing a static width of 8 rather than a variable width of `preWidth` is faster (we overwrite the extra bits written later)
				byte += 1 -- bit is also 0 now, but we don't need to set it since we no longer use the variable

				local midWidthBytes = (count - preWidth) // 8
				if midWidthBytes > 0 then
					buffer.fill(b, byte, mid, midWidthBytes)
					byte += midWidthBytes
				end

				if postWidth > 0 then
					bitbuffer.writeu[postWidth](b, byte, 0, mid)
				end
			end
		end

		--[=[
			Copy `count` bytes from ‘source’ starting at offset ‘sourceOffset’ into the ‘target’ at ‘targetOffset’.

			Unlike `buffer.copy`, it is not possible for ‘source’ and ‘target’ to be the same and then copy an overlapping region. This may be added in future.

			If ‘sourceOffset’ is nil or is omitted, it defaults to 0.

			If `count` is ‘nil’ or is omitted, the whole ‘source’ data starting from ‘sourceOffset’ is copied.
		]=]
		function bitbuffer.copy(
			target: buffer,
			targetByte: number,
			targetBit: number,
			source: buffer,
			sourceByte: number?,
			sourceBit: number?,
			count: number?
		)
			local count = count or (buffer.len(source) - targetByte) * 8 - targetBit
			local sourceByte = sourceByte or 0
			local sourceBit = sourceBit or 0

			if targetBit == 0 and sourceBit == 0 and count % 8 == 0 then
				buffer.copy(target, targetByte, source, sourceByte, count // 8)
			elseif count <= 53 then
				local value = bitbuffer.readu[count](source, sourceByte, sourceBit)
				bitbuffer.writeu[count](target, targetByte, targetBit, value)
			elseif targetBit == sourceBit then
				local preWidth = 8 - targetBit
				local postWidth = (count + targetBit) % 8

				local value = bitbuffer.readu8(source, sourceByte, sourceBit)
				bitbuffer.writeu8(target, targetByte, targetBit, value)

				local midWidthBytes = (count - preWidth) // 8
				if midWidthBytes > 0 then
					buffer.copy(target, targetByte + 1, source, sourceByte + 1, midWidthBytes)
				end

				if postWidth > 0 then
					local value = bitbuffer.readu[postWidth](source, sourceByte + 1 + midWidthBytes, 0)
					bitbuffer.writeu[postWidth](target, targetByte + 1 + midWidthBytes, 0, value)
				end
			else
				local preWidth = 8 - targetBit

				local value = bitbuffer.readu8(source, sourceByte, sourceBit)
				bitbuffer.writeu8(target, targetByte, targetBit, value)

				local alignedCount = (count - preWidth) // 8
				local chunkCount = alignedCount // 6

				-- Increment the `byte` and `bit` by `preWidth`
				sourceBit += preWidth
				if sourceBit >= 8 then
					sourceByte += 1
					sourceBit -= 8
				end

				-- `targetBit` is implicitly 0
				targetByte += 1

				for _ = 1, chunkCount do
					local value = bit32.extract(buffer.readu32(source, sourceByte), sourceBit, 24)
						+ bit32.extract(buffer.readu32(source, sourceByte + 3), sourceBit, 24) * 0x1000000

					buffer.writeu32(target, targetByte, value)
					buffer.writeu16(target, targetByte + 4, value // 0x100000000)

					sourceByte += 6
					targetByte += 6
				end

				local overflow = count - preWidth - chunkCount * 48
				if overflow > 0 then
					local value = bitbuffer.readu[overflow](source, sourceByte, sourceBit)
					bitbuffer.writeu[overflow](target, targetByte, 0, value)
				end
			end
		end
	end

	do -- base conversion
		local NUMBER_TO_BASE64 = buffer.fromstring("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
		local BASE64_TO_NUMBER = {}

		local CHARACTER_TO_BINARY = {}
		local BINARY_TO_NUMBER = {}

		local CHARACTER_TO_HEXADECIMAL = {}
		local HEXADECIMAL_TO_NUMBER = {}

		for index = 0, 255 do
			local binary = table.create(8)
			for field = 0, 7 do
				binary[field + 1] = bit32.extract(index, field, 1)
			end

			local binaryString = table.concat(binary)
			local hexadecimalString = string.format("%02x", index)

			local char = string.char(index)

			CHARACTER_TO_BINARY[char] = binaryString
			BINARY_TO_NUMBER[binaryString] = index

			CHARACTER_TO_HEXADECIMAL[char] = hexadecimalString
			HEXADECIMAL_TO_NUMBER[hexadecimalString] = index
		end

		for index = 0, 63 do
			BASE64_TO_NUMBER[buffer.readu8(NUMBER_TO_BASE64, index)] = index
		end

		local function baseLookupGenerator(default: { [string]: string })
			local cache = { [""] = default }

			return function(separator: string): { [string]: string }
				if cache[separator] then
					return cache[separator]
				end

				local lookupTable = {}
				for index = 0, 255 do
					local char = string.char(index)
					lookupTable[char] = default[char] .. separator
				end

				cache[separator] = lookupTable
				return lookupTable
			end
		end

		do -- binary
			local getLookup = baseLookupGenerator(CHARACTER_TO_BINARY)

			--[=[
				@function tobinary
				@within bitbuffer

				Returns the buffer data as a 'binary' string, mainly useful for debugging.

				@param b buffer
				@param separator string -- the separator characters to use between bytes

				@return string
			]=]
			function bitbuffer.tobinary(b: buffer, separator: string?): string
				local separatorLength = if separator then #separator else 0
				local lookupTable = getLookup(separator or "")

				local str = buffer.tostring(b):gsub(".", lookupTable)
				return str:sub(1, -1 - separatorLength)
			end

			--[=[
				@function frombinary
				@within bitbuffer

				Creates a buffer initialized to the contents of the 'binary' string.

				@param str string
				@param separator string -- the separator characters to use between bytes

				@return buffer
			]=]
			function bitbuffer.frombinary(str: string, separator: string?)
				local separatorLength = if separator then #separator else 0

				local codeLength = 8 + separatorLength
				local b = buffer.create((#str + separatorLength) / codeLength)

				local offset = 0
				for index = 1, #str, codeLength do
					local code = str:sub(index, index + 7)
					buffer.writeu8(b, offset, BINARY_TO_NUMBER[code])
					offset += 1
				end

				return b
			end
		end

		do -- hexadecimal
			local getLookup = baseLookupGenerator(CHARACTER_TO_HEXADECIMAL)

			--[=[
				@function tobinary
				@within bitbuffer

				Returns the buffer data as a hexadecimal string, mainly useful for debugging.

				@param b buffer
				@param separator string -- the separator characters to use between bytes

				@return string
			]=]
			function bitbuffer.tohexadecimal(b: buffer, separator: string?): string
				local separatorLength = if separator then #separator else 0
				local lookupTable = getLookup(separator or "")

				local str = buffer.tostring(b):gsub(".", lookupTable)
				return str:sub(1, -1 - separatorLength)
			end

			--[=[
				@function fromhexadecimal
				@within bitbuffer

				Creates a buffer initialized to the contents of the hexadecimal string.

				@param str string
				@param separator string -- the separator characters to use between bytes

				@return buffer
			]=]
			function bitbuffer.fromhexadecimal(str: string, separator: string?)
				local separatorLength = if separator then #separator else 0

				local codeLength = 2 + separatorLength
				local b = buffer.create((#str + separatorLength) / codeLength)

				local offset = 0
				for index = 1, #str, codeLength do
					local code = str:sub(index, index + 1)
					buffer.writeu8(b, offset, HEXADECIMAL_TO_NUMBER[code])
					offset += 1
				end

				return b
			end
		end

		do -- base64
			local function flipu16(value: number): number
				return (value // 256) -- FF00 -> 00FF
					+ (value % 256 * 256) -- 00FF -> FF00
			end

			--[=[
				@function tobase64
				@within bitbuffer

				Returns the buffer data as a base64 encoded string.

				@param b buffer
				@return string
			]=]
			function bitbuffer.tobase64(b: buffer): string
				local bufferLength = buffer.len(b)
				local bitCount = bufferLength * 8

				local paddingLength = 2 - (bufferLength - 1) % (2 + 1)
				local characterCount = math.ceil(bitCount / 6)

				local endOffset = (characterCount - 1) * 6
				local overhang = bitCount - endOffset

				local output = buffer.create(characterCount + paddingLength)
				local outputIndex = 0

				for offset = 0, endOffset - overhang, 6 do
					local byte, bit = offset // 8, offset % 8
					local byteWidth = (bit + 13) // 8
					bit = (byteWidth * 8 - 6) - bit

					local focus = if byteWidth == 1 then buffer.readu8(b, byte) else flipu16(buffer.readu16(b, byte))
					local code = bit32.extract(focus, bit, 6)

					buffer.writeu8(output, outputIndex, buffer.readu8(NUMBER_TO_BASE64, code))
					outputIndex += 1
				end

				if overhang > 0 then
					local byte, bit = endOffset // 8, (8 - overhang) - endOffset % 8

					local focus = buffer.readu8(b, byte)
					local code = bit32.lshift(bit32.extract(focus, bit, overhang), 6 - overhang)

					buffer.writeu8(output, outputIndex, buffer.readu8(NUMBER_TO_BASE64, code))
				end

				buffer.fill(output, characterCount, 61, paddingLength) -- '='
				return buffer.tostring(output)
			end

			--[=[
				@function frombase64
				@within bitbuffer

				Creates a buffer initialized to the contents of the base64 encoded string.

				@param str string
				@return buffer
			]=]
			function bitbuffer.frombase64(str: string)
				local paddingStart, paddingEnd = string.find(str, "=*$")
				local padding = (paddingEnd :: any) - (paddingStart :: any) + 1

				local codeCount = #str - padding
				local bitCount = (codeCount * 6) - (padding * 2)

				local endOffset = bitCount // 6 * 6
				local overhang = bitCount - endOffset

				local output = buffer.create(bitCount // 8)

				local inputIndex = 1
				for outputOffset = 0, endOffset - 6, 6 do
					local byte, bit = outputOffset // 8, outputOffset % 8
					local byteWidth = (bit + 13) // 8
					bit = (byteWidth * 8 - 6) - bit

					local code = BASE64_TO_NUMBER[str:byte(inputIndex)]
					if byteWidth == 2 then
						buffer.writeu16(output, byte, flipu16(bit32.replace(flipu16(buffer.readu16(output, byte)), code, bit, 6)))
					else
						buffer.writeu8(output, byte, bit32.replace(buffer.readu8(output, byte), code, bit, 6))
					end

					inputIndex += 1
				end

				if overhang > 0 then
					local byte, bit = endOffset // 8, (8 - overhang) - endOffset % 8
					local code = bit32.rshift(BASE64_TO_NUMBER[str:byte(inputIndex)], 6 - overhang)

					buffer.writeu8(output, byte, bit32.replace(buffer.readu8(output, byte), code, bit, overhang))
				end

				return output
			end
		end

	end
end

do -- editors
	do -- offset
		local Offset = {}
		Offset.__index = Offset

		function bitbuffer.offset(byte: number?, bit: number?)
			local self = {}
			self.__index = self

			if byte and bit then
				self.byte, self.bit = byte, bit
			elseif byte then
				self.byte, self.bit = byte // 8, byte % 8
			else
				self.byte, self.bit = 0, 0
			end

			return setmetatable(self, Offset)
		end

		function Offset:SetOffset(byte: number, bit: number?)
			if bit then
				self.byte = byte
				self.bit = bit
			else
				self.byte = byte // 8
				self.bit = byte % 8
			end
		end

		function Offset:IncrementOffset(byte: number, bit: number?)
			if bit == nil then
				byte, bit = byte // 8, byte % 8
			end

			if bit == 0 then
				self.byte += byte
			else
				self.bit += bit
				if self.bit >= 8 then
					self.byte += byte + self.bit // 8
					self.bit %= 8
				else
					self.byte += byte
				end
			end
		end

		function Offset:Align()
			if self._bit > 0 then
				self._byte += 1
				self._bit = 0
			end
		end
	end

	do -- reader & writer
		local RAD_90, RAD_180 = math.rad(90), math.rad(180)

		local CFRAME_SPECIAL_CASES = if CFrame then {
			CFrame.Angles(0, 0, 0),
			CFrame.Angles(RAD_90, 0, 0),
			CFrame.Angles(0, RAD_180, RAD_180),
			CFrame.Angles(-RAD_90, 0, 0),
			CFrame.Angles(0, RAD_180, RAD_90),
			CFrame.Angles(0, RAD_90, RAD_90),
			CFrame.Angles(0, 0, RAD_90),
			CFrame.Angles(0, -RAD_90, RAD_90),
			CFrame.Angles(-RAD_90, -RAD_90, 0),
			CFrame.Angles(0, -RAD_90, 0),
			CFrame.Angles(RAD_90, -RAD_90, 0),
			CFrame.Angles(0, RAD_90, RAD_180),
			CFrame.Angles(0, -RAD_90, RAD_180),
			CFrame.Angles(0, RAD_180, 0),
			CFrame.Angles(-RAD_90, math.rad(-180), 0),
			CFrame.Angles(0, 0, RAD_180),
			CFrame.Angles(RAD_90, RAD_180, 0),
			CFrame.Angles(0, 0, -RAD_90),
			CFrame.Angles(0, -RAD_90, -RAD_90),
			CFrame.Angles(0, math.rad(-180), -RAD_90),
			CFrame.Angles(0, RAD_90, -RAD_90),
			CFrame.Angles(RAD_90, RAD_90, 0),
			CFrame.Angles(0, RAD_90, 0),
			CFrame.Angles(-RAD_90, RAD_90, 0),
		} else nil

		do -- writer
			local Writer = bitbuffer.offset()

			function bitbuffer.writer(b: buffer)
				return setmetatable({
					buffer = b,
					byte = 0,
					bit = 0,
				}, Writer)
			end

			function Writer:UInt1(value: number)
				bitbuffer.writeu1(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 1)
			end

			function Writer:UInt2(value: number)
				bitbuffer.writeu2(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 2)
			end

			function Writer:UInt3(value: number)
				bitbuffer.writeu3(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 3)
			end

			function Writer:UInt4(value: number)
				bitbuffer.writeu4(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 4)
			end

			function Writer:UInt5(value: number)
				bitbuffer.writeu5(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 5)
			end

			function Writer:UInt6(value: number)
				bitbuffer.writeu6(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 6)
			end

			function Writer:UInt7(value: number)
				bitbuffer.writeu7(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 7)
			end

			function Writer:UInt8(value: number)
				bitbuffer.writeu8(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 0)
			end

			function Writer:UInt9(value: number)
				bitbuffer.writeu9(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 1)
			end

			function Writer:UInt10(value: number)
				bitbuffer.writeu10(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 2)
			end

			function Writer:UInt11(value: number)
				bitbuffer.writeu11(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 3)
			end

			function Writer:UInt12(value: number)
				bitbuffer.writeu12(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 4)
			end

			function Writer:UInt13(value: number)
				bitbuffer.writeu13(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 5)
			end

			function Writer:UInt14(value: number)
				bitbuffer.writeu14(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 6)
			end

			function Writer:UInt15(value: number)
				bitbuffer.writeu15(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 7)
			end

			function Writer:UInt16(value: number)
				bitbuffer.writeu16(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 0)
			end

			function Writer:UInt17(value: number)
				bitbuffer.writeu17(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 1)
			end

			function Writer:UInt18(value: number)
				bitbuffer.writeu18(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 2)
			end

			function Writer:UInt19(value: number)
				bitbuffer.writeu19(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 3)
			end

			function Writer:UInt20(value: number)
				bitbuffer.writeu20(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 4)
			end

			function Writer:UInt21(value: number)
				bitbuffer.writeu21(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 5)
			end

			function Writer:UInt22(value: number)
				bitbuffer.writeu22(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 6)
			end

			function Writer:UInt23(value: number)
				bitbuffer.writeu23(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 7)
			end

			function Writer:UInt24(value: number)
				bitbuffer.writeu24(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 0)
			end

			function Writer:UInt25(value: number)
				bitbuffer.writeu25(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 1)
			end

			function Writer:UInt26(value: number)
				bitbuffer.writeu26(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 2)
			end

			function Writer:UInt27(value: number)
				bitbuffer.writeu27(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 3)
			end

			function Writer:UInt28(value: number)
				bitbuffer.writeu28(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 4)
			end

			function Writer:UInt29(value: number)
				bitbuffer.writeu29(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 5)
			end

			function Writer:UInt30(value: number)
				bitbuffer.writeu30(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 6)
			end

			function Writer:UInt31(value: number)
				bitbuffer.writeu31(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 7)
			end

			function Writer:UInt32(value: number)
				bitbuffer.writeu32(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 0)
			end

			function Writer:UInt33(value: number)
				bitbuffer.writeu33(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 1)
			end

			function Writer:UInt34(value: number)
				bitbuffer.writeu34(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 2)
			end

			function Writer:UInt35(value: number)
				bitbuffer.writeu35(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 3)
			end

			function Writer:UInt36(value: number)
				bitbuffer.writeu36(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 4)
			end

			function Writer:UInt37(value: number)
				bitbuffer.writeu37(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 5)
			end

			function Writer:UInt38(value: number)
				bitbuffer.writeu38(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 6)
			end

			function Writer:UInt39(value: number)
				bitbuffer.writeu39(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 7)
			end

			function Writer:UInt40(value: number)
				bitbuffer.writeu40(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 0)
			end

			function Writer:UInt41(value: number)
				bitbuffer.writeu41(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 1)
			end

			function Writer:UInt42(value: number)
				bitbuffer.writeu42(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 2)
			end

			function Writer:UInt43(value: number)
				bitbuffer.writeu43(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 3)
			end

			function Writer:UInt44(value: number)
				bitbuffer.writeu44(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 4)
			end

			function Writer:UInt45(value: number)
				bitbuffer.writeu45(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 5)
			end

			function Writer:UInt46(value: number)
				bitbuffer.writeu46(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 6)
			end

			function Writer:UInt47(value: number)
				bitbuffer.writeu47(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 7)
			end

			function Writer:UInt48(value: number)
				bitbuffer.writeu48(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 0)
			end

			function Writer:UInt49(value: number)
				bitbuffer.writeu49(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 1)
			end

			function Writer:UInt50(value: number)
				bitbuffer.writeu50(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 2)
			end

			function Writer:UInt51(value: number)
				bitbuffer.writeu51(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 3)
			end

			function Writer:UInt52(value: number)
				bitbuffer.writeu52(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 4)
			end

			function Writer:UInt53(value: number)
				bitbuffer.writeu53(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 5)
			end

			function Writer:Int1(value: number)
				bitbuffer.writei1(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 1)
			end

			function Writer:Int2(value: number)
				bitbuffer.writei2(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 2)
			end

			function Writer:Int3(value: number)
				bitbuffer.writei3(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 3)
			end

			function Writer:Int4(value: number)
				bitbuffer.writei4(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 4)
			end

			function Writer:Int5(value: number)
				bitbuffer.writei5(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 5)
			end

			function Writer:Int6(value: number)
				bitbuffer.writei6(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 6)
			end

			function Writer:Int7(value: number)
				bitbuffer.writei7(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(0, 7)
			end

			function Writer:Int8(value: number)
				bitbuffer.writei8(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 0)
			end

			function Writer:Int9(value: number)
				bitbuffer.writei9(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 1)
			end

			function Writer:Int10(value: number)
				bitbuffer.writei10(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 2)
			end

			function Writer:Int11(value: number)
				bitbuffer.writei11(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 3)
			end

			function Writer:Int12(value: number)
				bitbuffer.writei12(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 4)
			end

			function Writer:Int13(value: number)
				bitbuffer.writei13(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 5)
			end

			function Writer:Int14(value: number)
				bitbuffer.writei14(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 6)
			end

			function Writer:Int15(value: number)
				bitbuffer.writei15(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(1, 7)
			end

			function Writer:Int16(value: number)
				bitbuffer.writei16(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 0)
			end

			function Writer:Int17(value: number)
				bitbuffer.writei17(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 1)
			end

			function Writer:Int18(value: number)
				bitbuffer.writei18(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 2)
			end

			function Writer:Int19(value: number)
				bitbuffer.writei19(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 3)
			end

			function Writer:Int20(value: number)
				bitbuffer.writei20(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 4)
			end

			function Writer:Int21(value: number)
				bitbuffer.writei21(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 5)
			end

			function Writer:Int22(value: number)
				bitbuffer.writei22(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 6)
			end

			function Writer:Int23(value: number)
				bitbuffer.writei23(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 7)
			end

			function Writer:Int24(value: number)
				bitbuffer.writei24(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 0)
			end

			function Writer:Int25(value: number)
				bitbuffer.writei25(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 1)
			end

			function Writer:Int26(value: number)
				bitbuffer.writei26(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 2)
			end

			function Writer:Int27(value: number)
				bitbuffer.writei27(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 3)
			end

			function Writer:Int28(value: number)
				bitbuffer.writei28(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 4)
			end

			function Writer:Int29(value: number)
				bitbuffer.writei29(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 5)
			end

			function Writer:Int30(value: number)
				bitbuffer.writei30(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 6)
			end

			function Writer:Int31(value: number)
				bitbuffer.writei31(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(3, 7)
			end

			function Writer:Int32(value: number)
				bitbuffer.writei32(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 0)
			end

			function Writer:Int33(value: number)
				bitbuffer.writei33(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 1)
			end

			function Writer:Int34(value: number)
				bitbuffer.writei34(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 2)
			end

			function Writer:Int35(value: number)
				bitbuffer.writei35(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 3)
			end

			function Writer:Int36(value: number)
				bitbuffer.writei36(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 4)
			end

			function Writer:Int37(value: number)
				bitbuffer.writei37(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 5)
			end

			function Writer:Int38(value: number)
				bitbuffer.writei38(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 6)
			end

			function Writer:Int39(value: number)
				bitbuffer.writei39(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 7)
			end

			function Writer:Int40(value: number)
				bitbuffer.writei40(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 0)
			end

			function Writer:Int41(value: number)
				bitbuffer.writei41(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 1)
			end

			function Writer:Int42(value: number)
				bitbuffer.writei42(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 2)
			end

			function Writer:Int43(value: number)
				bitbuffer.writei43(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 3)
			end

			function Writer:Int44(value: number)
				bitbuffer.writei44(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 4)
			end

			function Writer:Int45(value: number)
				bitbuffer.writei45(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 5)
			end

			function Writer:Int46(value: number)
				bitbuffer.writei46(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 6)
			end

			function Writer:Int47(value: number)
				bitbuffer.writei47(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(5, 7)
			end

			function Writer:Int48(value: number)
				bitbuffer.writei48(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 0)
			end

			function Writer:Int49(value: number)
				bitbuffer.writei49(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 1)
			end

			function Writer:Int50(value: number)
				bitbuffer.writei50(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 2)
			end

			function Writer:Int51(value: number)
				bitbuffer.writei51(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 3)
			end

			function Writer:Int52(value: number)
				bitbuffer.writei52(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 4)
			end

			function Writer:Int53(value: number)
				bitbuffer.writei53(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(6, 5)
			end

			function Writer:Float16(value: number)
				bitbuffer.writef16(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(2, 0)
			end

			function Writer:Float32(value: number)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(4, 0)
			end

			function Writer:Float64(value: number)
				bitbuffer.writef64(self.buffer, self.byte, self.bit, value)
				self:IncrementOffset(8, 0)
			end

			function Writer:String(value: string)
				bitbuffer.writeu32(self.buffer, self.byte, self.bit, #value)
				bitbuffer.writestring(self.buffer, self.byte + 4, self.bit, value)
				self:IncrementOffset(4 + #value, 0)
			end

			function Writer:NumberSequence(value: NumberSequence)
				self:UInt5(#value.Keypoints) -- max length of 20, tested
				for _, keypoint in value.Keypoints do
					self:NumberSequenceKeypoint(keypoint)
				end
			end

			function Writer:ColorSequence(value: ColorSequence)
				self:UInt5(#value.Keypoints) -- max length of 20, tested
				for _, keypoint in value.Keypoints do
					self:ColorSequenceKeypoint(keypoint)
				end
			end

			function Writer:CFrame(value: CFrame)
				local specialCase = table.find(CFRAME_SPECIAL_CASES, value.Rotation) or 0
				self:UInt5(specialCase)

				self:Vector3(value.Position)
				if specialCase == 0 then
					local axis, angle = value:ToAxisAngle()
					self:Vector3(axis * angle)
				end
			end

			function Writer:Boolean(value: boolean)
				bitbuffer.writeu1(self.buffer, self.byte, self.bit, if value then 1 else 0)
				self:IncrementOffset(0, 1)
			end

			function Writer:LosslessCFrame(value: CFrame)
				local specialCase = table.find(CFRAME_SPECIAL_CASES, value.Rotation) or 0
				self:UInt5(specialCase)

				self:Vector3(value.Position)
				if specialCase == 0 then
					self:Vector3(value.XVector)
					self:Vector3(value.YVector)
					self:Vector3(value.ZVector)
				end
			end

			function Writer:NumberRange(value: NumberRange)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.Min)
				bitbuffer.writef32(self.buffer, self.byte + 4, self.bit, value.Max)
				self:IncrementOffset(8, 0)
			end

			function Writer:Vector3int16(value: Vector3int16)
				bitbuffer.writei16(self.buffer, self.byte, self.bit, value.X)
				bitbuffer.writei16(self.buffer, self.byte + 2, self.bit, value.Y)
				bitbuffer.writei16(self.buffer, self.byte + 4, self.bit, value.Z)
				self:IncrementOffset(6, 0)
			end

			function Writer:Vector2int16(value: Vector2int16)
				bitbuffer.writei16(self.buffer, self.byte, self.bit, value.X)
				bitbuffer.writei16(self.buffer, self.byte + 2, self.bit, value.Y)
				self:IncrementOffset(4, 0)
			end

			function Writer:UDim2(value: UDim2)
				self:UDim(value.X)
				self:UDim(value.Y)
			end

			function Writer:NumberSequenceKeypoint(value: NumberSequenceKeypoint)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.Time)
				bitbuffer.writef32(self.buffer, self.byte + 4, self.bit, value.Value)
				bitbuffer.writef32(self.buffer, self.byte + 8, self.bit, value.Envelope)
				self:IncrementOffset(12, 0)
			end

			function Writer:BrickColor(value: BrickColor)
				bitbuffer.writeu11(self.buffer, self.byte, self.bit, value.Number)
				self:IncrementOffset(1, 3)
			end

			function Writer:Vector2(value: Vector2)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.X)
				bitbuffer.writef32(self.buffer, self.byte + 4, self.bit, value.Y)
				self:IncrementOffset(8, 0)
			end

			function Writer:UDim(value: UDim)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.Scale)
				bitbuffer.writei32(self.buffer, self.byte + 4, self.bit, value.Offset)
				self:IncrementOffset(8, 0)
			end

			function Writer:Color3(value: Color3)
				bitbuffer.writeu8(self.buffer, self.byte, self.bit, math.floor(value.R * 255))
				bitbuffer.writeu8(self.buffer, self.byte + 1, self.bit, math.floor(value.G * 255))
				bitbuffer.writeu8(self.buffer, self.byte + 2, self.bit, math.floor(value.B * 255))
				self:IncrementOffset(3, 0)
			end

			function Writer:ColorSequenceKeypoint(value: ColorSequenceKeypoint)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.Time)
				self:IncrementOffset(4, 0)
				self:Color3(value.Value)
			end

			function Writer:Vector3(value: Vector3)
				bitbuffer.writef32(self.buffer, self.byte, self.bit, value.X)
				bitbuffer.writef32(self.buffer, self.byte + 4, self.bit, value.Y)
				bitbuffer.writef32(self.buffer, self.byte + 8, self.bit, value.Z)
				self:IncrementOffset(12, 0)
			end

		end

		do -- reader
			local Reader = bitbuffer.offset()

			function bitbuffer.reader(b: buffer)
				return setmetatable({
					buffer = b,
					byte = 0,
					bit = 0
				}, Reader)
			end

			function Reader:__index(index)
				return Reader[index] or bitbuffer.offset[index]
			end

			function Reader:UInt1(): number
				local value = bitbuffer.readu1(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 1)
				return value
			end

			function Reader:UInt2(): number
				local value = bitbuffer.readu2(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 2)
				return value
			end

			function Reader:UInt3(): number
				local value = bitbuffer.readu3(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 3)
				return value
			end

			function Reader:UInt4(): number
				local value = bitbuffer.readu4(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 4)
				return value
			end

			function Reader:UInt5(): number
				local value = bitbuffer.readu5(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 5)
				return value
			end

			function Reader:UInt6(): number
				local value = bitbuffer.readu6(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 6)
				return value
			end

			function Reader:UInt7(): number
				local value = bitbuffer.readu7(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 7)
				return value
			end

			function Reader:UInt8(): number
				local value = bitbuffer.readu8(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 0)
				return value
			end

			function Reader:UInt9(): number
				local value = bitbuffer.readu9(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 1)
				return value
			end

			function Reader:UInt10(): number
				local value = bitbuffer.readu10(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 2)
				return value
			end

			function Reader:UInt11(): number
				local value = bitbuffer.readu11(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 3)
				return value
			end

			function Reader:UInt12(): number
				local value = bitbuffer.readu12(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 4)
				return value
			end

			function Reader:UInt13(): number
				local value = bitbuffer.readu13(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 5)
				return value
			end

			function Reader:UInt14(): number
				local value = bitbuffer.readu14(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 6)
				return value
			end

			function Reader:UInt15(): number
				local value = bitbuffer.readu15(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 7)
				return value
			end

			function Reader:UInt16(): number
				local value = bitbuffer.readu16(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 0)
				return value
			end

			function Reader:UInt17(): number
				local value = bitbuffer.readu17(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 1)
				return value
			end

			function Reader:UInt18(): number
				local value = bitbuffer.readu18(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 2)
				return value
			end

			function Reader:UInt19(): number
				local value = bitbuffer.readu19(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 3)
				return value
			end

			function Reader:UInt20(): number
				local value = bitbuffer.readu20(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 4)
				return value
			end

			function Reader:UInt21(): number
				local value = bitbuffer.readu21(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 5)
				return value
			end

			function Reader:UInt22(): number
				local value = bitbuffer.readu22(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 6)
				return value
			end

			function Reader:UInt23(): number
				local value = bitbuffer.readu23(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 7)
				return value
			end

			function Reader:UInt24(): number
				local value = bitbuffer.readu24(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 0)
				return value
			end

			function Reader:UInt25(): number
				local value = bitbuffer.readu25(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 1)
				return value
			end

			function Reader:UInt26(): number
				local value = bitbuffer.readu26(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 2)
				return value
			end

			function Reader:UInt27(): number
				local value = bitbuffer.readu27(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 3)
				return value
			end

			function Reader:UInt28(): number
				local value = bitbuffer.readu28(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 4)
				return value
			end

			function Reader:UInt29(): number
				local value = bitbuffer.readu29(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 5)
				return value
			end

			function Reader:UInt30(): number
				local value = bitbuffer.readu30(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 6)
				return value
			end

			function Reader:UInt31(): number
				local value = bitbuffer.readu31(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 7)
				return value
			end

			function Reader:UInt32(): number
				local value = bitbuffer.readu32(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 0)
				return value
			end

			function Reader:UInt33(): number
				local value = bitbuffer.readu33(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 1)
				return value
			end

			function Reader:UInt34(): number
				local value = bitbuffer.readu34(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 2)
				return value
			end

			function Reader:UInt35(): number
				local value = bitbuffer.readu35(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 3)
				return value
			end

			function Reader:UInt36(): number
				local value = bitbuffer.readu36(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 4)
				return value
			end

			function Reader:UInt37(): number
				local value = bitbuffer.readu37(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 5)
				return value
			end

			function Reader:UInt38(): number
				local value = bitbuffer.readu38(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 6)
				return value
			end

			function Reader:UInt39(): number
				local value = bitbuffer.readu39(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 7)
				return value
			end

			function Reader:UInt40(): number
				local value = bitbuffer.readu40(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 0)
				return value
			end

			function Reader:UInt41(): number
				local value = bitbuffer.readu41(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 1)
				return value
			end

			function Reader:UInt42(): number
				local value = bitbuffer.readu42(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 2)
				return value
			end

			function Reader:UInt43(): number
				local value = bitbuffer.readu43(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 3)
				return value
			end

			function Reader:UInt44(): number
				local value = bitbuffer.readu44(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 4)
				return value
			end

			function Reader:UInt45(): number
				local value = bitbuffer.readu45(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 5)
				return value
			end

			function Reader:UInt46(): number
				local value = bitbuffer.readu46(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 6)
				return value
			end

			function Reader:UInt47(): number
				local value = bitbuffer.readu47(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 7)
				return value
			end

			function Reader:UInt48(): number
				local value = bitbuffer.readu48(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 0)
				return value
			end

			function Reader:UInt49(): number
				local value = bitbuffer.readu49(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 1)
				return value
			end

			function Reader:UInt50(): number
				local value = bitbuffer.readu50(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 2)
				return value
			end

			function Reader:UInt51(): number
				local value = bitbuffer.readu51(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 3)
				return value
			end

			function Reader:UInt52(): number
				local value = bitbuffer.readu52(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 4)
				return value
			end

			function Reader:UInt53(): number
				local value = bitbuffer.readu53(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 5)
				return value
			end

			function Reader:Int1(): number
				local value = bitbuffer.readi1(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 1)
				return value
			end

			function Reader:Int2(): number
				local value = bitbuffer.readi2(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 2)
				return value
			end

			function Reader:Int3(): number
				local value = bitbuffer.readi3(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 3)
				return value
			end

			function Reader:Int4(): number
				local value = bitbuffer.readi4(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 4)
				return value
			end

			function Reader:Int5(): number
				local value = bitbuffer.readi5(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 5)
				return value
			end

			function Reader:Int6(): number
				local value = bitbuffer.readi6(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 6)
				return value
			end

			function Reader:Int7(): number
				local value = bitbuffer.readi7(self.buffer, self.byte, self.bit)
				self:IncrementOffset(0, 7)
				return value
			end

			function Reader:Int8(): number
				local value = bitbuffer.readi8(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 0)
				return value
			end

			function Reader:Int9(): number
				local value = bitbuffer.readi9(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 1)
				return value
			end

			function Reader:Int10(): number
				local value = bitbuffer.readi10(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 2)
				return value
			end

			function Reader:Int11(): number
				local value = bitbuffer.readi11(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 3)
				return value
			end

			function Reader:Int12(): number
				local value = bitbuffer.readi12(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 4)
				return value
			end

			function Reader:Int13(): number
				local value = bitbuffer.readi13(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 5)
				return value
			end

			function Reader:Int14(): number
				local value = bitbuffer.readi14(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 6)
				return value
			end

			function Reader:Int15(): number
				local value = bitbuffer.readi15(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 7)
				return value
			end

			function Reader:Int16(): number
				local value = bitbuffer.readi16(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 0)
				return value
			end

			function Reader:Int17(): number
				local value = bitbuffer.readi17(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 1)
				return value
			end

			function Reader:Int18(): number
				local value = bitbuffer.readi18(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 2)
				return value
			end

			function Reader:Int19(): number
				local value = bitbuffer.readi19(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 3)
				return value
			end

			function Reader:Int20(): number
				local value = bitbuffer.readi20(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 4)
				return value
			end

			function Reader:Int21(): number
				local value = bitbuffer.readi21(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 5)
				return value
			end

			function Reader:Int22(): number
				local value = bitbuffer.readi22(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 6)
				return value
			end

			function Reader:Int23(): number
				local value = bitbuffer.readi23(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 7)
				return value
			end

			function Reader:Int24(): number
				local value = bitbuffer.readi24(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 0)
				return value
			end

			function Reader:Int25(): number
				local value = bitbuffer.readi25(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 1)
				return value
			end

			function Reader:Int26(): number
				local value = bitbuffer.readi26(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 2)
				return value
			end

			function Reader:Int27(): number
				local value = bitbuffer.readi27(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 3)
				return value
			end

			function Reader:Int28(): number
				local value = bitbuffer.readi28(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 4)
				return value
			end

			function Reader:Int29(): number
				local value = bitbuffer.readi29(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 5)
				return value
			end

			function Reader:Int30(): number
				local value = bitbuffer.readi30(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 6)
				return value
			end

			function Reader:Int31(): number
				local value = bitbuffer.readi31(self.buffer, self.byte, self.bit)
				self:IncrementOffset(3, 7)
				return value
			end

			function Reader:Int32(): number
				local value = bitbuffer.readi32(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 0)
				return value
			end

			function Reader:Int33(): number
				local value = bitbuffer.readi33(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 1)
				return value
			end

			function Reader:Int34(): number
				local value = bitbuffer.readi34(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 2)
				return value
			end

			function Reader:Int35(): number
				local value = bitbuffer.readi35(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 3)
				return value
			end

			function Reader:Int36(): number
				local value = bitbuffer.readi36(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 4)
				return value
			end

			function Reader:Int37(): number
				local value = bitbuffer.readi37(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 5)
				return value
			end

			function Reader:Int38(): number
				local value = bitbuffer.readi38(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 6)
				return value
			end

			function Reader:Int39(): number
				local value = bitbuffer.readi39(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 7)
				return value
			end

			function Reader:Int40(): number
				local value = bitbuffer.readi40(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 0)
				return value
			end

			function Reader:Int41(): number
				local value = bitbuffer.readi41(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 1)
				return value
			end

			function Reader:Int42(): number
				local value = bitbuffer.readi42(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 2)
				return value
			end

			function Reader:Int43(): number
				local value = bitbuffer.readi43(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 3)
				return value
			end

			function Reader:Int44(): number
				local value = bitbuffer.readi44(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 4)
				return value
			end

			function Reader:Int45(): number
				local value = bitbuffer.readi45(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 5)
				return value
			end

			function Reader:Int46(): number
				local value = bitbuffer.readi46(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 6)
				return value
			end

			function Reader:Int47(): number
				local value = bitbuffer.readi47(self.buffer, self.byte, self.bit)
				self:IncrementOffset(5, 7)
				return value
			end

			function Reader:Int48(): number
				local value = bitbuffer.readi48(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 0)
				return value
			end

			function Reader:Int49(): number
				local value = bitbuffer.readi49(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 1)
				return value
			end

			function Reader:Int50(): number
				local value = bitbuffer.readi50(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 2)
				return value
			end

			function Reader:Int51(): number
				local value = bitbuffer.readi51(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 3)
				return value
			end

			function Reader:Int52(): number
				local value = bitbuffer.readi52(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 4)
				return value
			end

			function Reader:Int53(): number
				local value = bitbuffer.readi53(self.buffer, self.byte, self.bit)
				self:IncrementOffset(6, 5)
				return value
			end

			function Reader:Float16(): number
				local value = bitbuffer.readf16(self.buffer, self.byte, self.bit)
				self:IncrementOffset(2, 0)
				return value
			end

			function Reader:Float32(): number
				local value = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 0)
				return value
			end

			function Reader:Float64(): number
				local value = bitbuffer.readf64(self.buffer, self.byte, self.bit)
				self:IncrementOffset(8, 0)
				return value
			end

			function Reader:String(): string
				local length = bitbuffer.readu32(self.buffer, self.byte, self.bit)
				local value = bitbuffer.readstring(self.buffer, self.byte + 4, self.bit, length)
				self:IncrementOffset(4 + length, 0)
				return value
			end

			function Reader:NumberSequence(): NumberSequence
				local length = self:UInt5() -- max length of 20, tested
				local keypoints = table.create(length)

				for _ = 1, length do
					local keypoint = self:NumberSequenceKeypoint()
					table.insert(keypoints, keypoint)
				end

				return NumberSequence.new(keypoints)
			end

			function Reader:ColorSequence(): ColorSequence
				local length = self:UInt5() -- max length of 20, tested
				local keypoints = table.create(length)

				for _ = 1, length do
					local keypoint = self:ColorSequenceKeypoint()
					table.insert(keypoints, keypoint)
				end

				return ColorSequence.new(keypoints)
			end

			function Reader:CFrame(): CFrame
				local specialCase = self:UInt5()
				local position = self:Vector3()

				if specialCase == 0 then
					local axisAngle = self:Vector3()
					return CFrame.fromAxisAngle(axisAngle, axisAngle.Magnitude) + position
				else
					local specialCase = CFRAME_SPECIAL_CASES[specialCase]
					return CFrame.fromMatrix(position, specialCase.XVector, specialCase.YVector, specialCase.ZVector)
				end
			end

			function Reader:Boolean(): boolean
				local value = bitbuffer.readu1(self.buffer, self.byte, self.bit) == 1
				self:IncrementOffset(0, 1)
				return value
			end

			function Reader:LosslessCFrame(): CFrame
				local specialCase = self:UInt5()
				local position = self:Vector3()

				if specialCase == 0 then
					return CFrame.fromMatrix(position, self:Vector3(), self:Vector3(), self:Vector3())
				else
					local specialCase = CFRAME_SPECIAL_CASES[specialCase]
					return CFrame.fromMatrix(position, specialCase.XVector, specialCase.YVector, specialCase.ZVector)
				end
			end

			function Reader:NumberRange(): NumberRange
				local min = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				local max = bitbuffer.readf32(self.buffer, self.byte + 4, self.bit)
				self:IncrementOffset(8, 0)

				return NumberRange.new(min, max)
			end

			function Reader:Vector3int16(): Vector3int16
				local x = bitbuffer.readi16(self.buffer, self.byte, self.bit)
				local y = bitbuffer.readi16(self.buffer, self.byte + 2, self.bit)
				local z = bitbuffer.readi16(self.buffer, self.byte + 4, self.bit)
				self:IncrementOffset(6, 0)

				return Vector3int16.new(x, y, z)
			end

			function Reader:Vector2int16(): Vector2int16
				local x = bitbuffer.readi16(self.buffer, self.byte, self.bit)
				local y = bitbuffer.readi16(self.buffer, self.byte + 2, self.bit)
				self:IncrementOffset(4, 0)

				return Vector2int16.new(x, y)
			end

			function Reader:UDim2(): UDim2
				local x = self:UDim()
				local y = self:UDim()

				return UDim2.new(x, y)
			end

			function Reader:NumberSequenceKeypoint(): NumberSequenceKeypoint
				local time = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				local value = bitbuffer.readf32(self.buffer, self.byte + 4, self.bit)
				local envelope = bitbuffer.readf32(self.buffer, self.byte + 8, self.bit)
				self:IncrementOffset(12, 0)

				return NumberSequenceKeypoint.new(time, value, envelope)
			end

			function Reader:BrickColor(): BrickColor
				local number = bitbuffer.readu11(self.buffer, self.byte, self.bit)
				self:IncrementOffset(1, 3)

				return BrickColor.new(number)
			end

			function Reader:Vector2(): Vector2
				local x = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				local y = bitbuffer.readf32(self.buffer, self.byte + 4, self.bit)
				self:IncrementOffset(8, 0)

				return Vector2.new(x, y)
			end

			function Reader:UDim(): UDim
				local scale = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				local offset = bitbuffer.readi32(self.buffer, self.byte + 4, self.bit)
				self:IncrementOffset(8, 0)

				return UDim.new(scale, offset)
			end

			function Reader:Color3(): Color3
				local r = bitbuffer.readu8(self.buffer, self.byte, self.bit) / 255
				local g = bitbuffer.readu8(self.buffer, self.byte + 1, self.bit) / 255
				local b = bitbuffer.readu8(self.buffer, self.byte + 2, self.bit) / 255
				self:IncrementOffset(3, 0)

				return Color3.new(r, g, b)
			end

			function Reader:ColorSequenceKeypoint(): ColorSequenceKeypoint
				local time = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				self:IncrementOffset(4, 0)
				local value = self:Color3()

				return ColorSequenceKeypoint.new(time, value)
			end

			function Reader:Vector3(): Vector3
				local x = bitbuffer.readf32(self.buffer, self.byte, self.bit)
				local y = bitbuffer.readf32(self.buffer, self.byte + 4, self.bit)
				local z = bitbuffer.readf32(self.buffer, self.byte + 8, self.bit)
				self:IncrementOffset(12, 0)

				return Vector3.new(x, y, z)
			end

		end
	end
end

return bitbuffer