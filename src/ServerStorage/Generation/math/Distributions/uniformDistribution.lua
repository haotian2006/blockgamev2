local Distribution = {}

function Distribution.new(min,max)
    return {min or 1,max or 255}
end
function Distribution.parse(settings)
    return Distribution.new(settings.min ,settings.max )
end

function Distribution.sample(self,random:Random)
    local min = self[1]
    local max = self[2]
    return random:NextNumber(min, max)
end

return Distribution