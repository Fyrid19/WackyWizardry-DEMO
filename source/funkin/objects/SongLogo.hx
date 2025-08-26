package funkin.objects;

import haxe.Json;
import openfl.utils.Assets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef SongLogoData = {
	var scale:Float;
	// var anim:String;
	var antialiasing:Bool;
}

class SongLogo extends FlxSprite
{
	public var targetY:Float = 0;
	public var forceX:Float = Math.NEGATIVE_INFINITY;

	var logoData:SongLogoData;
	
	public function new(x:Float, y:Float, logo:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('freeplay/songLogos/' + logo) ?? Paths.image('freeplay/songLogos/placeholder'));

		if (Paths.fileExists('images/freeplay/songLogos/$logo.json', TEXT)) {
            logoData = Json.parse(Paths.getTextFromFile('images/freeplay/songLogos/$logo.json'));
            setGraphicSize(Std.int(width * (logoData.scale ?? 1)));
            antialiasing = logoData.antialiasing ?? ClientPrefs.globalAntialiasing;
            trace(logoData);
        } else {
            antialiasing = ClientPrefs.globalAntialiasing;
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.12, elapsed);
        
        y = FlxMath.lerp(y, (scaledY * 400) + (FlxG.height * 0.5 - height / 2), lerpRate);
        if (forceX != Math.NEGATIVE_INFINITY)
        {
            x = forceX;
        }
        else
        {
            x = FlxMath.lerp(x, (targetY * 100) + (FlxG.width / 2 - width / 2) + 230, lerpRate);
        }
	}
}
