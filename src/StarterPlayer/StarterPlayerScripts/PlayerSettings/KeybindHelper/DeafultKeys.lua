local Keys = {}
--[[   <ID>  = {
    {<KEY1>,<KEY2>},
    {ACTIONS...},
    DisplayName?
    Section?
}
]]
Keys.Keyboard = {
    Forward = {'w',"Forward"},
    Left = {'a',"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
    Jump = {'space',"Jump"},
    Attack = {'mousebutton1',"Attack"},
    Interact = {'mousebutton2',"Interact"},
    Crouch = {"leftshift","Crouch"},
    HitBoxes = {'r','HitBoxes'},
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
    MouseWheel = {"mousewheel","HotBarUpdateWheel"},
    Inventory = {'e','Inventory'},
    DebugMenu = {'f3',"DebugMenu"},
    DropItem = {'q',"DropItem"},
    ["Camera Mode"] = {"f4","CameraMode"}
}

--<>
Keys.Touch = {}

--<>
Keys.Controller = {}

return Keys