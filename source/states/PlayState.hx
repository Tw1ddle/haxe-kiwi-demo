package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxAxes;
import states.ShipDemo;

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
		buttons.push(new TextButton(0, 0, "Ship Demo", function() {
			openSubState(new ShipDemo(this));
		}));
		buttons.push(new TextButton(0, 0, "Layout Demo", function() {
			openSubState(new LayoutDemo(this));
		}));
		// TODO
		//buttons.push(new TextButton(0, 0, "Graphs Demo", function() {
		//	openSubState(new GraphsDemo(this));
		//}));
		
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