local recipes = {}
recipes.Test = {
    type = "Crafting",
    key = {
        d = {
            Item ='c:Dirt',
            }
    },
    shape = {
        " d",
        "dd",
    },
    result = {
        Item = 'c:GrassBlock',
        Count = 2
    }


}

recipes.KBStick = {
    type = "Crafting",
    key = {
        d = {
            Item ='c:Dirt',
            }
    },
    shape = {
        "d",
        "d"
    },
    result = {
        Item = 'c:GodStick',
        Count = 1
    }

}
recipes.LongStick = {
    type = "Crafting",
    key = {
        d = {
            Item ='c:Stone',
            }
    },
    shape = {
        "d",
        "d"
    },
    result = {
        Item = 'c:LongStick',
        Count = 1
    }

}

return recipes