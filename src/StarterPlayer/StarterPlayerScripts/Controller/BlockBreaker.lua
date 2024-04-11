local BlockBreaker = {}

local CubicalEvents = require(game.ReplicatedStorage.Events)

local InputHandler = require(script.Parent.Parent.InputHandler)
local Mouse = require(script.Parent.mouse)
local Data = require(game.ReplicatedStorage.Data)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Helper = require(script.Parent.Parent.Helper)
local Arms = require(script.Parent.Parent.core.Rendering.Arms)
local ItemHandler = require(game.ReplicatedStorage.Item)
local BlockHandler = require(game.ReplicatedStorage.Handler.Block)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local BlockBreaking = require(script.Parent.Parent.core.Rendering.BlockBreaking)

local RunService = game:GetService("RunService")

local GetPlayerEntity = Data.getPlayerEntity

local progress = 0


local LastInfo 

local function compareItem(item1,item2)
    if not item1 and not item2 then
        return true
    elseif not item1 or not item2 then
        return false
    end
    return ItemHandler.equals(item1,item2)
end

local function isSame(dictionary1, dictionary2)
    if not dictionary1 or not dictionary2 then return false end 
    return dictionary1.Block  == dictionary2.Block  and dictionary1.BlockPos == dictionary2.BlockPos and compareItem(dictionary1.Holding,dictionary2.Holding)
end

local getAssets = ResourceHandler.getAsset

local function createInfo()
    if not InputHandler.isDown("Attack") or InputHandler.inGui() then return end 
    local RayData = Mouse.getRay()
    local Entity = GetPlayerEntity()
    if not Entity then return end 
    if EntityHandler.isDead(Entity) then return end 
    if not RayData.block or  RayData.block == -1 then return end 
    local Info = {
        Block = RayData.block, 
        BlockPos = RayData.grid,
        --CurrentSlot = EntityHandler.getSlot(Entity),
        Holding = EntityHandler.getHolding(Entity)
    }
    return Info
end

local TotalFrames 

local wasAttacking = false

local function updateProgress(value,Takes)
    progress = value
    if Takes then
        TotalFrames = TotalFrames or getAssets("BlockBreakTextures")
        local percentage = Takes/(#TotalFrames)
        local Frame = progress//percentage+1
        BlockBreaking.setPrimary(wasAttacking,Frame)
    end
end


local function Update(dt)
    local info = createInfo()
    if not info  then 
        if wasAttacking then
            CubicalEvents.StopBreakingBlock.send()
            Arms.stopAnimation("Attack")
        end
        updateProgress(0)
        LastInfo = nil
        wasAttacking = false 
        BlockBreaking.setPrimary(nil,1)
        return 
    end 
    if not isSame(LastInfo, info) then
        if not Arms.isPlaying("Attack") then
            Arms.playAnimation("Attack",true)
        end
        updateProgress(0)
        LastInfo = info
        CubicalEvents.StartBreakingBlockServer.send(info.BlockPos)
    end
    wasAttacking = info.BlockPos
    local Multiplier = 1
    local TimeToBreak = BlockHandler.get( info.Block, "BreakTime") or 1
    if info.Holding then
        Multiplier = ItemHandler.getBreakMultiplier(info.Holding, info.Handler.Block) or 1
    end

    progress+=dt*Multiplier
    updateProgress(progress,TimeToBreak)

    if progress > TimeToBreak then
        local grid = info.BlockPos
       -- Helper.insertHoldingBlock(grid.X, grid.Y, grid.Z)
    end
  
end

RunService.Heartbeat:Connect(Update)


return BlockBreaker