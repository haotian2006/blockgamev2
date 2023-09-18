local self = {}
local bd
local qf 
local multihandler
local greedymesh
local csize 
local gridS 
local culling  
local ResourceHandler 
bd = require(game.ReplicatedStorage.DataHandler)
qf = require(game.ReplicatedStorage.QuickFunctions)
greedymesh = require(script.Parent.GreedyMesh)
csize =require(game.ReplicatedStorage.GameSettings).ChunkSize.X
gridS = require(game.ReplicatedStorage.GameSettings).GridSize
local gs = require(game.ReplicatedStorage.GameSettings)
culling = require(game.ReplicatedStorage.RenderStuff.Culling)
ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local rotationData = require(game.ReplicatedStorage.Libarys.RotationData)
multihandler = require(game.ReplicatedStorage.MultiHandler)
local chunk = require(game.ReplicatedStorage.Chunk)
local debugmode = true
self.Blocks ={}
self.storage = self.storage or Instance.new("Folder")
self.storage2 = self.storage2 or Instance.new("Folder")
local vector3 = Vector3.new 
function self.CreateTexture(texture,face,size)
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
local once = false
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
        local rx,ry,rz = unpack(i:split(','))
        v = deepCopy(v)
        for index,value in v do
           if neg[value] then
            v[index] = neg[value]
           end
        end
        mappings['-90,'..ry..','..rz] = v
    end
    for i,v in old do
        local rx,ry,rz = unpack(i:split(','))
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
print(mappings)
function self.GetOrderOfSide(Orientation)
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
local once =0 

function self.GetModel(Id)
    local info = ResourceHandler.GetBlock(Id)
    local Model = info["Model"]
    if Model then
    else
        return 
    end
end
function self.DeLoad(cx,cz)
    bd.DestroyChunk(cx,cz)
    if game.Workspace.Chunks:FindFirstChild(cx..","..cz) then
        local c = game.Workspace.Chunks:FindFirstChild(cx..","..cz)
        c.Parent = nil
        for i,v in c:GetChildren() do
            v:Destroy()
            if i%500 == 0 then
                task.wait(.2)
            end
        end
        c:Destroy()
    end
end
function self.GetBlocks(amount)
    local new = {}
    for i=1, amount do
     local p =  self.storage:FindFirstChildWhichIsA("BasePart")
      if p then
            p.Parent = nil
            table.insert(new,p)
        else
            break
        end
    end
    return new,amount - #new
end
tada = true
function self.GetBlockTable(cx,cz,SPECIAL)
    if bd.GetChunk(cx,cz) and  bd.GetChunk(cx+1,cz) and bd.GetChunk(cx-1,cz) and 
    bd.GetChunk(cx,cz+1) and bd.GetChunk(cx,cz-1) and not debugmode then
        local current =  bd.GetChunk(cx,cz)
        local block , ref = bd.GetChunk(cx,cz).Blocks--:to3DBlocks()
        local chunks = {
            block,
            bd.GetChunk(cx+1,cz).Blocks,
            bd.GetChunk(cx-1,cz).Blocks,
            bd.GetChunk(cx,cz+1).Blocks,
            bd.GetChunk(cx,cz-1).Blocks,
        }
        if SPECIAL then return chunks end 
        local culling = culling.HideBlocks(chunks)
        local meshed,unmeshed = {},{}
        meshed,unmeshed = greedymesh.meshtable(culling,false,cx,cz)
        return meshed,current,unmeshed 
        end
        if debugmode then
        return {},bd.GetChunk(cx,cz),{}
       end
end

function self.CreateBlock(v,ptouse,ori,isSafe)
    local p = ptouse or Instance.new("Part")
    p:ClearAllChildren()
    local name = v.data:match("([^,]*),?([^,]*),?([^,]*)")
    local info = ResourceHandler.GetBlock(name)
    p.Material = info.Material or  Enum.Material.SmoothPlastic 
    for i,v in  self.GetTextures(name,v.data.AirBlocks,ori,p,isSafe) do
        v.Parent = p
    end
    p.Transparency = info.Transparency or 0 
    p.Anchored = true
    return p
