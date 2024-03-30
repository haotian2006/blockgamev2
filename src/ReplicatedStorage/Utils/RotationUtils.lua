local r = {}
local mathUtil = require(game.ReplicatedStorage.Libs.MathFunctions)
r.indexPairs = {
    "0,0,0",
    "-0,-0,-1",
    "-0,-0,0",
    "-0,-0,1",
    "-0,-1,-0",
    "-0,-1,-1",
    "-0,-1,0",
    "-0,-1,1",
    "-0,0,-0",
    "-0,0,-1",
    "-0,0,0", 
    "-0,0,1",
    "-0,1,-0",
    "-0,1,-1",
    "-0,1,0",
    "-0,1,1",
    "-1,-0,-0",
    "-1,-0,0",
    "-1,-1,-0",
    "-1,-1,0",
    "-1,0,-0",
    "-1,0,0",
    "-1,1,-0",
    "-1,1,0",
    "0,-0,-0",
    "0,-0,-1",
    "0,-0,0",
    "0,-0,1",
    "0,-1,-0",
    "0,-1,-1",
    "0,-1,0",
    "0,-1,1",
    "0,0,-0",
    "0,0,-1",
    "-0,-0,-0",
    "0,0,1",
    "0,1,-0",
    "0,1,-1",
    "0,1,0",
    "0,1,1",
    "1,-0,-0",
    "1,-0,0",
    "1,-1,-0",
    "1,-1,0",
    "1,0,-0",
    "1,0,0",
    "1,1,-0",
    "1,1,0"
}
r.keyPairs = {
    ["0,0,0"] = 1,
    ["-0,-0,-1"] = 2,
    ["-0,-0,0"] = 3,
    ["-0,-0,1"] = 4,
    ["-0,-1,-0"] = 5,
    ["-0,-1,-1"] = 6,
    ["-0,-1,0"] = 7,
    ["-0,-1,1"] = 8,
    ["-0,0,-0"] = 9,
    ["-0,0,-1"] = 10,
    ["-0,0,0"] = 11,
    ["-0,0,1"] = 12,
    ["-0,1,-0"] = 13,
    ["-0,1,-1"] = 14,
    ["-0,1,0"] = 15,
    ["-0,1,1"] = 16,
    ["-1,-0,-0"] = 17,
    ["-1,-0,0"] = 18,
    ["-1,-1,-0"] = 19,
    ["-1,-1,0"] = 20,
    ["-1,0,-0"] = 21,
    ["-1,0,0"] = 22,
    ["-1,1,-0"] = 23,
    ["-1,1,0"] = 24,
    ["0,-0,-0"] = 25,
    ["0,-0,-1"] = 26,
    ["0,-0,0"] = 27,
    ["0,-0,1"] = 28,
    ["0,-1,-0"] = 29,
    ["0,-1,-1"] = 30,
    ["0,-1,0"] = 31,
    ["0,-1,1"] = 32,
    ["0,0,-0"] = 33,
    ["0,0,-1"] = 34,
    ["-0,-0,-0"] = 35,
    ["0,0,1"] = 36,
    ["0,1,-0"] = 37,
    ["0,1,-1"] = 38,
    ["0,1,0"] = 39,
    ["0,1,1"] = 40,
    ["1,-0,-0"] = 41,
    ["1,-0,0"] = 42,
    ["1,-1,-0"] = 43,
    ["1,-1,0"] = 44,
    ["1,0,-0"] = 45,
    ["1,0,0"] = 46,
    ["1,1,-0"] = 47,
    ["1,1,0"] = 48
}
local tableCache = {}
function r.convertToTable(str:string)
    if tableCache[str] then return tableCache[str] end 
    local function convert(x)
        if x == '0' then
            x = 0
        elseif x == '-0' then
            x = 180
        elseif x == '1' then
            x = 90
        elseif x == '-1' then
            x = -90
        else 
            x = 0
        end
        return (tonumber(x) or 0)
    end
    local x,y,z = str:match("([^,]*),?([^,]*),?([^,]*)")
    local v = {convert(x),convert(y),convert(z)}
    tableCache[str]  = v
    return v
end
function r.convertToCFrame(str:string)
    local t = r.convertToTable(str)
    return CFrame.fromOrientation(unpack(t))
end
function r.calculateRotationFromData(block,blockHitData,rayData)
    local coords = blockHitData.BlockPosition+blockHitData.Normal
    local hitpos = blockHitData.PointOfInt
    local orientation
    if block and block.components then
        block = block.components
        orientation = {0,0,0}
        local Direction = rayData.Direction
        local angle = mathUtil.GetAngleDL(Direction) 
        local dx = math.abs(Direction.X)
        local dz = math.abs(Direction.Z)
        if dx < dz then
            dx = 0
            dz = Direction.Z / dz
        else
            dz = 0
            dx = Direction.X/dx
        end
        if (dx == -1 or dx == 1) and block.RotateY then orientation[2] = dx end
        if dz == -1 and block.RotateY then
                orientation[2] = '-0'
        elseif  dz == 1 then
            orientation[3] = 0
        end
        if hitpos.Y >  coords.Y and block.RotateZ then  
            orientation[3] = '-0'
        else
        end
        if angle >=-41 and angle <= - 39 and block.RotateX then
            orientation[1] = 1
        elseif angle >= 39 and angle <=  41 and block.RotateX then
            orientation[1] = -1
        end
        orientation = (orientation[1]..','..orientation[2]..','..orientation[3])
        if orientation == '0,0,0' then 
            orientation =nil
        end
    end
    return orientation
end
return table.freeze(r)