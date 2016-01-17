package states;

import flixel.FlxG;
import haxe.Json;
import json.EaseHelper;
import json.JsonReader;
import json.NodeDefinition;
import kiwi.Constraint;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.Resolver;
import kiwi.Strength;
import kiwi.Variable;

class ShipDemo extends BaseDemoState {	
	private var problemDefinition: { nodes:Array<NodeDefinition> };
	private var root:Node;
	private var nodes = new Array<Node>();
	private var mouseX:Variable;
	private var mouseY:Variable;
	
	public function new(game:PlayState) {
		super(game);
	}
	
	override public function create():Void {
		super.create();
		
		loadProblem(JsonReader.readJsonFile("assets/data/ship.json"));
	}
	
	private function loadProblem(problem:String):Void {
		solver.reset();
		resolver = new Resolver();
		
		mouseX = resolver.resolveVariable("mousex");
		mouseY = resolver.resolveVariable("mousey");
		solver.addEditVariable(mouseX, Strength.strong);
		solver.addEditVariable(mouseY, Strength.strong);
		
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
			
			nodes.push(node);
			add(node);
			add(node.infoText);
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		solver.suggestValue(mouseX, FlxG.mouse.x);
		solver.suggestValue(mouseY, FlxG.mouse.y);
		
		solver.updateVariables();
		
		for(node in nodes) {
			node.tween(dt);
		}
	}
}