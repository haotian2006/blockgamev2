local self = {}
local bd = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local multihandler = require(game.ReplicatedStorage.MultiHandler)
local greedymesh = require(script.Parent.GreedyMesh)
local csize =require(game.ReplicatedStorage.GameSettings).ChunkSize.X
local gridS = require(game.ReplicatedStorage.GameSettings).GridSize
local culling = require(game.ReplicatedStorage.RenderStuff.Culling)
function self.render(cx,cz)
    -- print(  bd.GetChunk(cx+1,cz) and true, bd.GetChunk(cx-1,cz) and true, 
    -- bd.GetChunk(cx,cz+1) and true, bd.GetChunk(cx,cz-1) and true)
    if bd.GetChunk(cx,cz) and not game.Workspace.Chunks:FindFirstChild(cx..','..cz) then  --and  bd.GetChunk(cx+1,cz) and bd.GetChunk(cx-1,cz) and 
       -- bd.GetChunk(cx,cz+1) and bd.GetChunk(cx,cz-1) then
            local t = {
                bd.GetChunk(cx,cz):GetBlocks(),
                -- bd.GetChunk(cx+1,cz):GetBlocks(),
                -- bd.GetChunk(cx-1,cz):GetBlocks(),
                -- bd.GetChunk(cx,cz+1):GetBlocks(),
                -- bd.GetChunk(cx,cz-1):GetBlocks(),
            }
           -- local culling = culling.HideBlocks(cx,cz,t,bd.GetChunk(cx,cz):GetBlocks())
            local culling = multihandler.HideBlocks(cx,cz,t,1)
            local meshed = greedymesh.meshtable(culling)
            local ammountofblocks = 0
            for i,v in meshed do
				if v then
					ammountofblocks +=1
				end
			end	
            local folder = Instance.new("Folder")
			local blocks = ammountofblocks ~= 0 and multihandler.CreatePart(ammountofblocks,ammountofblocks < 10 and 1 or 10) or nil
			for i,v in meshed do
				local p = blocks[1]
				p.Parent = folder
				table.remove(blocks,1)
				p.Position = Vector3.new(v.real.X+cx*csize,v.real.Y,v.real.Z+cz*csize)*gridS
				p.Anchored = true
				p.Size = Vector3.new(v.l*gridS,v.h*gridS,v.w*gridS)
			end
			folder.Parent = workspace.Chunks
			folder.Name = cx..'x'..cz
    else
        return nil
    end
    return true
end
return self 