package funkin.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class SongLogo extends FlxSprite
{
	public var targetY:Float = 0;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	
	public function new(x:Float, y:Float, logo:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('freeplay/songLogos/' + logo) ?? Paths.image('freeplay/songLogos/placeholder'));
		antialiasing = ClientPrefs.globalAntialiasing;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		final lerpRate = FlxMath.getElapsedLerp(0.12, elapsed);
        
        y = FlxMath.lerp(y, (scaledY * 400) + (FlxG.height * 0.4), lerpRate);
        if (forceX != Math.NEGATIVE_INFINITY)
        {
            x = forceX;
        }
        else
        {
            x = FlxMath.lerp(x, (targetY * 250) + (FlxG.height * 0.75), lerpRate);
        }
	}
}
