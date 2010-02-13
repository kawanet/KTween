package {
	import flash.utils.setTimeout;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(width="320",height="480",frameRate="120",backgroundColor="#FFFFFF")]

	/**
	 * @author Yusuke Kawasaki
	 */
	public class Benchmark extends Sprite {
		private var canvas:BenchBase;
		private var textField:TextField;
		private var classList:Array = [BenchKTween, BenchTweener, BenchTweenNano, BenchGTween, BenchBetweenAS3];
		// private var classList:Array = [BenchKTween, BenchTweenNano, BenchBetweenAS3];
		// private var classList:Array = [BenchKTween];
		private var count:Number = 0;

		public function Benchmark():void {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void {
			textField = new TextField();
			textField.width = stage.stageWidth;
			textField.height = stage.stageHeight;
			addChild(textField);

			runTween();
		}

		private function runTween():void {
			if (textField.textHeight > stage.stageHeight * 0.8) return;
			if (count % classList.length == 0) {
				for(var i:int = 0;i < classList.length;i++) {
					var x:int = Math.random() * classList.length;
					var swap:Class = classList[i];
					classList[i] = classList[x];
					classList[x] = swap;
				}
			}
			count++;
			
			var benchClass:Class = classList[count % classList.length];
			var name:String = benchClass + ' ';
			name = name.replace('class Bench', '');
			textField.appendText(name);

			canvas = new benchClass();
			canvas.addEventListener(Event.COMPLETE, doneTween, false, 0, true);
			addChild(canvas);
		}

		private function doneTween(event:Event):void {
			canvas.removeEventListener(Event.COMPLETE, doneTween);
			
			// show FPT
			textField.appendText(canvas.fps + ' fps\r\n');
			if (count == 1) {
				textField.text = ""; // the first tween would take time
			}
			
			// remove test sprite
			removeChild(canvas);
			canvas = null;
			
			setTimeout(runTween, 1000);
		}
	}
}

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;

class BenchBase extends Sprite {
	private static const MAXOBJ:Number = 500;
	protected static const SWIDTH:Number = 320;
	protected static const SHEIGHT:Number = 480;
	protected static const IWIDTH:Number = 16;
	protected static const IHEIGHT:Number = 16;
	protected static const MINSEC:Number = 2;
	protected static const MAXSEC:Number = 6;
	private static const COLORPAT:Array = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF];
	private var count:Number = 0;
	private var startTime:Number;
	private var frame:Number = 0;
	protected var bmList:Array = [];
	public var fps:Number;
	private static var inited:Boolean = false;
	private static var yList0:Array = [];
	private static var yList1:Array = [];
	private static var secList:Array = [];

	public function BenchBase() {
		var i:int;
		var bmdList:Array = [];

		var rect:Rectangle = new Rectangle(0, 0, IWIDTH, IHEIGHT);
		for(i = 0;i < COLORPAT.length;i++) {
			var bmdata:BitmapData = new BitmapData(IWIDTH, IHEIGHT);
			bmdata.fillRect(rect, 0xFF000000 | COLORPAT[i]);
			bmdList.push(bmdata);
		}
			
		for(i = 0;i < MAXOBJ;i++) {
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = bmdList[i % bmdList.length];
			bmList.push(bitmap);
			addChild(bitmap);
		}
			
		addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		
		if (!inited) init();

		startTime = getTime();
		for(i = 0;i < bmList.length;i++) {
			var mc:DisplayObject = bmList[i];
			mc.x = -IWIDTH;
			mc.y = yList0[i];
			runTween(mc, yList1[i], secList[i]);
		}
	}

	private function init():void {
		for(var i:int = 0;i < bmList.length;i++) {
			var y0:Number = Math.floor(Math.random() * SHEIGHT);
			var y1:Number = Math.floor(Math.random() * SHEIGHT);
			var secs:Number = Math.random() * (MAXSEC - MINSEC) + MINSEC;
			yList0.push(y0);
			yList1.push(y1);
			secList.push(secs);
		}
		inited = true;
	}

	protected function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		// override this
	}

	private function enterFrameHandler(event:Event):void {
		frame++;
	}

	private function getTime():Number {
		var date:Date = new Date();
		return date.time;
	}

	protected function countDone(dummy:* = null):void {
		if (!stage) return;
		dummy; // dummy
		count++;
		if (count < MAXOBJ) return;
		removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		var endTime:Number = getTime();
		var spendTime:Number = (endTime - startTime) / 1000;
		fps = Math.round(frame / spendTime * 100) / 100;
		dispatchEvent(new Event(Event.COMPLETE));
	}
}

class BenchKTween extends BenchBase {
	import net.kawa.tween.KTJob;
	import net.kawa.tween.KTween;
	import net.kawa.tween.easing.Linear;
	protected override function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		var tween:KTJob = KTween.to(mc, secs, {x: SWIDTH, y: lastY}, Linear.easeOut, countDone);
		tween.round = true;
	}
}

class BenchTweener extends BenchBase {
	import caurina.transitions.Tweener;
	protected override function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		Tweener.addTween(mc, {x: SWIDTH, y:lastY, time: secs, rounded: true, transition: "linear", onComplete: countDone});
	}
}

class BenchTweenNano extends BenchBase {
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	protected override function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		// TweenNano doesn't have the roundProps feature.
		// TweenMax.to(mc, secs, {x: SWIDTH, y:lastY, roundProps:["x","y"], ease:Linear.easeNone, onComplete:countDone});
		TweenNano.to(mc, secs, {x: SWIDTH, y:lastY, ease:Linear.easeNone, onComplete:countDone});
	}
}

class BenchGTween extends BenchBase {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Linear;
	protected override function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		var tween:GTween = GTweener.to(mc, secs, {x: SWIDTH, y:lastY}, {ease:Linear.easeNone});
		// tween.roundValues = true; // the feature lost?
		// tween.useSnapping = true;
		tween.onComplete = countDone;
	}
}

class BenchBetweenAS3 extends BenchBase {
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.events.TweenEvent;
	import org.libspark.betweenas3.tweens.IObjectTween;
	import org.libspark.betweenas3.easing.Linear;
	protected override function runTween(mc:DisplayObject, lastY:Number, secs:Number):void {
		var tween:IObjectTween = BetweenAS3.tween(mc, {x: SWIDTH, y:lastY}, null, secs, Linear.easeNone);
		tween.addEventListener(TweenEvent.COMPLETE, countDone);
		tween.play();
	}
}
