package net.kawa.tween {
	import flash.utils.setTimeout;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Tween job manager class
	 * @author Yusuke Kawasaki
	 * @version 1.0
	 * @see reference 	net.kawa.tween.KTJob
	 */
	public class KTManager {
		private var stage:Sprite;
		private var running:Boolean = false;
		private var jobList:Array;

		/**
		 * Constructs a new KTManager instance.
		 **/
		public function KTManager():void {
			stage = new Sprite();
			jobList = new Array();
		}

		/**
		 * Enqueue a new tween job.
		 *
		 * @param job 		A job to be added to queue
		 * @param delay 	
		 **/
		public function queue(job:KTJob, delay:Number = 0):void {
			if (delay > 0) {
				var that:KTManager = this;
				var closure:Function = function ():void {				
					that.queue(job);		
				};
				setTimeout(closure, delay * 1000);
				return;
			}
			jobList.push(job);
			if (!running) awake();
		}

		private function awake():void {
			if (running) return;
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			running = true;
		}

		private function sleep():void {
			stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			running = false;
		}

		/* not used at the time
		private function restart():void {
		sleep();
		awake();
		}
		 */
		private function enterFrameHandler(e:Event):void {
			// close jobs finished
			for (var i:int = jobList.length - 1;i >= 0;i--) {
				var job:KTJob = jobList[i];
				if (job == null) {
					// invalid job however
					jobList.splice(i, 1);
				} else if (job.finished) {
					jobList.splice(i, 1);
					job.close();
				}
			}

			// all jobs done
			if (jobList.length < 1) {
				sleep();
				return;
			}
			
			step();
		}

		private function step():void {
			var last:uint = jobList.length;
			for (var i:uint = 0;i < last;i++) {
				var job:KTJob = jobList[i];
				job.step();
			}
		}

		/**
		 * Terminates all tween jobs immediately
		 */
		public function abort():void {
			for each (var job:KTJob in jobList) {
				job.abort();
			}
		}

		/**
		 * Stops and rollbacks to the first (begging) status of all tween jobs.
		 */
		public function cancel():void {
			for each (var job:KTJob in jobList) {
				job.cancel();
			}
		}

		/**
		 * Forces to finish all tween jobs.
		 */
		public function complete():void {
			for each (var job:KTJob in jobList) {
				job.complete();
			}
		}
	}
}
