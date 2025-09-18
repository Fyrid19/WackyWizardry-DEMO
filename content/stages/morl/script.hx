function onLoad()
{
	var bg:FlxSprite = new FlxSprite(200, -700).loadGraphic(Paths.image("morl"));
	bg.setGraphicSize(Std.int(bg.width * 4));
	game.gfGroup.alpha = 0;

	add(bg);
}

function onStepHit() {
    if (curStep == 236) { //236
        FlxTween.tween(dadGroup, {alpha: 0}, 3.5, {
            ease: FlxEase.sineOut
        });
    }
}