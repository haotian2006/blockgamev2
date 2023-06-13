local controls = {}
local run = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
controls.Keyboard = {
    Foward = {'w',"Foward"},
    Left = {'a',"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
    Jump = {'space',"Jump"},
    Attack = {'mousebutton1',"Attack"},
    Interact = {'mousebutton2',"Interact"},
    Crouch = {"leftshift","Crouch"},
    HitBoxs = {'r','HitBoxs'},
    Freecam = {'t',"Freecam"},
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
    Inventory = {'e','Inventory'},
    F5 = {"q","F5"}
}
controls.TOUCH = {
    
}
controls.CONTROLLER = {
    
}
controls.Mode = "Keyboard"
controls.__index = controls
function controls.new(data)
    local self = setmetatable(data or {},controls)
    if run:IsClient() then
       UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
        local lastvalue = lastInputType.Value
        if lastvalue == 8 then--keyboard
            self.Mode = "Keyboard"
        elseif lastvalue >=0 and lastvalue <=4 then--mouse
        elseif lastvalue == 7 then--touch
            self.Mode = "TOUCH"
        elseif lastvalue >=12 and lastvalue<=19 then--gamepad
            self.Mode = "CONTROLLER"  
        end
       end)
    end
    return self
end
function controls:GetData()
    return self[self.Mode] 
end
function controls:GetDeafult()
    return controls
end
function controls:AddInput(Description:string,KeyBinds:{string}|string,BoolFuncName:string,Mode:string)
    
end
function controls.newButton(Icon,text)
    
end
function controls.moveButton()
    
end
return controls