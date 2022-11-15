local qf = require(game.ReplicatedStorage.QuickFunctions)
local self = {}
--<Both
self.LoadedChunks = {}
self.LoadedEntitys = {}
--<Client Only
self.LocalPlayer = {}
--<Server Only
self.CompressedChunks = {}
self.Players = {}

local multihandeler = require(game.ReplicatedStorage.MultiHandler)
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.compressor)
function self.GetChunk(cx,cz,create)
    if not self.LoadedChunks[qf.cv2type("string",cx,cz)] and create then
        self.CreateChunk(nil,cx,cz)
    end
    return self.LoadedChunks[qf.cv2type("string",cx,cz)] 
end
function self.CreateChunk(cdata,cx,cz)
    self.LoadedChunks[qf.cv2type("string",cx,cz)] = ChunkObj.new(cx,cz,cdata)
    return self.LoadedChunks[qf.cv2type("string",cx,cz)] 
end
function self.DestroyChunk(cx,cz)
    local c = self.GetChunk(cx,cz)
    if c then
        c:Destroy()
        self.LoadedChunks[qf.cv2type("string",cx,cz)] = nil
    end
end
if runservice:IsClient() then return self end
--<server functions
function self.AddToLoad(cx,cz,stuff)
    local c = self.GetChunk(cx,cz,true)
    c:AddToLoad(stuff)
end
function self.DoCaves(cx,cz)
    local c = self.GetChunk(cx,cz,true)
    c:DoCaves()
end
script.DoFunc.OnInvoke = function(func,...)
   if self[func] then
    self[func](...)
   end
   return
end
self.SendToClient = {}
task.spawn(function()
    if not self.WhileLoop then
        self.WhileLoop = true
        while true do
            for i,v in ipairs(self.SendToClient) do
                task.spawn(function()
                    table.remove(self.SendToClient,i)
                    local chun = self.GetChunk(v[2],v[3],true)
                    chun:Generate()     
                    game.ReplicatedStorage.Events.GetChunk:FireClient(v[1],v[2],v[3],self.GetChunk(v[2],v[3]):GetBlocks() )
                end)
                if i%2 == 0 then task.wait() end
                task.wait()
            end
            task.wait()
        end
    end
end)
game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
    -- local position = player.Character.PrimaryPart.Position
    local new = self.GetChunk(cx,cz)
    if new and new:IsGenerating() then
        game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
        return 
    end
     --new:Generate()
     --print("e")
     table.insert(self.SendToClient,{player,cx,cz})
    --game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
   --                                                              task.wait(1)
   -- self.GetChunk(cx,cz).Blocks = {}
   -- self.GetChunk(cx,cz).Setttings.Generated = false
     -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
 end)
return self