public class DuplicatePatientCheck {
    @TestVisible private static final String patient_duplicate_multiple = 'n';
    @TestVisible private static final String patient_duplicate_none = '0';
    
    @InvocableMethod(label='Get Duplicate Contacts' description='Returns List of String')
    public static List<String> getDuplicateContacts(List<Contact> contacts) {
        List<String> sResults = new List<String>();
        contacts[0].Id = null;
        contacts[0].trig_dob__c = String.valueOf(contacts[0].Birthdate);
        contacts[0].sap_company_code__c = String.valueOf(contacts[0].sap_company_code__c);
        list<sObject> dasContacts = new list<sobject>();
        dasContacts.addall(contacts);
        list<Contact> duplicateContacts = new list<Contact>();
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(dasContacts);

        if(results.size() > 0){
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            contact c = (Contact) matchRecord.getRecord();
                            duplicateContacts.add(c);
                        }
                    }
                }
            }
        }
        String sresult = (duplicateContacts.size() == 1) ? String.ValueOf(duplicateContacts[0].Id) : (duplicateContacts.size() > 1) ? patient_duplicate_multiple : patient_duplicate_none ;
        sResults.add(sresult);
        return sResults;

    }
}