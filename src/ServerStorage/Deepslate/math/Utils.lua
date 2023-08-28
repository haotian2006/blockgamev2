local Utils = {}
function Utils.lerp(a, b, c)
    return b + a * (c - b)
end

function Utils.lerp2(a, b, c, d, e, f)
    return Utils.lerp(b, Utils.lerp(a, c, d), Utils.lerp(a, e, f))
end
--[[
function Utils.lerp3(a, b, c, d, e, f, g, h, i, j, k)
    return Utils.lerp(c, Utils.lerp2(a, b, d, e, f, g), Utils.lerp2(a, b, h, i, j, k))
end
]]

function Utils.lerp3(x, y, z,xm_ym_zm, xp_ym_zm, xm_yp_zm, xp_yp_zm,
    xm_ym_zp, xp_ym_zp, xm_yp_zp, xp_yp_zp
    )
    return (xm_ym_zm * (1 - x) * (1 - y) * (1 - z)) + (xp_ym_zm * x * (1 - y) * (1 - z)) + (xm_yp_zm * (1 - x) * y * (1 - z)) + (xp_yp_zm * x * y * (1 - z)) +
        (xm_ym_zp * (1 - x) * (1 - y) * z) + (xp_ym_zp * x * (1 - y) * z) + (xm_yp_zp * (1 - x) * y * z) + (xp_yp_zp * x * y * z)
end

function Utils.lazyLerp(a, b, c)
    if a == 0 then
        return b()
    elseif a == 1 then
        return c()
    else
        return b() + a * (c() - b())
    end
end

function Utils.lazyLerp2(a, b, c, d, e, f)
    return Utils.lazyLerp(b,function() return Utils.lazyLerp(a,c,d)end,function() return Utils.lazyLerp(a,e,f)end)
end

function Utils.lazyLerp3(a, b, c, d, e, f, g, h, i, j, k)
    return Utils.lazyLerp(c, function() return Utils.lazyLerp2(a, b, d, e, f, g)end, function() return Utils.lazyLerp2(a, b, h, i, j, k) end)
end
function Utils.clampedLerp(a, b, c)
    if c < 0 then
        return a
    elseif c > 1 then
        return b
    else
        return Utils.lerp(c, a, b)
    end
end

function Utils.inverseLerp(a, b, c)
    return (a - b) / (c - b)
end

function Utils.smoothstep(x)
    return x * x * x * (x * (x * 6 - 15) + 10)
end

function Utils.map(a, b, c, d, e)
    return Utils.lerp(Utils.inverseLerp(a, b, c), d, e)
end
function Utils.Size(t)
    if type(t) == "table" then
        return #t
    elseif typeof(t) == 'SharedTable' then
        return SharedTable.size(t)
    end
end
function Utils.clampedMap(a, b, c, d, e)
    return Utils.clampedLerp(d, e, Utils.inverseLerp(a, b, c))
end
Utils.floor = math.floor
Utils.noise = math.noise
function Utils.binarySearch(n, n2, predicate)
    local n3 = n2 - n
    while n3 > 0 do
        local n4 = math.floor(n3 / 2)
        local n5 = n + n4
        if predicate(n5) then
            n3 = n4
        else
            n = n5 + 1
            n3 = n3 - (n4 + 1)
        end
    end
    return n
end

return Utils