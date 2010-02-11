package net.kawa.tween {
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
		private var reverse:Boolean = false;
		private var initialized:Boolean = false;
		private var canceled:Boolean = false;
		private var startTime:Number;
		private var lastTime:Number;

		/**
		 * Constructs a new KTJob instance.
		 *
		 * @param target 	The object whose properties will be tweened.
		 * @param name 		The name of the tween job. Defaults to null.
		 **/
		public function KTJob(target:*, name:String = null):void {
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
			if (onInit != null) {
				onInit();
				onInit = null;
			}
		}

		private function setupValues():void {
			var key:String;

			if (from != null && to != null) {
				for (key in from) {
					target[key] = from[key];
				}
			} else if (from == null && to != null) {
				from = new Object();
				for (key in to) {
					from[key] = target[key];
				}
			} else if (from != null && to == null) {
				to = new Object();
				for (key in from) {
					to[key] = target[key];
					target[key] = from[key];
				}
			} else if (from == null && to == null) {
				// empty tweening means delaying
				from = new Object();
				to = new Object();
			}
		}

		/**
		 * Steps a sequence invoked by ENTER_FRAME events.
		 */
		public function step():void {
			if (finished) return;
			if (canceled) return;
			
			// not started yet
			if (!initialized) {
				init();
				return;
			}
			
			// get current time
			var date:Date = new Date();
			var curTime:Number = date.time;

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
			var key:String;
			if (round) {
				for (key in to) {
					target[key] = Math.round(from[key] + (to[key] - from[key]) * pos); 
				} 
			} else {
				for (key in to) {
					target[key] = from[key] + (to[key] - from[key]) * pos; 
				}
			}
		}

		/**
		 * Forces to finish the tween job.
		 */
		public function complete():void {
			if (!initialized) return;
			if (finished) return;
			if (canceled) return;
			
			for (var key:String in to) {
				target[key] = to[key];
			}
			finished = true;
			if (onComplete != null) {
				onComplete();
				onComplete = null;
			}
		}

		/**
		 * Stops and rollbacks to the first (begging) status of the tween job.
		 */
		public function cancel():void {
			if (!initialized) return;
			if (canceled) return;
			
			for (var key:String in to) {
				target[key] = from[key];
			}
			finished = true;
			canceled = true;
			if (onCancel != null) {
				onCancel();
				onCancel = null;
			}
		}

		/**
		 * Closes the tween job
		 */
		public function close():void {
			if (!initialized) return;
			if (canceled) return;
			
			finished = true;
			if (onClose != null) {
				onClose();
			}
			onInit = null;
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
		}
	}
}
