/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      Schedulable to check if Batch was failing
*                  
*
* @date             29.10.2018
* 
*/

public class PriceBookDummiesCheckBatchSchedule implements Schedulable{

    private static String PRICEBOOK_ENTRY_DUMMIES_MAIL_LIST = Utility.getSettingValue('PRICEBOOK_ENTRY_DUMMIES_MAIL_LIST','safbio-internal@mms-dresden.de');

    // this is needed for tests
    @TestVisible
    private static String state = 'No Run';

    private Id asyncApexJobId;

    public PriceBookDummiesCheckBatchSchedule(Id asyncApexJobId){
        this.asyncApexJobId = asyncApexJobId;
    }

    public void execute(SchedulableContext sc) {
        checkOnError(asyncApexJobId);
        // remove schedule after mail is send.
        System.abortJob(sc.getTriggerId());
    }

    public static void checkOnError(Id asyncApexJobId){
        List<AsyncApexJob> asyncApexJobs = [SELECT Id, Status, JobType, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, ExtendedStatus FROM AsyncApexJob WHERE Id = : asyncApexJobId];
        System.debug('checkOnError AsyncApexJob: ' + asyncApexJobs);

        state = 'run';

        if(asyncApexJobs.isEmpty() || asyncApexJobs[0].Status == 'Failed' || asyncApexJobs[0].Status == 'Aborted' || !String.isBlank(asyncApexJobs[0].ExtendedStatus)){

            //sending the mail if process PricebookEntryDummies fail
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = PRICEBOOK_ENTRY_DUMMIES_MAIL_LIST.split(',');
            mail.setSenderDisplayName(Label.SENDER_DISPLAY_NAME_PRICEBOOK_ENTRY_DUMMIES_MAIL);

            mail.setSubject(Label.SUBJECT_PRICEBOOK_ENTRY_DUMMIES_MAIL);
            mail.setToAddresses(sendTo);

            if(asyncApexJobs.isEmpty()){
                state = 'not existing';
                mail.setHtmlBody(String.format(Label.HTML_BODY_PRICEBOOK_ENTRY_DUMMIES_MAIL, new List<String>{asyncApexJobId}));
            } else {
                state = asyncApexJobs[0].Status;
                mail.setHtmlBody(String.format(Label.EMAIL_BODY_PRICEBOOK_ENTRY_BATCH, new List<String>{JSON.serializePretty(asyncApexJobs[0])}));
            }

            mails.add(mail);
            System.debug('Send Mail: ' + mail);
            Messaging.sendEmail(mails);
        }
    }


}