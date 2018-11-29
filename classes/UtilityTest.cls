/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      Unit test for utility class
*                  
*
* @date             18.09.2018
* 
*/

@IsTest
private class UtilityTest {
    @IsTest
    static void getRecordTypeIdTest(){
        System.assertNotEquals(null,Utility.getRecordTypeId(Constants.RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER));

        // A developer name which is not existing leads to null
        System.assertEquals(null,Utility.getRecordTypeId('ThisIsSomeVeryLongRecordTypeThatDoNotExsistThisIsSomeVeryLongRecordTypeThatDoNotExist'));
    }

    @IsTest
    static void getRecordTypeIdNoDmlTest(){
        System.assertNotEquals(null,Utility.getRecordTypeId(Account.SObjectType ,Constants.RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER));
    }

    @IsTest
    static void getRecordTypeIdOldTest(){
        System.assertNotEquals(null,Utility.getRecordTypeId('Account', Constants.RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER));
    }

    @IsTest
    static void getParentRoleIdTest(){

        UserRole userRole  = [SELECT Id, ParentRoleId, DeveloperName FROM UserRole WHERE DeveloperName = 'US_National_Manager'];

        System.debug('UserRole: ' + userRole );

        Set<Id> userRoleIds = new Set<Id>();
        userRoleIds.add(userRole.Id);
        Set<Id> parents = Utility.getParentRoleId(userRoleIds);

        List<UserRole> parentUserRoles  = [SELECT Id, ParentRoleId, DeveloperName FROM UserRole WHERE Id = : userRole.ParentRoleId ];
        System.debug('parent User Roles :' + parentUserRoles);

        System.debug('parent UserRoleIds by Utility.getParentRoleId :' + parents);

        for (UserRole parentUserRole : parentUserRoles){
            System.assert(parents.contains(parentUserRole.Id),' getParentRoleId did not return id of ' + parentUserRole + ' but it is a parent');
        }
    }

    @IsTest
    static void getRoleIdTest(){

        UserRole userRole  = [SELECT Id, ParentRoleId, DeveloperName FROM UserRole WHERE DeveloperName = 'US_National_Manager'];

        System.debug('UserRole: ' + userRole );

        Set<Id> userRoleIds = new Set<Id>();
        userRoleIds.add(userRole.Id);
        Set<Id> parents = Utility.getParentRoleId(userRoleIds);

        List<UserRole> parentUserRoles  = [SELECT Id, ParentRoleId, DeveloperName FROM UserRole WHERE Id = : userRole.ParentRoleId ];
        System.debug('parent User Roles :' + parentUserRoles);

        System.debug('parent UserRoleIds by Utility.getParentRoleId :' + parents);

        for (UserRole parentUserRole : parentUserRoles){
            System.assert(parents.contains(parentUserRole.Id),' getParentRoleId did not return id of ' + parentUserRole + ' but it is a parent');
        }

        // getAllSubRoleIds
        Set<Id> newSubRoles = Utility.getAllSubRoleIds(userRoleIds);
        // old implementation
        Set<Id> oldSubRoles = getAllSubRoleIdsWithDML(userRoleIds);

        System.debug('From Utils ' + newSubRoles);
        System.debug('With Query ' + oldSubRoles);

        //Check if they are the same size
        System.assertEquals(oldSubRoles.size(), newSubRoles.size());

        // test if both have the same RoleIds
        for (Id roleId : newSubRoles){
            if (!oldSubRoles.contains(roleId)) {
                System.assert(false,'RoleId ' + roleId + ' did not exsist in DML result. DML result: ' + oldSubRoles);
            }
        }

    }

    /**
     * Methode to test getAllSubRoleIds
     *
     * @param roleIds
     *
     * @return
     */
    private static Set<Id> getAllSubRoleIdsWithDML(Set<Id> roleIds) {

        Set<Id> currentRoleIds = new Set<Id>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[SELECT Id FROM UserRole WHERE ParentRoleId
                IN :roleIds AND ParentRoleId != NULL]) {
            currentRoleIds.add(userRole.Id);
        }

        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIdsWithDML(currentRoleIds));
        }

        return currentRoleIds;
    }
	
     /**
     * Method to test isContToMultipleAccountsEnabled
     *
     */
	@IsTest
    static void isContToMultipleAccountsEnabledTest() {
        System.assert(Utility.isContToMultipleAccountsEnabled());
    }
    
    /* test for product types to validation category
     * Cannot be overly sensible...
     * @author Florian Heer <f.heer@conciscon.de> 2018-09-25 SAFBIO-2178
     */
    @IsTest
    public static void testProductTypesAndCategories() {
        List<String> catsToTest = new List<String> {
          'Device', 'CardioMessenger', 'System', 'Lead', 'n/a', 'Loop Recorder'
        };
            
            for (String cat : catsToTest) {
                List<String> prodTypes = Utility.getContainedProductTypes(cat);
                for(String pt : prodTypes) {
                    System.assertEquals(cat, Utility.getValidationCategory(pt));
                }
            }
        System.assertEquals(null, Utility.getValidationCategory('Non-existent'));
        System.assertEquals(0, Utility.getContainedProductTypes('Non-existent').size());
    }

    @IsTest
    static void containsInBothTest() {

        // create two Sets
        Set<String> a = new Set<String>();
        a.add('1');
        a.add('2');
        a.add('3');
        a.add('4');

        Set<String> b = new Set<String>();
        b.add('2');
        b.add('3');

        Set<String> c = Utility.containsInBoth(a,b);

        System.debug('containsInBoth' +c );

        System.assertEquals(2, c.size());
        System.assert(c.contains('2'));
        System.assert(c.contains('3'));

    }

    @IsTest
    static void removeFromMapTest() {

        // create two Sets
        Map<String,String> a = new Map<String, String>();
        a.put('1','1');
        a.put('2','2');
        a.put('3','3');
        a.put('4','4');

        Set<String> b = new Set<String>();
        b.add('2');
        b.add('3');
        b.add('drölf');

        Utility.removeFromMap(a,b);

        System.assertEquals(2,a.size());
        System.assert(!a.containsKey('2'));
        System.assert(!a.containsKey('3'));

    }
    
    @IsTest
    static void testImplantableSerialized () {
        System.assertEquals(true, Utility.isImplantableSerialized(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD));
        System.assertEquals(false, Utility.isImplantableSerialized(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER));
    }

}