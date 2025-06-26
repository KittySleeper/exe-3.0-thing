package stages;

class sanicStage extends BaseStage {
override function create() {
	var bg:BGSprite = new BGSprite('sanicbg', -370, -130, 1.0, 1.0);
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    add(bg);
    if (ClientPrefs.shaders)
    weedVis = new WeedVision();
}
override function stepHit() {
	if (SONG.song.toLowerCase() == 'too-fest') {
    switch (curStep) {
    case 5, 9, 12, 634, 639, 642, 646, 650, 654, 710, 716, 774, 780, 838, 845, 895, 900, 905, 910, 1472, 1476, 1480, 1484:
    game.festSpinFull();
    case 64, 69, 73, 77, 383, 389, 393, 397, 448, 452, 456, 460, 512, 516, 520, 524, 576, 580, 584, 588, 664, 698, 729, 760, 790, 857:
    game.festSpinOppenet();
    case 408, 410, 412, 472, 474, 476, 536, 538, 540, 600, 602, 604, 682, 710, 745, 808, 825, 872, 888:
    game.festSpinPlayer();
    case 912:
    if (ClientPrefs.shaders && weedVis != null) {
    game.curShader = new ShaderFilter(weedVis);
    game.camGame.filters = [curShader];
    game.camHUD.filters = [curShader];
    game.camOther.filters = [curShader];
   }
    game.weedSpinningTime = true;
    case 1167:
    game.weedSpinningTime = false;
    }
   }
  }
}