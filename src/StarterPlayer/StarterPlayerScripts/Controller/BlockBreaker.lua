local BlockBreaker = {}

local InputHandler = require(script.Parent.Parent.InputHandler)
local Mouse = require(script.Parent.mouse)
local Data = require(game.ReplicatedStorage.Data)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Helper = require(script.Parent.Parent.Helper)
local Arms = require(script.Parent.Parent.core.Rendering.Arms)

local RunService = game:GetService("RunService")

local GetPlayerEntity = Data.getPlayerEntity

local progress = 0


local LastInfo 

local function isSame(dictionary1, dictionary2)

    if type(dictionary1) ~= "table" or type(dictionary2) ~= "table" then
        return dictionary1 == dictionary2
    end

    for key, value in (dictionary1) do
        if dictionary2[key] ~= value then
            return false
        end
    end

    for key, _ in (dictionary2) do
        if dictionary1[key] == nil then
            return false
        end
    end
    return true
end

local function createInfo()
    if not InputHandler.isDown("Attack") then return end 
    local RayData = Mouse.getRay()
    local Entity = GetPlayerEntity()
    if not Entity then return end 
    if EntityHandler.isDead(Entity) then return end 
    if not RayData.block or  RayData.block == -1 then return end 
    local Info = {
        Block = RayData.block, 
        BlockPos = RayData.grid,
        --CurrentSlot = EntityHandler.getSlot(Entity),
       -- Holding = EntityHandler.getHolding(Entity)
    }
    return Info
end

local function updateProgress(value)
    progress = 0
end


local function Update(dt)
    local info = createInfo()
    if not info  then 
        Arms.stopAnimation("Attack")
        updateProgress(0)
        LastInfo = nil
        return 
    end 
    if not isSame(LastInfo, info) then
        if not Arms.isPlaying("Attack") then
            Arms.playAnimation("Attack", nil, nil, nil,true)
        end
        updateProgress(0)
        LastInfo = info
    end
    progress+=dt*2

    if progress >1 then
        local grid = LastInfo.BlockPos
        Helper.insertBlock(grid.X, grid.Y, grid.Z, 0)
    end
  
end

RunService.Heartbeat:Connect(Update)


return BlockBreaker