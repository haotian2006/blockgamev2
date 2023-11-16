local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local ArmsHandler = require(game.ReplicatedStorage.Managers.ArmsManager)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local itemhand = require(game.ReplicatedStorage.ItemHandler)
local destroyblockEvent = bridge.CreateBridge("BlockBreak")
local placeBlockEvent = bridge.CreateBridge("BlockPlace")
local EntityBridge = bridge.CreateBridge("EntityBridge")
local qf = require(game.ReplicatedStorage.QuickFunctions)
local resource = require(game.ReplicatedStorage.ResourceHandler)
local gamesettings = require(game.ReplicatedStorage.GameSettings)
local data = require(game.ReplicatedStorage.DataHandler)
local Ray = require(game.ReplicatedStorage.Ray)
local camera = game.Workspace.CurrentCamera
local debugger = require(game.ReplicatedStorage.Libarys.Debugger)
local anihandler = require(game.ReplicatedStorage.AnimationController)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local managers = require(game.ReplicatedStorage.Managers)
local math = require(game.ReplicatedStorage.Libarys.MathFunctions)
local behaviorhandler = require(game.ReplicatedStorage.BehaviorHandler)
local hotbarhandler = managers.HotBarManager
local playerdollmanager = managers.PlayerDollHandler
local InventoryManager = managers.InventoryManager:Init()
local UIContainerManager = managers.UIContainerManager
hotbarhandler:Init()
local lp = game.Players.LocalPlayer
local localentity = data.GetLocalPlayer
local controls = {func = {},RenderStepped = {}} 
local Math = require(game.ReplicatedStorage.Libarys.MathFunctions)
local newKeyBinds = require(game.ReplicatedStorage.Libarys.PlayerControls).new()
controls.downtimer = {}
local downtimer = controls.downtimer 
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower()
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower()
    end
end
controls.Data = {}
controls.KeysPressed = {}
controls.Render = {}
controls.Functionsdown = {}
local CData = controls.Data
local GPlayer = data.GLocalPlayer
local Camera = game.Workspace.CurrentCamera
local func = controls.func
local Render = controls.Render
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local FD = controls.Functionsdown 
local CameraCFrame = camera.CFrame
local function interpolate(startVector3, finishVector3, alpha)
    local function currentState(start, finish, alpha)
        return start + (finish - start)*alpha

    end
    return Vector3.new(
        currentState(startVector3.X, finishVector3.X, alpha),
        currentState(startVector3.Y, finishVector3.Y, alpha),
        currentState(startVector3.Z, finishVector3.Z, alpha)
    )
end
local function checkempty(tab)
    return not (tab and next(tab) ~= nil)
end
local ExtraJump = 0
function func.F5()
    CData.F5  = not CData.F5 
end
function func.Inventory()
    InventoryManager.Enable(not InventoryManager.Frame.Enabled)
end
function func.HotBarUpdate(key,data)
    if not localentity() then return end 
    local slot = localentity().CurrentSlot or 1
    if data.UserInputType == Enum.UserInputType.MouseWheel then
        local upordown = data.Position.Z > 0 and "up" or "down"
        if upordown == "down" then
            slot +=1 
            if slot >= 10 then
                slot = 1
            end
        else
            slot -=1 
            if slot <= 0 then
                slot = 9
            end
        end
    else
        for i,v in newKeyBinds:GetData() do
            if string.find(i,"Slot") then else continue end 
            if v == key or (type(v) == "table" and table.find(v,key)) then
                slot = string.split(i,"Slot")[2]
                break
            end
        end
    end
    localentity().CurrentSlot = tonumber(slot)
    hotbarhandler.UpdateSelect(tonumber(slot))
end
function func.HitBoxs()
    data.HitBoxEnabled = not data.HitBoxEnabled 
    for i,v in game.Workspace.Entities:GetDescendants() do
        if v:IsA("SelectionBox") then
            v.Visible = not not data.HitBoxEnabled
        end
    end
    for i,v in game.Workspace.DamagedEntities:GetDescendants() do
        if v:IsA("SelectionBox") then
            v.Visible = not not data.HitBoxEnabled
        end
    end
