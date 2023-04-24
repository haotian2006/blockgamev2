local Components = {}
Components.BlockComp = {
    CanFloat = true,
    Gravity = nil,
    Hardness = 1, 
    CanCollide = true,
    BlastResistance = 0,
    CanRotate = false,
    Hitbox = 'Normal',
    Transparency = false,-- should blocks render behind 
    RotateX = false,
    RotateY = false,
    RotateZ = false,
}
Components.Inputs = {
    HoldTime = 0,
    AlsoHold = {},
    HasToLetGo = false,
    Trigger = nil
} 
Components.PlaceBlock = {
    Block = "self.HoldingItem",
    At = 'Hit.Position',
    Offset = Vector3.zero,
    Size = Vector3.one,
    Direaction = 'Hit.Direaction'
}
return Components