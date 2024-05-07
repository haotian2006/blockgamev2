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
        local SerializerTypes = require(game.ReplicatedStorage.Core.Serializer.types)
        local EntityFieldTypes = require(script.Parent.EntityFieldTypes)
        local IndexKey,KeyIndex,KeyType:{[string]:SerializerTypes.dataTypeInterface<any>} = EntityFieldTypes.getAllInfo()

        local Serializer = Core.Shared.Serializer
        Serializer = Core.Shared.awaitModule("Serializer")
        local bufferWriter = Serializer.writter

        local alloc = bufferWriter.alloc
        local u16 = bufferWriter.u16
        local u32 = bufferWriter.u32
        local getCursor = bufferWriter.getCursor
        funcx.read = function(b, cursor)
            local constructed = {}
            local startCursor = cursor
            local traversed = 0
            local size = buffer.readu16(b, startCursor)
            startCursor+=2 
            traversed+=2
            while traversed <size do
                local idx = buffer.readu16(b, startCursor)
                local key = IndexKey[idx]
                if not key then
                    warn("Key Not Found")
                    break
                end
                local parser = KeyType[key]
                startCursor+=2
                local value,offset = parser.read(b, startCursor)
                constructed[key] = if parser.CanNotSave then nil else value
                startCursor+=offset
                traversed+=offset+2
            end
            return constructed, size
        end
        funcx.write = function(Entity)
            alloc(2)
            local cursor = getCursor()
            u16(0)
            for key,value in Entity do
                local index = KeyIndex[key]
                if not index then continue end 
                local parser = KeyType[key]
                if not parser.isType(value) then continue end 
                if parser.CanNotSave then continue end 
                alloc(2)
                u16(index)
                parser.write(value)
            end 
            local size = getCursor() - cursor
            if size > END then
                warn("Entity Size OverFlow")
                size = END
            end
            buffer.writeu16(bufferWriter.getBuffer(), cursor, size)
        end
    
        funcx.isType = function(value)
            return type(value) == "table" and value.__IsEntity
        end
    end)
    return funcx
end

