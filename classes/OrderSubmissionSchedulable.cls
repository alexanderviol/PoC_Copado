public with sharing class OrderSubmissionSchedulable implements Schedulable{

    /**
    * Name of the scheduled job. Used to check for existance.
    */
    @testVisible private static final String JOB_NAME = 'OrderSubmissionJob';

    /**
     * Name of the Custom Metadata Record storing Amount of seconds for rescheduling if no orders are pending
     */
    private static final String METADATA_NAME_ORDERSUBMISSION_INTERVAL_BUSY = 'ORDERSUBMISSION_RETRY_INTERVAL_BUSY';

    /**
     * Name of the Custom Metadata Record storing Amount of seconds for rescheduling if pending orders are present
     */
    private static final String METADATA_NAME_ORDERSUBMISSION_INTERVAL_IDLE = 'ORDERSUBMISSION_RETRY_INTERVAL_IDLE';

    /**
     * Amount of seconds for rescheduling if pending orders are present
     */
    private static final Integer ORDER_SUBMISSION_BATCH_SIZE = 10;


    public void execute(SchedulableContext param1) {


        Integer rescheduleInSeconds = Integer.valueOf([
                SELECT Value__c
                FROM Setting__mdt
                WHERE DeveloperName = :METADATA_NAME_ORDERSUBMISSION_INTERVAL_IDLE LIMIT 1
        ].Value__c);

        Integer count = 1;

        List<Order> ordersToSubmit = new List<Order>();

        List<Order> orders = [
                SELECT Id
                FROM Order
                WHERE submit_to_sap__c = true
                AND Status = 'Pending SAP Submission'
                AND is_locked__c = false
                AND (
                        submitted_date__c = NULL
                        OR PoNumber != NULL
                )
                AND (
                        submission_attempts__c < 10
                        OR submission_attempts__c = NULL
                )
                LIMIT :ORDER_SUBMISSION_BATCH_SIZE + 1
        ];

        for (Order order : orders) {

            ordersToSubmit.add(order);
            count++;

            if (orders.size() > ORDER_SUBMISSION_BATCH_SIZE) {
                rescheduleInSeconds = Integer.valueOf([
                        SElECT Value__c
                        FROM Setting__mdt
                        WHERE DeveloperName = :METADATA_NAME_ORDERSUBMISSION_INTERVAL_BUSY LIMIT 1
                ].Value__c);
                break;
            }
        }

        if (!OrderSubmissionServiceTest.testOrderSubmissionSchedulableRunning) {
            OrderSubmissionService.submitOrders(ordersToSubmit);
        }
        this.reschedule(rescheduleInSeconds);

    }



    public void reschedule (Integer seconds)
    {
        if (seconds == null || seconds < 0) {
            seconds = 1;
        }

        // not possible to set new time and update, the job needs to be removed...
        removeExistingJob(JOB_NAME);

        DateTime nextRun = DateTime.Now().addSeconds(seconds);
        String cronExpression = nextRun.format('s m H d M \'?\' Y');

        System.schedule(JOB_NAME, cronExpression, new OrderSubmissionSchedulable());
    }


    private void removeExistingJob (String jobName)
    {
        List<CronTrigger> cronTriggers = [
                SELECT
                        Id
                FROM
                        CronTrigger
                WHERE
                        CronJobDetail.Name = :jobName
        ];

        if (cronTriggers.isEmpty() || cronTriggers.size() > 1) {
            return;
        }

        CronTrigger cronTrigger = cronTriggers.get(0);
        Id cronTriggerId = cronTrigger.Id;

        System.abortJob(cronTriggerId);
    }


}