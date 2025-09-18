function onLoad()
{
	var sky:FlxSprite = new FlxSprite(0, -800).loadGraphic(Paths.image("castle/sky"));
	sky.scrollFactor.set(0.1, 0.1);
	add(sky);

	var cublegoob:FlxSprite = new FlxSprite(0, -820).loadGraphic(Paths.image("castle/cubes"));
	cublegoob.scrollFactor.set(0.5, 0.5);
	add(cublegoob);

	var bg:FlxSprite = new FlxSprite(-700, -700).loadGraphic(Paths.image('castle/main' + (songName == 'Break In' ? '-tango' : '')));
	add(bg);
}