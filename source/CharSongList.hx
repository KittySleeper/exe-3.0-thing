package;

class CharSongList
{
	static var loaded:Bool = false;

	public static var data:Map<String, Array<String>> = [
		"majin" => ["endless", "endless-og"],
		"lord x" => ["cycles", "fate"],
		"tails doll" => ["sunshine", "soulless"],
		"requital" => ["forestall-desire", "deception"],
		"fleetway" => ["chaos"],
		"fatalerror" => ["fatality"],
		"xterion" => ["substantial", "digitalized"],
		"sl4sh" => ["b4cksl4sh"],
		"chaotix" => ["my-horizon", "our-horizon"],
		"yourself..." => ["yourself"],
		"christmas" => ["missiletoe", "slayballs"],
		"curse" => ["malediction"],
		"satanos" => ["perdition"],
		"starved" => ["prey", "fight-or-flight"],
		"sonic has passed" => ["burning"],
		"needlemouse" => ["round-a-bout"],
		"hog" => ["manual-blast"],
		"sunky" => ["milk"],
		"sanic" => ["too-fest"],
		"coldsteel" => ["personel"],
		"sh tails" => ["mania"]
	];

	public static var characters:Array<String> = [
	"majin", 
    "lord x", 
	"tails doll", 
	"sunky", 
	"fleetway", 
	"fatalerror", 
	"chaotix", 
    "yourself...",
	"christmas",
    "curse", 
    "starved",
    "needlemouse", 
    "hog", 
    "sanic", 
    "coldsteel", 
    "sh tails"
	];

	public static var charactersUnlocked:Array<String> = [];

	public static var songToFreeplayChar:Map<String, String> = [
		"endless" => "majin",
		"choas" => "fleetway",
		"fatality" => "fatalerror",
		"b4cksl4sh" => "sl4sh",
		"burning" => "sonic has passed",
		"soulless" => "tails doll",
		"malediction" => "curse",
		"digitalized" => "xterion",
		"manual-blast" => "hog",
		"black-sun" => "faker",
		"perdiction" => "satanos"
	];

	public static function init()
	{
		if (!loaded)
		{
			loaded = true;

			if (flixel.FlxG.save.data.charactersUnlocked != null)
			{
				var unlockedShit:Array<String> = flixel.FlxG.save.data.charactersUnlocked;

				for (str in unlockedShit)
				{
					charactersUnlocked.push(str);
				}
			}
			else
			{
				flixel.FlxG.save.data.charactersUnlocked = [];
			}

			trace(flixel.FlxG.save.data.charactersUnlocked);
		}
	}

	public static function save()
		for (str in charactersUnlocked)
			if (!flixel.FlxG.save.data.charactersUnlocked.contains(str))
				flixel.FlxG.save.data.charactersUnlocked.push(str);

	public static function getSongsByChar(char:String)
	{
		if (data.exists(char))
			return data.get(char);
		return [];
	}
}
