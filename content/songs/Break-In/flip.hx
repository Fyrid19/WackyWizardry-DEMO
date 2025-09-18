import flixel.text.FlxText;

var YOU:FlxText;

function onCreate() {
    game.playHUD.flipBar();
    game.playHUD.reloadHealthBarColors();
    
    YOU = new FlxText(0, 0, FlxG.width / 2, 'YOU', 36);
    YOU.setFormat(Paths.font('pointless.ttf'), 36, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    YOU.borderSize = 2.75;
    YOU.cameras = [camHUD];
    YOU.alpha = 0;
    YOU.y = ClientPrefs.downScroll ? FlxG.height - YOU.height - 200 : 200;
    add(YOU);
}

function onSongStart() {
    modManager.setValue("opponentSwap", 1);
    FlxTween.tween(YOU, {alpha: 1}, (Conductor.crotchet / 1000) * 2, {ease: FlxEase.sineOut});
    FlxTween.tween(YOU, {alpha: 0}, (Conductor.crotchet / 1000) * 2, {ease: FlxEase.sineIn, startDelay: (Conductor.crotchet / 1000) * 10});
}