local range = {}
--[[
    {
    multiplier: number,
    points: {
        {
            min: number,
            max: number
        },
    } 
]]
function range.new(multi, points)
    return { multi or 1, points }
end

export type Range = {
    
}

function range.parse(data)
    if data.min then
        return range.new(data.multiplier, {{min = data.min,max = data.max}})
    end
    return range.new(data.multiplier, data.points)
end


function range.inRange(self, value)
    local multiplier = self[1]
    local points = self[2]
    value*=multiplier
    for _, point in points do
        if value >= point.min and value <= point.max then
            return true
        end
    end
    return false
end

range.DEFAULT = range.new(1,{{min = 0,max = 1}})

return table.freeze(range)