return {
	Name = "give";
	Aliases = {"give"};
	Description = "Give Corn or Experience to player.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "players";
			Name = "targets";
			Description = "The players to set Sound Tree ids on.";
		},
        {
            Type = "string";
            Name = "Type of Input";
            Description = "Corn or Experience";
        },
        {
            Type = "number";
            Name = "Amount";
            Description = "The amount you want to give to the player.";
        }
	};
}