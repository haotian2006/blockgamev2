local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()
local LOCAL_PLAYER = game.Players.LocalPlayer
local entity = {}
local Animator = require(script.Animator)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GameSettings = require(game,ReplicatedStorage.GameSettings)
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
entity.DefaultValues = {}
entity.__index = entity
function entity.new(type:string)
    local info = BehaviorHandler.GetEntity(type)
    if not info then return warn(`Entity '{type}' does not exist`) end 
    local self = {}
    self.Type = type
    self.__main = info.components or {}
    self.__components = {}
    self.__changed = {}
    self.__animations = {}
    self.__playingAnimations = {}
    self.__ownership = nil
    self.__model = nil
    self.Position = Vector3.zero
    self.Chunk = Vector2.zero
    return setmetatable(self,entity)
end
function entity:addComponent(component,index)
    local entityData =  BehaviorHandler.GetEntity(self.Type)
    local componentData = entityData.component_groups[component]
    if not componentData then warn(`component {component} is not a member or {self.Type}`) end 
    componentData.Name = component
    entity.removeComponent(self,component)
    table.insert(self.__componets,index or 1,componentData)
end
function entity:removeComponent(name)
    for i,v in self.__components do
        if v.Name == name then
            table.remove(self.__components,i)
        end
    end
end
function entity:get(string) 
    if self[string] then
        return self[string]
    end
    for i,v in self.__componets do
        if v[string] then 
            return v[string]
        end
    end
    if self.__main[string] then 
        return self.__main[string]
    end
    return entity.DefaultValues[string]
end
function entity:set(key,value)
    self[key] = value
end

function entity:getVelocity():Vector3
    local x,y,z = 0,0,0
    for i,v in self.Velocity do
        if typeof(v) == "Vector3" and v == v then
            x+= v.X
            y+= v.Y
            z+= v.Z
        end
    end
    if x == 0 then
        x = -0.00000001
    end
    if z == 0 then
        z = -0.00000001
    end
    return Vector3.new(x,y,z)
end

function entity:isOwner(player)
    return self.__ownership == player
end
function entity:getOwner()
    return self.__ownership ~= nil and game.Players:GetPlayerByUserId(self.__ownership)
end
--//Updates
function entity:updatePosition(dt)
    local Velocity = entity.getVelocity(self)

end
function entity:update(dt)
    
end
--//Animaton
function entity:playAnimation(animation)
    if self.__dead then return end 
    local owner = entity.getOwner(self)
    if not IS_CLIENT then
        --//SendToUpdateTable
    elseif owner == LOCAL_PLAYER then
        Animator.play(self,animation)
            --//SendToUpdateTable
    else
        Animator.play(self,animation)
    end
end
function entity:destroy()
    self.__destroyed = true
end
return entity