import flixel.FlxG;

/** Exercise the real preloader, title timer and mobile plugin in a virtual display. */
class MobileStartupSmoke
{
	public static function main():Void
	{
		haxe.Timer.delay(function()
		{
			if (!Std.isOfType(FlxG.state, TitleState))
				fail("TitleState was not reached");
			var title = cast(FlxG.state, TitleState);
			@:privateAccess
			if (title.logoBl == null || title.gfDance == null || title.titleText == null || title.gfDance.frames.numFrames == 0)
				fail("Title artwork was not initialized");
			if (FlxG.cameras.list.length < 2)
				fail("Mobile overlay was not initialized");
			Sys.println("PASS: title artwork, intro timer and mobile overlay initialized");
			Sys.exit(0);
		}, 8000);
		ApplicationMain.main();
	}

	static function fail(message:String):Void
	{
		Sys.println("FAIL: " + message);
		Sys.exit(1);
	}
}
