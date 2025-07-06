package stages;

class LordSexStage extends BaseStage
{
    override function create()
    {
        var SKY:BGSprite = new BGSprite('LordXStage/sky', -1900, -1006, 1.0, 1.0);
		SKY.setGraphicSize(Std.int(SKY.width * .5));
		add(SKY);

		var hills:BGSprite = new BGSprite('LordXStage/hills1', -1440, -806 + 200, 1.0, 1.0);
		hills.setGraphicSize(Std.int(hills.width * .5));
		add(hills);

		var floor:BGSprite = new BGSprite('LordXStage/floor', -1400, -496, 1.0, 1.0);
		floor.setGraphicSize(Std.int(floor.width * .55));
		add(floor);

		var eyeflower:BGSprite = new BGSprite('LordXStage/WeirdAssFlower_Assets', 100 - 500, 100, 1.0, 1.0, ['flower'], true);
		eyeflower.setGraphicSize(Std.int(eyeflower.width * 0.8));
		add(eyeflower);

		var notknuckles:BGSprite = new BGSprite('LordXStage/NotKnuckles_Assets', 100 - 300, -400 + 25, 1.0, 1.0, ['Notknuckles'], true);
		notknuckles.setGraphicSize(Std.int(notknuckles.width * .5));
		add(notknuckles);

		var smallflower:BGSprite = new BGSprite('LordXStage/smallflower', -1500, -506, 1.0, 1.0);
		smallflower.setGraphicSize(Std.int(smallflower.width * .6));
		add(smallflower);

		var bfsmallflower:BGSprite = new BGSprite('LordXStage/smallflower', -1500 + 300, -506 - 50, 1.0, 1.0);
		bfsmallflower.setGraphicSize(Std.int(smallflower.width * .6));
		add(bfsmallflower);

		var smallflower2:BGSprite = new BGSprite('LordXStage/smallflowe2', -1500, -506 - 50, 1.0, 1.0);
		smallflower2.setGraphicSize(Std.int(smallflower.width * .6));
		add(smallflower2);

		var tree:BGSprite = new BGSprite('LordXStage/tree', -1900 + 650 - 100, -1006 + 350, 1.0, 1.0);
		tree.setGraphicSize(Std.int(tree.width * .7));
		add(tree);
    }
}