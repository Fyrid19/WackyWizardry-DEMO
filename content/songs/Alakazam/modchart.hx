import flixel.text.FlxText;

var stepTxt:FlxText;

function onCreate() {
    stepTxt = new FlxText(0, 400, FlxG.width, '', 36);
    stepTxt.cameras = [camHUD];
    add(stepTxt);
}

function onUpdate(elapsed:Float) {
    stepTxt.text = Std.string(curStep);
}

function onSongStart() {
    // modManager.queueEase(0, 128, "transformX", 1000, "linear");
    // modManager.queueEase(128, 170, "transformX", 0, "linear");
    // modManager.queueEase(170, 256, "transformX", 20000, "linear");
    
    modManager.queueEase(0, 32, "receptorSkewX", 1000);

    for (i in 256...512) {
        switch (i % 32) {
            case 0:
                for (j in 0...7) {
                    modManager.queueEase(i, i+4, "transform" + (j%2*2) + "Y", 10, "quartOut");
                    modManager.queueEase(i, i+4, "transform" + (j%2*2+1) + "Y", 0, "quartOut");
                }
            case 8:
                for (j in 0...7) {
                    modManager.queueEase(i, i+4, "transform" + (j%2*2) + "Y", 0, "quartOut");
                    modManager.queueEase(i, i+4, "transform" + (j%2*2+1) + "Y", 10, "quartOut");
                }
            case 16:
                for (j in 0...7) {
                    modManager.queueEase(i, i+4, "transform" + (j%2*2) + "Y", 10, "quartOut");
                    modManager.queueEase(i, i+4, "transform" + (j%2*2+1) + "Y", 0, "quartOut");
                }
            case 24:
                for (j in 0...7) {
                    modManager.queueEase(i, i+4, "transform" + (j%2*2) + "Y", 0, "quartOut");
                    modManager.queueEase(i, i+4, "transform" + (j%2*2+1) + "Y", 10, "quartOut");
                }
        }
    }
    
    modManager.queueEase(512, 512+4, "transformY", 0);
    modManager.queueEase(512, 512+4, "tipsy", 0.3);

    modManager.queueEase(768, 768+12, "drunk", 0.2);
    modManager.queueEase(768, 768+12, "tipsy", 0.5);
    
    modManager.queueEase(1008, 1024, "drunk", 0);
    modManager.queueEase(1008, 1024, "tipsy", 0);
}