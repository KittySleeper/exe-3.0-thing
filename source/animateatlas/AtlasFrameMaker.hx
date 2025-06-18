// AtlasFrameMaker.hx
package animateatlas;

import flixel.util.FlxDestroyUtil;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import haxe.Json;
import openfl.display.BitmapData;
import animateatlas.JSONData.AtlasData;
import animateatlas.JSONData.AnimationData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxColor;
#if desktop
import sys.FileSystem;
import sys.io.File;
#else
import js.html.FileSystem;
import js.html.File;
#end

using StringTools;

class AtlasFrameMaker extends FlxFramesCollection
{
    private static var frameCache:Map<String, Array<FlxFrame>> = new Map();
    private static var graphicsCache:Map<String, FlxGraphic> = new Map();

    public static function construct(key:String, ?_excludeArray:Array<String> = null, ?noAntialiasing:Bool = false):FlxFramesCollection
    {
        var animationData = loadAnimationData(key);
        var atlasData = loadAtlasData(key);
        var graphic = getCachedGraphic(key, atlasData);

        var ss = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
        var t = ss.createAnimation(noAntialiasing);
        
        _excludeArray = _excludeArray ?? t.getFrameLabels();
        trace('Creating: ' + _excludeArray);

        var frameCollection = new FlxFramesCollection(graphic, FlxFrameCollectionType.IMAGE);
        
        for(anim in _excludeArray)
        {
            var frames = getCachedFrames(key, anim, t, graphic);
            for(frame in frames) frameCollection.pushFrame(frame);
        }
        
        return frameCollection;
    }

    private static function loadAnimationData(key:String):AnimationData 
    {
        var path = Paths.fileExists('images/$key/Animation.json', IMAGE, false, null) 
            ? 'images/$key/Animation.json' 
            : 'images/$key/Animation1.json';
        
        return Json.parse(Paths.getTextFromFile(path).replace("\uFEFF", ""));
    }

    private static function loadAtlasData(key:String):AtlasData {
        var path = Paths.fileExists('images/$key/spritemap.json', IMAGE, false, null) 
            ? 'images/$key/spritemap.json' 
            : 'images/$key/spritemap1.json';
        
        return Json.parse(Paths.getTextFromFile(path).replace("\uFEFF", ""));
    }

    private static function getCachedGraphic(key:String, atlasData:AtlasData):FlxGraphic
    {
        var imagePath = 'images/${key}/${atlasData.meta.image}';
        if (!graphicsCache.exists(imagePath)) 
        {
            var graphic = Paths.image(imagePath);
            graphic.persist = true;
            graphicsCache.set(imagePath, graphic);
        }
        return graphicsCache.get(imagePath);
    }

    private static function getCachedFrames(key:String, animation:String, t:SpriteMovieClip, graphic:FlxGraphic):Array<FlxFrame>
    {
        var cacheKey = '$key:$animation';
        if (frameCache.exists(cacheKey)) 
            return frameCache.get(cacheKey).copy();
        
        var frames = generateFrames(t, animation, graphic);
        frameCache.set(cacheKey, frames.copy());
        return frames;
    }

    private static function generateFrames(t:SpriteMovieClip, animation:String, graphic:FlxGraphic):Array<FlxFrame> 
    {
        var frames = [];
        t.currentLabel = animation;
        var startFrame = t.getFrame(animation);
        var endFrame = startFrame + t.numFrames;
        
        for (i in startFrame...endFrame) 
        {
            t.currentFrame = i;
            if (t.currentLabel != animation) break;
            
            var bounds = t.getBounds(t);
            var bitmap = renderToBitmap(t, bounds);
            var frame = createFlxFrame(graphic, bitmap, bounds);
            frames.push(frame);
        }
        return frames;
    }

    private static function renderToBitmap(target:SpriteMovieClip, bounds:Rectangle):BitmapData
    {
        var bitmap = new BitmapData(
            Std.int(bounds.width + bounds.x), 
            Std.int(bounds.height + bounds.y), 
            true, 0
        );
        bitmap.draw(target, null, null, null, null, true);
        return bitmap;
    }

    private static function createFlxFrame(graphic:FlxGraphic, bitmap:BitmapData, bounds:Rectangle):FlxFrame
    {
        var frame = new FlxFrame(graphic);
        frame.frame = FlxRect.get(0, 0, bounds.width + bounds.x, bounds.height + bounds.y);
        frame.sourceSize.set(bounds.width + bounds.x, bounds.height + bounds.y);
        return frame;
    }

    public static function clearCache():Void
    {
        for (graphic in graphicsCache) 
            FlxDestroyUtil.destroy(graphic);
        
        graphicsCache.clear();
        frameCache.clear();
    }
}