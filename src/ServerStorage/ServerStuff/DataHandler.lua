local self = require(game.ReplicatedStorage.DataHandler)
local multihandeler = require(game.ReplicatedStorage.MultiHandler)
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.Libarys.compressor) 
local settings = require(game.ReplicatedStorage.GameSettings)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
local GetChunk = bridge.CreateBridge("GetChunk")
local isserver = runservice:IsServer()
function self.AddToLoad(cx,cz,stuff)
    local c = self.GetChunk(cx,cz,true)
    c:AddToLoad(stuff)
end
function self.DoCaves(cx,cz)
    local c = self.GetChunk(cx,cz,true)
    c:DoCaves()
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
                    local a = self.SendToClient[c]
                    self.SendToClient[c] = nil
                    self.InProgress[c] = true
                    --task.spawn(function()
                    local cx,cz = unpack(string.split(c,","))
                    cx,cz = tonumber(cx),tonumber(cz)
                    local chun = self.GetChunk(cx,cz,true)
                    chun:Generate()     
                    for i,v in a do
                        game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
                    end
                    self.InProgress[c] = nil
                end
                task.spawn(fun)
                if i%20 == 0 then task.wait() end
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
    end
end)
-- self.EntityLoop = false
-- if not self.EntityLoop then
--     self.EntityLoop = true
--     game:GetService("RunService").Heartbeat:Connect(function( deltaTime)
--         for id,entity in self.LoadedEntities do
--             task.spawn(entity.Update,entity,deltaTime)
--         end
--     end)
-- end
game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
    -- local position = player.Character.PrimaryPart.Position
    local new = self.GetChunk(cx,cz)
    if new and new:IsGenerating() then
        game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,new:GetBlocks() )
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
--  game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
--     -- local position = player.Character.PrimaryPart.Position
--     local new = self.GetChunk(cx,cz,true)
--      new:Generate()
--     game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
--    --                                                              task.wait(1)
--    -- self.GetChunk(cx,cz).Blocks = {}
--    -- self.GetChunk(cx,cz).Setttings.Generated = false
--      -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
--  end)
return {}