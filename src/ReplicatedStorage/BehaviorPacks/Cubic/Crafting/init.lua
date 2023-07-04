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

recipes.KBStick = {
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
        Item = 'C:GodStick',
        Count = 1
    }

}
recipes.LongStick = {
    type = "Crafting",
    key = {
        d = {
            Item ='C:Stone',
            }
    },
    shape = {
        "d",
        "d"
    },
    result = {
        Item = 'C:LongStick',
        Count = 1
    }

}

return recipes