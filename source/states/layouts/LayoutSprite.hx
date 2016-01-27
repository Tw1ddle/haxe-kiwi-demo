package states.layouts;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import kiwi.Variable;

// Describes a sprite in a layout
class LayoutSprite extends FlxSpriteGroup {	
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