package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import json.JsonReader;
import json.NodeDefinition;
import kiwi.Expression;
import kiwi.frontend.ConstraintParser;
import kiwi.frontend.IResolver;
import kiwi.Solver;
import kiwi.Strength;
import kiwi.Symbolics.VariableSymbolics;
import kiwi.Variable;

class NodeSprite extends FlxSpriteGroup {	
	private var node:Map<String, Variable>;
	
	private var rect:FlxSprite;
	
	private var rectColor:FlxColor;
	
	private var xV:Null<Float> = null;
	private var yV:Null<Float> = null;
	private var wV:Null<Float> = null;
	private var hV:Null<Float> = null;
	
	private	var nodeX:Variable;
	private	var nodeY:Variable;
	private	var nodeW:Variable;
	private	var nodeH:Variable;
	
	public function new(label:String, node:Map<String, Variable>) {
		super();
		this.node = node;
		this.rect = new FlxSprite();
		this.rectColor = FlxColor.fromRGBFloat(Math.random(), Math.random(), Math.random(), 0.3);
		
		updateVars();
		
		if (!varsValid()) {
			return;
		}
		
		x = xV;
		y = yV;
		rect.makeGraphic(Std.int(wV), Std.int(hV), rectColor);
		add(rect);
		
		add(new TextItem(0, 0, label));
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		updateVars();
		
		if (!varsValid()) {
			return;
		}
		
		x = xV;
		y = yV;
		
		if (rect.width != wV || rect.height != hV) {
			rect.makeGraphic(Std.int(wV), Std.int(hV), rectColor);
		}
		rect.width = wV;
		rect.height = hV;
	}
	
	private function updateVars():Void {
		nodeX = node.get(LayoutDemo.LEFT);
		nodeY = node.get(LayoutDemo.TOP);
		nodeW = node.get(LayoutDemo.WIDTH);
		nodeH = node.get(LayoutDemo.HEIGHT);
		
		if (nodeX == null) {
			nodeX = node.get(LayoutDemo.RIGHT);
			if (nodeX != null) {
				xV = nodeX.value - nodeW.value;
			}
		} else {
			xV = nodeX.value;
		}
		
		if (nodeY == null) {
			nodeY = node.get(LayoutDemo.BOTTOM);
			if(nodeY != null) {
				yV = nodeY.value - nodeH.value;
			}
		} else {
			yV = nodeY.value;
		}
		
		if(nodeW != null) {
			wV = nodeW.value;
		}
		
		if(nodeH != null) {
			hV = nodeH.value;
		}
	}
	
	private inline function varsValid():Bool {
		if (xV == null || yV == null || wV == null || hV == null) {
			return false;
		}
		
		if (Std.int(wV) <= 0 || Std.int(hV) <= 0) {
			return false;
		}
		
		return true;
	}
}

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
	
	private var problemDefinition: { nodes:Array<NodeDefinition> };
	
	public function new(game:PlayState) {
		super(game);
		
		resolver = new NodeResolver(solver);
	}
	
	private static function approxEqual(a:Float, b:Float):Bool {		
		var epsilon:Float = 1.0e-2;
		return Math.abs(a - b) < epsilon;
	}
	
	override public function create():Void {
		super.create();
		
		loadProblem(JsonReader.readJsonFile("assets/data/layout.json"));
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
		
		var resolver = cast(resolver, NodeResolver);
		
		for (key in resolver.nodes.keys()) {
			var node = resolver.nodes.get(key);
			add(new NodeSprite(key, node));
		}
	}
	
	override public function logVariables(resolver:IResolver):Void {
		addText("==========================");
		addText("^^^^^Solver variables^^^^^");
		
		var nodeResolver = null;
		
		try {
			nodeResolver = cast(resolver, NodeResolver);
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
		solver.suggestValue(mouseX, FlxG.mouse.x);
		solver.suggestValue(mouseY, FlxG.mouse.y);
		
		// NOTE allowing user to change window size by moving mouse
		solver.suggestValue(windowWidth, FlxG.mouse.x);
		solver.suggestValue(windowHeight, FlxG.mouse.y);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		suggestValues();
		
		solver.updateVariables();
	}
}

class NodeResolver implements IResolver {
	public var solver(default, null):Solver;
	public var nodes(default, null):Map<String, Map<String, Variable>>;
	
	public function new(solver:Solver) {
		this.solver = solver;
		nodes = new Map<String, Map<String, Variable>>();
	}
	
	private function getNode(name:String):Map<String, Variable> {
		var node = nodes.get(name);
		
		if (node == null) {
			node = new Map<String, Variable>();
			nodes.set(name, node);
		}
		
		return node;
	}
	
	private function getVariableFromNode(node:Map<String, Variable>, nodeName:String, varName:String):Variable {
		var variable = node.get(varName);
		
		if (variable != null) {
			return variable;
		}
		
		variable = new Variable(nodeName + "." + varName);
		node.set(varName, variable);
		
		try {
			switch(varName) {
				case LayoutDemo.RIGHT:
					solver.addConstraint(VariableSymbolics.equalsExpression(variable, VariableSymbolics.addVariable(getVariableFromNode(node, nodeName, LayoutDemo.LEFT), getVariableFromNode(node, nodeName, LayoutDemo.WIDTH))));
				case LayoutDemo.BOTTOM:
					solver.addConstraint(VariableSymbolics.equalsExpression(variable, VariableSymbolics.addVariable(getVariableFromNode(node, nodeName, LayoutDemo.TOP), getVariableFromNode(node, nodeName, LayoutDemo.HEIGHT))));
			}
		} catch(error:String) {
			trace("Constraint exception: " + error);
		}
		
		return variable;
	}
	
	public function resolveVariable(name:String):Variable {
		Sure.sure(name != null);
		
		var split = name.split(".");
		
		Sure.sure(split.length == 2);
		
		if (split.length != 2) {
			return null;
		}
		
		var nodeName = split[0];
		var propName = split[1];
		
		var node = getNode(nodeName);
		return getVariableFromNode(node, nodeName, propName);
	}
	
	public function resolveConstant(expression:String):Expression {
		Sure.sure(expression != null);
		
		var constant:Float = Std.parseFloat(expression);
		
		if (Math.isNaN(constant)) {
			//throw "Failed to parse constant expression: " + expression;
			return null;
		}
		
		return new Expression(constant);
	}
}