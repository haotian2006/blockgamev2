local controls = {pc = {},mode = 'pc',func = {},mtick = {},RenderStepped = {}}
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local destroyblockEvent = bridge.CreateBridge("BlockBreak")
local placeBlockEvent = bridge.CreateBridge("BlockPlace")
local EntityBridge = bridge.CreateBridge("EntityBridge")
local qf = require(game.ReplicatedStorage.QuickFunctions)
local resource = require(game.ReplicatedStorage.ResourceHandler)
local data = require(game.ReplicatedStorage.DataHandler)
local Ray = require(game.ReplicatedStorage.Ray)
local camera = game.Workspace.CurrentCamera
local debugger = require(game.ReplicatedStorage.Debugger)
local anihandler = require(game.ReplicatedStorage.AnimationController)
local hotbarhandler = require(game.ReplicatedStorage.Managers.HotBarManager)
hotbarhandler:Init()
local lp = game.Players.LocalPlayer
local localentity = data.GetLocalPlayer
controls.pc = {
    Foward = {'w',"Foward"},-- Name = {key,function}
    Left = {{'a',"c"},"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
    Jump = {'space',"Jump"},
    Attack = {'mousebutton1',"Attack"},
    Interact = {'mousebutton2',"Interact"},
    Crouch = {"leftshift","Crouch"},
    HitBoxs = {'r','HitBoxs'},
    Freecam = {'e',"Freecam"},
    Slot1 = {'one',"HotBarUpdate"},
    Slot2 = {'two',"HotBarUpdate"},
    Slot3 = {'three',"HotBarUpdate"},
    Slot4 = {'four',"HotBarUpdate"},
    Slot5 = {'five',"HotBarUpdate"},
    Slot6 = {'six',"HotBarUpdate"},
    Slot7 = {'seven',"HotBarUpdate"},
    Slot8 = {'eight',"HotBarUpdate"},
    Slot9 = {'nine',"HotBarUpdate"},
    MouseWheel = {"mousewheel","HotBarUpdate"},
    F5 = {"q","F5"}
}
controls.KeysPressed = {}
controls.Render = {}
controls.Functionsdown = {}
local GPlayer = data.GLocalPlayer
local Camera = game.Workspace.CurrentCamera
local func = controls.func
local Render = controls.Render
local mtick = controls.mtick
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
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower()
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower()
    end
end
local ExtraJump = 0
local F5 = false
function func.F5()
    F5 = not F5
end
function func.HotBarUpdate(key,data)
    local slot = localentity().CurrentSlot or 1
    if data.UserInputType == Enum.UserInputType.MouseWheel then
        local upordown = data.Position.Z > 0 and "up" or "down"
        if upordown == "up" then
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
        for i,v in controls[controls.mode] do
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
end
function func.HandleJump()
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
    if not data.LocalPlayer.Crouching then
        data.LocalPlayer.Crouching = true
        data.LocalPlayer.Position += Vector3.new(0,-.3/2,0)
        data.LocalPlayer.HitBox = Vector2.new( data.LocalPlayer.HitBox.X, data.LocalPlayer.HitBox.Y-.3)
        data.LocalPlayer.EyeLevel -=.3
        data.LocalPlayer.Speed = 1.31
        data.LocalPlayer:PlayAnimation("Crouch")
    end
    data.LocalPlayer:UpdateModelPosition()
    repeat
        task.wait()
    until not FD["Crouch"]
    if data.LocalPlayer.Crouching then
        data.LocalPlayer.Crouching = false
        data.LocalPlayer.Position += Vector3.new(0,.3/2,0)
        data.LocalPlayer.HitBox = Vector2.new( data.LocalPlayer.HitBox.X, data.LocalPlayer.HitBox.Y+.3)
        data.LocalPlayer.EyeLevel +=.3
        data.LocalPlayer:StopAnimation("Crouch")
        data.LocalPlayer.Speed = 5.612
    end
    data.LocalPlayer:UpdateModelPosition()
end
function func.Interact()
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.GetNormal = true
   -- rayinfo.IgnoreEntities = true
    local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5,rayinfo)
    if #raystuff.Objects >= 1 then
        --print("hit")
        local newpos = {}
        for i,v:string|table in raystuff.Objects do
            --print(v.Normal)
            if  v.Type == "Block" then
                local coords = v.BlockPosition+v.Normal
                for i,v in data.EntitiesinR(coords.X,coords.Y,coords.Z,1.5) or {} do
                    local a = CollisionHandler.AABBcheck(v.Position+v:GetVelocity()*task.wait(),Vector3.new(coords.X,coords.Y,coords.Z),Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X),Vector3.new(1,1,1))
                    if a then
                        return
                    end
                end
                if not data.GetBlock(coords.X,coords.Y,coords.Z) then 
                    data.InsertBlock(coords.X,coords.Y,coords.Z,'Type|s%Cubic:Dirt')
                end
                localentity():PlayAnimation("Place",true)
                placeBlockEvent:Fire(coords)
            elseif v.Type == "Entity"  then
            
            end
        end
    end
end
function func.Attack()
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
    local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5,rayinfo)
    if #raystuff.Objects >= 1 then
        local newpos = {}
        for i,v in raystuff.Objects do
            if  v.Type == "Block" then
                local block = v.BlockPosition
                local blocktr = qf.DecompressBlockData(data.GetBlock(block.X,block.Y,block.Z),"Type")
                if blocktr == "Cubic:Bedrock" then return end 
                data.RemoveBlock(block.X,block.Y,block.Z)
                destroyblockEvent:Fire(block)
            elseif v.Type == "Entity"  then
                debugger.HighLightEntity(v.EntityId,1)
                game.ReplicatedStorage.Events.KB:FireServer(v.EntityId,CameraCFrame.LookVector)
            end
        end
    end
    data.LocalPlayer:PlayAnimation("Attack",true)
