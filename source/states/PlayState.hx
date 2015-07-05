package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import haxe.Json;
import kiwi.Constraint;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.JsonTypes.ConstraintDefinition;
import kiwi.frontend.Resolver;
import kiwi.Solver;

using flixel.util.FlxSpriteUtil;

@:access(kiwi.Solver)
class PlayState extends FlxState {
	private var uiCamera:FlxCamera;
	private var problemTick:Int = 0;
	private var eventText:TextItem = new TextItem(0, 0, "Initializing...", 12);
	private var graph:FlxSprite;
	private var resolver:Resolver = new Resolver();
	private var solver:Solver = new Solver();
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
	
	public function generateProblem():String {
		var problem:String = '{"constraints":[{"inequality":"x >= 20", "strength":"required"},{"inequality":"y >= 2 + x", "strength":"required"}, {"inequality":"z == y - x", "strength":"required"}]}';
		problemTick++;
		return problem;
	}
	
	public function consumeProblem(problem:String):Void {		
		solver.reset();
		resolver = new Resolver();
		
		var problemDefinition: { constraints:Array<ConstraintDefinition> } = Json.parse(problem);
		
		for (constraintDefinition in problemDefinition.constraints) {
			//trace(constraintDefinition.inequality);
			var constraint:Constraint = ConstraintParser.parseConstraint(constraintDefinition.inequality, constraintDefinition.strength, resolver);
			solver.addConstraint(constraint);
		}
		
		solver.updateVariables();
	}
	
	public function graphProblem():Void {
		graph.drawLine(FlxG.width / 2, 0, FlxG.width / 2, FlxG.height);
		graph.drawLine(0, FlxG.height / 2, FlxG.width, FlxG.height / 2);
	}
	
	public function outputSolution():Void {
		var variables = resolver.variables;
		
		for (variable in variables) {
			addText(variable.name + " = " + variable.value);
		}
	}
	
	public function new():Void {
		super();
		
		add(eventText);
		
		//graph = new FlxSprite(0, 0);
		//graph.screenCenter(true, true);
		//graph.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		//add(graph);
		//addText("Created graph graphic...");
		
		uiCamera = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		FlxCamera.defaultCameras = [uiCamera];
		addText("Setup camera...");		
		
		var problem:String = generateProblem();
		addText("Made problem...");
		
		consumeProblem(problem);
		addText("Consumed problem...");
		
		addText("Outputting solution...");
		outputSolution();
		addText("Done...");
	}
	
	override public function draw():Void {
		super.draw();
		//graphProblem();
	}
}