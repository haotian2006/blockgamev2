local self = require(game.ReplicatedStorage.DataHandler)

local HttpService = game:GetService("HttpService")
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.Libarys.compressor) 
local settings = require(game.ReplicatedStorage.GameSettings)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
local GetChunk = bridge.CreateBridge("GetChunk")
local isserver = runservice:IsServer()
local lualzw = require(game.ReplicatedStorage.Libarys.lualzw)
function self.AddToLoad(cx,cz,stuff,op2)
    local c = self.GetChunk(cx,cz,'2')
    c:AddToLoad(stuff,op2)
end
function self.DoCaves(cx,cz,from)
    --if from == '-7,7'and tostring(cx..','..cz) == '-11,12' then print("acb") end 
    local c = self.GetChunk(cx,cz,'2')
   -- if from == '-7,7'and tostring(cx..','..cz) == '-11,12' then print("aadsab") end 
    c:DoCaves()
    -- if from == '-7,7' and tostring(c) == '-11,12' then
    --     print(c.GeneratingOther)
    --     print( c.Settings.GeneratedOthers)
    -- end
    return 
end
local InProgress = {}
function self.GetChunk(cx,cz,create)
    if not self.LoadedChunks[cx..','..cz] and create then
        if InProgress[cx..','..cz] then
            repeat
                task.wait()
            until not InProgress[cx..','..cz]
            return self.LoadedChunks[cx..','..cz] 
        end
        InProgress[cx..','..cz] = true
        self.CreateChunk(nil,cx,cz)
        InProgress[cx..','..cz] = false
    end
    return self.LoadedChunks[cx..','..cz] 
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
                    local cx,cz = unpack(string.split(c,","))
                    cx,cz = tonumber(cx),tonumber(cz)
                    local a = self.SendToClient[c]
                    self.SendToClient[c] = nil
                    self.InProgress[c] = true
                    --task.spawn(function()
                    local chun = self.GetChunk(cx,cz,true)
                    -- if cx == -7 and cz ==7 then
                    --     print("a")
                    -- end
                 -- print(  pcall(function()
                    chun:Generate() 
                    
               -- end))
                  --  self.LoadedChunks[cx..','..cz]  = chun
                    for i,v in a do
                        -- if cx == -7 and cz ==7 then
                        --      print(chun:GetBlocks())
                        --     -- print(self.GetChunk(cx,cz):GetBlocks())
                        -- end   
                        game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):CompressVoxels())
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
local ublock = bridge.CreateBridge("UpdateBlocks")
function self.CreateChunk(cdata,cx,cz)
    
    self.LoadedChunks[cx..','..cz] = ChunkObj.Create(cx,cz)
    return self.LoadedChunks[cx..','..cz] 
end 
function self.PlaceBlockGLOBAL(x,y,z,data)
    self.InsertBlock(x,y,z,data)
    ublock:FireAll({Add = {{Vector3.new(x,y,z),data}}})
end
function self.RemoveBlockGlobal(x,y,z,data)
    self.RemoveBlock(x,y,z)
    ublock:FireAll({Remove = {Vector3.new(x,y,z)}})
end
game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
    if cx > 32767 or cx < -32768 or cz > 32767 or cz < -32768 then warn("REACHED BORDER") return end 
    -- local position = player.Character.PrimaryPart.Position
    local new = self.GetChunk(cx,cz)
    if new and new:IsGenerating() then
        game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,new:CompressVoxels())
        return 
    end
     --new:Generate()
     --print("e")
     self.SendToClient[cx..','..cz] =  self.SendToClient[cx..','..cz] or {}
     table.insert(self.SendToClient[cx..','..cz],player )
    --game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
   --                                                              task.wait(1)
   -- self.GetChunk(cx,cz).Blocks = {}
   -- self.GetChunk(cx,cz).Settings.Generated = false
     -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
 end)
--  game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
--     -- local position = player.Character.PrimaryPart.Position
--     local new = self.GetChunk(cx,cz,true)
--      new:Generate()
--     game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
--    --                                                              task.wait(1)
--    -- self.GetChunk(cx,cz).Blocks = {}
--    -- self.GetChunk(cx,cz).Settings.Generated = false
--      -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
--  end)
return {}