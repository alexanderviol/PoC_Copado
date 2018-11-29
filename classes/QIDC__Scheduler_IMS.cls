/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Scheduler_IMS {
    @RemoteAction
    global static void abortSchedulerJob(String cronID) {

    }
    @RemoteAction
    global static CronTrigger invokeSchedulerJob(String pClassName, String CRON_EXP) {
        return null;
    }
    @RemoteAction
    global static CronTrigger invokeSchedulerJobWithJobName(String pJobName, String CRON_EXP, String pClassName) {
        return null;
    }
global class DeltaDownloadSchedulerException extends Exception {
}
global class SchedulerException extends Exception {
}
}
