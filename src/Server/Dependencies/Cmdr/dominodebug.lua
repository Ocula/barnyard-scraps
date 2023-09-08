return {
	Name = "dominodebug";
	Aliases = {"dominodebug"};
	Description = "";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "players";
			Name = "targets";
			Description = "The players affected.";
		},
        {
            Type = "boolean";
            Name = "Toggle";
            Description = "true or false";
        },
	};
}