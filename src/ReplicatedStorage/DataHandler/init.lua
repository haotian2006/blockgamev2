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
self.InProgress = {}
task.spawn(function()
    local times = 0
    if not self.WhileLoop then
        self.WhileLoop = true
        times+=1
        while true do
            local i = 0
            for c,v in self.SendToClient do
                if not self.SendToClient[c] or self.InProgress[c] then continue end 
                i +=1
                local function fun()
                    self.InProgress[c] = true
                    --task.spawn(function()
                    local cx,cz = unpack(string.split(c,","))
                    cx,cz = tonumber(cx),tonumber(cz)
                    local chun = self.GetChunk(cx,cz,true)
                    chun:Generate()     
                    for i,v in self.SendToClient[c] do
                        game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
                    end
                    self.SendToClient[c] = nil
                    self.InProgress[c] = nil
                end
            
                -- if i%2 then
                --     task.spawn(fun)
                -- else
                --     fun()
                -- end
                task.spawn(fun)
            end 
            -- for i,v in pairs(self.SendToClient) do
            --     if not self.SendToClient[i] then continue end 
            --        --task.spawn(function()
            --        local cx,cz = unpack(string.split(i,","))
            --        cx,cz = tonumber(cx),tonumber(cz)
            --         local chun = self.GetChunk(cx,cz,true)
            --         chun:Generate()     
            --         for i,v in self.SendToClient[i] do
            --             game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
            --         end
            --         self.SendToClient[i] = nil
            --       -- end)
            --        --if i %6 == 0 then task.wait(.05) end 
            -- end
            task.wait()
        end
        if times%6 == 0 then times = 0 task.wait(.1) end
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
     self.SendToClient[cx..','..cz] =  self.SendToClient[cx..','..cz] or {}
     table.insert(self.SendToClient[cx..','..cz],player )
    --game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
   --                                                              task.wait(1)
   -- self.GetChunk(cx,cz).Blocks = {}
   -- self.GetChunk(cx,cz).Setttings.Generated = false
     -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
 end)
return self