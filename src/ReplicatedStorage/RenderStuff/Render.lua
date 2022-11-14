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
function self.CreateTexture(texture,face)
        local new = Instance.new("Texture")
        new.Texture = texture.Texture
        new.StudsPerTileU = gridS
        new.Face = face

        new.StudsPerTileV = gridS
        return new
end
local once = false
function self.GetTextures(Id,walls)
   -- print(walls[2])
    local info = ResourceHandler.GetBlock(Id)
    local texture = info["Texture"]
    local stuff ={}
    local sides = {"Right","Left","Top","Bottom","Back","Front"}
    for i,v in walls do
        if i == 1 or not tonumber(v) then continue end
        sides[tonumber(v)] = ""
    end
    if texture then
        if type(texture) == "table" then
            for i,v in texture do
                if texture["Side"] then
                    table.insert(stuff,self.CreateTexture(texture["Front"],"Front"))
                    table.insert(stuff,self.CreateTexture(texture["Back"],"Back"))
                    table.insert(stuff,self.CreateTexture(texture["Left"],"Left"))
                    table.insert(stuff,self.CreateTexture(texture["Right"],"Right"))
                else
                    table.insert(stuff,self.CreateTexture(v,i))
                end
            end
        elseif type(texture) == "userdata" then
            local d = false  if not once then once = true d= true end
            for i,v in sides do
                if  v ~= "" then
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
function self.render(cx,cz)
    -- print(  bd.GetChunk(cx+1,cz) and true, bd.GetChunk(cx-1,cz) and true, 
    -- bd.GetChunk(cx,cz+1) and true, bd.GetChunk(cx,cz-1) and true)
    if bd.GetChunk(cx,cz) and not game.Workspace.Chunks:FindFirstChild(cx..','..cz) and  bd.GetChunk(cx+1,cz) and bd.GetChunk(cx-1,cz) and 
         bd.GetChunk(cx,cz+1) and bd.GetChunk(cx,cz-1) then
            local t = {
                bd.GetChunk(cx,cz).Blocks,
                bd.GetChunk(cx+1,cz):GetEdge("x"),
                bd.GetChunk(cx-1,cz):GetEdge("x-1"),
                bd.GetChunk(cx,cz+1):GetEdge("z"),
                bd.GetChunk(cx,cz-1):GetEdge("z-1"),
            }
           -- local culling = culling.HideBlocks(cx,cz,t,bd.GetChunk(cx,cz).Blocks)
            local culling = multihandler.HideBlocks(cx,cz,t,4)
            local meshed = greedymesh.meshtable(culling)
            local ammountofblocks = 0
            for i,v in meshed do
				if v then
					ammountofblocks +=1
				end
			end	
            local folder = Instance.new("Folder")
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
                local name = v.data.Type
                -- if name == 'Cubic:Grass' then
                --     p.Color = Color3.new(0.172549, 0.721568, 0.062745)
                -- elseif name == 'Cubic:Dirt'  then
                --     p.Color = Color3.new(0.580392, 0.2, 0.047058)
                -- elseif name == 'Cubic:Stone' then
                --     p.Color = Color3.new(0.305882, 0.305882, 0.305882)
                -- elseif name == 'Cubic:Bedrock' then
                --     p.Color = Color3.new(0, 0, 0)
                -- end
                for i,v in  self.GetTextures(name,v.data.AirBlocks) do
                    v.Parent = p
                end
               -- p.Transparency = 1
                  -- p.Size = Vector3.new(3,3,3) 
                -- p.Position = qf.cv3type("vector3",qf.cbt("chgrid","real",cx,cz,qf.cv3type("tuple",i)))
				
				p.Anchored = true
                p.Position = Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS
				p.Size = Vector3.new(v.l*gridS,v.h*gridS,v.w*gridS)
			end
			folder.Parent = workspace.Chunks
			folder.Name = cx..','..cz

    else
        return nil
    end
    return true
end
return self 