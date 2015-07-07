package json;

import motion.easing.Bounce;
import motion.easing.Expo;
import motion.easing.IEasing;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Sine;

class EaseHelper {
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
}