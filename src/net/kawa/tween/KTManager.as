package net.kawa.tween {
	import flash.utils.setTimeout;
	import flash.display.Sprite;
	import flash.events.Event;

	import net.kawa.tween.KTJob;

	/**
	 * Tween job manager class
	 * @author Yusuke Kawasaki
	 * @version 1.0
	 * @see reference 	net.kawa.tween.KTJob
	 */
	public class KTManager {
		private var stage:Sprite;
		private var running:Boolean = false;
		private var jobList:Array = new Array();
		private var jobAdded:Array = new Array();

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
			jobAdded.unshift(job);
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
			if (!jobList) return;
			if (!jobAdded) return;
			
			// close jobs finished
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				if (job == null) {
					// an invalid job instance however
					jobList.splice(i, 1);
				} else if (job.finished) {
					jobList.splice(i, 1);
					job.close();
				}
			}
			
			// check new jobs added
			if (jobAdded.length > 0) {
				jobList.unshift.apply(jobList, jobAdded);
				jobAdded.length = 0;
			}
			
			// check all jobs done
			if (jobList.length < 1) {
				sleep();
				return;
			}
			
			// tick
			step();
		}

		private function step():void {
			var i:int = jobList.length;
			var date:Date = new Date();
			var curTime:Number = date.time;
			while (i--) {
				var job:KTJob = jobList[i];
				job.step(curTime);
			}
		}

		/**
		 * Terminates all tween jobs immediately.
		 */
		public function abort():void {
			mergeList();
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				job.abort();
			}
		}

		/**
		 * Stops and rollbacks to the first (beginning) status of all tween jobs.
		 */
		public function cancel():void {
			mergeList();
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				job.cancel();
			}
		}

		/**
		 * Forces to finish all tween jobs.
		 */
		public function complete():void {
			mergeList();
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				job.complete();
			}
		}

		/**
		 * Pauses all tween jobs.
		 */
		public function pause():void {
			mergeList();
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				job.pause();
			}
		}

		/**
		 * Proceeds with all tween jobs paused.
		 */
		public function resume():void {
			// mergeList(); // this isn't needed
			var i:int = jobList.length;
			while (i--) {
				var job:KTJob = jobList[i];
				job.resume();
			}
		}

		private function mergeList():void {
			if (jobAdded.length == 0) return;
			jobList.unshift.apply(jobList, jobAdded);
			jobAdded.length = 0;
		}
	}
}
