package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import json.EaseHelper;
import json.JsonReader;
import json.NodeDefinition;
import kiwi.Constraint;
import kiwi.DebugHelper;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.Resolver;
import kiwi.Solver;
import kiwi.Strength;
import kiwi.Variable;
import motion.Actuate;

using flixel.util.FlxSpriteUtil;

class Node extends FlxSprite {
	private var speedFactor:Float;
	private var pX:Variable;
	private var pY:Variable;
	private var tweenDuration:Float;
	private var ease:Dynamic;
	public var infoText:FlxText;
	
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
		infoText.text = pX.name + " = " + pX.value + "," + pY.name + " = " + pY.value;
	}
	
	public function tween(dt:Float):Void {
		Actuate.tween(this, tweenDuration, { x: pX.value - width / 2, y: pY.value - height / 2 }, false).ease(ease);
	}
}

@:access(kiwi.Solver)
class PlayState extends FlxState {
	private static var imageTypes:Array<String> = [ "jelly", "heart", "lollipop", "star", "swirl", "wrappedsolid" ];
	private static var imageColors:Array<String> = [ "red", "teal", "blue", "orange", "purple", "yellow" ];
	
	private var problemDefinition: { nodes:Array<NodeDefinition> };
	private var eventText:TextItem = new TextItem(0, 0, "Initializing...", 12);
	
	private var debugCanvas:FlxSprite = new FlxSprite();
	
	private var resolver:Resolver = new Resolver();
	private var solver:Solver = new Solver();
	private var root:Node;
	private var nodes:Array<Node> = new Array<Node>();
	
	private var mouseX:Variable;
	private var mouseY:Variable;
	
	private var timeRunning:Float = 0;
	private var sin2Time:Variable;
	private var squareWave:Variable;
	
	private var drawDebug:Bool = true;
	
	override public function create():Void {
		super.create();
		add(eventText);
		
		loadProblem(JsonReader.readJsonFile("assets/data/equalities.json"));
		
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(debugCanvas);
		
		logInstructions();
	}
	
	override public function draw():Void {
		super.draw();
		
		if(drawDebug) {
			for (nodeDefinition in problemDefinition.nodes) {
				var x = resolver.resolveVariable(nodeDefinition.xVar);
				var y = resolver.resolveVariable(nodeDefinition.yVar);
				
				debugCanvas.drawLine(x.value - 5, y.value, x.value + 5, y.value);
				debugCanvas.drawLine(x.value, y.value - 5, x.value, y.value + 5);
			}
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		timeRunning += dt;
		
		if (FlxG.keys.justPressed.A) {
			clearLog();
			logInstructions();
			logVariables();
		}
		if (FlxG.keys.justPressed.C) {
			clearLog();
			logInstructions();
			logConstraints();
		}
		if (FlxG.keys.justPressed.D) {
			toggleDebug();
		}
		
		var sin2 = Math.pow(Math.sin(timeRunning), 2);
		solver.suggestValue(sin2Time, sin2);
		
		if (sin2 <= 0.5) {
			solver.suggestValue(squareWave, 0);
		} else {
			solver.suggestValue(squareWave, 1);
		}
		
		solver.suggestValue(mouseX, FlxG.mouse.x);
		solver.suggestValue(mouseY, FlxG.mouse.y);
		
		solver.updateVariables();
		
		for(node in nodes) {
			node.tween(dt);
		}
	}
	
	private function loadProblem(problem:String):Void {
		solver.reset();
		resolver = new Resolver();
		
		mouseX = resolver.resolveVariable("mousex");
		mouseY = resolver.resolveVariable("mousey");
		sin2Time = resolver.resolveVariable("sin2Time");
		squareWave = resolver.resolveVariable("squareWave");
		solver.addEditVariable(mouseX, Strength.strong);
		solver.addEditVariable(mouseY, Strength.strong);
		solver.addEditVariable(sin2Time, Strength.strong);
		solver.addEditVariable(squareWave, Strength.strong);
		
		problemDefinition = Json.parse(problem);
		
		for (nodeDefinition in problemDefinition.nodes) {
			var constraintX:Constraint = ConstraintParser.parseConstraint(nodeDefinition.xInequality, resolver);
			solver.addConstraint(constraintX);
			var constraintY:Constraint = ConstraintParser.parseConstraint(nodeDefinition.yInequality, resolver);
			solver.addConstraint(constraintY);
			
			var x = resolver.resolveVariable(nodeDefinition.xVar);
			var y = resolver.resolveVariable(nodeDefinition.yVar);
			var node = new Node(x, y, getCandyName(), nodeDefinition.tweenDuration, EaseHelper.getEase(nodeDefinition.tweenEase));
			
			if (nodeDefinition.xVar == "rootx" && nodeDefinition.yVar == "rooty") {
				root = node;
			}
			
			nodes.push(node);
			add(node);
			add(node.infoText);
		}
	}
	
	private function toggleDebug():Void {
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		
		drawDebug = !drawDebug;
		
		debugCanvas.visible = drawDebug;
		for (node in nodes) {
			node.infoText.visible = drawDebug;
		}
	}
	
	private function getCandyName(?type:String = null, ?color:String = null):String {
		if (type == null) {
			type = imageTypes[Std.int(Math.random() * (imageTypes.length - 1))];
		}
		if (color == null) {
			color = imageColors[Std.int(Math.random() * (imageColors.length - 1))];
		}
		return "assets/images/" + type + "_" + color + ".png";
	}
	
	private function logConstraints():Void {
		addText("==========================");
		addText("^^^^^Constraints^^^^^");
		addText(DebugHelper.dumpConstraints(solver.constraints));
		addText("==========================");
	}
	
	private function logVariables():Void {
		addText("==========================");
		addText("^^^^^Solver variables^^^^^");
		for (variable in resolver.variables) {
			addText(variable.name + " = " + variable.value);
		}
		addText("==========================");
	}
	
	private function logInstructions():Void {
		addText("Press 'A' to dump solver variables");
		addText("Press 'C' to dump solver constraints");
		addText("Press 'D' to toggle debug rendering");
	}
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
}