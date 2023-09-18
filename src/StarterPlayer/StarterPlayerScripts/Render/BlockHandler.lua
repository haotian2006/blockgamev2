local module = {}
local vector3 = Vector3.new
local rotationData = require(game.ReplicatedStorage.Libarys.RotationData)
local gameSetting = require(game.ReplicatedStorage.GameSettings)
local resourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local gridS = gameSetting.GridSize
local function split(string:string)
    return string:match("([^,]*),?([^,]*),?([^,]*)")
end
module.RotateStuff = {
    ["0,0,0"] = function(size)
        return size
    end,
    ["1,0,0"] = function(size)
        return vector3(size.X,size.Z,size.Y)  
    end,
    ["0,1,0"] = function(size)
        return vector3(size.Z,size.Y,size.X)
    end,
    ["0,0,1"] = function(size)
        return vector3(size.Y,size.X,size.Z)
    end,
    ["0,1,1"] = function(size)
        return vector3(size.Z,size.X,size.Y)
    end,
    ["1,1,0"] = function(size)
        return vector3(size.Z,size.X,size.Y)  
    end,
}
local RotateStuff = module.RotateStuff
do
    local function makeallrhitboxs()
        for i,v in RotateStuff do
            local values = {split(i)}
            for n =1,3 do
                local c = table.clone(values)
                c[n] = -tonumber(c[n])
                RotateStuff[table.concat(c,',')] = v
            end
        end
    end
    makeallrhitboxs() makeallrhitboxs() makeallrhitboxs()
end
local function deepCopy(original)
    if type(original) ~= "table" then return original end 
    local copy = {}
    for k, v in pairs(original) do
      if type(v) == "table" then
        v = deepCopy(v)
      end
      copy[k] = v
    end
    return copy
end
local directions = {"Right", "Left", "Top", "Bottom", "Back", "Front"} 
local mappings = {
--['90,0,0'] = {1, 2, 6, 5, 3, 4}, 
--['-90,0,0'] = {1, 2, 5, 6, 4, 3}, 
    ['0,0,0'] = {1, 2, 3, 4, 5, 6}, 
    ['0,90,0'] = {5, 6, 3, 4, 2, 1},--
    ['0,-90,0'] = {6, 5, 3, 4, 1, 2},
    ['0,180,0'] = {2, 1, 3, 4, 6, 5},
    ['0,90,180'] = {5, 6, 4, 3, 1, 2},
    ['0,-90,180'] = {6, 5, 4, 3, 2, 1},--{4,3,5,6,2,1}
    ['0,0,180'] = {2, 1, 4, 3, 5, 6}, 
    ['0,180,180'] = {1, 2, 4, 3, 6, 5}, 
--3 = 6 4 = 5 
}
local mappings2 = {[0]={}}
local function findCombo(number)
    local x = {1, 2, 4, 8, 16, 32}
    local result = {}
    for i = 1, #x do
      if bit32.band(number, 2^(i-1)) ~= 0 then
        table.insert(result, i)
      end
    end
    return result
end
do
    for i =1,63 do
        mappings2[i] = findCombo(i)
    end
end

do 
    local pos = {[3] = 6,[6] = 4,[5] = 3,[4] = 5}
    local neg = {[3] = 6,[6] = 4,[5] = 3,[4] = 5}
    local old = deepCopy(mappings)
    for i,v in old do
        local rx,ry,rz = split(i)
        v = deepCopy(v)
        for index,value in v do
           if neg[value] then
            v[index] = neg[value]
           end
        end
        mappings['-90,'..ry..','..rz] = v
    end
    for i,v in old do
        local rx,ry,rz = split(i)
        v = deepCopy(v)
        for index,value in v do
           if pos[value] then
            v[index] = pos[value]
           end
        end
        mappings['90,'..ry..','..rz] = v
    end
    mappings['90,180,180'] = {1, 2, 6, 5, 3, 4}
    mappings['90,-90,180'] = {3,4,6,5,2,1}
    mappings['90,0,180'] =   {2,1,6,5,4,3}
    mappings ["-90,-90,0"] = {3,4,5,6,1,2}
    mappings["90,90,180"] = {4,3,6,5,1,2}
end
function module.GetOrderOfSide(Orientation)
    if not Orientation then return directions end 
    local orientation = rotationData.convertToCFrame(Orientation)
   -- print(table.concat(orientation,','))
    local mapping = mappings[orientation[1]..','..orientation[2]..','..orientation[3]]
    if not mapping then return directions end 
    local new_directions = {}
    for i = 1, #mapping do
        new_directions[i] = directions[mapping[i]]
    end
    return new_directions
end
function module.CreateTexture(texture,face,size)
    local new
    if texture:IsA("Decal") or texture:IsA("Texture") or type(texture) == "string" then
        new = Instance.new("Texture")
        new.Texture = type(texture) == "string" and texture or texture.Texture
        new.StudsPerTileU = (size or gridS )
        new.StudsPerTileV =( size or gridS)
        new.Face = face
    elseif texture:IsA("SurfaceGui") then
        new = texture:Clone()
        new.Face = face 
    end
    return new
end 
function module.GetTextures(Id,walls,Orientation,part,loc)
     local info = resourceHandler.GetBlock(Id)
     local texture = info["Texture"]
     if typeof(texture) == "BrickColor" then
         part.BrickColor = info["Texture"]
         return {}
     elseif typeof(texture) == "Color3" then
         part.Color = info["Texture"]  
         return {}
     end
     local stuff ={}
     local sidesnumbers = module.GetOrderOfSide(Orientation)
     local sides = {Right = true,Left = true,Top = true,Bottom = true,Back = true,Front =true}
     for i,v in mappings2[tonumber(walls)] do
         if  not tonumber(v) then continue end
         sides[sidesnumbers[tonumber(v)]] = nil
     end
     if texture then
         if type(texture) == "table" then
             for i,v in texture do
                 if sides[i] then
                     table.insert(stuff,module.CreateTexture(v,i))
                 end
             end
         elseif type(texture) == "userdata" then
             for v in sides do
                 if  v ~= "" then
                     table.insert(stuff,module.CreateTexture(texture,v))
                 end
             end
         end
     else
     end
     return stuff
 end
 function module.CreateBlock(v,ptouse,ori,isSafe)
    local p = ptouse or Instance.new("Part")
    p:ClearAllChildren()
    local name = v.data[1][1][1]
    local info = resourceHandler.GetBlock(name) or {}
    p.Material = info.Material or  Enum.Material.SmoothPlastic 
    for i,v in  module.GetTextures(name,v.data[2],ori,p,isSafe) do
        v.Parent = p
    end
    p.Transparency = info.Transparency or 0 
    p.Anchored = true
    return p
end
return module 