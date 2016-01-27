package states.tweens;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import json.EaseHelper;
import json.JsonReader;
import json.TweenNodeDefinition;
import kiwi.Constraint;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.VarResolver;
import kiwi.Strength;
import kiwi.Variable;
import states.tweens.TweenSprite;

using flixel.util.FlxSpriteUtil;

// TODO

class GraphsDemo extends BaseDemoState {
	public static inline var GRAPHS_PER_ROW = 4;
	public static inline var ITEM_SPACING = 10;
	
	private var mouseX:Variable;
	private var mouseY:Variable;
	
	public function new(game:PlayState) {
		super(game);
	}
	
	override public function create():Void {
		super.create();
		
		loadProblem();
	}
	
	private function loadProblem():Void {
		solver.reset();
		resolver = new VarResolver();
		
		mouseX = resolver.resolveVariable("mousex");
		mouseY = resolver.resolveVariable("mousey");
		solver.addEditVariable(mouseX, Strength.strong);
		solver.addEditVariable(mouseY, Strength.strong);
		
		/*
		problemDefinition = Json.parse(problem);
		
		for (nodeDefinition in problemDefinition.nodes) {
			var constraintX:Constraint = ConstraintParser.parseConstraint(nodeDefinition.xInequality, resolver);
			solver.addConstraint(constraintX);
			var constraintY:Constraint = ConstraintParser.parseConstraint(nodeDefinition.yInequality, resolver);
			solver.addConstraint(constraintY);
			
			var x = resolver.resolveVariable(nodeDefinition.xVar);
			var y = resolver.resolveVariable(nodeDefinition.yVar);
			var node = new Node(x, y, BaseDemoState.getCandyName(), nodeDefinition.tweenDuration, EaseHelper.getEase(nodeDefinition.tweenEase));
			
			if (nodeDefinition.xVar == "rootx" && nodeDefinition.yVar == "rooty") {
				root = node;
			}
			
			// TODO plot graphs instead of nodes
		}
		*/
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		solver.suggestValue(mouseX, FlxG.mouse.x);
		solver.suggestValue(mouseY, FlxG.mouse.y);
		
		solver.updateVariables();
	}
	
	private function addGraph(description:String):Void {
		var graph = new Graph(description);
	}
}

class Graph extends FlxSpriteGroup {
	public var description:String;
	
	public var box:FlxSprite;
	public var point:FlxSprite;
	public var trailPoint:FlxSprite;
	
	public var graphX:Float;
	public var graphY:Float;
	
	public function new(description:String) {
		super();
		
		this.description = description;
		
		box = new FlxSprite().makeGraphic(Std.int(FlxG.width / GraphsDemo.GRAPHS_PER_ROW - GraphsDemo.ITEM_SPACING * 2), Std.int(FlxG.height / 11 - GraphsDemo.ITEM_SPACING * 2), FlxColor.WHITE);
		box.drawRect(box.x, box.y, box.width, box.height, FlxColor.TRANSPARENT, { thickness: 2, color: FlxColor.BLACK });
		add(box);
		
		var text = new FlxText(0, 0, 0, description, 8);
		text.color = FlxColor.GRAY;
		add(text);
		
		point = new FlxSprite();
		point.makeGraphic(6, 6, FlxColor.TRANSPARENT);
		point.drawCircle(3, 3, 3, FlxColor.RED);
		add(point);
		
		trailPoint = new FlxSprite();
		trailPoint.makeGraphic(2, 2, FlxColor.BLUE);
		add(trailPoint);
		
		text.setPositionUsingCenter(width / 2, height / 2);
		
		graphX = 0;
		graphY = 0;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		point.x = graphX + x - point.width / 2;
		point.y = graphY + y - point.height / 2;
		
		trailPoint.x = graphX + x - trailPoint.width / 2;
		trailPoint.y = graphY + y - trailPoint.height / 2;
	}
}