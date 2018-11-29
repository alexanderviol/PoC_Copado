/*
 *  Test class for FLSEnforcer class 
 *  Created Date - May 31, 2018
 *  Created by   - Sumit
 * 
 * Revision History - 
 * Date             | Developer Name                | Version               | Changes/Ticket Number 
 * ================================================================================================      
 *  
 */
@isTest
private class FLSEnforcerTest {
	private static testMethod void testIsCreatable() {
        System.assertEquals(true, FLSEnforcer.isCreatable('Account', new List<String>{'Name'}));
    }
    
    private static testMethod void testisUpdatable() {
        System.assertEquals(true, FLSEnforcer.isUpdatable('Account', new List<String>{'Name'}));
    }
    
    private static testMethod void testisdeleteable() {
        System.assertEquals(true, FLSEnforcer.isdeleteable('Account'));
    }
}