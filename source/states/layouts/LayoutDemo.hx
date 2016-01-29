package states.layouts;

import flixel.FlxG;
import haxe.Json;
import json.LayoutNodeDefinition;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.IResolver;
import kiwi.Strength;
import kiwi.Variable;

// Demonstrates mock UI layouts
class LayoutDemo extends BaseDemoState {
    public static inline var LEFT = "left";
    public static inline var RIGHT = "right";
    public static inline var TOP = "top";
    public static inline var BOTTOM = "bottom";
    public static inline var HEIGHT = "height";
    public static inline var WIDTH = "width";
	
	private var mouseX:Variable;
	private var mouseY:Variable;
	private var windowWidth:Variable;
	private var windowHeight:Variable;
	
	private var layoutString:String;
	private var problemDefinition: { nodes:Array<LayoutNodeDefinition> };
	
	public function new(game:PlayState, layoutString:String) {
		super(game);
		
		this.layoutString = layoutString;
		
		resolver = new LayoutVarResolver(solver);
	}
	
	override public function create():Void {
		super.create();
		loadProblem(layoutString);
	}
	
	private function loadProblem(problem:String):Void {		
		problemDefinition = Json.parse(problem);
		
		try {
			for (constraint in problemDefinition.nodes) {
				solver.addConstraint(ConstraintParser.parseConstraint(constraint.inequality, constraint.strength, resolver));
			}
		} catch(error:String) {
			trace("Constraint exception: " + error);
		}
		
		try {
			mouseX = resolver.resolveVariable("global.mousex");
			mouseY = resolver.resolveVariable("global.mousey");
			windowWidth = resolver.resolveVariable("global.windowWidth");
			windowHeight = resolver.resolveVariable("global.windowHeight");
			
			solver.addEditVariable(mouseX, Strength.strong);
			solver.addEditVariable(mouseY, Strength.strong);
			solver.addEditVariable(windowWidth, Strength.strong);
			solver.addEditVariable(windowHeight, Strength.strong);
			
			suggestValues();
			solver.updateVariables();
		} catch (error:String) {
			trace("Constraint exception: " + error);
		} catch (error:Dynamic) {
			addText("Unknown exception: " + Std.string(error));
		}
		
		var resolver = cast(resolver, LayoutVarResolver);
		
		for (key in resolver.nodes.keys()) {
			var node = resolver.nodes.get(key);
			add(new LayoutSprite(key, node));
		}
	}
	
	override public function logVariables(resolver:IResolver):Void {
		addText("==========================");
		addText("^^^^^Solver variables^^^^^");
		
		var nodeResolver = null;
		
		try {
			nodeResolver = cast(resolver, LayoutVarResolver);
		} catch(error:String) {
			nodeResolver = null;
		}
		
		if(nodeResolver != null) {
			for (node in nodeResolver.nodes) {
				for (variable in node) {
					addText(variable.name + " = " + variable.value);
				}
			}
		}
		addText("==========================");
	}
	
	private function suggestValues():Void {
		try {
			solver.suggestValue(mouseX, FlxG.mouse.x);
			solver.suggestValue(mouseY, FlxG.mouse.y);
			solver.suggestValue(windowWidth, FlxG.width);
			solver.suggestValue(windowHeight, FlxG.height);
		} catch (error:String) {
			addText("Caught exception: " + error);
		} catch (error:Dynamic) {
			addText("Unknown exception: " + Std.string(error));
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		suggestValues();
		
		solver.updateVariables();
	}
}