local Components = {}
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