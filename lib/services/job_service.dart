import 'dart:async';

class CustomJob {
  CustomJob(this.name, this.periodicity, this.callback);

  final String name;
  final Duration periodicity;
  DateTime installTime;
  DateTime nextRun;
  final Function callback;
}

JobService jobService = JobService();

class JobService {
  List<CustomJob> installedJobs = [];

  bool installJob(CustomJob job) {
    for (CustomJob j in installedJobs) {
      if (j.name == job.name) return false;
    }
    final now = DateTime.now();
    job.installTime = now;
    job.nextRun = now.add(job.periodicity);
    installedJobs.add(job);
    return true;
  }

  void start() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      step();
    });
  }

  void step() {
    final now = DateTime.now();
    for (CustomJob j in installedJobs) {
      if (now.isAfter(j.nextRun) || now.isAtSameMomentAs(j.nextRun)) {
        j.nextRun = now.add(j.periodicity);
        j.callback();
      }
    }
  }
}
