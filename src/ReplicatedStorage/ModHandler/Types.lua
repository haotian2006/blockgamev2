local Players = game:GetService("Players")
--//math
export type Line = typeof(setmetatable({}, {})) & {
    p1:Point,
    p2:Point,
    
    CalculateSlopeAndB: (self:Line) -> ( number, number),
    Length: (self:Line) -> number,
    CalculateMidPoint: (self:Line) -> Point,
    CalculatePointOfInt: (self:Line, Other:Line) -> Point|nil
}
export type Point = typeof(setmetatable({}, {})) & {
    x:number,
    y:number,
    DistanceFromPoint: (self:Point,p:Point) -> number,
    ToVector2: (self:Point) -> Vector2,
}
export type Math = {
    newPoint : (x:number,y:number) -> (),
    newLine:(p1:Point,p2:Point) -> Line,
    worldCFrameToC0ObjectSpace: (motor6DJoint:Motor6D,worldCFrame:CFrame) -> CFrame,
    angle_between: (n:number, a:number ,b:number) -> boolean, 
    GetClosestNumber: (num:number,tab:{number}) -> number,
    lerp: (start:number,goal:number,dt:number) -> number,
    GetXYfromangle: (angle:number,radius:number,center:number) ->number,
    AngleDifference: (angle1:number,angle2:number ) -> number,
    ReflectAngleAcrossY: (dt:number) -> number,
    NegativeToPos: (dt:number) -> number,
    PosToNegative:(dt:number) -> number,
    GetAngleDL: (originalRayVector:number) ->number
}
--\\

export type Functions = {

}
export type DataHandler = {

}
export type Debris = {

}
export type Compresser = {

}
export type Manager = {
    ArmsManager:{}
}
export type Behaviors = {

}
export type Resources = {

}
export type Settings = {

}
export type Ray = {

}
export type Remote = typeof(setmetatable({}, {})) & {
	OnClientEvent:RBXScriptSignal,
	OnServerEvent:RBXScriptSignal,
	Event:RBXScriptSignal,

    GetRemote:(Name:string) -> Remote,
	FireClient:(self:Remote,player:Player,...any) ->nil,
	FireAllClients:(self:Remote,...any) ->nil,
    FireServer:(self:Remote,...any) ->nil,
    Disconnect:(self:Remote)->nil,

}
export type AnimationController = {

}
export type ItemHandler = {

}



--//Movers
export type MoveTo = typeof(setmetatable({}, {})) & {

}
export type Curve = typeof(setmetatable({}, {})) & {
    
}
export type EntityMover = typeof(setmetatable({}, {})) & {
    
}

--\\

export type Entity = typeof(setmetatable({}, {})) & {
    Id:string,
    Position:Vector3,
    Type:string,
    Velocity:{string: Vector3},
    Data:{},
    Crouching:boolean,
    Entity:Model|nil,
    NotSaved:{
        behaviors:{},
        NoClear:{},
    },
    PlayingAnimations:{},
    --//shared
    IndexFromComponets: (self:Entity,key:any,ignore:{}|nil) -> (any,boolean|string),
    GetAllData:(self:Entity,SPECIAL:boolean) -> {},
    new: (data:{}) -> Entity,
    UpdateChunk: (self:Entity) -> nil,
    UpdateIdleAni: (self:Entity) ->nil,
    UpdateHandSlot: (self:Entity,slot:number) ->nil,
    GetVelocity: (self:Entity) -> Vector3,
    GetItemFromSlot: (slot:number) -> (number,string),
    GetQf:() -> Functions,
    GetData:() ->DataHandler,
    CanCrouch: (self:Entity) -> boolean,
    Crouch: (self:Entity,letgo:boolean) -> nil,
    GetPropertyWithMulti:(self:Entity,name:string) -> number,
    GPWM:(self:Entity,name:string) -> number,
    GetEyePosition: (self:Entity) ->Vector3,
    GetFeetPosition: (self:Entity) ->Vector3,
    AddVelocity: (self:Entity,Name:string,Velocity:Vector3) -> nil,
    AddToNoClear: (self:Entity,name:string) -> nil,
    RemoveFromNoClear: (self:Entity,name:string) -> nil,
    ClearVelocity: (self:Entity) ->nil,
    CloneProperties: (self:Entity, x:{}|nil) ->{},
    RemoveFromChunk: (self:Entity) -> nil,
    SetBodyRotationDir: (self:Entity,dir:Vector3) -> nil,
    SetHeadRotationDir: (self:Entity,dir:Vector3) -> nil,
    TurnTo: (self:Entity,Position:Vector3,timetotake:number|nil) ->nil,
    LookAt:(self:Entity,Position:Vector3,timetotake:number|nil) ->nil,
    KnockBack:(self:Entity,force:Vector3,time:number|nil) ->nil,
    MoveTo: (self:Entity,x:number,y:number,z:number) -> MoveTo,
    IsClientControl: (self:Entity) ->boolean,
    SetPosition: (self:Entity,position: Vector3)->nil,
    PlayAnimation: (self:Entity,Name:string,PlayOnce:boolean|nil) -> nil,
    StopAnimation: (self:Entity,Name:string) -> nil,
    SetBodyVelocity: (self:Entity,name:string,velocity:Vector3) -> nil,
    GetBodyVelocity: (self:Entity,name:string) -> Vector3|nil,
    Jump: (self:Entity) -> nil,
    SetState: (self:Entity,state:string,value:any) -> nil,
    GetState: (self:Entity,state:string) -> any,
    GetStateData: (self:Entity,state:string,target:string) -> any ,
    OnDeath: (self:Entity) -> nil,
    Destroy: (self:Entity) -> nil,
     
    --//client
    OnHarmed: (self:Entity,dmg:number) ->nil,
    LoadAnimation: (self:Entity,Name:string) -> nil,
    UpdateRotationClient: (self:Entity) ->nil,
    SetModelTransparency: (self:Entity, value:number) ->nil,

    --//server
    AddComponentGroup: (self:Entity,name:string,index:number | nil) ->nil,
    RemoveComponentGroup: (self:Entity,name:string) ->nil,
    Damage:(self:Entity,amt:number) ->nil,
    Kill:(self:Entity) ->nil,
    SetNetworkOwner: (self:Entity,Players:Player | nil) ->nil,
}   
--//other
export type InputData = {
    ItemData : {},
    Index:number,
    Item:string,
    InputData:{},
    Input:string,
    IsDown:boolean,
    Controls:{
        GetInputEvent:(name:string) -> RBXScriptSignal,
        IsDown: (key:string) -> boolean,


    },
    ItemHandler:{},
    Player:Player
}
return {} 
