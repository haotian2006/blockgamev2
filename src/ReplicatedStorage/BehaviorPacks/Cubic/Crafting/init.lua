local recipes = {}
recipes.Test = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:Dirt',
            }
    },
    Shape = {
        " d",
        "dd",
    },
    Result = {
        Item = 'c:GrassBlock',
        Count = 2
    }


}

recipes.KBStick = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:Dirt',
            }
    },
    Shape = {
        "d",
        "d"
    },
    Result = {
        Item = 'c:GodStick',
        Count = 1
    }

}
recipes.LongStick = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:Stone',
            }
    },
    Shape = {
        "d",
        "d"
    },
    Result = {
        Item = 'c:LongStick',
        Count = 1
    }

}

return recipes