end
function func.HandleJump()
    if not localentity() or localentity():GetState('Dead') or localentity().Ingui then return end 
    if  GPlayer.Jumping or data.LocalPlayer["CanNotJump"] then return end
    local e 
    local jumpedamount =0 
    local jumpheight = data.LocalPlayer.JumpHeight or 0 --1.25
    local muti = 4.5
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local jump = jumpheight*muti
        local datacondition = DateTime.now().UnixTimestampMillis/1000-ExtraJump <=0.05
        if (GPlayer.Grounded or datacondition)  and not GPlayer.Jumping then
            if datacondition then  ExtraJump = 0  end
            if jumpedamount == 0 then
                jumpedamount += jumpheight*(deltaTime)*muti
            end 
           end
        if jumpedamount > 0 and jumpedamount <=jumpheight  then
         jumpedamount += jumpheight*(deltaTime)*muti
         jump = jumpheight*muti
         GPlayer.Jumping = true
         else
            GPlayer.Jumping = false
             jump = 0
             jumpedamount = 0
             GPlayer.Velocity.Jump = Vector3.new()
             e:Disconnect()
        end
        local touse = jump--fps.Value>62 and (jump/deltaTime)/60 or jump
        GPlayer.Velocity.Jump =Vector3.new(0,touse,0)
    end)
end
function func.Crouch()
    local plr = localentity()
    if not localentity() or localentity():GetState('Dead') or localentity().Ingui or not plr:CanCrouch() then return end 
    if not data.LocalPlayer.Crouching then
        localentity():Crouch()
    end
    data.LocalPlayer:UpdateModelPosition()
    repeat
        task.wait()
    until (not FD["Crouch"] or not plr:CanCrouch()) and not plr:IsGrounded(true)
    if data.LocalPlayer.Crouching then
        localentity():Crouch(true)
    end
    data.LocalPlayer:UpdateModelPosition()
end
function func.Interact()
    do
         return
    end
    if not localentity() or localentity():GetState('Dead') or localentity().Ingui then return end 
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.GetNormal = true
   -- rayinfo.IgnoreEntities = true
   rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5.1,rayinfo)
    if #raystuff.Objects >= 1 then
        --print("hit")
        local newpos = {}
        for i,v:string|table in raystuff.Objects do
            --print(v.Normal)
            local item = localentity().HoldingItem or {}
            if  v.Type == "Block" and item[1] and ResourceHandler.IsBlock(item[1]) then
                local coords = v.BlockPosition+v.Normal
                local hitpos = v.PointOfInt
                --print(item)
                local orientation = nil
                local block = ResourceHandler.IsBlock(item[1])
                block = behaviorhandler.GetBlock(block)
                if block and block.components then
                    block = block.components
                    orientation = {0,0,0}
                    local direaction = camera.CFrame.LookVector
                    local angle = math.GetAngleDL(direaction) 
                    local dx = math.abs(direaction.X)
                    local dz = math.abs(direaction.Z)
                    if dx < dz then
                        dx = 0
                        dz = direaction.Z / dz
                     else
                        dz = 0
                        dx = direaction.X/dx
                     end
                    -- print(direaction.X,dx,dz)
                     if (dx == -1 or dx == 1) and block.RotateY then
                        orientation[2] = dx
                     end
                     if dz == -1 and block.RotateY then
                        orientation[2] = '-0'
                     elseif  dz == 1 then
                        orientation[3] = 0
                     end
                     if hitpos.Y >  coords.Y and block.RotateZ then 
                        orientation[3] = '-0'
                    else
                    end
                   -- print(angle)
                    if angle >=-40 and angle <= - 39 and block.RotateX then
                        orientation[1] = 1
                    elseif angle >= 39 and angle <=  40 and block.RotateX then
                        orientation[1] = -1
                    end
                    orientation = (orientation[1]..','..orientation[2]..','..orientation[3])
                    --print(orientation)
                    if orientation == '0,0,0' then 
                        orientation =nil
                    end
                end
                if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z,data)  then 
                    data.InsertBlock(coords.X,coords.Y,coords.Z,item[1])
                    localentity():PlayAnimation("Place",true)
                    ArmsHandler.PlayAnimation('Attack',true)
                    placeBlockEvent:Fire(coords,orientation)
                end
            elseif v.Type == "Entity"  then
             
            end
        end
    end
