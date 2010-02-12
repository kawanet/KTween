package {
	import flash.events.Event;
	import flash.display.Sprite;

	import net.kawa.tween.easing.*;

	[SWF(width="1000",height="510",frameRate="30",backgroundColor="#FFFFFF")]

	/**
	 * @author Yusuke Kawasaki
	 */
	public class Test_KTweenList extends Sprite {
		public function Test_KTweenList():void {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void {
			var linear:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Linear, 0);
			var sine:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Sine, 100);
			var quad:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Quad, 200);
			var cubic:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Cubic, 300);
			var quart:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Quart, 400);
			var quint:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Quint, 500);
			var circ:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Circ, 600);
			var elastic:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Elastic, 700);
			var bounce:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Bounce, 800);
			var back:TestEaseLine = new TestEaseLine(net.kawa.tween.easing.Back, 900);
			
			addChild(linear);
			addChild(sine);
			addChild(cubic);
			addChild(quad);
			addChild(quart);
			
			addChild(quint);
			addChild(circ);
			addChild(elastic);
			addChild(back);
			addChild(bounce);

			linear.y = 10;
			sine.y = 110;
			quad.y = 210;
			cubic.y = 310;
			quart.y = 410;

			quint.y = 10;
			circ.y = 110;
			elastic.y = 210;
			bounce.y = 310;
			back.y = 410;
			
			quint.x = 500;
			circ.x = 500;
			elastic.x = 500;
			bounce.x = 500;
			back.x = 500;
		}
	}
}

import flash.utils.setTimeout;
import flash.text.TextField;
import flash.events.Event;
import flash.display.Sprite;

import net.kawa.tween.easing.Linear;
import net.kawa.tween.KTween;

class TestEaseLine extends Sprite {
	private var duration:Number = 2;
	private var easeClass:Class;

	public function TestEaseLine(ease:Class, delay:Number):void {
		easeClass = ease;
		var field:TextField = new TextField();
		field.text = [easeClass].join("").replace(/class /i, "").replace(/\W+/g, "");
		addChild(field);
		field.x = 5;
		setTimeout(run, delay * 8);
	}

	private function run():void {
		
		var easeIn:KTweenEaseTest = new KTweenEaseTest(); 
		var easeOut:KTweenEaseTest = new KTweenEaseTest(); 
		var easeInOut:KTweenEaseTest = new KTweenEaseTest(); 
		easeIn.x = 50;
		easeOut.x = 200;
		easeInOut.x = 350;
		
		addChild(easeIn);
		addChild(easeOut);
		addChild(easeInOut);

		KTween.to(easeIn, duration, {curX:140}, Linear.easeOut);
		KTween.to(easeOut, duration, {curX:140}, Linear.easeOut);
		KTween.to(easeInOut, duration, {curX:140}, Linear.easeOut);

		KTween.from(easeIn, duration, {curY:90}, easeClass['easeIn']).onInit = easeIn.onActivate;
		KTween.from(easeOut, duration, {curY:90}, easeClass['easeOut']).onInit = easeOut.onActivate;
		KTween.from(easeInOut, duration, {curY:90}, easeClass['easeInOut']).onInit = easeInOut.onActivate;
	}
}

class KTweenEaseTest extends Sprite {
	public var prevX:Number = Number.NaN;
	public var prevY:Number = Number.NaN;
	public var curX:Number = 0;
	public var curY:Number = 0;

	public function KTweenEaseTest():void {
		
		graphics.lineStyle(1.0, 0x000000, 1, true);
		graphics.drawRect(0, 0, 140, 90);
		
		addEventListener(Event.ENTER_FRAME, update);
	}

	public function onActivate():void {
		prevX = curX;
		prevY = curY;
	}

	private function update(e:Event):void {
		if (prevX == curX && prevY == curY)return;
		graphics.lineStyle(2.0, 0x2020C0, 1.0);
		graphics.moveTo(prevX, prevY);
		graphics.lineTo(curX, curY);
		prevX = curX;
		prevY = curY;
	}
}
	
