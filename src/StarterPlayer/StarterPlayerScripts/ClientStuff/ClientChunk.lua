local Chunk = require(game.ReplicatedStorage.Chunk)
function Chunk:GetLVersion()
    if self.Changed then
        self.LVersion +=1
        self.Changed  = false
    end
    return self.LVersion
end
function Chunk:GetLastCompressed()
    local currentversion = self:GetLVersion()
    local lastCompressed = self.lastCompressed
    local compressedVersion = lastCompressed[3]
    if compressedVersion ~= currentversion then

        local comp = self:CompressVoxels()
        comp[3] = currentversion
        self.lastCompressed = comp
    end
    return tostring(self),self.lastCompressed
end
return Chunk