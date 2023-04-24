local recipes = {}
recipes.Test = {
    type = "Crafting",
    key = {
        d = {
            Item ='C:Dirt',
            }
    },
    shape = {
        " d",
        "dd",
    },
    result = {
        Item = 'C:Grass',
        Count = 2
    }


}
recipes.Test2 = {
    type = "Crafting",
    key = {
        d = {
            Item ='C:Dirt',
            }
    },
    shape = {
        "d",
        "d"
    },
    result = {
        Item = 'C:Grass',
        Count = 3
    }

}

return recipes