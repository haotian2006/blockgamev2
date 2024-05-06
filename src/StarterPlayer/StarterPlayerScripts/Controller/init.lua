local Controller = {}
local InputHandler = require(script.Parent:WaitForChild("InputHandler"))
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local IsMoving = false 
local Events = require(game.ReplicatedStorage.Events)
local Data = require(game.ReplicatedStorage.Data)
local LPE = Data.getPlayerEntity
local EntityHandler = require(game.ReplicatedStorage.Handler.EntityHandler)
local EntityUtils = EntityHandler.Utils
local MathLib = require(game.ReplicatedStorage.Libs.MathFunctions)
local Mouse = require(script.mouse)
local CustomCamera = require(script.Camera)
local UiHandler = require(script.Parent.core.Ui)
local UiContainer = require(script.Parent.core.Ui.ContainerHandler)
local EntityTaskReplicator = require(game.ReplicatedStorage.Handler.EntityHandler.EntityReplicator.EntityTaskReplicator)
local BlockHandler = require(game.ReplicatedStorage.Handler.Block)
local BlockBreaker = require(script.BlockBreaker)

local DataHandler = require(game.ReplicatedStorage.Data)
local ConversionUtil = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Runner = require(game.ReplicatedStorage.Runner)

local Helper = require(script.Parent.Helper)


task.wait()
local RenderHandler = require(script.Parent.core.chunk.Rendering.Handler)


local Functions = {}
function Functions.Crouch(key,IsDown,GPE,inputs)
    local Player = LPE()
    if EntityHandler.isDead(Player) or  Player.Crouching or not IsDown then return end 
    EntityHandler.crouch(Player,true)
    repeat
        task.wait()
    until (not InputHandler.isDown("Crouch") and   EntityHandler.canCrouch(Player,true))
    EntityHandler.crouch(Player,false)
end
 
local ray = require(game.ReplicatedStorage.CollisionHandler.Ray)

local highlights = Instance.new("Part",workspace)
highlights.Size = Vector3.new(3,3,3)
highlights.Anchored = true
highlights.Transparency = 1
local H = Instance.new("Highlight",highlights)
H.Adornee = highlights
H.DepthMode = "Occluded"
H.FillTransparency = 1

local hb = false
function Functions.HitBoxes(key,IsDown,GPE,inputs)
    if not IsDown then return end 
    hb = not hb
end

local function AttackBlock(RayData)
    if not RayData.block then return end 
    local BlockPos = RayData.grid
   -- Helper.insertBlock(BlockPos.X,BlockPos.Y,BlockPos.Z,0)
    return true
end

local OpenInv 
function Functions.Inventory(key,IsDown,GPE)
    local entity = DataHandler.getPlayerEntity()
    if (EntityHandler.isDead(entity) and not OpenInv) or not IsDown then 
        return
    end
    if OpenInv then
        UiContainer.open("InventoryFrame")
    else
        UiContainer.close("InventoryFrame")
    end
    OpenInv = not OpenInv
end

local OpenedDebug = false
function Functions.DebugMenu(key,IsDown)
    if  IsDown then return end 
    OpenedDebug = not OpenedDebug
    if OpenedDebug then
        UiHandler.open('DebugMenu')
    else
        UiHandler.close('DebugMenu')
    end
end

function Functions.Attack(key,IsDown,GPE,inputs)
    if not IsDown then return end 
    local RayData = Mouse.getRay()
    if AttackBlock(RayData) then return end 

    if RayData.entity then
        Helper.AttackEntity(RayData.entity.Guid)
    end

end
local Order = {"First","Second","Third"}
local orderIdx = 1
function Functions.CameraMode(key,IsDown,GPE,input)
    if not IsDown then return end 
    orderIdx +=1
    if orderIdx >3 then
        orderIdx = 1
    end
    CustomCamera.setMode(Order[orderIdx])
end

function Functions.DropItem(key,IsDown,GPE)
    if not IsDown then return end 
    Events.DropItem.send()
end

function Functions.Interact(key,IsDown,GPE,inputs)
    if not IsDown or InputHandler.inGui() then return end 
    local RayData = Mouse.getRay()
    if not RayData.block then return end 
    local event = BlockHandler.getEvent(RayData.block, "onInteract") 
    if event then
        if not event(RayData.block,RayData.grid,LPE()) then
            return
        end
    end
    local BlockPos = RayData.grid+RayData.normal
    Helper.insertHoldingBlock(BlockPos.X,BlockPos.Y,BlockPos.Z)
end

local Binded = false
function  Controller.createBinds()
    if Binded then 
        warn(`Controller Is already Binded`)
        return 
    end 
    Binded = true
    InputHandler.bindToRender("#Controller-Handler",20,function(dt)
        local Entity = LPE()
        if EntityHandler.isDead(Entity) then return end 
        local F = InputHandler.isDown("Forward")
        local B = InputHandler.isDown("Back")
        local L = InputHandler.isDown("Left")
        local R = InputHandler.isDown("Right")
        local CameraCFrame = CustomCamera.getCFrame()
        local LookVector = CameraCFrame.LookVector
        local RightVector = CameraCFrame.RightVector
        LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)
        RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)
        local forward = LookVector*(F and 1 or 0)
        local Back = -LookVector*(B and 1 or 0)
        local Left = -RightVector*(L and 1 or 0)
        local Right = RightVector*(R and 1 or 0)
        local velocity = forward + Back + Left+ Right
        local v2 = forward + Back*-1 + (B and -1 or 1)*(Left+ Right)
        velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit)
        v2 = ((v2.Unit ~= v2.Unit) and Vector3.new(0,0,0) or v2.Unit)
        if velocity:FuzzyEq(Vector3.zero,0.01) then
           IsMoving = false
        else
           IsMoving = true
        end
        
        EntityHandler.setMoveDirection(Entity,velocity) 
        local pitch,yaw = MathLib.GetP_YawFromVector3((CameraCFrame.LookVector))
        EntityUtils.rotateHeadTo(Entity,pitch,yaw)
        if InputHandler.isDown("Jump") then
            EntityHandler.jump(Entity)
        end
    end)
    
    for i,v in Functions do
        InputHandler.bindFunctionTo(`{i}-Controller`,v,i)
    end
end

function Controller.setCameraTo(entity)
        CustomCamera.bindToEntity(entity)
end

function Controller.getMouse()
    return Mouse
end

function Controller.getCamera()
    return CustomCamera
end

function Controller.destroyBinds()
    if not Binded then return end 
    Binded = false
    InputHandler.unbindFromRender("#Controller-Handler")
    for i,v in Functions do
        InputHandler.unbindFunction(`{i}-Controller`)
    end
end

local function Update()
    Mouse.update()
end

game:GetService("RunService").RenderStepped:Connect(Update)

return table.freeze(Controller)