end
local render = require(script.Parent.Render)
function func.Attack()
    if not localentity() or localentity():GetState('Dead') or localentity().Ingui then    return end 
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5.1,rayinfo)
    if #raystuff.Objects >= 1 then
        local newpos = {}
        for i,v in raystuff.Objects do
            if  v.Type == "Block" then
                local block = v.BlockPosition
                local blocktr =data.GetBlock(block.X,block.Y,block.Z)
                if (blocktr and blocktr[2].T == "c:Bedrock") or not blocktr then return end 
                --data.RemoveBlock(block.X,block.Y,block.Z)
                render.updateBlocks(nil,block.X,block.Y,block.Z)
                destroyblockEvent:Fire(block)
            elseif v.Type == "Entity"  then
                game.ReplicatedStorage.Events.KB:FireServer(v.EntityId,CameraCFrame.LookVector)
            end
        end
    end
    data.LocalPlayer:PlayAnimation("Attack",true)
    ArmsHandler.PlayAnimation('Attack',true)
end
local t = 0
local tick = gamesettings.ClientReplicationRate
function Render.Update(dt)
    local self = data.LocalPlayer
    for i,v in data.LoadedEntities do
        v:Update(dt)
    end
    if  localentity() then   
        self.Entity.PrimaryPart.CFrame = CFrame.new(self.Position*3)
    end
    if t >= tick and localentity() then
        t = 0
        local serverstuff = localentity() and self:GetServerChanges() or {}
        local ToSend = {}
        for i,v in self do 
            if not serverstuff[i] then continue end 
            do
                if type(v) == "table" and type(v.GetUpdated) == "function"then
                    ToSend[i] = v:GetUpdated()
                    continue
                elseif not self:IsUpdated(i) then
                    continue
                end
            end
            if type(v) ~= "table"then ToSend[i] = v continue end 
            if  type(v["Sterilize"]) == "function" then
                ToSend[i] = v:Sterilize()
            else
                ToSend[i] = qf.deepCopy(v)
            end
        end
        for i,v in self.__Update do
            if not serverstuff[i] then continue end 
            if self.__P[i] == nil then
                ToSend[i] = "__NULL__"
            else
                ToSend[i] = self.__P[i]
            end
        end 
        local changed,encoded
        if not localentity() or localentity():GetState('Dead')  then 
        else
            changed,encoded = self:ENCODE(ToSend)
        end 
        ToSend =  next(ToSend) ~= nil and ToSend or (changed and encoded) or {}
        if next(ToSend) ~= nil and ToSend[1] == nil  then
            ToSend.ENCODE = encoded 
        end
        if next(ToSend) ~= nil then
         EntityBridge:Fire(tostring(game.Players.LocalPlayer.UserId),ToSend)
        end
        self:ClearUpdated()
    end
    t+= dt
    if  localentity() then   
    self:ClearVelocity()
    anihandler.UpdateEntity(self)
    end
