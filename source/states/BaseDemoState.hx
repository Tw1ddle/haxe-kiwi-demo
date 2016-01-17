package states;

import flixel.FlxG;
import flixel.FlxSubState;
import kiwi.DebugHelper;
import kiwi.frontend.Resolver;
import kiwi.Solver;

@:access(kiwi.Solver)
class BaseDemoState extends FlxSubState {
	private var game:PlayState;
	
	private var resolver:Resolver = new Resolver();
	private var solver:Solver = new Solver();
	
	private var eventText:TextItem = new TextItem(0, 0, "Initializing...", 12);
	private var backButton:TextButton;
	
	public function new(game:PlayState) {
		super();
		this.game = game;
	}
	
	override public function create():Void {
		super.create();
		
		backButton = new TextButton(20, FlxG.height, "Back", function():Void {
			game.closeSubState();
		});
		backButton.scale.set(1, 4);
		backButton.updateHitbox();
		backButton.label.offset.y = -20;
		backButton.y -= backButton.height + 20;
		add(backButton);
		
		add(eventText);
		logInstructions();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.keys.justPressed.A) {
			clearLog();
			logInstructions();
			logVariables(resolver);
		}
		if (FlxG.keys.justPressed.C) {
			clearLog();
			logInstructions();
			logConstraints(solver);
		}
	}
	
	private static var imageTypes:Array<String> = [ "jelly", "heart", "lollipop", "star", "swirl", "wrappedsolid" ];
	private static var imageColors:Array<String> = [ "red", "teal", "blue", "orange", "purple", "yellow" ];
	public static function getCandyName(?type:String = null, ?color:String = null):String {
		if (type == null) {
			type = imageTypes[Std.int(Math.random() * (imageTypes.length - 1))];
		}
		if (color == null) {
			color = imageColors[Std.int(Math.random() * (imageColors.length - 1))];
		}
		return "assets/images/" + type + "_" + color + ".png";
	}
	
	public function logConstraints(solver:Solver):Void {
		addText("==========================");
		addText("^^^^^Constraints^^^^^");
		addText(DebugHelper.dumpConstraints(solver.constraints));
		addText("==========================");
	}
	
	public function logVariables(resolver:Resolver):Void {
		addText("==========================");
		addText("^^^^^Solver variables^^^^^");
		for (variable in resolver.variables) {
			addText(variable.name + " = " + variable.value);
		}
		addText("==========================");
	}
	
	public function logInstructions():Void {
		addText("Press 'A' to dump solver variables");
		addText("Press 'C' to dump solver constraints");
	}
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
}