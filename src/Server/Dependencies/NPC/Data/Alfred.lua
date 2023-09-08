return {
    Name = "Alfred",
    Rank = 1, 
    Character = "characters:farmer joe", -- [testing] character id -> vendors: ... (vendors is already added to the string, so just do whatever's under vendors folder)
    Stage = "stages:testalfred",
    IsVendor = true, 

    Dialogue = {
        ["en-us"] = {
            Greet = [[Hey there <player>!<br /><br />I'm <npc: alfred>... I've got things that fall, things that flip... things that <topple>.]],         
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

        Items = {
            "dominos:basic:basic",
            "dominos:turns:turn",
            "dominos:basic:double stagger",
            "dominos:basic:elevated",
            "dominos:basic:left bend",
            "dominos:basic:right bend", 
            "dominos:turns:3-way cross",
        }, 

        Sale = { -- game will search for "All" or any active event names.
            -- All = 0.8 (20% sale on all items)
            -- Halloween = 0.8 (20% sale on halloween-approved items)
            -- ["dominos:basic:basic"] = 0.8 (20% off on this specific item)
            ["dominos:basic:basic"] = 0.8, 
        }, 
    }, 
}