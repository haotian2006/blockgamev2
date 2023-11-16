local Holder = {}
Holder.Entities = {}
function Holder.getAllEntities()
    return Holder.Entities
end
function Holder.addEntity(Guid,entity)
    if not entity then
        Holder.Entities[Guid.Guid] = Guid 
        return
    end
    Holder.Entities[Guid] = entity
end
function Holder.getEntity(Guid)
    return Holder.Entities[Guid] 
end
function Holder.removeEntity(Guid)
    Holder.Entities[Guid] = nil
end
return Holder