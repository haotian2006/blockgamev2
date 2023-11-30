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
            entity:LookAt(Vector3.new(EPosition.X+offsetx,entity:GetEyePosition().Y,EPosition.Z+offsetz))
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
            --if not entity:BehaviorCanRun("behavior.GoToPlayer",data,true,true) then return end 
            local range = data.MaxRange or 10
            local pos = entity.Position
            entity.NotSaved["behaviors"]["behavior.GoToPlayer"] = true
            for i,v in entity:GetData().EntitiesinR(pos.X,pos.Y,pos.Z,range) do
                if v.Type == "Player" and v.Health >0 then
                    if (entity.Position-v.Position).Magnitude >= 20 then 
                        entity.Speed= 70
                    end
                    entity:MoveTo(v.Position.X,v.Position.Y,v.Position.Z)
                    break
                end
            end
            entity.Speed= 2
            entity.NotSaved["behaviors"]["behavior.GoToPlayer"] = false
        end,
        bhtype = {"Movement"},
    },
    ['behavior.AttackPlayer'] = {
        func = function(entity,data)
            local interval = data.interval or 3
            local chance = math.random(1,interval)
		    if chance ~= 1 then return end
            if not entity:BehaviorCanRun("behavior.AttackPlayer",data,true,true) then return end 
            local range = data.MaxRange or 3
            local pos = entity.Position
            entity.NotSaved["behaviors"]["behavior.AttackPlayer"] = true
            for i,v in entity:GetData().EntitiesinR(pos.X,pos.Y,pos.Z,range) do
                if v.Type == "Player" and v.Health >0 then
                    local dir = (v.Position-entity.Position).Unit
                    local velocity = Vector3.new(dir.X*2,.6,dir.Z*2)
                    entity:PlayAnimation("Attack",true)
                    v:Damage(1)
                    require(game.ReplicatedStorage.BridgeNet).CreateBridge("DoMover"):FireTo(game.Players:GetPlayerByUserId(tonumber(i)),i,"Curve",velocity,.2)
                    break
                end
            end
            entity.NotSaved["behaviors"]["behavior.AttackPlayer"] = false
        end,
        bhtype = {""},
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
                    local y = v.Position.Y-v.Hitbox.Y/2+eyelevel/2
                    entity:LookAt(v:GetEyePosition())
                    break
                end
            end
        end,
        bhtype = "Turning",
    },
}