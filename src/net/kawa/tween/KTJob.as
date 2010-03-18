package net.kawa.tween {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import net.kawa.tween.easing.Quad;

	/**
	 * Dispatched when the tween job has just started.<br/>
	 * Note this would not work with KTween's static methods, 
	 * ex. <code>KTween.fromTo()</code>,
	 * as these methods start a job at the same time.
	 *
	 * @eventType flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * Dispatched when the value chaned.
	 *
	 * @eventType flash.events.Event.CAHNGE
	 */
	[Event(name="change", type="flash.events.Event")]

	/**
	 * Dispatched when the tween job has just completed.<br/>
	 * Note this would be invoked before the Flash Player renders the object 
	 * at the final position.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * Dispatched when the tween job is closing.<br/>
	 * Note this would be invoked at the next <code>ENTER_FRAME</code> event of onComplete.
	 *
	 * @eventType flash.events.Event.CLOSE
	 */
	[Event(name="close", type="flash.events.Event")]

	/**
	 * Dispatched when the tween job is canceled.
	 *
	 * @eventType flash.events.Event.CANCEL
	 */
	[Event(name="cancel", type="flash.events.Event")]

	/**
	 * KTJob
	 * Tween job calss for the KTween
	 * @author Yusuke Kawasaki
	 * @version 1.0
	 */
	public class KTJob extends EventDispatcher {
		/**
		 * Name of the tween job.
		 */
		public var name:String;
		/**
		 * The length of the tween in seconds.
		 */
		public var duration:Number = 1.0;
		/**
		 * The target object to tween.
		 */
		public var target:*;
		/**
		 * The object which contains the first (beginning) status in each property.
		 * In case of null, the current propeties would be copied from the target object.
		 */
		public var from:Object;
		/**
		 * The object which contains the last (ending) status in each property.
		 * In case of null, the current propeties would be copied from the target object.
		 */
		public var to:Object;
		/**
		 * The easing equation function.
		 */
		public var ease:Function = Quad.easeOut;
		/**
		 * True after the job was finished including completed, canceled and aborted.
		 */
		public var finished:Boolean = false;
		/**
		 * Set true to round the result value to the nearest integer number.
		 */
		public var round:Boolean = false;
		/**
		 * Set true to repeat the tween from the beginning after finished.
		 */
		public var repeat:Boolean = false;
		/**
		 * Set true to repeat the tween reverse back from the ending after finished.
		 * repeat property must be true.
		 */
		public var yoyo:Boolean = false;
		/**
		 * The callback function invoked when the tween job has just started.<br/>
		 * Note this would not work with KTween's static methods, 
		 * ex. <code>KTween.fromTo()</code>,
		 * as these methods start a job at the same time.
		 */
		public var onInit:Function;
		/**
		 * The callback function invoked when the value chaned.
		 */
		public var onChange:Function;
		/**
		 * The callback function invoked when the tween job has just completed.<br/>
		 * Note this would be invoked before the Flash Player renders the object 
		 * at the final position.
		 */
		public var onComplete:Function;
		/**
		 * The callback function invoked when the tween job is closing.<br/>
		 * Note this would be invoked at the next <code>ENTER_FRAME</code> event of onComplete.
		 */
		public var onClose:Function;
		/**
		 * The callback function invoked when the tween job is canceled.
		 */
		public var onCancel:Function;
		/**
		 * Arguments for onInit callback function.
		 */
		public var onInitParams:Array;
		/**
		 * Arguments for onChange callback function.
		 */
		public var onChangeParams:Array;
		/**
		 * Arguments for onComplete callback function.
		 */
		public var onCompleteParams:Array;
		/**
		 * Arguments for onClose callback function.
		 */
		public var onCloseParams:Array;
		/**
		 * Arguments for onCancel callback function.
		 */
		public var onCancelParams:Array;
		private var reverse:Boolean = false;
		private var initialized:Boolean = false;
		private var canceled:Boolean = false;
		private var pausing:Boolean = false;
		private var startTime:Number;
		private var lastTime:Number;
		private var propList:Array = new Array();
		private var invokeEvent:Boolean = false;

		/**
		 * Constructs a new KTJob instance.
		 *
		 * @param target 	The object whose properties will be tweened.
		 **/
		public final function KTJob(target:*):void {
			this.target = target;
		}

		/**
		 * Initializes from/to values of the tween job.
		 */
		public function init(curTime:Number = -1):void {
			if (initialized) return;
			if (finished) return;
			if (canceled) return;
			if (pausing) return;

			// get current time
			if (curTime < 0) {
				curTime = getTime();
			}
			startTime = curTime;

			setupValues();
			initialized = true;
			
			// activated
			if (onInit is Function) {
				onInit.apply(onInit, onInitParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.INIT);
				dispatchEvent(event);
			}
		}

		/**
		 * @private
		 */
		protected function setupValues():void {
			var key:String;
			var prop:_KTProperty;
			if (from != null && to != null) {
				applyFirstValues();
			} else if (from == null && to != null) {
				from = new Object();
				for (key in to) {
					from[key] = target[key];
				}
			} else if (from != null && to == null) {
				to = new Object();
				for (key in from) {
					to[key] = target[key];
				}
				applyFirstValues();
			} else if (from == null && to == null) {
				// empty tweening means delaying
				from = new Object();
				to = new Object();
			}
			for (key in to) {
				if (from[key] == to[key]) continue; // skip this
				prop = new _KTProperty(key, from[key], to[key]);
				propList.push(prop);
			}
		}

		private function applyFirstValues():void {
			for (var key:String in from) {
				target[key] = from[key];
			}
			if (onChange is Function) {
				onChange.apply(onChange, onChangeParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.CHANGE);
				dispatchEvent(event);
			}
		}

		private function applyFinalValues():void {
			for (var key:String in to) {
				target[key] = to[key];
			}
			if (onChange is Function) {
				onChange.apply(onChange, onChangeParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.CHANGE);
				dispatchEvent(event);
			}
		}

		/**
		 * Steps the sequence by every ticks invoked by ENTER_FRAME event.
		 * @param curTime The current time in milliseconds since the epoch. Optional.
		 */
		public function step(curTime:Number = -1):void {
			if (finished) return;
			if (canceled) return;
			if (pausing) return;
			
			// get current time
			if (curTime < 0) {
				curTime = getTime();
			}
			
			// not started yet
			if (!initialized) {
				init(curTime);
				return;
			}

			// check invoked in the same time
			if (lastTime == curTime) return;
			lastTime = curTime;
			
			// check finished
			var secs:Number = (curTime - startTime) * 0.001;
			if (secs >= duration) {
				if (repeat) {
					if (yoyo) {
						reverse = !reverse;
					}
					secs -= duration;
					startTime = curTime - secs * 1000;
				} else {
					complete();
					return;
				}
			}
			
			// tweening
			var pos:Number = secs / duration;
			if (reverse) {
				pos = 1 - pos;
			}
			if (ease != null) {
				pos = ease(pos);
			}
			update(pos);
		}

		/**
		 * @private
		 */
		protected function update(pos:Number):void {
			if (!propList) return;

			var prop:_KTProperty;
			var i:int = propList.length;
			if (round) {
				while (i--) {
					prop = propList[i];
					target[prop.key] = Math.round(prop.from + prop.diff * pos);
				}
			} else {
				while (i--) {
					prop = propList[i];
					target[prop.key] = prop.from + prop.diff * pos;
				}
			}
			if (onChange is Function) {
				onChange.apply(onChange, onChangeParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.CHANGE);
				dispatchEvent(event);
			}
		}

		/**
		 * Forces to finish the tween job.
		 */
		public function complete():void {
			if (!initialized) return;
			if (finished) return;
			if (canceled) return;
			if (!to) return;
			if (!target) return;
			
			applyFinalValues();

			finished = true;
			if (onComplete is Function) {
				onComplete.apply(onComplete, onCompleteParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.COMPLETE);
				dispatchEvent(event);
			}
		}

		/**
		 * Stops and rollbacks to the first (beginning) status of the tween job.
		 */
		public function cancel():void {
			if (!initialized) return;
			if (canceled) return;
			if (!from) return;
			if (!target) return;
			
			applyFirstValues();
			
			finished = true;
			canceled = true;
			if (onCancel is Function) {
				onCancel.apply(onCancel, onCancelParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.CANCEL);
				dispatchEvent(event);
			}
		}

		/**
		 * Closes the tween job
		 */
		public function close():void {
			if (!initialized) return;
			if (canceled) return;
			
			finished = true;
			if (onClose is Function) {
				onClose.apply(onClose, onCloseParams);
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.CLOSE);
				dispatchEvent(event);
			}
			clearnup();
		}

		/**
		 * @private
		 */
		protected function clearnup():void {
			onInit = null;
			onChange = null;
			onComplete = null;
			onCancel = null;
			onClose = null;
			onInitParams = null;
			onChangeParams = null;
			onCompleteParams = null;
			onCloseParams = null;
			onCancelParams = null;
			propList = null;
			invokeEvent = false;
		}

		/**
		 * Terminates the tween job immediately.
		 */
		public function abort():void {
			finished = true;
			canceled = true;
			clearnup();
		}

		/**
		 * Pauses the tween job.
		 */
		public function pause():void {
			if (pausing) return;
			pausing = true;
			lastTime = getTime();
		}

		/**
		 * Proceeds with the tween jobs paused.
		 */
		public function resume():void {
			if (!pausing) return;
			pausing = false;
			var curTime:Number = getTime();
			startTime = curTime - (lastTime - startTime);
			step(curTime);
		}

		/**
		 * @private
		 */
		protected function getTime():Number {
			var date:Date = new Date();
			return date.time;
		}

		/**
		 * @private
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			invokeEvent = true;
		}
	}
}

final class _KTProperty {
	public var key:String;
	public var from:Number;
	public var diff:Number;

	public function _KTProperty(key:String, from:Number, to:Number):void {
		this.key = key;
		this.from = from;
		this.diff = to - from;
	}
}
