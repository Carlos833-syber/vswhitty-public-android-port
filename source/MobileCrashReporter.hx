package;

import haxe.CallStack;
import lime.app.Application;
import lime.system.System;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;

/** Show Haxe exceptions on the test APK instead of silently terminating. */
class MobileCrashReporter
{
	static var reporting:Bool = false;

	public static function install():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
	}

	static function onError(event:UncaughtErrorEvent):Void
	{
		event.preventDefault();
		report(event.error);
	}

	public static function report(error:Dynamic):Void
	{
		if (reporting)
			return;
		reporting = true;
		var stack = CallStack.toString(CallStack.exceptionStack());
		var details = Std.string(error) + "\n" + stack;
		trace(details);

		#if sys
		try
		{
			sys.io.File.saveContent(System.applicationStorageDirectory + "last-crash.txt", Date.now().toString() + "\n" + details);
		}
		catch (storageError:Dynamic)
		{
			trace("Could not save crash report: " + Std.string(storageError));
		}
		#end

		try
		{
			Application.current.window.alert("Envie uma foto desta mensagem para investigar o fechamento.\n\n" + details, "VS Whitty - erro");
		}
		catch (dialogError:Dynamic)
		{
			trace("Could not show crash report: " + Std.string(dialogError));
		}
		System.exit(1);
	}
}
