package {
	import flash.utils.setTimeout;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Sprite;

	import net.kawa.tween.KTween;
	import net.kawa.tween.easing.Linear;

	[SWF(width="320",height="480",frameRate="10",backgroundColor="#FFFFFF")]

	/**
	 * @author Yusuke Kawasaki
	 */
	public class Test_KTweenTicks extends Sprite {
		private var tf:TextField;
		private var objA:TestObject;
		private var objB:TestObject;
		private var startTime:Number;

		public function Test_KTweenTicks():void {
			startTime = getTime();
			addEventListener(Event.EXIT_FRAME, exitFrameListener);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			tf = drawTextField();
			addChild(tf);

			objA = new TestObject();
			objB = new TestObject();
			
			setTimeout(runTestA, 1);
			setTimeout(runTestB, 401);
		}

		private function getTime():Number {
			var date:Date = new Date();
			return date.time;
		}

		private function exitFrameListener(event:Event):void {
			showStatus();
			if (objB.x >= 1) {
				removeEventListener(Event.EXIT_FRAME, exitFrameListener);
			}
		}

		private function showStatus():void {
			var numA:String = numFormat(objA.x);
			var numB:String = numFormat(objB.x);
			var str:String = getSec() + '\tA:' + numA + '\tB:' + numB + '\n';
			tf.appendText(str);
		}

		private function getSec():String {
			var time:Number = (getTime() - startTime) / 1000;
			// time = Math.round(time * 100) / 100;
			var sec:String = numFormat(time);
			return sec;
		}

		private function numFormat(x:Number):String {
			if (isNaN(x)) return '-----';
			var str:String = String(Math.round(x * 1000) / 1000);
			if (str.search(/\./) < 0) str += '.';
			while (str.length < 5) str += '0';
			return str;
		}

		private function runTestA():void {
			tf.appendText(getSec() + '\tA:start\n');
			KTween.fromTo(objA, 1, {x:0}, {x:1}, Linear.easeOut, onCloseA);
		}

		private function runTestB():void {
			tf.appendText(getSec() + '\tB:start\n');
			KTween.fromTo(objB, 1, {x:0}, {x:1}, Linear.easeOut, onCloseB);
		}

		private function onCloseA():void {
			tf.appendText(getSec() + '\tA:done\n');
		}

		private function onCloseB():void {
			tf.appendText(getSec() + '\tB:done\n');
		}

		private function drawTextField():TextField {
			var sp:TextField = new TextField();
			sp.multiline = false;
			var textFormat:TextFormat = new TextFormat('_sans', 16, 0);
			sp.defaultTextFormat = textFormat;
			sp.width = stage.stageWidth;
			sp.height = stage.stageHeight;
			sp.text = '';
			return sp;
		}
	}
}

class TestObject {
	public var x:Number = Number.NaN;
}