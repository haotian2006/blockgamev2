local self = {}
local bd = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local multihandler = require(game.ReplicatedStorage.MultiHandler)
local greedymesh = require(script.Parent.GreedyMesh)
local csize =require(game.ReplicatedStorage.GameSettings).ChunkSize.X
local gridS = require(game.ReplicatedStorage.GameSettings).GridSize
local culling = require(game.ReplicatedStorage.RenderStuff.Culling)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
self.Blocks ={}
self.storage = self.storage or Instance.new("Folder")
self.storage2 = self.storage2 or Instance.new("Folder")
local collisions = require(game.ReplicatedStorage.CollisonHandler)
local vector3 = Vector3.new
function self.CreateTexture(texture,face)
    local new
    if texture:IsA("Decal") or texture:IsA("Texture") then
        new = Instance.new("Texture")
        new.Texture = texture.Texture
        new.StudsPerTileU = gridS
        new.StudsPerTileV = gridS
        new.Face = face
    elseif texture:IsA("SurfaceGui") then
        new = texture:Clone()
        new.Face = face
    end

        return new
end 
local once = false
local directions = {"Right", "Left", "Top", "Bottom", "Back", "Front"} 
local mappings = { -- tried to us chatgpt for this, didn't work so decided to just hard code it
--['90,0,0'] = {1, 2, 6, 5, 3, 4}, 
--['-90,0,0'] = {1, 2, 5, 6, 4, 3}, 
    ['0,0,0'] = {1, 2, 3, 4, 5, 6}, 
    ['0,90,0'] = {5, 6, 3, 4, 2, 1},
    ['0,-90,0'] = {6, 5, 3, 4, 1, 2},
    ['0,180,0'] = {2, 1, 3, 4, 6, 5},
    ['0,90,180'] = {5, 6, 4, 3, 1, 2},
    ['0,-90,180'] = {6, 5, 4, 3, 2, 1},
    ['0,0,180'] = {2, 1, 4, 3, 5, 6}, 
    ['0,180,180'] = {1, 2, 4, 3, 6, 5}, 
--3 = 6 4 = 5 
}
do 
    local pos = {[3] = 6,[6] = 4,[5] = 3,[4] = 5}
    local neg = {[3] = 6,[6] = 4,[5] = 3,[4] = 5}
    local old = qf.deepCopy(mappings)
    for i,v in old do
        local rx,ry,rz = unpack(i:split(','))
        v = qf.deepCopy(v)
        for index,value in v do
           if neg[value] then
            v[index] = neg[value]
           end
        end
        mappings['-90,'..ry..','..rz] = v
    end
    for i,v in old do
        local rx,ry,rz = unpack(i:split(','))
        v = qf.deepCopy(v)
        for index,value in v do
           if pos[value] then
            v[index] = pos[value]
           end
        end
        mappings['90,'..ry..','..rz] = v
    end
    mappings['90,180,180'] = {1, 2, 6, 5, 3, 4}
end
function self.GetOrderOfSide(Orientation)
    if not Orientation then return directions end 
    local orientation = collisions.ConvertToTable(Orientation)
   -- print(table.concat(orientation,','))
    local mapping = mappings[orientation[1]..','..orientation[2]..','..orientation[3]]
    if not mapping then return directions end 
    local new_directions = {}
    for i = 1, #mapping do
        new_directions[i] = directions[mapping[i]]
    end
    return new_directions
end
function self.GetTextures(Id,walls,Orientation,part)
   -- print(walls[2])
    local info = ResourceHandler.GetBlock(Id)
    local texture = info["Texture"]
    if typeof(texture) == "BrickColor" then
        part.BrickColor = info["Texture"]
        return {}
    elseif typeof(texture) == "Color3" then
        part.Color = info["Texture"]  
        return {}
    end
    local stuff ={}
    local sidesnumbers = self.GetOrderOfSide(Orientation)
    local sides = {Right = true,Left = true,Top = true,Bottom = true,Back = true,Front =true}
    -- local t = {}
    -- for i,v in sidesnumbers do
    --     t[v] = directions[i]
    -- end
    for i,v in walls do
        if i == 1 or not tonumber(v) then continue end
        sides[sidesnumbers[tonumber(v)]] = nil
    end
    if texture then
        if type(texture) == "table" then
            for i,v in texture do
                if sides[i] then
                    -- i = t[i]
                    table.insert(stuff,self.CreateTexture(v,i))
                end
            end
        elseif type(texture) == "userdata" then
            local d = false  if not once then once = true d= true end
            for v in sides do
                if  v ~= "" then
                    --v = t[v]
                    table.insert(stuff,self.CreateTexture(texture,v))
                end
            end

            -- table.insert(stuff,self.CreateTexture(texture,"Back"))
            -- table.insert(stuff,self.CreateTexture(texture,"Left"))
            -- table.insert(stuff,self.CreateTexture(texture,"Right"))
            -- table.insert(stuff,self.CreateTexture(texture,"Top"))
            -- table.insert(stuff,self.CreateTexture(texture,"Bottom"))
        end
    else
    end
    return stuff
