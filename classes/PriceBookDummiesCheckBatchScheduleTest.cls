/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      
*                  
*
* @date             29.10.2018
* 
*/

@IsTest
private class PriceBookDummiesCheckBatchScheduleTest {
    @IsTest
    static void testSendMailNotExist() {

        Test.startTest();
        PriceBookDummiesCheckBatchSchedule.checkOnError(null);
        Test.stopTest();

        Integer invocations = Limits.getEmailInvocations();
        //System.assertEquals(1, invocations, 'An email should be sent');
        // check which state was set
        System.assertEquals('not existing',PriceBookDummiesCheckBatchSchedule.state);
    }
}