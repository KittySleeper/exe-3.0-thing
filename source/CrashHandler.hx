package;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Exception;
import flixel.FlxG;
import lime.system.System;

using StringTools;

class CrashHandler
{
    static final LOGS_DIR = "logs/";
    
    public static function init():Void
    {
        try {
            openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
            #if cpp
            untyped __global__.__hxcpp_set_critical_error_handler(onError);
            #elseif hl
            hl.Api.setErrorHandler(onError);
            #end
        } catch (e:Exception) {
            trace("Failed to initialize crash handler: " + e.message);
        }
    }

    private static function onUncaughtError(e:UncaughtErrorEvent):Void
    {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        var message = parseErrorMessage(e.error);
        var stack = formatStack(haxe.CallStack.exceptionStack());
        
        handleCrash(message, stack);
    }

    #if (cpp || hl)
    private static function onError(message:Dynamic):Void
    {
        var log = [];
        if (message != null && Std.string(message).length > 0)
            log.push(Std.string(message));
            
        log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));
        handleCrash(log.join('\n'), "");
    }
    #end

    private static function parseErrorMessage(error:Dynamic):String
    {
        return if (Std.isOfType(error, Error)) {
            cast(error, Error).message;
        } else if (Std.isOfType(error, ErrorEvent)) {
            cast(error, ErrorEvent).text;
        } else {
            Std.string(error);
        }
    }

    private static function formatStack(stack:Array<haxe.CallStack.StackItem>):String
    {
        return [for (item in stack) switch (item) {
            case CFunction: "Non-Haxe (C) Function";
            case Module(c): 'Module $c';
            case FilePos(parent, file, line, _):
                switch (parent) {
                    case Method(cla, func): '${file.replace(".hx", "")}.$func() [line $line]';
                    case _: '${file.replace(".hx", "")} [line $line]';
                }
            case LocalFunction(v): 'Local Function $v';
            case Method(cl, m): '$cl - $m';
        }].join("\n");
    }

    private static function handleCrash(message:String, stack:String):Void
    {
        var fullError = message + (stack.length > 0 ? '\n$stack' : "");
        
        #if sys
        saveCrashLog(fullError);
        #end
        
        stopAudio();
        showErrorPopup(fullError);
        System.exit(1);
    }

    private static function stopAudio():Void
    {
        FlxG.sound.music?.stop();
        try {
            if (PlayState.instance != null) {
                PlayState.instance.vocals?.stop();
            }
        } catch (e:Dynamic) {}
    }

    private static function showErrorPopup(message:String):Void
    {
        try {
            CoolUtil.showPopUp(message, "Error!");
        } catch (e:Dynamic) {
            trace("Failed to show error popup: " + e);
        }
    }

    #if sys
    private static function saveCrashLog(content:String):Void
    {
        try {
            if (!FileSystem.exists(LOGS_DIR)) {
                FileSystem.createDirectory(LOGS_DIR);
            }
            
            var fileName = LOGS_DIR + Date.now().toString()
                .replace(" ", "-")
                .replace(":", "'") + ".txt";
                
            File.saveContent(fileName, content);
        } catch (e:Exception) {
            trace('Failed to save crash log: ${e.message}');
        }
    }
    #end
}