end
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
           -- v.Parent = self.storage
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
function self.GetBlockTable(cx,cz)
    if bd.GetChunk(cx,cz) and  bd.GetChunk(cx+1,cz) and bd.GetChunk(cx-1,cz) and 
    bd.GetChunk(cx,cz+1) and bd.GetChunk(cx,cz-1) then
       local t = {
           bd.GetChunk(cx,cz).Blocks,
           bd.GetChunk(cx+1,cz):GetEdge("x"),
           bd.GetChunk(cx-1,cz):GetEdge("x-1"),
           bd.GetChunk(cx,cz+1):GetEdge("z"),
           bd.GetChunk(cx,cz-1):GetEdge("z-1"),
       }
      -- local culling = culling.HideBlocks(cx,cz,t,bd.GetChunk(cx,cz).Blocks)
     local culling = multihandler.HideBlocks(cx,cz,t,3)--need to fix this
     local meshed,unmeshed = greedymesh.meshtable(culling)
      return meshed,bd.GetChunk(cx,cz),unmeshed 
    end
end
function self.CreateBlock(v,ptouse,ori)
    local p = ptouse or Instance.new("Part")
    p:ClearAllChildren()
    p.Material = Enum.Material.SmoothPlastic
    local name = v.data.T
    for i,v in  self.GetTextures(name,v.data.AirBlocks,ori,p) do
        v.Parent = p
    end
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
        local p = self.CreateBlock(v,pb,v.data.O)
        p.Name = i
        p.Size = Vector3.one
        p.CFrame  = CFrame.new(Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS)*(v.data.O and collisions.ConvertToCFrame(v.data.O) or CFrame.new())
        p.Size = RotateStuff[v.data.O or '0,0,0'](Vector3.new(v.l*gridS,v.h*gridS,v.w*gridS))
        p.Parent = folder
    end
    for i:string,v in unmeshed do
        chunkobj.RenderedBlocks[i] = v
        if nonchangedblocks[i] then continue end
        index +=1
        if index%2000 == 0 then task.wait() end
       -- print(v.T,i)
        local p = ResourceHandler.GetBlock(v.T).Mesh:Clone()
        for i,v in  self.GetTextures(v.T,{},v.O) do
            v.Parent = p
        end
        p.Name = i
        p.Anchored = true
        local x,y,z = unpack(i:split(','))
        local offset = ResourceHandler.GetBlock(v.T).Offset or Vector3.zero
        p.CFrame = CFrame.new(Vector3.new(x+cx*csize,y,z+cz*csize)*gridS)*(v.O and collisions.ConvertToCFrame(v.O) or CFrame.new())*CFrame.new(offset*gridS)
        p.Parent = folder
    end
    task.spawn(qf.DestroyBlocks,blockstodel)
    folder.Parent = workspace.Chunks
    folder.Name = cx..','..cz

return true
end
function self.render(cx,cz)
    local meshed = self.GetBlockTable(cx,cz)
    if not meshed then return false end 
    local ammountofblocks = 0
    for i,v in meshed do
        if v then
            ammountofblocks +=1
        end
    end	
    local folder = Instance.new("Model")
    local blocks,stillneed = {},ammountofblocks--self.GetBlocks(ammountofblocks)
    local rest = stillneed > 0 and multihandler.CreatePart(stillneed,stillneed < 20 and 1 or 20) or {}
    -- print(stillneed,#blocks)
    for i,v in rest do
        table.insert(blocks,v)
    end
    local index = 0
    for i,v in meshed do
        index +=1
        if index%2000 == 0 then task.wait() end
        local p = blocks[1]
        p.Parent = folder
        table.remove(blocks,1)
        p.Material = Enum.Material.SmoothPlastic
        local name = v.data.T
        for i,v in  self.GetTextures(name,v.data.AirBlocks) do
            v.Parent = p
        end
        p.Anchored = true
        p.Position = Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS
        p.Size = Vector3.new(v.l*gridS,v.h*gridS,v.w*gridS)
    end
    folder.Parent = workspace.Chunks
    folder.Name = cx..','..cz
end
return self 