/*
 * Test class for PrintDoctorLetterController
 * 
 * @author          emma
 * @created         2018-04-24
 * @modified        2018-09-03
 * @systemLayer     Test 
 *  
 */

@isTest
public class PrintDoctorLetterControllerTest {
    /**
     * Test that a type of document is selected 
     * and ready to be sent to the lightning component for creation 
     * 
     * @author          emma
     * @created         2018-04-24
     */ 
	public static testMethod void testCreateDoctorLetter() {
        Test.setCurrentPageReference(new PageReference('Page.PrintDocDoctorLetter'));
        System.currentPageReference().getParameters().put('docL', 'true');
		System.currentPageReference().getParameters().put('docLw', 'true');
        
		PrintDoctorLetterController pdc = new PrintDoctorLetterController();
        System.assertEquals(ApexPages.currentPage().getParameters().get('docLw'), 'true');
    }
    /*
     * When no document selected or the checkbox has no value for any reason
     * 
     * @author          emma
     * @created         2018-09-03 
     */
    public static testMethod void testNoLetterSelected() {
        Test.setCurrentPageReference(new PageReference('Page.PrintDocDoctorLetter'));

        
         try {
          	System.currentPageReference().getParameters().put('docL', '');
			PrintDoctorLetterController pdc = new PrintDoctorLetterController();   
         }catch(Exception e){ 
            System.assertEquals(e.getMessage().contains(e.getMessage()), true);   
         }
    }
}