import flixel.addons.display.FlxBackdrop;

var cubeOne:FlxSprite;
var cubeTwo:FlxSprite;
var cubeThree:FlxSprite;
var cubeFour:FlxSprite;
var cubeGroup:FlxSpriteGroup;

var tubes:FlxSprite;
var epicBackdrop:FlxBackdrop;

var shader = null;

function onLoad() {
	var sky:FlxSprite = new FlxSprite(-1000, -1000).loadGraphic(Paths.image("epicLand/sky"));
	sky.setGraphicSize(Std.int(sky.width * 1.3));
	sky.scrollFactor.set(0.3, 0.3);
	add(sky);

	epicBackdrop = new FlxBackdrop().loadGraphic(Paths.image("epicLand/epic_tile_new"));
	epicBackdrop.velocity.set(60, 60);
	epicBackdrop.rotation = -10;
	epicBackdrop.scrollFactor.set(0.5, 0.5);
	add(epicBackdrop);
	
	tubes = new FlxSprite(-1000, -1000).loadGraphic(Paths.image("epicLand/tubes"));
	tubes.setGraphicSize(Std.int(tubes.width * 1.3));
	tubes.scrollFactor.set(0.6, 0.6);
	tubes.alpha = 0.8;
	add(tubes);
	
    shader = newShader('glitchShader');
    shader.setFloat('uSpeed', 0.5);
    shader.setFloat('uWaveAmplitude', 0.02);
    shader.setFloat('uFrequency', 1);
    shader.setBool('uEnabled', true);
    tubes.shader = shader;

	/* cubes are stolen from sgj bg
	i want them to rotate like in that. i would do it myself but i dont know how to use tweens yet :(
	also i know i could probably use a for loop to optimize it better but its almost midnight and im way too tied for that
	maybe ill do it later */
	
	// i gotchu - kay

	cubeGroup = new FlxSpriteGroup();
	add(cubeGroup);

	cubeOne = new FlxSprite(-500, 0).loadGraphic(Paths.image("epicLand/cube1"));
	cubeOne.scrollFactor.set(0.6, 0.6);
	cubeGroup.add(cubeOne);

	cubeTwo = new FlxSprite(300, -400).loadGraphic(Paths.image("epicLand/cube2"));
	cubeTwo.scrollFactor.set(0.6, 0.6);
	cubeGroup.add(cubeTwo);

	cubeThree = new FlxSprite(1050, -100).loadGraphic(Paths.image("epicLand/cube3"));
	cubeThree.scrollFactor.set(0.6, 0.6);
	cubeGroup.add(cubeThree);

	cubeFour = new FlxSprite(1700, -200).loadGraphic(Paths.image("epicLand/cube4"));
	cubeFour.scrollFactor.set(0.6, 0.6);
	cubeGroup.add(cubeFour);

	var stage:FlxSprite = new FlxSprite(-800, -900).loadGraphic(Paths.image("epicLand/hi"));
	stage.setGraphicSize(Std.int(stage.width * 1.2));	
	add(stage);

	var ball = new FlxSprite(680, -800);
	ball.frames = Paths.getSparrowAtlas('epicLand/ball');
	ball.animation.addByPrefix('spin', 'spin', 24, true);
	ball.setGraphicSize(Std.int(ball.width * 1.2));
	add(ball);
	ball.animation.play('spin', true);
}

var shaderTime:Float = 0;
function onUpdate(elapsed:Float) {
	for (sprite in cubeGroup) {
		sprite.angle += 0.2;
	}
	
    shaderTime += elapsed;
    shader.setFloat('uTime', shaderTime);
}

function onBeatHit() {
	for (sprite in cubeGroup) {
		sprite.scale.set(1.2, 1.2);
		FlxTween.tween(sprite.scale, {x: 1, y: 1}, (Conductor.crotchet / 1000) * 0.90, {ease: FlxEase.quadOut});
	}
}