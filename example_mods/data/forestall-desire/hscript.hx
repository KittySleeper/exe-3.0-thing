import Character;
import Boyfriend;

function onCreatePost()
{
	playerStrums.forEach(function(spr:FlxSprite)
	{
		spr.x -= 30;
	});

	opponentStrums.forEach(function(spr:FlxSprite)
	{
		spr.x += 30;

	});
}

function onUpdatePost(elapsed) {
    switch (curStep) {
        case 784:
            FlxG.camera.flash();

            var black = new FlxSprite(-800, -320).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
            insert(3, black);

            dadGroup.remove(dad);
            var olddx = dad.x;
            var olddy = dad.y;
            dad = new Character(olddx, olddy, 'requital-whisper');
            dadGroup.add(dad);

            boyfriendGroup.remove(boyfriend);
            var oldbfx = boyfriend.x + 50;
            var oldbfy = boyfriend.y - 100;
            boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-whisper');
            boyfriendGroup.add(boyfriend);

            gfGroup.remove(gf);
            var oldgfx = gf.x + 350;
            var oldgfy = gf.y - 120;
            gf = new Character(oldgfx, oldgfy, 'pico-whisper');
            gfGroup.add(gf);
    }
}