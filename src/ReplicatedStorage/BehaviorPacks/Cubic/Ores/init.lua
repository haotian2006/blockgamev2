local ores = {
    ["c:purple"] = {
        block = "c:purpleOre",
        chance = 100,
        minRange = 1,
        maxRange = 10,
        noiseScale = 10,
        randomY = {
            type = "triangular",
            min = 2,
            max = 60,
            peak = 40,
        },
        noiseSettings = {
            amplitudes = {1},
            firstOctave = -3
        }

    }

}
return ores