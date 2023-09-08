return {
    Name = "Lionel",
    Rank = 1, 
    Character = "characters:deer", -- [testing] character id -> vendors: ... (vendors is already added to the string, so just do whatever's under vendors folder)
    Stage = "stages:testlionel",
    IsVendor = true, 

    Dialogue = {
        ["en-us"] = {
            Greet = [[EEK <player> ... did you hear any lions? ... I have some dominos for you.]],         
            AccessDenied = "I'd love to give you some fresh sets, but you've gotta get your <rank> up! I only sell to XYZ",
            Fail = "Have a good one!", 
            Success = "Thanks for the <corn>",

            First = {
                [1] = "a",
                [2] = "b",
                [3] = "c",
            },
        },
    }, 

    Interact = {
        Sections = {
            "All",
            "Featured",
            "Sale"
        },

        Items = { --oh also leave the gates out of this, they're glitchy as hell LMAO got it
            "dominos:rise:big bridge",
            "dominos:rise:bigger bridge",
            "dominos:special:assortment",
            "dominos:rise:little bridge",
            "dominos:turns:tripod",
            "dominos:turns:stairs u-turn",
            "dominos:rise:double-helix",
            "dominos:rise:full stairs 1",
            "dominos:rise:full stairs 2",
            "dominos:rise:grand staircase",
            "dominos:rise:half stairs",
            "dominos:rise:hill", 
            "dominos:special:big domino", 
        },  

        Sale = { -- game will search for "All" or any active event names.
            -- All = 0.8 (20% sale on all items)
            -- Halloween = 0.8 (20% sale on halloween-approved items)
            -- ["dominos:basic:basic"] = 0.8 (20% off on this specific item)
            ["dominos:basic:basic"] = 0.8, 
        }, 
    }, 
}