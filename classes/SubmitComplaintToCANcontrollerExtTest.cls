/*
 * Test class for SubmitComplaintToCANcontrollerExt
 * created by : emma
 * created date : 01.06.2018
 */
@isTest
global class SubmitComplaintToCANcontrollerExtTest {

    static list<complaint__c> complaintList = new list<complaint__c>();
    static complaint__c objComplaint;

    /**
     * Method to initialize test data
     */
    private static void init() {

        case objCase = TestDataFactory.createCase();
        insert objCase;

        objComplaint = TestDataFactory.createComplaint(objCase.id);
        complaintList.add(objComplaint);

        complaint__c secComplaint = TestDataFactory.createComplaint(objCase.id);
        complaintList.add(secComplaint);
    }

    //test submit if at least one record selected
    private static testMethod void testSubmitComplaintsIfRecordSelected (){
        init();
        insert objComplaint;

        test.startTest();
        List<complaint__c> complaintList = new List <complaint__c>{objComplaint};
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(complaintList);
        controller.setSelected(complaintList);

        SubmitComplaintToCANcontrollerExt toSubmit = new SubmitComplaintToCANcontrollerExt(controller);

        System.assertEquals(0, ApexPages.getMessages().size());

        toSubmit.submit();

        Test.stopTest();
    }

    // test submit if no record is selected
    private static testMethod void testSubmitComplaintsIfNoRecordSelected(){
        init();
        insert objComplaint;

        test.startTest();
        List<complaint__c> complaintsList = new List <complaint__c>();
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(complaintsList);
        SubmitComplaintToCANcontrollerExt toSubmit = new SubmitComplaintToCANcontrollerExt(controller);

        System.assert(ApexPages.getMessages().get(0).getDetail().contains(Label.CAN_SUBMISSION_SELECTED_ERROR_NOTHINGSELECTED), 'Page Message CAN_SUBMISSION_SELECTED_ERROR_NOTHINGSELECTED not added.');
        test.stopTest();
    }

}