end
local entityhandlerv2 = require(game.ReplicatedStorage.EntityHandlerV2)
local entityv2 = require(script.Parent.Test.EntityHandlerV2)
local utils = require(game.ReplicatedStorage.EntityHandlerV2.Utils)
function Render.Move(dt)
    if not localentity() or localentity():GetState('Dead') or not localentity().Entity or localentity().Ingui then return end 
    local LookVector = CameraCFrame.LookVector
    local RightVector = CameraCFrame.RightVector
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)--
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)--
    local foward = LookVector*(FD["Foward"]and 1 or 0)
    local Back = -LookVector*(FD["Back"]and 1 or 0)
    local Left = -RightVector*(FD["Left"]and 1 or 0)
    local Right = RightVector*(FD["Right"]and 1 or 0)
    local velocity = foward + Back + Left+ Right
    local v2 = foward + Back*-1 + (FD["Back"] and -1 or 1)*(Left+ Right)
    data.LocalPlayer.Bodydir = velocity
    velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit)
    v2 = ((v2.Unit ~= v2.Unit) and Vector3.new(0,0,0) or v2.Unit)
    if velocity:FuzzyEq(Vector3.zero,0.01) then
        localentity():SetState('Stopping',true)
    else
        localentity():SetState('Stopping',false)
    end
   entityhandlerv2.setMoveDireaction(entityv2,velocity) 
    data.LocalPlayer.Velocity["Movement"] = velocity* (localentity():GPWM('Speed') or 0 )
    local pitch,yaw = Math.GetP_YawFromVector3((CameraCFrame.LookVector))
    utils.rotateHeadTo(entityv2,Vector2.new(pitch,yaw))
    utils.followMovement(entityv2,Vector2.new(v2.X,v2.Z).Unit)
    if FD["Jump"] then data.LocalPlayer:Jump() entityhandlerv2.jump(entityv2) end 
    if uis:IsKeyDown(Enum.KeyCode.T) then
        entityv2.t = not entityv2.t
       -- entityhandlerv2.setVelocity(entityv2,"Physics",(velocity+Vector3.new(0,.5,0)).Unit * 50)
    end
end
local second 
local outline = game.Workspace.Outline
function controls.Render.OutLine()
    if not localentity() or localentity():GetState('Dead') or not localentity().Entity then return end 
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
   -- rayinfo.IgnoreEntities = true
     local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5.1,rayinfo)
    if #raystuff.Objects >= 1 then
        local v = raystuff.Objects[1]
           -- print(v.Normal,lookvector)
            if  v.Type == "Block" then
                local a = v.BlockPosition
            outline.Position = a*3
            outline.SelectionBox.Transparency = 0
        else
            outline.SelectionBox.Transparency = 1
        end
    else
        outline.SelectionBox.Transparency = 1
    end
end
controls.PlayerDoll = nil 
function controls.RenderStepped.Update(dt)
    if not localentity() or localentity():GetState('Dead') or not localentity().Entity then table.clear(controls.Functionsdown) table.clear(controls.KeysPressed)  table.clear(controls.Data) table.clear(controls.downtimer) end 
    if  localentity() and not localentity().ClientArms then localentity().ClientArms = ArmsHandler.Init() end
    ArmsHandler.UpdateArms(dt)
    if not controls.PlayerDoll then
        controls.PlayerDoll = playerdollmanager.new(lp.PlayerGui:WaitForChild('Hud').PlayerModel,nil,60,10,25)
    else
        controls.PlayerDoll:Update()
    end
