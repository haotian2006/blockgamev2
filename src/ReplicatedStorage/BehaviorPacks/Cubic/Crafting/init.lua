local recipes = {}
recipes.Test = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:dirt',
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
            Item ='c:dirt',
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

recipes.Plank = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:wood',
            }
    },
    Shape = {
        "d"
    },
    Result = {
        Item = 'c:plank',
        Count = 4
    }


}
recipes.LongStick = {
    Type = "Crafting",
    Key = {
        d = {
            Item ='c:stone',
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