return {
    Name = "Cluck Norris",
    Rank = 1, 
    Character = "characters:Chicken", -- [testing] character id -> vendors: ... (vendors is already added to the string, so just do whatever's under vendors folder)
    Stage = "stages:testcluck",
    IsVendor = true, 

    Dialogue = {
        ["en-us"] = {
            Greet = [[BOK! BOK! BOK! <player> I'VE GOT SOME COOL DOMINO SETS I PROMISE.]],         
            AccessDenied = "I'd love to give you some fresh sets, but you've gotta get your <rank> up! I only sell to XYZ",
            Fail = "Have a good one!", 
            Success = "Thanks for the <corn>!",

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

        Items = {
            "dominos:basic:zig 1",
            "dominos:basic:zig 2",
            "dominos:basic:right spread",
            "dominos:basic:left spread",
            "dominos:basic:left zag",
            "dominos:basic:right zag",
            "dominos:basic:spread",
            "dominos:basic:spread stagger",
            "dominos:curves:swerve 1",
            "dominos:curves:swerve 2",
            "scenery:other:windmill", 
        }, 

        Sale = { -- game will search for "All" or any active event names.
            -- All = 0.8 (20% sale on all items)
            -- Halloween = 0.8 (20% sale on halloween-approved items)
            -- ["dominos:basic:basic"] = 0.8 (20% off on this specific item)
            ["dominos:basic:basic"] = 0.8, 
        }, 
    }, 
}