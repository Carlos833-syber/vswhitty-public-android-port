package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/** Touch input is independent of its artwork: hiding hitboxes never disables input. */
class MobileControls extends FlxGroup
{
	static var instance:MobileControls;

	var held:Array<Bool> = [false, false, false, false, false, false, false];
	var pressed:Array<Bool> = [false, false, false, false, false, false, false];
	var released:Array<Bool> = [false, false, false, false, false, false, false];
	var boxes:Array<FlxSprite> = [];
	var labels:Array<FlxText> = [];
	var hud:FlxCamera;
	var surface:Dynamic;
	var blocked:Array<Int> = [];
	var gameplay:Bool = false;

	public static function install():Void
	{
		#if mobile
		if (instance == null)
		{
			instance = new MobileControls();
			FlxG.plugins.add(instance);
			FlxG.signals.postStateSwitch.add(instance.attachCamera);
		}
		#end
	}

	public static function check(button:Int, edge:Int = 0):Bool
	{
		if (instance == null)
			return false;
		return edge == 1 ? instance.pressed[button] : edge == 2 ? instance.released[button] : instance.held[button];
	}

	public function new()
	{
		super();
		var colors = [
			0xFFC24B99,
			0xFF00FFFF,
			0xFF12FA05,
			0xFFF9393F,
			0xFF555555,
			0xFF555555,
			0xFF555555
		];
		var names = ["LEFT", "DOWN", "UP", "RIGHT", "OK", "BACK", "PAUSE"];
		for (i in 0...7)
		{
			var box = new FlxSprite().makeGraphic(1, 1, colors[i]);
			box.scrollFactor.set();
			boxes.push(box);
			add(box);
			var label = new FlxText(0, 0, 0, names[i], 18);
			label.alignment = CENTER;
			label.scrollFactor.set();
			labels.push(label);
			add(label);
		}
		attachCamera();
	}

	function attachCamera():Void
	{
		// Flixel resets cameras between states; this overlay always uses an unzoomed camera.
		hud = new FlxCamera();
		hud.bgColor = 0;
		FlxG.cameras.add(hud, false);
		cameras = [hud];
		surface = null;
	}

	override public function update(elapsed:Float):Void
	{
		var current:flixel.FlxState = FlxG.state;
		while (current.subState != null)
			current = current.subState;
		if (surface != current)
		{
			surface = current;
			blocked = [
				for (touch in FlxG.touches.list) if (touch.pressed && !touch.justPressed) touch.touchPointID
			];
			held = [false, false, false, false, false, false, false];
		}
		gameplay = Std.isOfType(current, PlayState);
		var next = [false, false, false, false, false, false, false];
		for (i in 0...7)
		{
			var lane = gameplay && i < 4;
			var width:Float = lane ? FlxG.width / 4 : FlxG.width / (gameplay ? 3 : 6);
			var x:Float = lane ? i * width : (gameplay ? i - 4 : i) * width;
			var y:Float = lane ? 72 : gameplay ? 0 : FlxG.height - 96;
			var height:Float = lane ? FlxG.height - 72 : gameplay ? 72 : 96;
			var box = boxes[i];
			box.setPosition(x, y);
			box.scale.set(width - 2, height - 2);
			box.updateHitbox();
			labels[i].setPosition(x, y + 20);
			labels[i].fieldWidth = width;
			box.visible = labels[i].visible = (gameplay || i < 6) && (!lane || FlxG.save.data.showHitboxes != false);
			for (touch in FlxG.touches.list)
			{
				if (!touch.pressed || blocked.indexOf(touch.touchPointID) != -1)
					continue;
				var point = touch.getScreenPosition(hud);
				if ((gameplay || i < 6) && point.x >= x && point.x < x + width && point.y >= y && point.y < y + height)
					next[i] = true;
				point.put();
			}
			pressed[i] = next[i] && !held[i];
			released[i] = !next[i] && held[i];
			box.alpha = next[i] ? 0.35 : lane ? 0.08 : 0.55;
			labels[i].alpha = lane ? 0.4 : 1;
		}
		blocked = blocked.filter(function(id)
		{
			for (touch in FlxG.touches.list)
				if (touch.touchPointID == id && touch.pressed)
					return true;
			return false;
		});
		held = next;
		super.update(elapsed);
	}
}
