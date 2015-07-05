package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	private var uiCamera:FlxCamera;
	private var problemCount:Int;
	private var eventText:TextItem;
	private var graph:FlxSprite;
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
	
	public function generateProblem():String {
		var problem:String = "";
		
		problemCount++;
		
		return problem;
	}
	
	public function new():Void {
		super();
		destroySubStates = false;
		
		problemCount = 0;
		
		eventText = new TextItem(0, 0, "Initializing...", 12);
		add(eventText);
		
		uiCamera = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		FlxCamera.defaultCameras = [uiCamera];
		addText("Setup camera...");
		
		graph = new FlxSprite();
		FlxSpriteUtil.screenCenter(graph);
		add(graph);
		addText("Created graph graphic...");
		
		var problem:String = generateProblem();
		
		addText("Created problem...");
		
		addText("Graphing problem...");
	}
}