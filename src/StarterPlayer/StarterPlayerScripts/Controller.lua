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
local lp = game.Players.LocalPlayer
controls.pc = {
    Foward = {'w',"Foward"},-- Name = {key,function}
    Left = {{'a',"c"},"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
    Jump = {'space',"Jump"},
    Attack = {'mousebutton1',"Attack"},
    Interact = {'mousebutton2',"Interact"},
    Crouch = {"leftshift","Crouch"},
    HitBoxs = {'f3','HitBoxs'}
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
local CrouchEvent = bridge.CreateBridge("CrouchEvent")
function func.Crouch()
    if data.LocalPlayer.Crouching then
        data.LocalPlayer.Crouching = false
        data.LocalPlayer.Position += Vector3.new(0,.3/2,0)
        data.LocalPlayer.HitBox = Vector2.new( data.LocalPlayer.HitBox.X, data.LocalPlayer.HitBox.Y+.3)
        data.LocalPlayer.EyeLevel +=.3
    else
        data.LocalPlayer.Crouching = true
        data.LocalPlayer.Position += Vector3.new(0,-.3/2,0)
        data.LocalPlayer.HitBox = Vector2.new( data.LocalPlayer.HitBox.X, data.LocalPlayer.HitBox.Y-.3)
        data.LocalPlayer.EyeLevel -=.3
    end
    data.LocalPlayer:UpdateModelPosition()
end
function func.Interact()
    local lookvector = Camera.CFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.GetNormal = true
   -- rayinfo.IgnoreEntities = true
    local raystuff = Ray.Cast(Camera.CFrame.Position/3,lookvector*5,rayinfo)
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
                placeBlockEvent:Fire(coords)
            elseif v.Type == "Entity"  then
            
            end
        end
    end
end
function func.Attack()
    local lookvector = Camera.CFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
   -- rayinfo.IgnoreEntities = true
    local raystuff = Ray.Cast(Camera.CFrame.Position/3,lookvector*5,rayinfo)
    if #raystuff.Objects >= 1 then
        --print("hit")
        local newpos = {}
        for i,v in raystuff.Objects do
            if  v.Type == "Block" then
                destroyblockEvent:Fire(v.BlockPosition)
            elseif v.Type == "Entity"  then
                debugger.HighLightEntity(v.EntityId,1)
                game.ReplicatedStorage.Events.KB:FireServer(v.EntityId,Camera.CFrame.LookVector)
            end
        end
       -- debugger.HighLightMutiBlocks(newpos)
       -- debugger.HighLightEntity(raystuff[1],1)
    end
end
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower()
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower()
    end
end
function GetVelocity(self):Vector3
    local x,y,z = 0,0,0
    for i,v in self.Velocity do
        if typeof(v) == "Vector3" and v == v then
            x+= v.X 
            y+= v.Y
            z+= v.Z
        end
    end
    if x == 0 then
        x = 0.00000001
    end
    if z == 0 then
        z = 0.00000001
    end
    return Vector3.new(x,y,z)
end
local last 
--[[
function Render.UpdateEntity(dt)
    if checkempty(data.LocalPlayer) then return end 
    local self = data.LocalPlayer
    self.Position = data.GLocalPlayer.Position
    local velocity = GetVelocity(self)
    local p2 = interpolate(self.Position,self.Position+velocity,dt) 
    velocity = (p2-self.Position)
    local newp = CollisionHandler.entityvsterrain(self,velocity)--self.Position + self:GetVelocity()--
    local g = CollisionHandler.IsGrounded(self)
    if last and not g and not GPlayer.Jumping then
        ExtraJump = DateTime.now().UnixTimestampMillis/1000
    end
    data.GLocalPlayer.Grounded = g
    last = g
    self.Entity.PrimaryPart.CFrame = CFrame.new(newp*3)
    data.GLocalPlayer.Position = newp
    local neck =  self.Entity:FindFirstChild("Neck",true)
    local MainWeld = self.Entity:FindFirstChild("MainWeld",true)
    local plrmodel = resource.GetEntityModelFromData(data.LocalPlayer)
    local eneck = plrmodel:FindFirstChild("Neck",true)
    local eMainWeld = plrmodel:FindFirstChild("MainWeld",true)
    EntityBridge:Fire(newp,{Neck = neck.C0.Rotation*eneck.C0.Rotation:Inverse(),MainWeld = MainWeld.C0.Rotation*MainWeld.C0.Rotation:Inverse()})
end]]
function Render.Update(dt)
    local self = data.LocalPlayer
    for i,v in data.LoadedEntities do
        v:Update(dt)
    end
    if checkempty(data.LocalPlayer) then return end 
    local neck =  self.Entity:FindFirstChild("Neck",true)
    local MainWeld = self.Entity:FindFirstChild("MainWeld",true)
    local plrmodel = resource.GetEntityModelFromData(data.LocalPlayer)
    local eneck = plrmodel:FindFirstChild("Neck",true)
    local eMainWeld = plrmodel:FindFirstChild("MainWeld",true)
    self.Entity.PrimaryPart.CFrame = CFrame.new(self.Position*3)
    EntityBridge:Fire(self.Position,{Neck = neck.C0.Rotation*eneck.C0.Rotation:Inverse(),MainWeld = MainWeld.C0.Rotation*eMainWeld.C0.Rotation:Inverse()},{Crouching = self.Crouching})
    self:ClearVelocity()
end
function Render.Move(dt)
    if checkempty(data.LocalPlayer) then return end 
    local LookVector = Camera.CFrame.LookVector
    local RightVector = Camera.CFrame.RightVector
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)--
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)--
    local foward = LookVector*(FD["Foward"]and 1 or 0)
    local Back = -LookVector*(FD["Back"]and 1 or 0)
    local Left = -RightVector*(FD["Left"]and 1 or 0)
    local Right = RightVector*(FD["Right"]and 1 or 0)
    local velocity = foward + Back + Left+ Right
    velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit) * (data.LocalPlayer.Speed or 0 )
    data.LocalPlayer.Velocity["Movement"] = velocity
    if FD["Jump"] then data.LocalPlayer:Jump() 
