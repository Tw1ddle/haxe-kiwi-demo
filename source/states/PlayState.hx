package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import json.JsonReader;
import states.layouts.LayoutDemo;
import states.tweens.CandiesDemo;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	public var timeRunning(default, null):Float = 0;
	
	private var buttonsGroup = new FlxTypedSpriteGroup<TextButton>(); // User controls
	
	public function new() {
		super();
		
		persistentDraw = false;
		persistentUpdate = true;
	}
	
	override public function create():Void {
		super.create();
		
		var buttons:Array<TextButton> = [];
		buttons.push(new TextButton(0, 0, "Candies Demo", function() {
			openSubState(new CandiesDemo(this));
		}));
		//buttons.push(new TextButton(0, 0, "Graphs Demo", function() {
		//	openSubState(new GraphsDemo(this));
		//}));
		buttons.push(new TextButton(0, 0, "Simple Layout", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/simple_layout.json")));
		}));
		buttons.push(new TextButton(0, 0, "MousePointer", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/pointer.json")));
		}));
		buttons.push(new TextButton(0, 0, "Container", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/container.json")));
		}));
		buttons.push(new TextButton(0, 0, "Centered Container", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/centered.json")));
		}));
		buttons.push(new TextButton(0, 0, "Minsize", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/minsize.json")));
		}));
		
		// TODO BUG: sometimes these work, other times they don't. Maybe due to map order in Kiwi, or some other bug..?
		#if debug
		buttons.push(new TextButton(0, 0, "Maxsize", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/maxsize.json")));
		}));
		buttons.push(new TextButton(0, 0, "MinMaxsize", function() {
			openSubState(new LayoutDemo(this, JsonReader.readJsonFile("assets/data/minmaxsize.json")));
		}));
		#end
		
		var x:Float = 0;
		for (button in buttons) {
			button.x = x;
			button.scale.set(1, 4);
			button.updateHitbox();
			button.label.offset.y = -20;
			x += button.width + 10;
			buttonsGroup.add(button);
		}
		
		buttonsGroup.screenCenter(FlxAxes.X);
		buttonsGroup.y = FlxG.height * 0.75;
		add(buttonsGroup);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		timeRunning += dt;
	}
}