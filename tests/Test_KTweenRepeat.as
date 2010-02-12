package {
	import net.kawa.tween.KTJob;

	import flash.events.Event;
	import flash.display.Sprite;

	import net.kawa.tween.KTween;
	import net.kawa.tween.easing.*;

	[SWF(width="320",height="480",frameRate="30",backgroundColor="#FFFFFF")]

	/**
	 * @author Yusuke Kawasaki
	 */
	public class Test_KTweenRepeat extends Sprite {
		public function Test_KTweenRepeat():void {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void {
			var normal:Circle = new Circle();
			var repeat:Circle = new Circle();
			var yoyo:Circle = new Circle();
			normal.y = 100;
			repeat.y = 250;
			yoyo.y = 400;
			addChild(normal);
			addChild(repeat);
			addChild(yoyo);
			var duration:Number = 2;

			KTween.to(normal, duration, {x:320}, Quad.easeOut);
			KTween.to(repeat, duration, {x:320}, Quad.easeOut).repeat = true;
			var tyoyo:KTJob = KTween.to(yoyo, duration, {x:320}, Quad.easeOut);
			tyoyo.repeat = true;
			tyoyo.yoyo = true;
		}
	}
}

import flash.display.Sprite;

class Circle extends Sprite {
	public function Circle():void {
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 50);
		graphics.endFill();
	}
}
	
