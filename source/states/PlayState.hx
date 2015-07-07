package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import json.JsonReader;
import json.NodeDefinition;
import kiwi.Constraint;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.Resolver;
import kiwi.Solver;
import kiwi.Strength;
import kiwi.Variable;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Expo;
import motion.easing.IEasing;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Sine;

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
		Actuate.tween(this, tweenDuration, { x: pX.value - width / 2, y: pY.value - height / 2 }, true).ease(ease);
	}
}

@:access(kiwi.Solver)
class PlayState extends FlxState {
	private static var imageTypes:Array<String> = [ "jelly", "heart", "lollipop", "star", "swirl", "wrappedsolid" ];
	private static var imageColors:Array<String> = [ "red", "teal", "blue", "orange", "purple", "yellow" ];
	
	private var problemTick:Int = 0;
	private var problemDefinition: { nodes:Array<NodeDefinition> };
	private var uiCamera:FlxCamera;
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
	
	private var varLogButton:TextButton;
	private var drawDebugButton:TextButton;
	
	override public function create():Void {
		super.create();
		
		add(eventText);
		
		varLogButton = new TextButton(FlxG.width / 2, FlxG.height - 80, "Log variable values", outputSolution);
		drawDebugButton = new TextButton(FlxG.width / 2 - 100, FlxG.height - 80, "Draw debug", toggleDrawDebug);
		
		uiCamera = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		FlxCamera.defaultCameras = [uiCamera];
		addText("Setup camera...");
		
		var problem:String = generateEqualitiesProblem();
		addText("Made problem " + problemTick + "...");
		
		consumeProblem(problem);
		addText("Consumed problem...");
		
		add(varLogButton);
		add(drawDebugButton);
		
		add(debugCanvas);
	}
	
	override public function draw():Void {
		super.draw();
		
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		for (nodeDefinition in problemDefinition.nodes) {
			var x = resolver.resolveVariable(nodeDefinition.xVar);
			var y = resolver.resolveVariable(nodeDefinition.yVar);
			
			debugCanvas.drawLine(x.value - 5, y.value, x.value + 5, y.value);
			debugCanvas.drawLine(x.value, y.value - 5, x.value, y.value + 5);
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		timeRunning += dt;
		
		solver.suggestValue(sin2Time, Math.pow(Math.sin(timeRunning), 2));
		
		if (FlxG.mouse.justPressed) {
			solver.suggestValue(mouseX, FlxG.mouse.x);
			solver.suggestValue(mouseY, FlxG.mouse.y);
		}
		
		solver.updateVariables();
		
		if (FlxG.mouse.justPressed) {
			for(node in nodes) {
				node.tween(dt);
			}
		}
	}
	
	public function addText(text:String):Void {
		eventText.text = text + "\n" + eventText.text;
	}
	
	public function clearLog():Void {
		eventText.text = "Waiting...";
	}
	
	public function generateEqualitiesProblem():String {
		var problem:String = JsonReader.readJsonFile("assets/data/candies.json");
		problemTick++;
		return problem;
	}
	
	public function getCandyName(?type:String = null, ?color:String = null):String {
		if (type == null) {
			type = imageTypes[Std.int(Math.random() * (imageTypes.length - 1))];
		}
		if (color == null) {
			color = imageColors[Std.int(Math.random() * (imageColors.length - 1))];
		}
		return "assets/images/" + type + "_" + color + ".png";
	}
	
	public static function getEase(name:String):IEasing {
		if (name == null || name.length == 0) {
			return Linear.easeNone;
		}
		if (name == "quadin") {
			return Quad.easeIn;
		}
		if (name == "quadinout") {
			return Quad.easeInOut;
		}
		if (name == "quadout") {
			return Quad.easeOut;
		}
		if (name == "sinein") {
			return Sine.easeIn;
		}
		if (name == "sineinout") {
			return Sine.easeInOut;
		}
		if (name == "sineout") {
			return Sine.easeOut;
		}
		if (name == "bouncein") {
			return Bounce.easeIn;
		}
		if (name == "bounceinout") {
			return Bounce.easeInOut;
		}
		if (name == "bounceout") {
			return Bounce.easeOut;
		}
		if (name == "expoin") {
			return Expo.easeIn;
		}
		if (name == "expoinout") {
			return Expo.easeInOut;
		}
		if (name == "expoout") {
			return Expo.easeOut;
		}
		return Linear.easeNone;
	}
	
	public function consumeProblem(problem:String):Void {
		solver.reset();
		resolver = new Resolver();
		
		mouseX = resolver.resolveVariable("mouseX");
		mouseY = resolver.resolveVariable("mouseY");
		sin2Time = resolver.resolveVariable("sin2Time");
		solver.addEditVariable(mouseX, Strength.strong);
		solver.addEditVariable(mouseY, Strength.strong);
		solver.addEditVariable(sin2Time, Strength.strong);
		
		problemDefinition = Json.parse(problem);
		
		for (nodeDefinition in problemDefinition.nodes) {
			//trace(constraintDefinition.inequality);
			var constraintX:Constraint = ConstraintParser.parseConstraint(nodeDefinition.xInequality, resolver);
			solver.addConstraint(constraintX);
			var constraintY:Constraint = ConstraintParser.parseConstraint(nodeDefinition.yInequality, resolver);
			solver.addConstraint(constraintY);
			
			var x = resolver.resolveVariable(nodeDefinition.xVar);
			var y = resolver.resolveVariable(nodeDefinition.yVar);
			var node = new Node(x, y, getCandyName(), nodeDefinition.tweenDuration, getEase(nodeDefinition.tweenEase));
			
			if (nodeDefinition.xVar == "rootX" && nodeDefinition.yVar == "rootY") {
				root = node;
			}
			
			nodes.push(node);
			add(node);
			add(node.infoText);
		}
	}
	
	public function outputSolution():Void {
		addText("Outputting solution...");
		
		var variables = resolver.variables;
		
		for (variable in variables) {
			addText(variable.name + " = " + variable.value);
		}
	}
	
	private function toggleDrawDebug():Void {
		debugCanvas.visible = !debugCanvas.visible;
		for (node in nodes) {
			node.infoText.visible = !node.infoText.visible;
		}
	}
}