local controls = {pc = {},mode = 'pc',func = {}}
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local data = require(game.ReplicatedStorage.DataHandler)
controls.pc = {
    Foward = {'w',"Foward"},-- Name = {key,function}
    Left = {{'a',"c"},"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
    Jump = {'space',"Jump"},
}
controls.KeysPressed = {}
controls.Render = {}
controls.Functionsdown = {}
local GPlayer = data.GLocalPlayer
local Camera = game.Workspace.CurrentCamera
local func = controls.func
local Render = controls.Render
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
function func.HandleJump()
    if  GPlayer.Jumping == true then return end
    local e 
    local jumpedamount =0 
    local jumpheight =  3
    local muti = jumpheight
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local jump = jumpheight*muti
        if GPlayer.Grounded  and not GPlayer.Jumping then
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
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower()
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower()
    end
end
local speed = 5.612
function GetVelocity(self):Vector3
    local x,y,z = 0,0,0
    for i,v in self.Velocity do
        if typeof(v) == "Vector3" then
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
function Render.UpdateEntity(dt)
    if not data.LocalPlayer or not next(data.LocalPlayer) then return end 
    local self = data.LocalPlayer
    self.Position = data.GLocalPlayer.Position
    local velocity = GetVelocity(self)
    local p2 = interpolate(self.Position,self.Position+velocity,dt) 
    velocity = (p2-self.Position)
    local newp = CollisionHandler.entityvsterrain(self,velocity)--self.Position + self:GetVelocity()--
    data.GLocalPlayer.Grounded = CollisionHandler.IsGrounded(self)
    self.Entity.Position = newp*3
    data.GLocalPlayer.Position = newp
end
function Render.Move(dt)
    if not data.LocalPlayer or not next(data.LocalPlayer) then return end 
    local LookVector = Camera.CFrame.LookVector
    local RightVector = Camera.CFrame.RightVector
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)--
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)--
    local foward = LookVector*(FD["Foward"]and 1 or 0)
    local Back = -LookVector*(FD["Back"]and 1 or 0)
    local Left = -RightVector*(FD["Left"]and 1 or 0)
    local Right = RightVector*(FD["Right"]and 1 or 0)
    local velocity = foward + Back + Left+ Right
    velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit) *speed 
    data.GLocalPlayer.Velocity["Movement"] = velocity
    if FD["Jump"] then func.HandleJump() end 
   -- game.ReplicatedStorage.Events.SendEntities:FireServer(velocity)
end
function Render.Fall(dt)
    local entity =   data.LocalPlayer
    if not entity or not next(entity) or not GPlayer or not next(GPlayer) or false  then return end 
    local cx,cz = qf.GetChunkfromReal(GPlayer.Position.X,GPlayer.Position.Y,GPlayer.Position.Z,true)
    if not data.GetChunk(cx,cz) then return end 
    data.GLocalPlayer.FallTicks = data.GLocalPlayer.FallTicks or 0
    local max = 5
    local fallrate = (((0.99^data.GLocalPlayer.FallTicks)-1)*max)*max

    if data.GLocalPlayer.Grounded  or data.GLocalPlayer.Jumping  then -- or not entity.CanFall
        data.GLocalPlayer.Velocity.Fall = Vector3.new(0,0,0) 
        data.GLocalPlayer.IsFalling = false
        data.GLocalPlayer.FallTicks = 0
    elseif not data.GLocalPlayer.Grounded  then
        data.GLocalPlayer.FallTicks += 1
        data.GLocalPlayer.Velocity.Fall = Vector3.new(0,fallrate,0) 
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
runservice.Heartbeat:Connect(controls.renderupdate)
return controls