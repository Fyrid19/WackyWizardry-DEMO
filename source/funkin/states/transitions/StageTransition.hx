package funkin.states.transitions;

import funkin.backend.BaseTransitionState;

class StageTransition extends BaseTransitionState {
	var fillOne:FlxSprite;
	var fillTwo:FlxSprite;
	
	override function create() {
		final cam = CameraUtil.lastCamera;
		cameras = [cam];
        
		final duration:Float = status == OUT ? 0.8 : 0.6;
		final zoom:Float = FlxMath.bound(cam.zoom, 0.001);
		final width:Int = Math.ceil(cam.width / zoom);
		final height:Int = Math.ceil(cam.height / zoom);

        if (status == IN) {
            fillOne = new FlxSprite().makeScaledGraphic(width, height/2, FlxColor.BLACK);
            fillOne.y = -height/2;
            fillOne.scrollFactor.set();
            add(fillOne);
            
            fillTwo = new FlxSprite().makeScaledGraphic(width, height/2, FlxColor.BLACK);
            fillTwo.y = height;
            fillTwo.scrollFactor.set();
            add(fillTwo);
            
            FlxTween.tween(fillOne, {y: 0}, duration, {ease: FlxEase.quadInOut});
            FlxTween.tween(fillTwo, {y: height/2}, duration, {onComplete: Void -> dispatchFinish(), ease: FlxEase.quadInOut});
        } else {
            fillOne = new FlxSprite().makeScaledGraphic(width/2, height, FlxColor.BLACK);
            fillOne.x = 0;
            fillOne.scrollFactor.set();
            add(fillOne);
            
            fillTwo = new FlxSprite().makeScaledGraphic(width/2, height, FlxColor.BLACK);
            fillTwo.x = width/2;
            fillTwo.scrollFactor.set();
            add(fillTwo);
            
            FlxTween.tween(fillOne, {x: -width/2}, duration, {ease: FlxEase.quadInOut});
            FlxTween.tween(fillTwo, {x: width}, duration, {onComplete: Void -> dispatchFinish(), ease: FlxEase.quadInOut});
        }
		
		super.create();
    }
}