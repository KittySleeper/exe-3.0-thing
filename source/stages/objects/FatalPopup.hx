package stages.objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;

//fully recoded by justx
//now it looks more sexy
class FatalPopup extends FlxSpriteGroup {
    static final BASE_SCALE = 1.75;
    static final TYPE2_MODIFIER = 1.2;
    static final TYPE3_MODIFIER = 1.5;
    
    public static final POPUP_LIMIT = 10;
    
    public static var activePopups:Array<FatalPopup> = [];
    static var limitedPopups:Array<FatalPopup> = [];
    
    public var onClose:Void->Void;
    var popup:FlxSprite;
    var closeButton:FlxSprite;
    var isClosing = false;
    
    public function new(x:Int = 0, y:Int = 0, type:Int = 1, ignoreLimit:Bool = false) {
        super(x, y);
        
        var scale = switch type {
            case 2: BASE_SCALE * TYPE2_MODIFIER;
            case 3: BASE_SCALE * TYPE3_MODIFIER;
            case _: BASE_SCALE;
        };
        ignoreLimit = ignoreLimit || type > 1;
        
        createPopup(scale);
        setupCloseButton(scale);
        managePopupLimit(ignoreLimit);
        
        activePopups.push(this);
        antialiasing = ClientPrefs.globalAntialiasing;
    }

    function createPopup(scale:Float) {
        popup = new FlxSprite();
        popup.frames = Paths.getSparrowAtlas("error_popups", 'exe');
        popup.animation.addByPrefix("open", "idle", 24, false);
        popup.animation.play("open");
        popup.setGraphicSize(Std.int(popup.width * scale));
        popup.updateHitbox();
        add(popup);
    }

    function setupCloseButton(scale:Float) {
        final buttonX = (88 + 34) * scale;
        final buttonY = (75 + 46) * scale;
        final buttonWidth = Std.int(32 * scale);
        final buttonHeight = Std.int(16 * scale);
        
        closeButton = new FlxSprite(buttonX, buttonY);
        closeButton.makeGraphic(buttonWidth, buttonHeight, 0x00FFFFFF);
        closeButton.alpha = 0.0001;
        add(closeButton);
    }

    function managePopupLimit(ignoreLimit:Bool) {
        if (!ignoreLimit) {
            while (limitedPopups.length >= POPUP_LIMIT) {
                limitedPopups.shift().close();
            }
            limitedPopups.push(this);
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.mouse.justPressed && !isClosing) {
            for (camera in cameras) {
                var mousePos = FlxG.mouse.getWorldPosition(camera);
                if (closeButton.overlapsPoint(mousePos, true, camera)) {
                    close();
                    break;
                }
            }
        }
    }

    public function close() {
        if (isClosing || !exists) return;
        isClosing = true;
        
        if (onClose != null) onClose();
        
        if (popup.animation.getByName("close") == null) {
            popup.animation.reverse();
            popup.animation.callback = reverseCallback;
        } else {
            popup.animation.play("close");
            popup.animation.callback = animationEndCallback;
        }
    }

    function reverseCallback(_, frame:Int, _) {
        if (frame <= 0) finalizeClose();
    }

    function animationEndCallback(_, _, _) {
        if (popup.animation.finished) finalizeClose();
    }

    function finalizeClose() {
        popup.animation.callback = null;
        kill();
    }

    override function kill() {
        if (!alive) return;
        
        activePopups.remove(this);
        limitedPopups.remove(this);
        
        super.kill();
    }

    override function destroy() {
        super.destroy();
        popup = FlxDestroyUtil.destroy(popup);
        closeButton = FlxDestroyUtil.destroy(closeButton);
        onClose = null;
    }

    public static function cleanup() {
        for (popup in activePopups.copy()) {
            popup.destroy();
        }
        activePopups = [];
        limitedPopups = [];
    }
}