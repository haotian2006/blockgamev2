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
    local func = {}
    task.defer(function()
        local Core = require(game.ReplicatedStorage.Core)
        local ItemHandler = require(script.Parent)

        local indexKey,keyIndex = ItemHandler.getTables()

        local Serializer = Core.Shared.Serializer
        Serializer = Core.Shared.awaitModule("Serializer")
        local bufferWriter = Serializer.writter
        local getBuffer = bufferWriter.getBuffer
        local getCursor = bufferWriter.getCursor
        local alloc = bufferWriter.alloc
        local u16 = bufferWriter.u16
        local u32 = bufferWriter.u32
        local u8 = bufferWriter.u8
        func.read = function(b, cursor)
           -- local constructed = {}
            local startCursor = cursor
            local traversed = 0
            local size = buffer.readu16(b, startCursor)
            if size == 0 then return "",2 end 
            startCursor+=2
            local id = buffer.readu16(b, startCursor)
            startCursor+=2
            local var = buffer.readu8(b, startCursor)
            traversed+=5
      
            return ItemHandler.new(id,var), size
        end
        func.write = function(Item)
            local cursor = getCursor()
            alloc(2)
            u16(0)
            
            if Item == "" then
                return
            end

            u16(Item[1] or 0)
            u8(Item[2] or 0)
            --//write components 
            local size = getCursor() - cursor
            if size > END then
                warn("Item Size OverFlow")
                size = END
            end
            buffer.writeu16(getBuffer(), cursor, size)
        end
    
        func.isType = function(value)
            return (type(value) == "table" and value[1]) or value == ""
        end
    end)
    return func
end

