local function writeu24(b,offset, value)

    local byte1 = (value // (256 * 256)) % 256
    local byte2 = (value // 256) % 256
    local byte3 = value % 256

    buffer.writeu16(b, offset, byte1 * 256 + byte2)
    buffer.writeu8(b, offset+2, byte3)
end

local function readu24(b,offset)
    local u16Value = buffer.readu16(b, offset)

    local byte3 = buffer.readu8(b, offset+2)

    return (u16Value * 256) + byte3
end

local END = 2^16-1
return function ()
    local funcx = {}
    task.defer(function()
        local Core = require(game.ReplicatedStorage.Core)
        local ContainerHandler = require(script.Parent)


        local ByteNet = Core.Shared.ByteNet
        ByteNet = Core.Shared.awaitModule("ByteNet")
        local bufferWriter = ByteNet.writter

        local ItemWritter = ByteNet.Types.item.write
        local StringWritter = ByteNet.Types.string.write
        local ItemReader = ByteNet.Types.item.read
        local StringReader = ByteNet.Types.string.read
        local alloc = bufferWriter.alloc
        local u16 = bufferWriter.u16
        local u8 =  ByteNet.Types.uint8
        local u8Read = u8.read
        local u8Write = u8.write
        local u32 = bufferWriter.u32
        funcx.read = function(b, cursor)
            local arrayLength = buffer.readu16(b, cursor)
			local arrayCursor = cursor + 2
			local Container = {}
            local Type,length = StringReader(b,arrayCursor)
            arrayCursor+=length
            Container[1] = Type

			for i = 2, arrayLength do
                local amt,len = u8Read(b,arrayCursor)
                arrayCursor+=len
				local item, length_ = ItemReader(b, arrayCursor)

                if item == "" then
                    Container[i] = ""
                else
                    Container[i] = {item,amt}
                end

				arrayCursor += length_
			end
            -- local name,nLen = StringReader(b, arrayCursor)
            -- arrayCursor+= nLen
            -- table.insert(Container,{__Name = name})
			return Container, arrayCursor - cursor
        end
        funcx.write = function(container)
            local size = ContainerHandler.size(container)+1
            alloc(2)
			u16(size) -- write length, 2 bytes
            StringWritter(container[1])
			for i = 2, size do
                local at = container[i]
                if at == "" then
                    u8Write(0)
                    ItemWritter("")
                else
                    u8Write(at[2])
                    ItemWritter(at[1])
                end
			end
            --StringWritter(container[#container].__Name or container[1])
        end
    
        funcx.isType = function(value)
            return type(value) == "table" and value[1]
        end
    end)
    return funcx
end

