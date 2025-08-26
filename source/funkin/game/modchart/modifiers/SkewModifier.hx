package funkin.game.modchart.modifiers;

import math.Vector3;

import flixel.math.FlxPoint;

import funkin.game.modchart.Modifier.ModifierOrder;
import funkin.states.*;
import funkin.objects.*;

class SkewModifier extends NoteModifier
{
	override function getName() return 'skew';
	
	override function getOrder() return PRE_REVERSE;
	
	inline function lerp(a:Float, b:Float, c:Float)
	{
		return a + (b - a) * c;
	}
	
	function getSkew(sprite:Dynamic, skew:FlxPoint, data:Int, player:Int)
	{
		var y = skew.y;
		skew.x *= 1 - getValue(player);
		skew.y *= 1 - getValue(player);
		var angle = 1;
		
		skew.x *= (Math.sin(angle * Math.PI / 180)) + (Math.cos(angle * Math.PI / 180));
		skew.x *= (Math.sin(angle * Math.PI / 180)) + (Math.cos(angle * Math.PI / 180));
		
		skew.y *= (Math.cos(angle * Math.PI / 180)) + (Math.sin(angle * Math.PI / 180));
		skew.y *= (Math.cos(angle * Math.PI / 180)) + (Math.sin(angle * Math.PI / 180));
		if ((sprite is Note) && sprite.isSustainNote) skew.y = y;
		
		return skew;
	}
	
	override function shouldExecute(player:Int, val:Float) return true;
	
	override function ignorePos() return true;
	
	override function ignoreUpdateReceptor() return false;
	
	override function ignoreUpdateNote() return false;
	
	override function updateNote(beat:Float, note:Note, pos:Vector3, player:Int)
	{
		var skew:FlxPoint = null;
		if (getSubmodValue('noteSkewX', player) > 0 || getSubmodValue('noteSkewY', player) > 0)
		{
			var skewX = getSubmodValue("noteSkewX", player);
			var skewY = getSubmodValue("noteSkewY", player);
			if (skewX == 0) skewX = note.defSkew.x;
			if (skewY == 0) skewY = note.defSkew.y;
			skew = getSkew(note, FlxPoint.weak(skewX, skewY), note.noteData, player);
		}
		else skew = getSkew(note, FlxPoint.weak(note.defSkew.x, note.defSkew.y), note.noteData, player);
		
		if (note.isSustainNote) skew.y = note.defSkew.y;
		
		note.skew.copyFrom(skew);
		skew.putWeak();
	}
	
	override function updateReceptor(beat:Float, receptor:StrumNote, pos:Vector3, player:Int)
	{
		var skew:FlxPoint = null;
		if (getSubmodValue('receptorSkewX', player) > 0 || getSubmodValue('receptorSkewY', player) > 0)
		{
			var skewX = getSubmodValue("receptorSkewX", player);
			var skewY = getSubmodValue("receptorSkewY", player);
			if (skewX == 0) skewX = receptor.defSkew.x;
			if (skewY == 0) skewY = receptor.defSkew.y;
			skew = getSkew(receptor, FlxPoint.weak(skewX, skewY), receptor.noteData, player);
		}
		else skew = getSkew(receptor, FlxPoint.weak(receptor.defSkew.x, receptor.defSkew.y), receptor.noteData, player);
		
		var skew = getSkew(receptor, FlxPoint.weak(receptor.defSkew.x, receptor.defSkew.y), receptor.noteData, player);
		receptor.skew.copyFrom(skew);
		skew.putWeak();
	}
	
	override function getSubmods()
	{
		var subMods:Array<String> = [
			"receptorSkewX",
			"receptorSkewY",
			"noteSkewX",
			"noteSkewY"
		];
		
		var receptors = modMgr.receptors[0];
		var kNum = receptors.length;
		for (i in 0...PlayState.SONG.keys)
		{
			subMods.push('receptor${i}SkewX');
			subMods.push('receptor${i}SkewY');
			subMods.push('note${i}SkewX');
			subMods.push('note${i}SkewY');
		}
		return subMods;
	}
}