end 
   -- game.ReplicatedStorage.Events.SendEntities:FireServer(velocity)
end
function mtick.Fall()
    -- local entity =   data.LocalPlayer
    -- if  checkempty(entity) or  checkempty(entity) or false  then return end 
    -- local cx,cz = qf.GetChunkfromReal(GPlayer.Position.X,GPlayer.Position.Y,GPlayer.Position.Z,true)
    -- if not data.GetChunk(cx,cz) then return end 
    -- data.GLocalPlayer.FallTicks = data.GLocalPlayer.FallTicks or 0
    -- local max = entity.FallRate or 150
    -- local fallrate =(((0.99^data.GLocalPlayer.FallTicks)-1)*max)/1.4

    -- if data.GLocalPlayer.Grounded  or data.GLocalPlayer.Jumping  then -- or not entity.CanFall
    --     data.GLocalPlayer.Velocity.Fall = Vector3.new(0,0,0) 
    --     data.GLocalPlayer.IsFalling = false
    --     data.GLocalPlayer.FallTicks = 0
    -- elseif not data.GLocalPlayer.Grounded  then
    --     data.GLocalPlayer.FallTicks += 1
    --     data.GLocalPlayer.Velocity.Fall = Vector3.new(0,fallrate,0) 
    -- end

end
local follow = false
local oldyy = 180
local playerinfo = {}
local second 
local outline = game.Workspace.Outline
function controls.Render.OutLine()
    local lookvector = Camera.CFrame.LookVector
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {tostring(lp.UserId)}
    rayinfo.Debug = false
    --rayinfo.RaySize = Vector3.new(.01,.01,.01)
   -- rayinfo.IgnoreEntities = true
    local raystuff = Ray.Cast(Camera.CFrame.Position/3,lookvector*5,rayinfo)
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
    if not checkempty(data.LocalPlayer) then
        local Current_Entity = data.LocalPlayer.Entity
        second = second or Current_Entity:FindFirstChild("SecondLayer",true)
        local muti
        local entityw = Current_Entity
        local Torso = entityw:FindFirstChild("Torso",true)
        local neck =  entityw:FindFirstChild("Neck",true)
        local MainWeld = entityw:FindFirstChild("MainWeld",true)
        if neck and Torso and MainWeld then
            local upordown = math.sign(camera.CFrame.LookVector.Unit:Dot(Vector3.new(0,1,0)))
            local goalCF = CFrame.lookAt(neck.Part1.Position, neck.Part1.Position+camera.CFrame.LookVector, Torso.CFrame.UpVector)
            local xx, yy, zz = qf.worldCFrameToC0ObjectSpace(neck,goalCF):ToOrientation()
            if math.abs(math.deg(yy)) <= 125 and upordown ==-1 then
            follow = true
            end
            if math.abs(math.deg(yy)) >= 55 and upordown == 1 then
                follow = true
            end
            if (oldyy < math.abs(yy) and upordown == -1 )or  (oldyy > math.abs(yy) and upordown == 1 ) then
                follow = false
            end

            if (FD["Foward"]) and not (FD["Back"]) or not (FD["Foward"]) and (FD["Back"])  and not (FD["Left"]) and not (FD["Right"]) then
                muti = 0
            end
            if ((FD["Foward"]) and (FD["Left"]) ) or  (FD["Left"]) and not (FD["Back"]) and not (FD["Right"]) then
                muti = 120
            end
            if ((FD["Foward"]) and (FD["Right"])) or (FD["Right"]) and not (FD["Left"]) and  not (FD["Back"])  then
                muti = -120
            end
            if not (FD["Foward"]) and not (FD["Left"]) and  (FD["Back"]) and (FD["Right"]) then
                muti = 120
            end
            if not (FD["Foward"]) and  (FD["Left"]) and   (FD["Back"])   then
                muti = -120
            end
            if follow ==true or muti then
                local pos =  MainWeld.C0.Position
                local mad = muti
                muti = muti or (upordown == 1 and 50 or 120)
                xx, yy, zz = qf.worldCFrameToC0ObjectSpace(MainWeld,goalCF*CFrame.fromOrientation(0,muti*(mad and 1 or math.sign(yy)),0)):ToOrientation()
                game:GetService("TweenService"):Create(MainWeld,TweenInfo.new(0.1),{C0 = CFrame.new(pos.X, pos.Y, pos.Z)*CFrame.fromOrientation(0,yy,0)}):Play()
                -- MainWeld.C0 = CFrame.new(pos.X, pos.Y, pos.Z)*CFrame.fromOrientation(0,yy,0)
            end
            xx, yy, zz = qf.worldCFrameToC0ObjectSpace(neck,goalCF):ToOrientation()
            -- game:GetService("TweenService"):Create(neck,TweenInfo.new(1),{C0 = CFrame.new( neck.C0.X,  neck.C0.Y,  neck.C0.Z)*CFrame.fromOrientation(xx,yy,zz)}):Play()
        neck.C0 = CFrame.new( neck.C0.X,  neck.C0.Y,  neck.C0.Z)*CFrame.fromOrientation(xx,yy,zz)--refunction.worldCFrameToC0ObjectSpace(neck,goalCF)
            oldyy = math.abs(yy)
        end
        if (camera.CFrame.Position - camera.Focus.Position).Magnitude < 0.6 and Current_Entity then
            --print("fps")
           -- Player.PlayerGui.Arms.vp.Visible = true
            second.Parent = nil
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
            --print("not fps")
            --Player.PlayerGui.Arms.vp.Visible = false
            second.Parent = Current_Entity:FindFirstChild("Model",true)
            for i,v in ipairs(playerinfo)do
                if  v["Transparency"] then
                    v.Transparency =0
                end
           end
        end
    end

end
uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end 
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = key
    if controls[controls.mode] then
        for i,v in controls[controls.mode] do
            local function second()
                if v[2] then
                    if type(v[2]) == "string" then
                        if controls.func[v[2]] then
                            task.spawn(controls.func[v[2]],key)
                        end
                    else
                        task.spawn(v[2],key)
                    end
                    controls.Functionsdown[v[2]] = controls.Functionsdown[v[2]] or {}
                    controls.Functionsdown[v[2]][key] = true
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