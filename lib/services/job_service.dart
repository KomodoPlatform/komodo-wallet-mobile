import 'dart:async';

import 'package:komodo_dex/utils/log.dart';

/// Returns a `Future` in order for us to know when the callback has finished,
/// allowing us not to call the same callback two times in parallel
/// and to detect a hanging callback.
typedef JobCallback = Future<void> Function(CustomJob);

class CustomJob {
  CustomJob(this._name, this._period, this._timeout, this._callback);
  final String _name;

  /// Minimal number of seconds between the job invocations.
  /// `0.0` if the job is paused.
  double _period;
  int _timeout;
  JobCallback _callback;
  DateTime _started;
  DateTime _finished;
}

JobService jobService = JobService();

/// Periodically invokes asynchronous jobs,
/// guarding against invoking the jobs too often
/// and against invoking a job while the previous invocation has not been finished yet.
class JobService {
  final Map<String, CustomJob> _jobs = {};
  DateTime _lastRun, _lastPeriodic;

  static const int _many = 2147483647;

  void _maintenance() {
    // If we aren't invoked then we are missing a timer.
    final now = DateTime.now();
    final runDelta =
        _lastRun != null ? now.difference(_lastRun).inMilliseconds : _many;
    final periodicDelta = _lastPeriodic != null
        ? now.difference(_lastPeriodic).inMilliseconds
        : _many;
    if (runDelta > 2222 && periodicDelta > 3333) {
      _lastPeriodic = now;
      Timer.periodic(const Duration(seconds: 1), (t) => step());
    }
  }

  /// Schedules a job with the given unique [name] if it wasn't scheduled already.
  /// Job invocations will be at least [period] seconds apart.
  /// We'll also wait for the job to finish or reach a [timeout] before reinvoking it.
  ///
  /// If the job is already installed then we update its [period], [timeout] and [cb].
  ///
  /// The job is paused while its [period] is 0.
  void install(String name, double period, JobCallback cb,
      {int timeout = 333}) {
    _maintenance();
    if (_jobs.containsKey(name)) {
      _jobs[name]._period = period;
      _jobs[name]._timeout = timeout;
      _jobs[name]._callback = cb;
    } else {
      _jobs[name] = CustomJob(name, period, timeout, cb);
    }
  }

  void suspend(String name) {
    if (_jobs.containsKey(name)) {
      _jobs[name]._period = 0.0;
    }
  }

  Future<void> step() async {
    final now = DateTime.now();

    if (_lastRun != null) {
      // #637: Guard against duplicate timers reducing performance.
      final deltaMs = now.difference(_lastRun).inMilliseconds;
      if (deltaMs < 777) return;
    }

    _lastRun = now;

    for (CustomJob job in _jobs.values) {
      if (job._period == 0.0) continue;

      if (job._started != null) {
        final startDeltaMs = now.difference(job._started).inMilliseconds;
        if (startDeltaMs < job._period * 1000.0) continue;
      }

      // If still running.
      if (job._started != null && job._finished == null) {
        // Guard against time going backwards.
        if (now.millisecondsSinceEpoch < job._started.millisecondsSinceEpoch) {
          continue;
        }

        final startDeltaMs = now.difference(job._started).inMilliseconds;
        if (startDeltaMs < job._timeout * 1000) {
          continue;
        } else {
          Log.println('job_service:103', 'job ${job._name} timed out');
        }
      }

      if (job._finished != null) {
        final finishDeltaMs = now.difference(job._finished).inMilliseconds;
        if (finishDeltaMs < 100) continue;
      }

      (CustomJob job) async {
        job._started = now;
        job._finished = null;
        try {
          await job._callback(job);
        } catch (ex) {
          Log.println('job_service:118', 'job ${job._name} error: $ex');
        }
        job._finished = DateTime.now();
        //final delta = job._finished.difference(now).inMilliseconds / 1000.0;
        //Log.println('job_service:122', 'job ${job._name} done in ${delta}s');
      }(job);
    }
  }
}
