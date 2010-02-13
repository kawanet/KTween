package net.kawa.tween {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import net.kawa.tween.easing.Quad;

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
		 * The object which contains the first (begging) status in each property.
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
		 * Set true to repeat the tween from the begging after finished.
		 */
		public var repeat:Boolean = false;
		/**
		 * Set true to repeat the tween reverse back from the ending after finished.
		 * repeat property must be true.
		 */
		public var yoyo:Boolean = false;
		/**
		 * The callback function invoked when the job has just started.
		 */
		public var onInit:Function;         // job just started
		/**
		 * The callback function invoked when the value chaned.
		 */
		public var onChange:Function;
		/**
		 * The callback function invoked when the job has just completed.
		 * Note this may be invoked before Flash renders the object.
		 */
		public var onComplete:Function;		// soon after job done
		/**
		 * The callback function invoked when the job is closing.
		 * Note this is invoked in the next ENTER_FRAME event of onComplete.
		 */
		public var onClose:Function;		// job done
		/**
		 * The callback function invoked when the job is canceled.
		 */
		public var onCancel:Function;		// job canceled
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
		private var startTime:Number;
		private var lastTime:Number;
		private var propList:Array = new Array();
		private var invokeEvent:Boolean = false;

		/**
		 * Constructs a new KTJob instance.
		 *
		 * @param target 	The object whose properties will be tweened.
		 * @param name 		The name of the tween job. Defaults to null.
		 **/
		public final function KTJob(target:*, name:String = null):void {
			this.name = name;
			this.target = target;
		}

		/**
		 * Initializes from/to values of the tween job.
		 */
		public function init():void {
			if (initialized) return;
			if (finished) return;
			if (canceled) return;

			var date:Date = new Date();
			startTime = date.time;
			setupValues();
			initialized = true;
			
			// activated
			if (onInit is Function) {
				onInit.apply(onInit, onInitParams);
				onInit = null;
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
				setFirstValues();
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
				setFirstValues();
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

		private function setFirstValues():void {
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

		private function setFinalValues():void {
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
		 * Steps a sequence invoked by ENTER_FRAME events.
		 */
		public function step(curTime:Number = 0):void {
			if (finished) return;
			if (canceled) return;
			
			// not started yet
			if (!initialized) {
				init();
				return;
			}
			
			// get current time
			if (curTime == 0) {
				var date:Date = new Date();
				curTime = date.time;
			}

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
			
			// check invoked in the same time
			if (lastTime == curTime) return;
			lastTime = curTime;
			
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
			
			setFinalValues();

			finished = true;
			if (onComplete is Function) {
				onComplete.apply(onComplete, onCompleteParams);
				onComplete = null;
			}
			if (invokeEvent) {
				var event:Event = new Event(Event.COMPLETE);
				dispatchEvent(event);
			}
		}

		/**
		 * Stops and rollbacks to the first (begging) status of the tween job.
		 */
		public function cancel():void {
			if (!initialized) return;
			if (canceled) return;
			if (!from) return;
			if (!target) return;
			
			setFirstValues();
			
			finished = true;
			canceled = true;
			if (onCancel is Function) {
				onCancel.apply(onCancel, onCancelParams);
				onCancel = null;
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
				onClose = null;
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