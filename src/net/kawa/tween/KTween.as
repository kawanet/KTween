package net.kawa.tween {
	import net.kawa.tween.KTJob;
	import net.kawa.tween.KTManager;

	/**
	 * Tween frontend class for ease of use
	 * @author Yusuke Kawasaki
	 * @version 1.0
	 * @see reference 	net.kawa.tween.KTManager
	 * @see reference 	net.kawa.tween.KTJob
	 */
	public class KTween {
		/**
		 * The global KTManager instance.
		 */
		static private var manager:KTManager = new KTManager();
		/**
		 * KTJob class to create KTJob instances. KTJob is default.
		 */
		static public var jobClass:Class = KTJob;

		/**
		 * Starts a new KTween job specifying the first (begging) status.
		 * The last (ending) status will be back the current status.
		 * 
		 * @param target   	The target object to be tweened.
		 * @param duration 	The length of the tween in seconds.
		 * @param from 	 	The object which contains the first (begging) status in each property.
		 * @param ease 	 	The easing equation function. Quad.easeOut is default.
		 * @param callback	The callback function invoked after the tween completed as onClose.
		 * @return			The KTween job instance.
		 */
		static public function from(target:*, duration:Number, from:Object, ease:Function = null, callback:Function = null):KTJob {
			var job:KTJob = new jobClass(target);
			job.from = from;
			job.duration = duration;
			if (ease != null) job.ease = ease;
			job.onClose = callback;
			queue(job);
			return job;
		}

		/**
		 * Starts a new KTween job specifying the last (ending) status.
		 * The current status is used as the first (begging) status.
		 * 
		 * @param target   	The target object to be tweened.
		 * @param duration 	The length of the tween in seconds.
		 * @param to 	 	The object which contains the last (ending) status in each property.
		 * @param ease 	 	The easing equation function. Quad.easeOut is default.
		 * @param callback	The callback function invoked after the tween completed as onClose.
		 * @return			The KTween job instance.
		 */
		static public function to(target:*, duration:Number, to:Object, ease:Function = null, callback:Function = null):KTJob {
			var job:KTJob = new jobClass(target);
			job.to = to;
			job.duration = duration;
			if (ease != null) job.ease = ease;
			job.onClose = callback;
			queue(job);
			return job;
		}

		/**
		 * Starts a new KTween job.
		 * 
		 * @param target   	The target object to be tweened.
		 * @param duration 	The length of the tween in seconds.
		 * @param from 	 	The object which contains the first (begging) status in each property.
		 * @param to 	 	The object which contains the last (ending) status in each property.
		 * @param ease 	 	The easing equation function. Quad.easeOut is default.
		 * @param callback	The callback function invoked after the tween completed as onClose.
		 * @return			The KTween job instance.
		 */
		static public function fromTo(target:*, duration:Number, from:Object, to:Object, ease:Function = null, callback:Function = null):KTJob {
			var job:KTJob = new jobClass(target);
			job.from = from;
			job.to = to;
			job.duration = duration;
			if (ease != null) job.ease = ease;
			job.onClose = callback;
			queue(job);
			return job;
		}

		/**
		 * Regists a new tween job to the job queue.
		 *
		 * @param job 		A job to be added to queue
		 * @param delay 	
		 **/
		static public function queue(job:KTJob, delay:Number = 0):void {
			manager.queue(job, delay);
		}

		/**
		 * Terminates all tween jobs immediately
		 */
		static public function abort():void {
			manager.abort();
		}

		/**
		 * Stops and rollbacks to the first (begging) status of all tween jobs.
		 */
		static public function cancel():void {
			manager.cancel();
		}

		/**
		 * Forces to finish all tween jobs.
		 */
		static public function complete():void {
			manager.complete();
		}
	}
}