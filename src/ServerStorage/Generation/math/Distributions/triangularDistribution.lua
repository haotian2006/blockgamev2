local Distribution = {}

function Distribution.new(min,max,peak)
    return {min,max,peak}
end
function Distribution.parse(settings)
    return Distribution.new(settings.min,settings.max,settings.peak)
end

function Distribution.sample(self,random:Random)
    local min = self[1]
    local max = self[2]
    local peak = self[3]
    if not peak then return random:NextInteger(min,max) end 
    local value = random:NextNumber()
    if value < (peak - min)/(max-min) then
        return min + math.sqrt(value*(max-min)*(peak-min))
    end
    return max - math.sqrt((1-value)*(max - min)*(max - peak))
end

return Distribution