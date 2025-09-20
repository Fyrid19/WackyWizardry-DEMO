var pruj:FlxSprite;

function onCreatePost() {
    pruj = new FlxSprite();
    pruj.frames = Paths.getSparrowAtlas('pruj');
    pruj.animation.addByPrefix('idle', 'pruj idle0', 24);
    pruj.animation.addByPrefix('run', 'pruj run0', 24);
    pruj.animation.play('run');
    pruj.cameras = [camOther];
    pruj.x = -pruj.width;
    pruj.y = FlxG.height/2 - pruj.height/2;
    add(pruj);
}

function onStepHit() {
    switch (curStep) {
        case 126:
            FlxTween.tween(pruj, {x: FlxG.width/2 - pruj.width/2}, 0.5, {onComplete: (t) -> {
                pruj.animation.play('idle');
                new FlxTimer().start(2, (t2) -> {
                    pruj.animation.play('run');
                    FlxTween.tween(pruj, {x: FlxG.width}, 0.5);
                });
            }});
    }
}