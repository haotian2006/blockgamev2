return {
    ['behavior.Random_Stroll'] = {
        func = function(entity,data)
            local interval = data.interval or 120
            local chance = math.random(1,interval)
		    if chance ~= 1 then return end
            if not entity:BehaviorCanRun("behavior.Random_Stroll",data,true,true) then return end 
            local speed_multiplier = data.speed_multiplier or 1 
            local xz_dist = (data.maxXZ or 10)
            local y_dist = (data.maxy or 7)
            local EPosition = entity.Position
            local offsetx,offsetz,offsety = math.random(-xz_dist,xz_dist),math.random(-xz_dist,xz_dist),math.random(-y_dist,y_dist)
            entity.NotSaved["behaviors"]["behavior.Random_Stroll"] = true
            entity:MoveTo(EPosition.X+offsetx,EPosition.Y+offsety,EPosition.Z+offsetz)
            entity.NotSaved["behaviors"]["behavior.Random_Stroll"] = false
        end,
        bhtype = {"Movement","Turning"},
    },
    ['behavior.GoToPlayer'] = {
        func = function(entity,data)
            local interval = data.interval or 3
            local chance = math.random(1,interval)
		    if chance ~= 1 then return end
            if not entity:BehaviorCanRun("behavior.GoToPlayer",data,true,true) then return end 
            local range = data.MaxRange or 10
            local pos = entity.Position
            entity.NotSaved["behaviors"]["behavior.GoToPlayer"] = true
            for i,v in entity:GetData().EntitiesinR(pos.X,pos.Y,pos.Z,range) do
                if v.Type == "Player" then
                    entity:MoveTo(v.Position.X,v.Position.Y,v.Position.Z)
                    break
                end
            end
            entity.NotSaved["behaviors"]["behavior.GoToPlayer"] = false
        end,
        bhtype = {"Movement","Turning"},
    },
    ['behavior.LookAtPlayer'] = {
        func = function(entity,data)
            local interval = data.interval or 1
            local chance = math.random(1,interval)
		    if chance ~= 1 then return end
            if not entity:BehaviorCanRun("behavior.LookAtPlayer",data,true,true) then return end 
            local range = data.MaxRange or 10
            local pos = entity.Position
            for i,v in entity:GetData().EntitiesinR(pos.X,pos.Y,pos.Z,range) do
                if v.Type == "Player" then
                    local eyelevel = v.EyeLevel or 0
                    local y = v.Position.Y-v.HitBox.Y/2+eyelevel
                    entity:LookAt(Vector3.new(v.Position.X,y,v.Position.Z))
                    break
                end
            end
        end,
        bhtype = "Turning",
    },
    ['behavior.Fall'] = {
        func = function(entity,data)
            local cx,cz = entity:GetQf().GetChunkfromReal(entity.Position.X,entity.Position.Y,entity.Position.Z,true)
            if not entity:GetData().GetChunk(cx,cz) then return end 
            entity.Data.FallTicks = entity.Data.FallTicks or 0
            local max = entity.FallRate or 150
            local fallrate =(((0.99^entity.Data.FallTicks)-1)*max)/1.4
        
            if entity.Data.Grounded  or entity.Data.Jumping  then -- or not entity.CanFall
                entity.Velocity.Fall = Vector3.new(0,0,0) 
                entity.Data.IsFalling = false
                entity.Data.FallTicks = 0
            elseif not entity.Data.Grounded  then
                entity.Data.FallTicks += 1
                entity.Velocity.Fall = Vector3.new(0,fallrate,0) 
            end
        end,
        bhtype = "Falling",
        CNRIC = true,

    }
}