var skyGradient:FlxSprite;
var boppingGradient:Bool = false;
var wizzlow:FlxSprite;

function onLoad() {
	var sky:FlxSprite = new FlxSprite(0, -800).loadGraphic(Paths.image("EVILcastle/night"));
	sky.scrollFactor.set(0.1, 0.1);
	add(sky);

	skyGradient = new FlxSprite(0, -600).loadGraphic(Paths.image("EVILcastle/EVILgradient"));
	skyGradient.scrollFactor.set(0.1, 0.1);
	skyGradient.alpha = 0.3;
	add(skyGradient);

	var cublegoob:FlxSprite = new FlxSprite(0, -820).loadGraphic(Paths.image("EVILcastle/cubes-evil"));
	cublegoob.scrollFactor.set(0.5, 0.5);
	add(cublegoob);

	var bg:FlxSprite = new FlxSprite(-700, -700).loadGraphic(Paths.image("EVILcastle/main-evil"));
	add(bg);

	wizzlow = new FlxSprite(-550, 0);
	wizzlow.frames = Paths.getSparrowAtlas('wizzlow-yike');
	wizzlow.animation.addByPrefix('idle', 'idle', 24, false);
	wizzlow.animation.play('idle', true);
	add(wizzlow);
}

function onEvent(n:String, v:String, v2:String) {
	if (n == 'GradientBop') {
		boppingGradient = switch(v) {
			case 'true': true;
			case 'false': false;
			default: !boppingGradient;
		}
		
		skyGradient.alpha = 0.8;
		FlxTween.tween(skyGradient, {alpha: 0.3}, (Conductor.crotchet / 1000) / 2, {ease: FlxEase.cubicOut});
	}
}

function onBeatHit() {
	if (boppingGradient) {
		skyGradient.alpha = 0.8;
		FlxTween.tween(skyGradient, {alpha: 0.3}, (Conductor.crotchet / 1000) / 2, {ease: FlxEase.cubicOut});
	}
	
    if (curBeat % 2 == 0) {
		wizzlow.animation.play('idle', true);
    }
}

function onSongStart() {
	wizzlow.animation.play('idle', true);	
}