package;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxMath;

using StringTools;

class WarningState extends MusicBeatState
{
	var warningText:FlxText;

    var menuItems:Array<String> = ["yes", "no"];
    var menuObjects:Array<FlxText> = [];

    var curSelected:Int = 0;
    var canMove:Bool = false;

	override public function create()
	{
        super.create();

        PlayerSettings.init();

        FlxG.save.bind('exenew', 'kittysleeper');

        if (!FlxG.save.data.firstBoot) {
            FlxG.switchState(new Intro());
            return;
        }

		warningText = new FlxText(0, -1500, FlxG.width, "", 15);
		warningText.font = Paths.font("sonic-cd-menu-font.ttf");
		warningText.applyMarkup("<R>WARNING<R>\n\nThis mod is not for children or those who are easily disturbed.\nPlayer discretion is advized.\n\nThis mod contains flashing lights and imagery that may cause discomfort and or seizures for those with photosensitive epilepsy.\n\n<R>DO YOU WISH TO PROCEED?<R>",
			[new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "<R>")]);
		warningText.alignment = CENTER;
		FlxTween.tween(warningText, {y: FlxG.height / 2 - warningText.height / 2}, 3, {ease: FlxEase.quintInOut});
		add(warningText);

        for (i => item in menuItems) {
            var obj = new FlxText(450 + (300 * i), -1500, FlxG.width, item, 25);
            obj.font = Paths.font("sonic-cd-menu-font.ttf");
            FlxTween.tween(obj, {y: FlxG.height * 0.8}, 4.5 + (i * 1.5), {ease: FlxEase.quintInOut, startDelay: 3, onComplete: function(tween){canMove = i == menuObjects.length - 1;}});
            obj.ID = i;
            menuObjects.push(obj);
            add(obj);
        }
	}

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.UI_LEFT_P && canMove)
            curSelected = FlxMath.wrap(curSelected + 1, 0, menuItems.length-1);
        if (controls.UI_RIGHT_P && canMove)
            curSelected = FlxMath.wrap(curSelected - 1, 0, menuItems.length-1);
        if (controls.ACCEPT && canMove)
            accept();

        for (obj in menuObjects)
            if (curSelected == obj.ID) obj.color = FlxColor.RED else obj.color = FlxColor.WHITE;
    }

    function accept() {
        trace("accepted");

        if (warningText.text.contains("children")) { //CHILDREN?!?!
            trace("hi");
            
            if (menuObjects[curSelected].text == "yes") {
                canMove = false;

                FlxTween.tween(warningText, {y: -1500}, 3, {ease: FlxEase.quintInOut});

                for (i => obj in menuObjects) {
                    FlxTween.tween(obj, {y: -1500}, 4.5 + (i * 1.5), {ease: FlxEase.quintInOut, startDelay: 3, onComplete: function(tween){if (i == menuItems.length -1) {
                        warningText.applyMarkup("ONE MOMENT!\n\n<R>Have you already played UPDATE 2?<R>\n\nIf so, you can skip past the old content, and instead face <R>brand new terrors<R> that eagerly await you past this point\n\n...\n\n<R>SKIP AHEAD TO THE NEW CONTENT?<R>",
                        [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "<R>")]); 
                        FlxTween.tween(warningText, {y: FlxG.height / 2 - warningText.height / 2}, 1.5, {ease: FlxEase.quintInOut});
                        for (i2 => obj2 in menuObjects)
                            FlxTween.tween(obj2, {y: FlxG.height * 0.8}, 4.5 + (i2 * 1.5), {ease: FlxEase.quintInOut, startDelay: 1.5, onComplete: function(tween){canMove = i == menuItems.length - 1;}});
                    }}});
                }
            }

            if (menuObjects[curSelected].text == "no")
                Sys.exit(1);
        } else {
            if (menuObjects[curSelected].text == "yes") {
                FlxG.save.data.firstBoot = false;
                FlxG.save.flush();
            }

            FlxG.switchState(new Intro());
        }
    }
}