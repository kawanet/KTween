package net.kawa.tween {
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.display.Sprite;
	import flash.events.Event;

	import net.kawa.tween.KTJob;

	/**
	 * Tween job manager class
	 * @author Yusuke Kawasaki
	 * @version 1.0.1
	 * @see net.kawa.tween.KTJob
	 */
	public class KTManager {
		private var stage:Sprite;
		private var running:Boolean = false;
		private var firstJob:KTJob;
		private var lastJob:KTJob;
		private var firstAdded:KTJob;
		private var lastAdded:KTJob;

		/**
		 * Constructs a new KTManager instance.
		 **/
		public function KTManager():void {
			stage = new Sprite();
		}

		/**
		 * Regists a new tween job to the job queue.
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
			job.init();
			if (lastAdded != null) {
				lastAdded.next = job;
			} else {
				firstAdded = job;
			}
			lastAdded = job;

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

		private function enterFrameHandler(e:Event):void {
			// close jobs finished
			var prev:KTJob = null;
			var job:KTJob = firstJob;
			while (job != null) {
				if (job.finished) {
					if (prev == null) {
						firstJob = job.next;
					} else {
						prev.next = job.next;
					}
					if (job.next == null) {
						lastJob = prev;
					}
					job.close();
				} else {
					prev = job;
				}
				job = job.next;
			}

			// check new jobs added
			if (firstAdded != null) {
				mergeList();
			}
			
			// check all jobs done
			if (firstJob == null) {
				sleep();
				return;
			}
			
			// tick
			step();
		}

		private function step():void {
			var curTime:Number = getTimer();
			var job:KTJob = firstJob;
			while (job != null) {
				job.step(curTime);
				job = job.next;
			}
		}

		/**
		 * Terminates all tween jobs immediately.
		 * @see net.kawa.tween.KTJob#abort()
		 */
		public function abort():void {
			mergeList();
			var job:KTJob = firstJob;
			while (job != null) {
				job.abort();
				job = job.next;
			}
		}

		/**
		 * Stops and rollbacks to the first (beginning) status of all tween jobs.
		 * @see net.kawa.tween.KTJob#cancel()
		 */
		public function cancel():void {
			mergeList();
			var job:KTJob = firstJob;
			while (job != null) {
				job.cancel();
				job = job.next;
			}
		}

		/**
		 * Forces to finish all tween jobs.
		 * @see net.kawa.tween.KTJob#complete()
		 */
		public function complete():void {
			mergeList();
			var job:KTJob = firstJob;
			while (job != null) {
				job.complete();
				job = job.next;
			}
		}

		/**
		 * Pauses all tween jobs.
		 * @see net.kawa.tween.KTJob#pause()
		 */
		public function pause():void {
			mergeList();
			var job:KTJob = firstJob;
			while (job != null) {
				job.pause();
				job = job.next;
			}
		}

		/**
		 * Proceeds with all tween jobs paused.
		 * @see net.kawa.tween.KTJob#resume()
		 */
		public function resume():void {
			// mergeList(); // this isn't needed
			var job:KTJob = firstJob;
			while (job != null) {
				job.resume();
				job = job.next;
			}
		}

		private function mergeList():void {
			if (!firstAdded) return;
			if (lastJob != null) {
				lastJob.next = firstAdded;	
			} else {
				firstJob = firstAdded;
			}
			lastJob = lastAdded;
			firstAdded = null;
			lastAdded = null;
		}
	}
}
