return {
    Name = "Moolivia",
    Rank = 1, 
    Character = "characters:cow", -- [testing] character id -> vendors: ... (vendors is already added to the string, so just do whatever's under vendors folder)
    Stage = "stages:testmoo",
    IsVendor = true, 

    Dialogue = {
        ["en-us"] = {
            Greet = [[MoOOOOoooOoOoo... Oh... <player> I didn't see you there.]],         
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
            "dominos:physics:short stack 1",
            "dominos:physics:short stack 2",
            "dominos:physics:tall stack 1",
            "dominos:physics:tall stack 2",
            "dominos:turns:big u-turn",
            "dominos:turns:l-stairs",
            "dominos:turns:l-high",
            "dominos:turns:l-low",
            "scenery:shrubbery:bush",
            "scenery:shrubbery:orange tree",
            "scenery:shrubbery:tree",
        }, 

        Sale = { -- game will search for "All" or any active event names.
            -- All = 0.8 (20% sale on all items)
            -- Halloween = 0.8 (20% sale on halloween-approved items)
            -- ["dominos:basic:basic"] = 0.8 (20% off on this specific item)
            ["dominos:basic:basic"] = 0.8, 
        }, 
    }, 
}-- a deer named lionel is so funny to me. do it.