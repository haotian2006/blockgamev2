local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
Chunk.__index = Chunk
Chunk.__tostring = function(self)
    return self:GetNString()
end
Chunk.__call = function(self)
    return self:GetNTuple()
end
local area1,area2 = (chunksize.X^2)*chunksize.Y,chunksize.X*chunksize.Y
local cmp = function(x,y,z)
    return y * (area1) + z * (area2) + x
  end
Chunk.To1D = function(x,y,z)
   if typeof(x) == "Vector3" then return cmp(x.X,x.Y,x.Z) end
   return cmp(x,y,z)
end
--block example: Name|C:Grass
local function round(x)return math.floor(x+.5)end
function Chunk.new(cx,cz,data)
    if not cx or not cz then
        warn("Unable to create chunk")
        return nil
    end
    local ch = {}
    setmetatable(ch,Chunk)
    ch.RegionData = {}
    ch.Entities = {}
    ch.Setttings = data and data.Setttings or {}
    ch.Blocks = data and data.Blocks or {}
    ch.ToLoad = data and data.ToLoad or {}
    ch.Chunk = Vector2.new(cx,cz)
    ch.Generating = false
    ch.RenderedBlocks = {}
    ch.Changed = data and  (data.Changed ~= false and true or false)
    -- if cx == -1 and cz == 1 then
    --     task.spawn(function()
    --         while task.wait(1) do
    --             print(ch.Entities)
    --         end
    --     end)
    -- end
    return ch
end
function Chunk:AddToLoad(stuff)
    self.Changed = true
    if  self.Setttings.Generated  then
        for i,v in stuff do
            local t = i:split(',')
            if tonumber(t[2]) <=0 then continue end  
            self.Blocks[i] = v
        end
    else
        for i,v in stuff do
            self.ToLoad[i] = v
        end
    end
end
function Chunk:GetBlock(x,y,z,islocal)--realpos
    if islocal then
        if self.Blocks[x..','..y..','..z] then
            return self.Blocks[x..','..y..','..z],x..','..y..','..z 
        end
    else
        return self.Blocks[qF.Realto1DBlock(x,y,z)]
    end

end
function Chunk:GetBlocks()
    return self.Blocks
end
function Chunk:RemoveBlock(x,y,z,useGrid)
    if useGrid then
        x,y,z =  round(x)%settings.ChunkSize.X,round(y),round(z)%settings.ChunkSize
    end
    self.Blocks[x..','..y..','..z] = nil
    self.Changed = true
end
function Chunk:InsertBlock(x,y,z,bdata,useGrid)
    if useGrid then
        x,y,z =  round(x)%settings.ChunkSize.X,round(y),round(z)%settings.ChunkSize
    end
    self.Changed = true
    self.Blocks[x..','..y..','..z] = bdata
end
function  Chunk:GetEdge(dir)
    local new = {}
    if dir == "x" then
        local x = 0
        for y = 0, chunksize.Y-1 do
            for z =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    elseif dir == "x-1" then
        local x = chunksize.X-1
        for y = 0, chunksize.Y-1 do
            for z =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    elseif dir == "z" then
        local z = 0
        for y = 0, chunksize.Y-1 do
            for x =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    else
        local z = chunksize.X-1
        for y = 0, chunksize.Y-1 do
            for x =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    end
    return new
end
function Chunk:GetNString():string
    return self.Chunk.X..","..self.Chunk.Y
end
function Chunk:GetNTuple():IntValue|IntValue
    return self.Chunk.X,self.Chunk.Y
end
function Chunk:SetData(which,data)
    self.Changed = true
    self[which] = data
end
function Chunk:Destroy()
    setmetatable(self, nil) self = nil
end
if runservice:IsClient() then return Chunk end
return Chunk 