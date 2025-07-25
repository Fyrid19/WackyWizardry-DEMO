package funkin.game.huds;

import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.helpers.FlxBounds;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;

import flixel.addons.ui.U;

import funkin.objects.Bar;
import funkin.objects.HealthIcon;

// not exactly psych's hud but its similar so theres stuff borrowed from it
@:access(funkin.states.PlayState)
class DimensionalHUD extends BaseHUD {
    var healthBar:DdeHealthBar;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;

	var timeBar:Bar;
    var timeTxt:FlxText;

    var scoreTxt:FlxText;
    var accuracyTxt:FlxText;
	var ratingsTxt:FlxText;

	var noteRatingTxt:FlxText;
	var noteComboTxt:FlxText;
	var ratingData:Map<String, FlxColor> = [
		'sick' => 0xFFFFFF00,
		'good' => 0xFF00FF00,
		'bad' => 0xFF0000FF,
		'shit' => 0xFFAA00FF,
		'miss' => 0xFFFF0000
	];

    var font:String = Paths.font('pointless.ttf');

	var healthBarY:Float = 0;
    override function init() {
        name = 'DDE';

        healthBar = new DdeHealthBar(0, 0, parent);
        healthBar.screenCenter(X);
        healthBar.y = (!ClientPrefs.downScroll) ? FlxG.height + healthBar.height + 20 : -healthBar.height - 20;
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
        add(healthBar);

		healthBarY = (!ClientPrefs.downScroll) ? FlxG.height - healthBar.height : 5;
		
		iconP1 = new HealthIcon(parent.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);
		
		iconP2 = new HealthIcon(parent.dad.healthIcon, false);
		iconP2.y = healthBar.y;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		
		scoreTxt = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(font, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		// add(scoreTxt);
		
		accuracyTxt = new FlxText(0, 0, FlxG.width, "", 32);
		accuracyTxt.setFormat(font, 32, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		accuracyTxt.x = -50;
		accuracyTxt.y = !ClientPrefs.downScroll ? FlxG.height - accuracyTxt.height - 50 : 50;
		accuracyTxt.alpha = 0;
		accuracyTxt.scrollFactor.set();
		accuracyTxt.borderSize = 2.5;
		accuracyTxt.visible = !ClientPrefs.hideHud;
		add(accuracyTxt);
		
		ratingsTxt = new FlxText(0, 0, FlxG.width * 0.17, "", 18);
		ratingsTxt.setFormat(font, 18, FlxColor.BLACK, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		ratingsTxt.alpha = 0;
		ratingsTxt.scrollFactor.set();
		ratingsTxt.borderSize = 1.75;
		ratingsTxt.visible = !ClientPrefs.hideHud;
		add(ratingsTxt);
		
		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(0, 0, FlxG.width, "", 18);
		timeTxt.setFormat(font, 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.y = !ClientPrefs.downScroll ? 19 : FlxG.height - timeTxt.height - 19;
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = parent.updateTime = showTime;
		if (ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		if (ClientPrefs.timeBarType == 'Song Name') timeTxt.text = PlayState.SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), '', function() return parent.songPercent, 0, 1, 600, 14);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		
		var posX:Float = FlxG.width * 0.5;
		noteRatingTxt = new FlxText(posX, 0, FlxG.width / 2, "", 22);
		noteRatingTxt.setFormat(font, 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noteRatingTxt.y = !ClientPrefs.downScroll ? FlxG.height * 0.45 : FlxG.height * 0.55;
		noteRatingTxt.scrollFactor.set();
		noteRatingTxt.borderSize = 1.75;
		noteRatingTxt.visible = !ClientPrefs.hideHud;
		noteRatingTxt.alpha = 0;
		add(noteRatingTxt);
		
		noteComboTxt = new FlxText(noteRatingTxt.x, 0, noteRatingTxt.fieldWidth, "", 16);
		noteComboTxt.setFormat(font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noteComboTxt.y = !ClientPrefs.downScroll ? noteRatingTxt.y + noteRatingTxt.height + 5 : noteRatingTxt.y - noteComboTxt.height - 5;
		noteComboTxt.scrollFactor.set();
		noteComboTxt.borderSize = 1.75;
		noteComboTxt.visible = !ClientPrefs.hideHud;
		noteComboTxt.alpha = 0;
		add(noteComboTxt);
		
		onUpdateScore(0, 0, 0);
		
		ratingsTxt.y = !ClientPrefs.downScroll ? FlxG.height - ratingsTxt.height - 50 : 50;
		
        reloadHealthBarColors();
		
		parent.setOnScripts('healthBar', healthBar);
		parent.setOnScripts('iconP1', iconP1);
		parent.setOnScripts('iconP2', iconP2);
		parent.setOnScripts('accuracyTxt', accuracyTxt);
		parent.setOnScripts('ratingsTxt', ratingsTxt);
		parent.setOnScripts('timeBar', timeBar);
		parent.setOnScripts('timeTxt', timeTxt);
		parent.setOnScripts('noteRatingTxt', noteRatingTxt);
		parent.setOnScripts('noteComboTxt', noteComboTxt);
    }
    
	override function update(elapsed:Float) {
		super.update(elapsed);
		updateIconsPosition();
        updateIconsScale(elapsed);

        if (healthBar.isAnimFinish() && healthBar.getAnim().startsWith('bump') && !healthBar.trans)
            healthBar.playAnim('idle' + animSuffix, true);
		
		if (!parent.startingSong && !parent.paused && parent.updateTime && !parent.endingSong) {
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
			parent.songPercent = (curTime / parent.songLength);
			
			var songCalc:Float = (parent.songLength - curTime);
			if (ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;
			
			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if (secondsTotal < 0) secondsTotal = 0;
			
			if (ClientPrefs.timeBarType != 'Song Name') timeTxt.text = flixel.util.FlxStringUtil.formatTime(secondsTotal, false);
		}
    }

	override function onCountdown(count:Int) {
		switch (count) {
			case 0:
				FlxTween.tween(iconP1, {y: healthBarY}, (Conductor.crotchet / 1000), {ease: FlxEase.circOut});
			case 1:
				FlxTween.tween(iconP2, {y: healthBarY}, (Conductor.crotchet / 1000), {ease: FlxEase.circOut});
			case 2:
				FlxTween.tween(healthBar, {y: healthBarY}, (Conductor.crotchet / 1000), {ease: FlxEase.circOut});
			case 3:
				iconP1.scale.set(1.4, 1.4);
				iconP2.scale.set(1.4, 1.4);
				FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crotchet / 1250 * parent.gfSpeed, {ease: FlxEase.circOut});
				FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crotchet / 1250 * parent.gfSpeed, {ease: FlxEase.circOut});
		}
	}

	override function onSongStart() {
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(accuracyTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(ratingsTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	}

    public var animSuffix:String = '';
    
    var oldHealth:Float = 0;
    override function onHealthChange(health:Float) {
		final newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.playstate.health, healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);
		
		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; // If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; // If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)

        // health bar anim
        if (healthBar.percent > 80) {
            animSuffix = '-winning';
            // trace('winner winner');
        } else if (healthBar.percent < 20) {
            animSuffix = '-losing';
            // trace('yo you fucking suck');
        }

        if (animSuffix == '-winning') {
            if (oldHealth < 80 && healthBar.percent > 80) {
                healthBar.playAnim('transin' + animSuffix);
                healthBar.trans = true;
            } else if (oldHealth > 80 && healthBar.percent < 80) {
                healthBar.playAnim('transout' + animSuffix);
                healthBar.trans = true;
                animSuffix = '';
            }
        } else if (animSuffix == '-losing') {
            if (oldHealth > 20 && healthBar.percent < 20) {
                healthBar.playAnim('transin' + animSuffix);
                healthBar.trans = true;
            } else if (oldHealth < 20 && healthBar.percent > 20) {
                healthBar.playAnim('transout' + animSuffix);
                healthBar.trans = true;
                animSuffix = '';
            }
        }

        if (healthBar.trans) {
            if (healthBar.isAnimFinish() && (healthBar.getAnim().startsWith('transin') || healthBar.getAnim().startsWith('transout'))) {
                healthBar.trans = false;
                // trace('no transitioning');
            }
        }

        oldHealth = healthBar.percent;
	}
	
	override function onCharacterChange() {
		reloadHealthBarColors();
		iconP1.changeIcon(parent.boyfriend.healthIcon);
		iconP2.changeIcon(parent.dad.healthIcon);
	}

    override function beatHit() {
		if (curBeat % parent.gfSpeed == 0) { //new shit
			iconP1.scale.set(1.4, 0.9);
			iconP2.scale.set(1.4, 0.9);

			FlxTween.angle(iconP1, -5, 0, Conductor.crotchet / 1300 * parent.gfSpeed, {ease: FlxEase.backOut});
			FlxTween.angle(iconP2, 5, 0, Conductor.crotchet / 1300 * parent.gfSpeed, {ease: FlxEase.backOut});

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crotchet / 1250 * parent.gfSpeed, {ease: FlxEase.circOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crotchet / 1250 * parent.gfSpeed, {ease: FlxEase.circOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

        if (curBeat % parent.gfSpeed * 2 == 0) {
            if (!healthBar.trans) healthBar.playAnim('bump' + animSuffix);
        }
	}

    override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false) {
		// scoreTxt.text = FlxStringUtil.formatMoney(score, false);
		
		if (score > 0)
        	accuracyTxt.text = '$accuracy%';
		else
			accuracyTxt.text = '100%';

		ratingsTxt.text = 'SICK: ' + U.padDigits(parent.sicks, 3) + '\n'
		+ 'GOOD: ' + U.padDigits(parent.goods, 3) + '\n'
		+ 'BAD: ' + U.padDigits(parent.bads, 3) + '\n'
		+ 'SHIT: ' + U.padDigits(parent.shits, 3) + '\n'
		+ 'MISSES: ' + U.padDigits(misses, 3) + '\n';

		if (missed) popUpScore('miss', 0);
	}

	var comboTimer:FlxTimer = null;
	override function popUpScore(ratingImage:String, combo:Int) {
		FlxTween.cancelTweensOf(noteRatingTxt);
		FlxTween.cancelTweensOf(noteComboTxt);
		if (comboTimer != null) comboTimer.cancel();

		noteRatingTxt.alpha = 1;
		noteComboTxt.alpha = 1;

		noteRatingTxt.text = ratingImage.toUpperCase();
		noteComboTxt.text = U.padDigits(combo, 3);

		noteRatingTxt.color = ratingData[ratingImage];

		comboTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxTween.tween(noteRatingTxt, {alpha: 0}, 0.5);
			FlxTween.tween(noteComboTxt, {alpha: 0}, 0.5);
		});
	}

    public function updateIconsScale(elapsed:Float) {
		// var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9));
		// iconP1.scale.set(mult, mult);
		// iconP1.updateHitbox();
		
		// var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9));
		// iconP2.scale.set(mult, mult);
		// iconP2.updateHitbox();
	}

    public function updateIconsPosition() {
		final iconOffset:Int = 26;

        var healthOffset:Float = (healthBar.percent - 50) * 1.45;

		if (!healthBar.leftToRight) {
			iconP1.x = (healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset) + healthOffset;
			iconP2.x = (healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2) + healthOffset;
		} else {
			iconP1.x = (healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2) + healthOffset;
			iconP2.x = (healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset) + healthOffset;
		}
	}

    public function reloadHealthBarColors() {
		var dad = parent.dad;
		var bf = parent.boyfriend;
        healthBar.changeColors(dad.healthColour, bf.healthColour);

        var colorBorder:FlxColor = dad.healthColour;
        var colorLeft:FlxColor = dad.healthColour;
        var colorRight:FlxColor = dad.healthColour;

        colorBorder.brightness = 0.4;
        colorRight.brightness = 0.7;

        timeBar.setColors(colorLeft, colorRight, colorBorder);
	}
}

// a lot of this is referenced from the bar class i just made it work how i want it to
class DdeHealthBar extends FlxSpriteGroup {
    public var healthBarLeft:FlxSprite;
    public var healthBarRight:FlxSprite;

    public var playstate:PlayState;
    
    public var percent(default, set):Float;
    public var bounds:FlxBounds<Float> = new FlxBounds(0.0, 0.0);
	public var leftToRight(default, set):Bool = false;

	public var barWidth:Int = 1;
	public var barHeight:Int = 1;
	public var barCenter(default, null):Float = 0;

    public var trans:Bool = false; // bad words here (im funny)

    public function new(x:Float, y:Float, playstate:PlayState, ?color1:FlxColor, ?color2:FlxColor) {
        super(x, y);

        this.playstate = playstate;

        setBounds(playstate.healthBounds.min, playstate.healthBounds.max);

        var scroll:String = !ClientPrefs.downScroll ? 'Upscroll' : 'Downscroll';
        
        healthBarLeft = new FlxSprite();
        healthBarLeft.frames = Paths.getSparrowAtlas(getAsset(!ClientPrefs.downScroll ? 'healthbar_upscroll' : 'healthbar_downscroll'));

        healthBarLeft.animation.addByIndices('idle', scroll, [0], '', 24, true);

        healthBarLeft.animation.addByIndices('transin-losing', scroll, MathUtil.numberArray(1, 8), '', 24, false);
        healthBarLeft.animation.addByIndices('bump-losing', scroll, MathUtil.numberArray(9, 25), '', 24, true);
        healthBarLeft.animation.addByIndices('idle-losing', scroll, [25], '', 24, true);
        healthBarLeft.animation.addByIndices('transout-losing', scroll, [26, 27, 28, 29, 0], '', 24, false);

        healthBarLeft.animation.addByIndices('transin-winning', scroll, MathUtil.numberArray(30, 37), '', 24, false);
        healthBarLeft.animation.addByIndices('bump-winning', scroll, MathUtil.numberArray(38, 54), '', 24, true);
        healthBarLeft.animation.addByIndices('idle-winning', scroll, [54], '', 24, true);
        healthBarLeft.animation.addByIndices('transout-winning', scroll, [55, 56, 57, 58, 0], '', 24, false);

        healthBarRight = healthBarLeft.clone();
        
        playAnim('idle', true);

        barWidth = Std.int(healthBarLeft.width);
        barHeight = Std.int(healthBarLeft.height);

        healthBarLeft.color = color1 ?? 0xFFFF0000;
        healthBarRight.color = color2 ?? 0xFF00FF00;
        
		healthBarLeft.antialiasing = healthBarRight.antialiasing = antialiasing = ClientPrefs.globalAntialiasing;

        add(healthBarRight);
        add(healthBarLeft);
        
		regenerateClips();
    }
	
	public var enabled:Bool = true;

    override function update(elapsed:Float) {
		if (!enabled)
		{
			super.update(elapsed);
			return;
		}
		
		if (playstate != null)
		{
			var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(playstate.health, bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
			percent = (value != null ? value : 0);
		}
		else percent = 0;
		super.update(elapsed);
	}

    public function setBounds(min:Float, max:Float) {
		bounds.min = min;
		bounds.max = max;
	}

    public function playAnim(anim:String, ?force:Bool = true) {
        healthBarLeft.animation.play(anim, force);
        healthBarRight.animation.play(anim, force);
        // trace(anim);
    }

    public function getAnim() {
        return healthBarLeft.animation.name; // they should both be doing the same animation anyway
    }

    public function isAnimFinish() {
        return healthBarLeft.animation.finished && healthBarRight.animation.finished;
    }

    public function updateBar() {
        if (healthBarLeft == null || healthBarRight == null) return;
		
		healthBarLeft.setPosition(x, y);
		healthBarRight.setPosition(x, y);
		
		var leftSize:Float = 0;
		if (leftToRight) leftSize = FlxMath.lerp(0, barWidth, percent / 100);
		else leftSize = FlxMath.lerp(0, barWidth, 1 - percent / 100);
		
		healthBarLeft.clipRect.width = leftSize;
		healthBarLeft.clipRect.height = barHeight;
		
		healthBarRight.clipRect.width = barWidth - leftSize;
		healthBarRight.clipRect.height = barHeight;
		healthBarRight.clipRect.x = leftSize;
		
		barCenter = healthBarLeft.x + leftSize;
        
        healthBarLeft.clipRect = healthBarLeft.clipRect;
        healthBarRight.clipRect = healthBarRight.clipRect;
    }

    public function regenerateClips() {
		if (healthBarLeft != null)
		{
			healthBarLeft.setGraphicSize(barWidth, barHeight);
			healthBarLeft.updateHitbox();
			healthBarLeft.clipRect = new FlxRect(0, 0, barWidth, barHeight);
		}
		if (healthBarRight != null)
		{
			healthBarRight.setGraphicSize(barWidth, barHeight);
			healthBarRight.updateHitbox();
			healthBarRight.clipRect = new FlxRect(0, 0, barWidth, barHeight);
		}
		updateBar();
	}

    public function changeColors(color1:FlxColor, color2:FlxColor) {
        if (healthBarLeft != null) healthBarLeft.color = color1;
        if (healthBarRight != null) healthBarRight.color = color2;
    }

    private function set_percent(value:Float) {
		var doUpdate:Bool = false;
		if (value != percent) doUpdate = true;
		percent = value;
		
		if (doUpdate) updateBar();
		return value;
	}

    private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

    public function getAsset(asset:String)
        return 'hud/$asset';
}