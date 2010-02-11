package net.kawa.tween {
	import flash.events.Event;

	import net.kawa.tween.KTJob;

	/**
	 * Tween job calss which invokes events.
	 * @author Yusuke Kawasaki
	 * @version 1.0
	 * @see reference 	net.kawa.tween.KTJob
	 */
	public class KTJobEvent extends KTJob {
		/**
		 * Invokes an Event.INIT event after onInit() function called.
		 */
		public override function init():void {
			super.init();
			dispatchEvent(new Event(Event.INIT));
		}

		/**
		 * Invokes an Event.COMPLETE event after onComplete() function called.
		 */
		public override function complete():void {
			super.complete();
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Invokes an Event.CANCEL event after onCancel() function called.
		 */
		public override function cancel():void {
			super.cancel();
			dispatchEvent(new Event(Event.CANCEL));
		}

		/**
		 * Invokes an Event.CLOSE event after onClose() function called.
		 */
		public override function close():void {
			dispatchEvent(new Event(Event.CLOSE));
			super.close();
		}
	}
}
