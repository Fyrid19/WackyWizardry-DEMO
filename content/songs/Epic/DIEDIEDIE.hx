import funkin.objects.HealthIcon;
import flixel.FlxSprite;

var mikeyDeath:FlxSprite;
var andrewKiller:FlxSprite;
var smashEffect1:FlxSprite;
var smashEffect2:FlxSprite;

var duplicateIcon:HealthIcon;

// creating stuff but hiding it as well
function onCreatePost() {
	smashEffect1 = new FlxSprite(-300);
    smashEffect1.frames = Paths.getSparrowAtlas('epicLand/die');
    smashEffect1.animation.addByPrefix('idle', 'death', 24);
    smashEffect1.setGraphicSize(Std.int(FlxG.width * 4));
    smashEffect1.screenCenter();
    smashEffect1.visible = false;
    add(smashEffect1);

	mikeyDeath = new FlxSprite(dadGroup.x, dadGroup.y).loadGraphic(Paths.image("epicLand/mikeyhesdead"));
	mikeyDeath.setGraphicSize(Std.int(mikeyDeath.width * 1.9));
    mikeyDeath.visible = false;
	add(mikeyDeath);

    andrewKiller = new FlxSprite(dadGroup.x - 2000, dadGroup.y - 100);
    andrewKiller.frames = Paths.getSparrowAtlas('epicLand/NinjaAndrew');
    andrewKiller.setGraphicSize(Std.int(andrewKiller.width * 1.6));
    andrewKiller.animation.addByPrefix('bored', 'Bored0', 24, false);
    andrewKiller.animation.addByPrefix('smug', 'Smug0', 12, false);
    andrewKiller.animation.addByPrefix('wind', 'Wind Back0', 24, false);
    andrewKiller.animation.addByPrefix('swing1', 'Swing0', 10, false);
    andrewKiller.animation.addByPrefix('idle', 'Shimmy Idle0', 12, false);
    andrewKiller.animation.play('bored');
    add(andrewKiller);

	smashEffect2 = new FlxSprite(1400);
    smashEffect2.frames = Paths.getSparrowAtlas('epicLand/superdie');
    smashEffect2.animation.addByPrefix('idle', 'superdeath', 24, false);
    smashEffect2.setGraphicSize(Std.int(FlxG.width));
    smashEffect2.angle = 270;
    add(smashEffect2);

    // duplicateIcon = new HealthIcon(game.dad.healthIcon, false);
    // duplicateIcon.cameras = [camHUD];
    // duplicateIcon.x = game.iconP2.x;
    // duplicateIcon.y = game.iconP2.y + 50;
    // duplicateIcon.visible = !ClientPrefs.hideHud;
    // duplicateIcon.alpha = ClientPrefs.healthBarAlpha;
    // add(duplicateIcon);
}

function onStepHit() {
    switch (curStep) {
        case 728:
            FlxG.camera.target = andrewKiller;
            FlxG.camera.targetOffset.y = -350;
            FlxG.camera.targetOffset.x = 100;
            FlxTween.tween(andrewKiller, {x: dadGroup.x - 500}, 1, {ease: FlxEase.quintOut});
        case 736:
            andrewKiller.animation.play('smug');
            FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.1}, 0.8, {ease: FlxEase.quintOut});
        case 743:
            andrewKiller.animation.play('wind');
            andrewKiller.offset.set(400, 180);
            FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.3}, 1, {ease: FlxEase.quintIn});
        case 748:
            andrewKiller.animation.play('swing1');
        case 752:
            mikeyDeath.visible = true;
            camHUD.alpha = 0;

            smashEffect1.visible = true;
            smashEffect1.animation.play('idle');

            // game.playHUD.iconP2.visible = false;
            // duplicateIcon.frame = 2;
            // FlxTween.shake(duplicateIcon, 0.10, 0.65);

            dadGroup.visible = false;
            FlxG.camera.followLerp = 0;
            FlxTween.tween(FlxG.camera.targetOffset, {x: 500, y: -100}, 0.01, {ease: FlxEase.quintOut});
            FlxTween.shake(mikeyDeath, 0.10, 0.65, 0x11, {onComplete: (t:FlxTween) -> {
                FlxTween.tween(camHUD, {alpha: 1}, 0.4, {ease: FlxEase.sineOut});
                FlxTween.tween(smashEffect1, {alpha: 0}, 1, {ease: FlxEase.sineIn});
                FlxTween.tween(mikeyDeath, {x: dadGroup.x + 7000, y: dadGroup.y - 2000, angle: 180}, 0.3, {ease: FlxEase.sineOut, onComplete: (t2:FlxTween) -> {
                    mikeyDeath.kill();
                    remove(mikeyDeath);
                    mikeyDeath.destroy();
                    smashEffect2.animation.play('idle');
                    FlxTween.tween(FlxG.camera.targetOffset, {x: 0}, 0.1, {ease: FlxEase.quintOut});
                    FlxG.sound.play(Paths.sound('blast'));
                }});
            }});
        case 760:
            andrewKiller.animation.play('idle', true);
            andrewKiller.offset.set(180, 100);
            FlxG.camera.targetOffset.y = 0;
            FlxG.camera.target = game.camFollow;
            FlxTween.tween(andrewKiller, {x: dadGroup.x}, 0.5, {ease: FlxEase.quadOut});
        case 768:
            FlxG.camera.followLerp = 0.04;
            dadGroup.visible = true;
            andrewKiller.kill();
            remove(andrewKiller);
            andrewKiller.destroy();
    }
}