local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Controller = {}
local Data = require(game.ReplicatedStorage.Data) 
local PlayerSettingsPath = script.Parent:WaitForChild("PlayerSettings")
local KeyBinds = require(PlayerSettingsPath:WaitForChild("KeybindHelper"))
local Signal = require(game.ReplicatedStorage.Libs.Signal)
local TempSignal = require(script.TempSignal)
Data.set("PlayerController",script) 
local State = "Keyboard"
local ActionsDown = {}
local events = {}
local TempEvents = {}
local RenderEvents = {}
local InGui = false

local InputBegan = Signal.protected()
local InputEnded = Signal.protected()

local Types = require(game.ReplicatedStorage.Core.Types)


export type ControllerEvent = Types.ControllerEvent
export type TempControllerEvent = Types.TempControllerEvent


Controller.getKeyFromInput = KeyBinds.getKeyFromInput


function Controller.getState()
    return State
end
function Controller.createTemporaryEventTo(Action): TempControllerEvent
    local sign =TempSignal.new(Action,TempEvents)
    return sign
end
function Controller.getOrCreateEventTo(Action): ControllerEvent 
    if events[Action] then
        return events[Action]
    end
    local si = Signal.new()
    events[Action] = si
    return si
end
function Controller.destroyAllEventsFor(Action)
    local data =  events[Action]
    if not data then return end 
    data:DisconnectAll()
    events[Action] = nil 
end
local BindedFunctions = {}
local keyPairsBinded = {}

function  Controller.bindToRender(Name,priority,fx)
   RunService:BindToRenderStep(`InputHandler|{Name}`, priority, fx)
end

function  Controller.unbindFromRender(Name)
    RunService:UnbindFromRenderStep(`InputHandler|{Name}`)
end

function Controller.bindFunctionTo(Name,func,action,priority,notGPE,notInGui)
    if BindedFunctions[Name] then  warn(`{Name} is already Binded`) end 
    local d = {action,func,priority or 20,notGPE,notInGui}
    BindedFunctions[Name] = d
    keyPairsBinded[action] = keyPairsBinded[action] or {}
    table.insert(keyPairsBinded[action],d)
    table.sort(keyPairsBinded[action],function(a,b)
        return a[3]<b[3]
    end)
end

function Controller.unbindFunction(name)
    local d = BindedFunctions[name]
    if not d then return end 
    local parent = keyPairsBinded[d[1]]
    BindedFunctions[name] = nil
    table.remove(parent,table.find(parent,d))
    if next(parent) == nil then
        keyPairsBinded[d[1]] = nil
    end
end
 
local function runFunctions(action,input,down,IsTyping,keys)
    local InGui = Controller.inGui()
    for i,v in keyPairsBinded[action] or {} do 
        local notGPE,notInGui = v[4],v[5]
        if InGui and notInGui then continue end 
        if IsTyping and notGPE then continue end 

        local status =  v[2](input,down,IsTyping,keys)
        if status == true then --Enum.ContextActionResult.Sink
            break
        end
    end
end 

function Controller.isDown(action)
    return ActionsDown[action] or false
end

function Controller.inGui()
    return InGui
end

function Controller.setGui(bool)
    InGui = bool
end

local enabled = true
UserInputService.InputBegan:Connect(function(keycode)
    if keycode.KeyCode == Enum.KeyCode.Y then
       -- enabled = not enabled
    end
end)


local function HandleInputBegan(input,IsTyping)
    if not enabled then return end 
   local actions = KeyBinds.getActionsFromKey(input)
   for v,keys in actions do
        InputBegan:Fire(v,IsTyping,keys)
        ActionsDown[v] = true
        if events[v] then
            events[v]:Fire(input,true,IsTyping,keys)
        end
        if TempEvents[v] then 
            for i,event in TempEvents[v] do
                event:Fire(input,true,IsTyping,keys)
            end
        end
        if  keyPairsBinded[v] then
            task.spawn(runFunctions,v,input,true,IsTyping,keys)
        end
   end
end
local function HandleInputEnded(input,IsTyping)
    if not enabled then return end 
    local actions = KeyBinds.getActionsFromKey(input)
   for v,keys in actions do
        InputEnded:Fire(input,IsTyping,keys)
        ActionsDown[v] = nil
        if events[v] then
            events[v]:Fire(input,false,IsTyping,keys)
        end
        if TempEvents[v] then
            for i,event in TempEvents[v] do
                event:Fire(input,false,IsTyping,keys)
            end
        end
        if  keyPairsBinded[v] then
            task.spawn(runFunctions,v,input,false,IsTyping,keys)
        end
   end
end

Controller.InputBegan = InputBegan.Event
Controller.InputEnded = InputEnded.Event
Controller.UISInputEnded = UserInputService.InputEnded
Controller.UISInputBegan = UserInputService.InputBegan
Controller.UISInputChanged = UserInputService.InputChanged
Controller.UISKeyDown = function(keycode:Enum.KeyCode)
    return UserInputService:IsKeyDown(keycode)
end


UserInputService.InputChanged:Connect(HandleInputBegan)
UserInputService.InputBegan:Connect(HandleInputBegan)
UserInputService.InputEnded:Connect(HandleInputEnded)
UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
    local lastvalue = lastInputType.Value
    if lastvalue == 8 then--keyboard
        State = KeyBinds.setCurrentState("Keyboard")
    elseif lastvalue >=0 and lastvalue <=4 then--mouse
    
    elseif lastvalue == 7 then--touch
        State = KeyBinds.setCurrentState("Touch")
    elseif lastvalue >=12 and lastvalue<=19 then--gamepad
        State = KeyBinds.setCurrentState("Controller")
    end
   end)
return table.freeze(Controller)