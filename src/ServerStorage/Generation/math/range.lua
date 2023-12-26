local range = {}

function range.new(min,max,peak)
    return {min,max,peak}
end
function range.parse(settings)
    return {settings.min,settings.max,settings.peak}
end
--[[
    public static float TriangularDistribution(float minimum = 0f, float peak = 0.5f, float maximum = 1f)
{
    float v = UnityEngine.Random.value;

    if (v < (peak - minimum) / (maximum - minimum))
        return minimum + Mathf.Sqrt(v * (maximum - minimum) * (peak - minimum));
    else
        return maximum - Mathf.Sqrt((1f - v) * (maximum - minimum) * (maximum - peak));
}
]]
function range.sample(self,random:Random)
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

return range