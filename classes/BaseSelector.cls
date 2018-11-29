/**************************************************************************************************************
* BaseSelector
* @author Gokul Palagiri
* @CreatedDate -    10.10.2018
* Gokul Palagiri:   10.10.2018 : Initial Version
****************************************************************************************************************/
/**
* Selector Class helper
**/
public virtual class BaseSelector {
    public BaseSelector() {
    }

    /**
    * Constructs a String from given fields so that it can be used in a SOQL query
    * @param    List<Schema.FieldSetMember> fields wants a list of fields that can be queried
    * @returns  String that contains all fields that can be queried
    **/
    public String ConstructFieldString(List<Schema.FieldSetMember> fields) {
        Boolean hasIdField = false;
        List<String> fieldsList = new List<String>();
        for (Schema.FieldSetMember field : fields) {
            hasIdField = field.getFieldPath().toLowerCase() == 'id' ? true : false;
            fieldsList.add(field.getFieldPath());
        }
        if (!hasIdField) {fieldsList.add('Id');}
        return String.join(fieldsList, ',');
    }

    /**
    * Constructs a String from a given Set of ids
    * @param    Set<Id> ids set of ids
    * @returns  String that contains all values to look into
    **/
    public String ConstructInClauseString(Set<Id> ids) {
        List<String> cache = new List<String>();
        for (Id recordId : ids) {
            cache.add('\'' + recordId + '\'');
        }
        String idsStr = String.join(cache, ',');
        return '(' + idsStr + ')';
    }

    /**
    * Constructs a String from a given Set of Strings
    * @param    Set<String> strings set of strings
    * @returns  String that contains all values to look into
    **/
    public String ConstructInClauseString(Set<String> strings) {
        List<String> cache = new List<String>();
        for (String s : strings) {
            cache.add('\'' + s + '\'');
        }
        String idsStr = String.join(cache, ',');
        return '(' + idsStr + ')';
    }

    /**
   * Constructs a String from a given Set of Integers
   * @param    Set<Integer> set of strings
   * @returns  String that contains all values to look into
   **/
    public String ConstructInClauseString(Set<Integer> integers) {
        List<String> cache = new List<String>();
        for (Integer i : integers) {
            cache.add( String.valueOf(i) );
        }
        String idsStr = String.join(cache, ',');
        return '(' + idsStr + ')';
    }

    /**
    * Constructs a String from a given List of Strings
    * @param    List<String> strings list of strings
    * @returns  String that contains all fields that need to be queried
    **/
    public String ConstructFieldString(List<String> fields) {
        Boolean hasIdField = false;
        List<String> fieldsList = new List<String>();
        for (String field : fields) {
            hasIdField = field.toLowerCase() == 'id' ? true : false;
            if(hasIdField){fieldsList.add(field);}
        }
        if (!hasIdField){fieldsList.add('Id');}
        return String.join(fieldsList, ',');
    }

    /**
    * Constructs a String from a given Set of Strings
    * @param    Set<String> strings set of strings
    * @returns  String that contains all fields that need to be queried
    **/
    public String ConstructFieldString(Set<String> fields) {
        Boolean hasIdField = false;
        List<String> fieldsList = new List<String>();
        for (String f : fields) {
            if (f.toLowerCase() == 'id')
                hasIdField = true;
            fieldsList.add(f);
        }
        if (!hasIdField)
            fieldsList.add('Id');
        return String.join(fieldsList, ',');
    }
}