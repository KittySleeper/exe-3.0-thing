package;

import flixel.FlxState;
import hxcodec.VideoHandler;

/**
 * Legit Just Plays An MP4 In A State
 */
class MP4State extends FlxState {
    var videoName:String;
    var canSkip:Bool = false;
    var onComplete:Dynamic;

    override public function new(videoName:String, canSkip:Bool = false, ?onComplete:Dynamic) {
        super();
        this.videoName = videoName;
        this.canSkip = canSkip;
        this.onComplete = onComplete;
    }

    override public function create() {
        super.create();

        var video = new VideoHandler();
        video.canSkip = canSkip;
        video.finishCallback = onComplete;
        video.playVideo(Paths.video(videoName));
    }

    override public function update(elapsed) {
        super.update(elapsed);
    }
}