local Holder = {}
local Entities = {}
Holder.Entities = Entities
local IdEntity = {}
local runservice = game:GetService("RunService")
local IsServer = runservice:IsServer()
local getNextId,returnId
local Handler
local Removed
if IsServer then
    Removed = {}
    Holder.Removed = {}
    local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
    local MaxSize = 2^16
    local SecondarySize = 2^12
    local IdQueue = Queue.new(2^12)
    local current = 0
    function getNextId()
        if current<SecondarySize then
            current+=1
            return current
        end
        local nextId = Queue.dequeue(IdQueue)
        if not nextId and current<MaxSize then
            current+=1
            return current
        elseif not nextId then
            warn("Out Of IDs For Entity")
            return 
        end
        return nextId
    end

    function returnId(Id)
        Queue.enqueue(IdQueue, Id)
    end
end
function Holder.getAllEntities()
    return Entities
end

function Holder.addEntity(Guid,entity)
    if IsServer  then
        local Id = getNextId()
        local toUse = (entity or Guid)
        toUse.__NetworkId = Id
        Holder.linkEntity(Id, toUse)
    end
    if not entity then
        local temp = Guid
        Guid = Guid.Guid
        entity = temp
    end
    if entity then
        Handler.updateChunk(entity)
    end
    Entities[Guid] = entity
end

function Holder.getEntity(Guid)
    return Entities[Guid] 
end

function Holder.removeEntity(Guid)
    if type(Guid) == "table" then
        Guid =  Guid.Guid
    end
    if IsServer and Entities[Guid]  then
        Holder.unLink( Entities[Guid].__NetworkId)
    end
    local e =  Entities[Guid]
    if not e then return end 
    Handler.updateChunk(e)
    Entities[Guid] = nil
end

function Holder.getAllLinks()
    return IdEntity
end

function Holder.linkEntity(id,entity)
    IdEntity[id] = entity
end

function Holder.getEntityFromLink(id)
    return IdEntity[id] 
end

function Holder.unLink(id)
    if returnId then returnId(id) end 
    if Removed then
        local entity =IdEntity[id] 
        if not entity then return end 
        Removed[entity.Guid] = id
    end
    IdEntity[id] = nil
end

function Holder.getIdFromGuid(Guid)
    local e = Entities[Guid]
    if Removed and Removed[Guid] then return Removed[Guid] end 
    if not e then return end
    return e.__NetworkId
end

function Holder.init(entity)
    Handler = entity
end

return Holder