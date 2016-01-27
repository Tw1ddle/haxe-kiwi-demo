package states.tweens;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import kiwi.Variable;
import motion.Actuate;

class TweenSprite extends FlxSprite {
	public var infoText(default, null):FlxText;
	
	private var speedFactor:Float;
	private var pX:Variable;
	private var pY:Variable;
	private var tweenDuration:Float;
	private var ease:Dynamic;
	
	public function new(pX:Variable, pY:Variable, ?graphic:FlxGraphicAsset, ?tweenDuration:Float = 0.1, ?ease:Dynamic) {
		super(pX.value, pY.value, graphic);
		this.pX = pX;
		this.pY = pY;
		this.tweenDuration = tweenDuration;
		this.ease = ease;
		this.infoText = new FlxText();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		infoText.x = x;
		infoText.y = y;
		infoText.text = pX.name + " = " + Std.int(pX.value) + "," + pY.name + " = " + Std.int(pY.value);
	}
	
	public function tween(dt:Float):Void {
		Actuate.tween(this, tweenDuration, { x: pX.value - width / 2, y: pY.value - height / 2 }, false).ease(ease);
	}
}