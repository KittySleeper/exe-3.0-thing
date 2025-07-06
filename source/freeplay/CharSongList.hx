package freeplay;

import flixel.FlxG;

class CharSongList
{
	static var initialized = false;
	
	public static final characters = [
		"majin", 
		"lord x", 
		"tails doll", 
		"sunky", 
		"fleetway", 
		"fatalerror", 
		"chaotix", 
		"yourself...", 
		"curse", 
		"starved",
		"needlemouse", 
		"hog", 
		"sanic", 
		"coldsteel", 
		"sh tails"
	];
	
	public static var charactersUnlocked:Array<String> = [];
	
	public static final songData:Map<String, Array<String>> = [
		"majin" => ["endless", "endless-og"],
		"lord x" => ["cycles"],
		"tails doll" => ["sunshine", "soulless"],
		"sunky" => ["milk"],
		"fleetway" => ["chaos"],
		"fatalerror" => ["fatality"],
		"chaotix" => ["my-horizon", "our-horizon"],
		"yourself..." => ["yourself"],
		"curse" => ["malediction"],
		"starved" => ["prey", "fight-or-flight"],
		"needlemouse" => ["round-a-bout"],
		"hog" => ["hog", "manual-blast"],
		"sanic" => ["too-fest"],
		"coldsteel" => ["personel", "personel-serious"],
		"sh tails" => ["mania"]
	];
	
	public static function init()
	{
		if (initialized) return;
		initialized = true;
		
		charactersUnlocked = FlxG.save.data.charactersUnlocked != null ? 
			FlxG.save.data.charactersUnlocked.copy() : [];
	}

	public static function unlockSong(songId:String) {
        if (FlxG.save.data.unlockedSongs == null) {
            FlxG.save.data.unlockedSongs = [];
        }
        
        if (!FlxG.save.data.unlockedSongs.contains(songId)) {
            FlxG.save.data.unlockedSongs.push(songId);
            save();
        }
    }
    
    public static function isSongUnlocked(songId:String):Bool {
        if (FlxG.save.data.cheatUnlock) return true;
        
        if (FlxG.save.data.unlockedSongs != null) {
            return FlxG.save.data.unlockedSongs.contains(songId);
        }
        return false;
    }
	
	public static function save() {
		FlxG.save.data.charactersUnlocked = charactersUnlocked.copy();
	}
	
	public static function getSongsByChar(char:String):Array<String> {
		return songData.exists(char) ? songData.get(char) : [];
	}
}