package states.layout;

import kiwi.Expression;
import kiwi.frontend.IResolver;
import kiwi.Solver;
import kiwi.Symbolics.VariableSymbolics;
import kiwi.Variable;

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