end
local RotateStuff = {
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
do
    local function makeallrhitboxs()
        for i,v in RotateStuff do
            local values = string.split(i,',')
            for n =1,3 do
                local c = table.clone(values)
                c[n] = -tonumber(c[n])
                RotateStuff[table.concat(c,',')] = v
            end
        end
    end
    makeallrhitboxs() makeallrhitboxs() makeallrhitboxs()
end
function self.UpdateChunk(cx,cz,debug)
    local meshed,chunkobj,unmeshed = self.GetBlockTable(cx,cz)
    if not (meshed or unmeshed) or not chunkobj  then  return false end 
    local ammountofblocks = 0
    local blockstodel = {}
    local nonchangedblocks = {}
    for i,v in chunkobj.RenderedBlocks do
        if not meshed[i] or not unmeshed[i] then
            local folder = qf.GetFolder(cx,cz)
            if folder and folder:FindFirstChild(i) and folder:FindFirstChild(i):IsA("Part") then
                
                table.insert(blockstodel,folder:FindFirstChild(i))
            elseif folder and folder:FindFirstChild(i)then
                folder:FindFirstChild(i):Destroy()
            end
            chunkobj.RenderedBlocks[i] = nil
        end
    end
    for i,v in meshed do
        if chunkobj.RenderedBlocks[i] then 
            if not qf.CompareTables(v,chunkobj.RenderedBlocks[i]) then
                local folder = qf.GetFolder(cx,cz)
                if folder and folder:FindFirstChild(i) and folder:FindFirstChild(i):IsA("Part") then
                    table.insert(blockstodel,folder:FindFirstChild(i))
                elseif folder and folder:FindFirstChild(i)then
                    folder:FindFirstChild(i):Destroy()
                end
            else
                nonchangedblocks[i] = v 
            end
        end
    end	
    for i,v in unmeshed do
        if chunkobj.RenderedBlocks[i] then 
            if not qf.CompareTables(v,chunkobj.RenderedBlocks[i]) then
                
            else
                nonchangedblocks[i] = v
            end
        end
    end	
    chunkobj.RenderedBlocks = {}
    local folder = qf.GetFolder(cx,cz) or Instance.new("Model")
    local index = 0
    local newb = 0
    for i,v in meshed do
        chunkobj.RenderedBlocks[i] = v
        if nonchangedblocks[i] then continue end
        index +=1
        if index%2000 == 0 then task.wait() end
        local pi,pb = next(blockstodel)
        if pi then blockstodel[pi] = nil else newb +=1 end 
     --   v.data = qf.DecompressItemData(v.data)
        local tt,oo,ss,air = v.data:match("([^,]*),?([^,]*),?([^,]*)")
        if oo and ss then
            oo = rotationData.indexPairs[tonumber(oo)]
        end
        if not ss then
            air = oo
        end
        if not air then
            air = ss
        end
        local p = self.CreateBlock(v,pb,oo,CFrame.new(Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS)*(oo and rotationData.convertToCFrame(oo) or CFrame.new()).Position)
        p.Name = tostring(i)
        p.Size = Vector3.one
        p.CFrame  = CFrame.new(Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS)*(oo and rotationData.convertToCFrame(oo) or CFrame.new())
        p.Size = RotateStuff[oo or '0,0,0'](Vector3.new(v.l*gridS,v.h*gridS,v.w*gridS))
        p.Parent = folder
    end
    for i:Vector3,v in unmeshed do
        chunkobj.RenderedBlocks[i] = v
        if nonchangedblocks[i] then continue end
        index +=1
      --  v = qf.DecompressItemData(v)
        if index%2000 == 0 then task.wait() end
        local tt,oo,ss,air = v:match("([^,]*),?([^,]*),?([^,]*)")
        if oo and ss then
            oo = rotationData.indexPairs[tonumber(oo)]
        end
        if not ss then
            air = oo
        end
        if not air then
            air = ss
        end
        local dat= ResourceHandler.GetBlock(tt)
        local p =dat.Mesh:Clone()
        for i,v in  self.GetTextures(tt,0,oo) do
            v.Parent = p
        end
       -- p.Transparency = dat.Transparency
        p.Name = tostring(i)
        p.Anchored = true
        local x,y,z = i.X,i.Y,i.Z
        local offset = ResourceHandler.GetBlock(tt).Offset or Vector3.zero
        p.CFrame = CFrame.new(Vector3.new(x+cx*csize,y,z+cz*csize)*gridS)*(v.O and rotationData.convertToCFrame(oo) or CFrame.new())*CFrame.new(offset*gridS)
        p.Parent = folder
    end
    task.spawn(qf.DestroyBlocks,blockstodel)
    folder.Parent = workspace.Chunks
    folder.Name = cx..','..cz
return true
end
return self 