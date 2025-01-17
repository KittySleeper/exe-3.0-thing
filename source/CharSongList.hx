package;

class CharSongList
{
	static var loaded:Bool = false;

	public static var data:Map<String, Array<String>> = [
		"majin" => ["endless", "endless-og"],
		"lord x" => ["cycles"],
		"tails doll" => ["sunshine", "soulless"],
		"requital" => ["forestall-desire", "deception"],
		"fleetway" => ["chaos"],
		"fatalerror" => ["fatality"],
		"chaotix" => ["my-horizon", "our-horizon"],
		"yourself..." => ["yourself"],
		"curse" => ["malediction"],
		"starved" => ["prey", "fight-or-flight"],
		"xterion" => ["substantial", "digitalized"],
		"needlemouse" => ["round-a-bout"],
		"hog" => ["manual-blast"],
		"sunky" => ["milk"],
		"sanic" => ["too-fest"],
		"coldsteel" => ["personel"],
	];

	public static var characters:Array<String> = [
		"majin",
		"lord x",
		"tails doll",
		"requital",
		"fleetway",
		"fatalerror",
		"yourself...",
		"chaotix",
		"curse",
		"starved",
		"xterion",
		"needlemouse",
		"hog",
		"sunky",
		"sanic",
		"coldsteel",
	];

	public static var charactersUnlocked:Array<String> = [
		// just for locks
		"majin",
		"lord x",
		"tails doll",
		"requital",
		"fleetway",
		"yourself...",
		"fatalerror",
		"chaotix",
		"curse",
		"starved",
		"xterion",
		"needlemouse",
		"hog",
		"sunky",
		"sanic",
		"coldsteel",
	];

	public static function init()
	{
		if (!loaded)
		{
			loaded = true;
			
			var unlockedShit:Array<String> = flixel.FlxG.save.data.charactersUnlocked;

			for (str in unlockedShit)
			{
				charactersUnlocked.push(str);
			}
		}
	}

	public static function getSongsByChar(char:String)
	{
		if (data.exists(char))
			return data.get(char);
		return [];
	}
}