end
local last 
function Render.Update(dt)
    local self = data.LocalPlayer
    for i,v in data.LoadedEntities do
        v:Update(dt)
    end
    if checkempty(data.LocalPlayer) then return end 
    local neck =  self.Entity:FindFirstChild("Neck",true)
    local MainWeld = self.Entity:FindFirstChild("MainWeld",true)
    self.Entity.PrimaryPart.CFrame = CFrame.new(self.Position*3)
    EntityBridge:Fire(tostring(game.Players.LocalPlayer.UserId),self)
    self:ClearVelocity()
    anihandler.UpdateEntity(self)
end
function Render.Move(dt)
    if checkempty(data.LocalPlayer) then return end 
    local LookVector = CameraCFrame.LookVector
    local RightVector = CameraCFrame.RightVector
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)--
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)--
    local foward = LookVector*(FD["Foward"]and 1 or 0)
    local Back = -LookVector*(FD["Back"]and 1 or 0)
    local Left = -RightVector*(FD["Left"]and 1 or 0)
    local Right = RightVector*(FD["Right"]and 1 or 0)
    local velocity = foward + Back + Left+ Right
    data.LocalPlayer.bodydir = velocity
    velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit) * (data.LocalPlayer.Speed or 0 )
    data.LocalPlayer.Velocity["Movement"] = velocity
    if FD["Jump"] then data.LocalPlayer:Jump() 
end 
end
local follow = false
local oldyy = 180
local playerinfo = {}
local second 
local outline = game.Workspace.Outline
function controls.Render.OutLine()
    if next(localentity()) == nil then return end 
    local lookvector = CameraCFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
    --rayinfo.RaySize = Vector3.new(.01,.01,.01)
   -- rayinfo.IgnoreEntities = true
     local raystuff = Ray.Cast(localentity().Entity.Eye.Position/3,lookvector*5,rayinfo)
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
function controls.RenderStepped.Camera()
    lp.PlayerGui:WaitForChild("Hud")
    if not FD["Freecam"] then
        CameraCFrame = camera.CFrame
        uis.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    uis.MouseIconEnabled = false
    if not F5 then
        lp.PlayerGui:WaitForChild("Hud").Cursor.Visible = true
        lp.CameraMaxZoomDistance = 0.5
        lp.CameraMinZoomDistance = 0.5
    else
        lp.PlayerGui:WaitForChild("Hud").Cursor.Visible = false
        lp.CameraMaxZoomDistance = 6
        lp.CameraMinZoomDistance = 6
    end
    if not checkempty(data.LocalPlayer) then
        local Current_Entity = data.LocalPlayer.Entity
        second = second or Current_Entity:FindFirstChild("SecondLayer",true)
        local muti
        local entityw = Current_Entity
        local Torso = entityw:FindFirstChild("Torso",true)
        local neck =  entityw:FindFirstChild("Neck",true)
        local MainWeld = entityw:FindFirstChild("MainWeld",true)
        if neck and Torso and MainWeld then
            data.LocalPlayer:SetHeadRotationFromDir(CameraCFrame.LookVector*10)
        end
        data.LocalPlayer:UpdateRotationClient()
        if (camera.CFrame.Position - camera.Focus.Position).Magnitude < 0.6 and Current_Entity then
            data.GetLocalPlayer().VeiwMode = "First"
            for i,v in second and second:GetChildren() or {} do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 1 
                end
            end
            if playerinfo[1] == nil then
               for i,v in ipairs(Current_Entity:GetDescendants())do
                local success = pcall(function()  v["Transparency"] = v["Transparency"] end)
                    if success and v.Transparency == 0 then
                        table.insert(playerinfo,v)
                        v.Transparency =1
                    end
               end
            else
                for i,v in ipairs(playerinfo)do
                    if  v["Transparency"] then
                        v.Transparency =1
                    end
               end
            end
        elseif Current_Entity then
            data.GetLocalPlayer().VeiwMode = "Third"
            --print("not fps")
            --Player.PlayerGui.Arms.vp.Visible = false
            --second.Parent = Current_Entity:FindFirstChild("Model",true)
            for i,v in second and second:GetChildren() or {} do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 0 
                end
            end
            for i,v in ipairs(playerinfo)do
                if  v["Transparency"] then
                    v.Transparency =0
                end
           end
        end
    end

end
local function doinput(input,gameProcessedEvent)
    local key = getkeyfrominput(input)
    if gameProcessedEvent then return end 
    controls.KeysPressed[key] = key
    if controls[controls.mode] then
        for i,v in controls[controls.mode] do
            local function second()
                if v[2] then
                    controls.Functionsdown[v[2]] = controls.Functionsdown[v[2]] or {}
                    controls.Functionsdown[v[2]][key] = true
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
uis.InputBegan:Connect(doinput)
uis.InputChanged:Connect(function(i,g)
    local key = getkeyfrominput(i)
    if key == "mousewheel" then
        doinput(i,g)
    end
end)

uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end 
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = nil
    for i,v in controls.Functionsdown do
        if v[key] then
            controls.Functionsdown[i][key] = nil
            if next(controls.Functionsdown[i]) == nil then
                controls.Functionsdown[i] = nil
            end
        end
    end
end)
function controls.renderupdate(dt)
    for i,v in controls.Render do
        task.spawn(v,dt)
    end
end
task.spawn(function()
    local one = 1/60
    while task.wait(one) do
        for i,v in mtick do
            task.spawn(v)
        end
    end
end)
runservice.Heartbeat:Connect(controls.renderupdate)
runservice.RenderStepped:Connect(function(dt)
    for i,v in controls.RenderStepped do
        task.spawn(v,dt)
    end
end)
return controls