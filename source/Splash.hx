package;

import flixel.FlxState;

import funkin.FunkinAssets;
import funkin.states.TitleState;
import funkin.video.FunkinVideoSprite;

using StringTools;

@:access(flixel.FlxGame)
@:access(Main)
class Splash extends FlxState
{
	var _cachedAutoPause:Bool;
	
	var spriteEvents:FlxTimer;
	var logo:FlxSprite;
	var logoClone:FlxSprite;
	
	override function create()
	{
		_cachedAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;

		FlxTimer.wait(1, () -> {
			#if VIDEOS_ALLOWED
			var video = new FunkinVideoSprite();
			add(video);
			video.onFormat(() -> {
				video.setGraphicSize(0, FlxG.height);
				video.updateHitbox();
				video.screenCenter();
			});
			video.onEnd(finish);
			if (video.load(Paths.video('intro'))) video.delayAndStart();
			else
			#end logoFunc();
		});
	}
	
	override function update(elapsed:Float)
	{
		if (logo != null)
		{
			logo.updateHitbox();
			logo.screenCenter();
			
			if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)
			{
				finish();
			}
		}
		
		super.update(elapsed);
	}
	
	function logoFunc()
	{
		var folder = FileSystem.readDirectory('assets/images/branding');
		var img = folder[FlxG.random.int(0, folder.length - 1)];
		trace(folder);
		
		logo = new FlxSprite().loadGraphic(Paths.image('branding/${img.replace('.png', '')}'));
		logo.screenCenter();
		logo.alpha = 0;
		add(logo);

		logoClone = logo.clone();
		logoClone.screenCenter();
		logoClone.alpha = 0;
		add(logoClone);
		
		spriteEvents = new FlxTimer().start(1, (t0:FlxTimer) -> {
			new FlxTimer().start(0.25, (t1:FlxTimer) -> {
				// FlxG.sound.volume = 1;
				FlxG.sound.play(Paths.sound('intro'));
				FlxTween.tween(logo, {alpha: 1}, 1, {
					onComplete: (t:FlxTween) -> {
						new FlxTimer().start(1.10, (t2:FlxTimer) -> {
							logoClone.alpha = 0.5;
							FlxTween.tween(logoClone, {alpha: 0, 'scale.x': 1.4, 'scale.y': 1.4}, 0.75, {
								ease: FlxEase.quadOut,
								onComplete: (tt:FlxTween) -> {
									FlxTween.tween(logo, {alpha: 0, angle: 360, 'scale.x': 0, 'scale.y': 0}, 2, {
										ease: FlxEase.sineIn,
										onComplete: (ttt:FlxTween) -> {
											new FlxTimer().start(3, (t3:FlxTimer) -> {
												finish();
											});
										}
									});
								}
							});
						});
					}
				});
			});
		});
	}

	function finish()
	{
		if (spriteEvents != null)
		{
			spriteEvents.cancel();
			spriteEvents.destroy();
		}
		complete();
	}
	
	function complete()
	{
		FlxG.autoPause = _cachedAutoPause;
		FlxG.switchState(TitleState.new);
	}
}
