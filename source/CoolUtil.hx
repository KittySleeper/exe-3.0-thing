package;

import flixel.FlxG;
import flixel.sound.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if windows
import winapi.WindowsAPI;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	inline public static function clamp(n:Float, l:Float, h:Float)
	{
		if (n > h)
			n = h;
		if (n < l)
			n = l;

		return n;
	}

	public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point == null ? FlxPoint.weak() : point;
		p.set((x * Math.cos(angle)) - (y * Math.sin(angle)), (x * Math.sin(angle)) + (y * Math.cos(angle)));
		return p;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}

	inline public static function quantizeAlpha(f:Float, interval:Float){
		return Std.int((f+interval/2)/interval)*interval;
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	public static function hasVersion(vers:String) {
		return lime.system.System.platformLabel.toLowerCase().indexOf(vers.toLowerCase()) != -1;
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function unzipFile(srcZip:String, dstDir:String, ignoreRootFolder:Bool = false) {
        trace("Unzipping archive");
		
        FileSystem.createDirectory(dstDir);
        
        var inFile = sys.io.File.read(srcZip);
        var entries = haxe.zip.Reader.readZip(inFile);
        inFile.close();

        for(entry in entries) {
            var fileName = entry.fileName;
            if (fileName.charAt(0) != "/" && fileName.charAt(0) != "\\" && fileName.split("..").length <= 1) {
                var dirs = ~/[\/\\]/g.split(fileName);
                if ((ignoreRootFolder != false && dirs.length > 1) || ignoreRootFolder == false) {
                    if (ignoreRootFolder != false) {
                        dirs.shift();
                    }
                
                    var path = "";
                    var file = dirs.pop();
                    for (d in dirs) {
                        path += d;
                        sys.FileSystem.createDirectory(dstDir + "/" + path);
                        path += "/";
                    }
                
                    if (file == "") {
                        continue;
                    }

                    path += file;
                
                    var data = haxe.zip.Reader.unzip(entry);
                    var f = File.write(dstDir + "/" + path, true);
                    f.write(data);
                    f.close();
                }
            }
        } //_entry

        var contents = sys.FileSystem.readDirectory(dstDir);
        if (contents.length > 0) {
            trace('Unzipped successfully to ${dstDir}: (${contents.length} top level items found)');
        } else {
            throw 'No contents found in "${dstDir}"';
        }
    }

	public static function setDarkMode(title:String, enable:Bool) {
		#if windows
		if(title == null) title = lime.app.Application.current.window.title;
		lime.Native.setDarkMode(title, enable);
		#end
	}

	public static function showPopUp(message:String, title:String):Void
	{
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#elseif linux
		Sys.command("zenity", ["--info", "--title=" + title, "--text=" + message]);
		#elseif windows
		WindowsAPI.showMessageBox(message, title);
		#else
		lime.app.Application.current.window.alert(message, title);
		#end
	}
}