end
function controls.RenderStepped.Camera()
    if not localentity() or localentity():GetState('Dead')  then  
        uis.MouseIconEnabled = true 
        uis.MouseBehavior  = Enum.MouseBehavior.Default
        return 
    end 
    if not checkempty(data.LocalPlayer) then
        local Current_Entity = data.LocalPlayer.Entity
        second = second or Current_Entity:FindFirstChild("SecondLayer",true)
        local muti
        local entityw = Current_Entity
            data.LocalPlayer:SetHeadRotationDir(CameraCFrame.LookVector*10)
       -- end
        data.LocalPlayer:UpdateRotationClient()
        if (camera.CFrame.Position - camera.Focus.Position).Magnitude < 0.6 and Current_Entity then
            data.GetLocalPlayer().VeiwMode = "First"
            if ArmsHandler.GetArmsframe() then
                ArmsHandler.GetArmsframe().Enabled = true
            end
            localentity():SetModelTransparency(1)
        elseif Current_Entity then
            data.GetLocalPlayer().VeiwMode = "Third"
            localentity():SetModelTransparency(0)
            if ArmsHandler.GetArmsframe() then
                ArmsHandler.GetArmsframe().Enabled = false
            end
        end
    end
    if  localentity().Ingui  then 
        uis.MouseIconEnabled = true 
        uis.MouseBehavior  = Enum.MouseBehavior.Default
        return
    else     
        uis.MouseIconEnabled = false
    end 
    lp.PlayerGui:WaitForChild("Hud")
    if not FD["Freecam"] then
        CameraCFrame = camera.CFrame
        uis.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    if not CData.F5  then
        lp.PlayerGui:WaitForChild("Hud").Cursor.Visible = true
        lp.CameraMaxZoomDistance = 0.5
        lp.CameraMinZoomDistance = 0.5
    else
        lp.PlayerGui:WaitForChild("Hud").Cursor.Visible = false
        lp.CameraMaxZoomDistance = 6
        lp.CameraMinZoomDistance = 6
    end

end


local KeyDown = bridge.CreateBridge("UisKeyInput")
local function doinput(input,gameProcessedEvent)
    if not localentity() or localentity():GetState('Dead')  then return end 
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = key
    downtimer[key] = downtimer[key] or os.clock()
    if newKeyBinds:GetData() then
        for i,v in newKeyBinds:GetData() do
            local function second()
                if v[2] then
                    KeyDown:Fire(v[2],true)
                    downtimer[v[2]] = downtimer[v[2]] or os.clock()
                    if controls.Events[v[2]] then controls.Events[v[2]]:fire(key,true) end
                    controls.Functionsdown[v[2]] = controls.Functionsdown[v[2]] or {}
                    controls.Functionsdown[v[2]][key] = true
                    if itemhand.handleItemInput(v[2],true,controls,localentity()) then
                        return
                    end
                    if type(v[2]) == "string" then
                        if controls.func[v[2]] then
                            task.spawn(controls.func[v[2]],key,input)
                        end
                    else
                        task.spawn(v[2],key,input)
                    end
                end
            end
            if v[1] == key then
                second()
            elseif type(v[1]) == "table" then
                if table.find(v[1],key) then
                    second()
                end
            end 
        end
    end
end
function controls:IsDown(key)
    return self.KeysPressed[key] or controls.Functionsdown[key]
end
uis.InputBegan:Connect(doinput)
uis.InputChanged:Connect(function(i,g)
    local key = getkeyfrominput(i)
    if key == "mousewheel" then
        doinput(i,g)
    end
end)

uis.InputEnded:Connect(function(input, gameProcessedEvent)
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = nil
    downtimer[key] = nil
    for i,v in controls.Functionsdown do
        if v[key] then
            controls.Functionsdown[i][key] = nil
            if next(controls.Functionsdown[i]) == nil then
                KeyDown:Fire(i,false)
                controls.Functionsdown[i] = nil
                downtimer[i] = nil
                if controls.Events[i] then controls.Events[i]:fire(key,false) end
            end
        end
    end
end)
controls.Events = {}
local signal = require(game.ReplicatedStorage.Libarys.Signal)
function controls:GetInputEvent(name)
    if not controls.Events[name] then controls.Events = signal.new() end 
    return (controls.Events[name]::signal.Signal<string,boolean>)
end
function controls.renderupdate(dt)
    for i,v in controls.Render do
        task.spawn(v,dt)
    end
end
runservice.Heartbeat:Connect(controls.renderupdate)
runservice.RenderStepped:Connect(function(dt)
    for i,v in controls.RenderStepped do
        task.spawn(v,dt)
    end
end)
return controls