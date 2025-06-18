package flixel.addons.transition;

class OvalTransitionSubstate extends ShapeTransitionSubstate
{
  public function new(){
    super();
    shape = 'oval';
    time = 0.9;
    maxScale = 10;
  }
}
