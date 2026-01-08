function onCreate() {
    var bg = new FlxSprite(-750, 50).loadGraphic(Paths.image("requital/marble_BGP1"));
    bg.scale.set(1.5, 1.5);
    bg.antialiasing = true;
    add(bg);

    var floor = new FlxSprite(-750, 50).loadGraphic(Paths.image("requital/marble_floorP1"));
    floor.scale.set(1.5, 1.5);
    floor.antialiasing = true;
    add(floor);
}