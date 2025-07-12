package stages;

class TailsWorkshop extends BaseStage
{
    var background:BGSprite;
    override function create()
    {
     background = new BGSprite('shtails/bg', 0, -50, 1.95, 1.95);
     add(background);
    }

}