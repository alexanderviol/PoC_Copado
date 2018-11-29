/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ApexLangUtils {
    global static Integer CONNECTOR_PUNCTUATION;
    global static Integer CONTROL;
    global static String CR;
    global static Integer CURRENCY_SYMBOL;
    global static Integer DASH_PUNCTUATION;
    global static Integer DECIMAL_DIGIT_NUMBER;
    global static String DEFAULT_LANGUAGE_CODE;
    global static QIDC.IntegerRange DIGIT_ASCII_RANGE;
    global static String EMPTY;
    global static List<String> EMPTY_STRING_ARRAY;
    global static Integer END_PUNCTUATION;
    global static String HTTP_LANGUAGE_CODE_PARAMETER_KEY;
    global static Integer INDEX_NOT_FOUND;
    global static String LF;
    global static String LINE_SEPARATOR;
    global static QIDC.IntegerRange LOWERCASE_ASCII_RANGE;
    global static Integer LOWERCASE_LETTER;
    global static Integer MATH_SYMBOL;
    global static Integer MAX_INTEGER;
    global static QIDC.IntegerRange MAX_INTEGER_RANGE;
    global static Long MAX_LONG;
    global static QIDC.LongRange MAX_LONG_RANGE;
    global static Integer MAX_NUMBER_OF_ELEMENTS_IN_LIST {
        get;
    }
    global static Integer MIN_INTEGER;
    global static Long MIN_LONG;
    global static Integer MODIFIER_SYMBOL;
    global static Integer OTHER_PUNCTUATION;
    global static Integer SPACE_SEPARATOR;
    global static Integer START_PUNCTUATION;
    global static Set<String> SUPPORTED_LANGUAGE_CODES;
    global static Integer UNASSIGNED;
    global static QIDC.IntegerRange UPPERCASE_ASCII_RANGE;
    global static Integer UPPERCASE_LETTER;
    global ApexLangUtils() {

    }
    global static String abbreviate(String str, Integer maxWidth) {
        return null;
    }
    global static String abbreviate(String str, Integer offset, Integer maxWidth) {
        return null;
    }
    global static String abbreviate(String str, Integer lower, Integer upper, String appendToEnd) {
        return null;
    }
    global static void addConfirm(String message) {

    }
    global static void addError(String message) {

    }
    global static void addFatal(String message) {

    }
    global static void addInfo(String message) {

    }
    global static void addWarning(String message) {

    }
    global static void assertArraysAreEqual(List<Object> expected, List<Object> actual) {

    }
    global static void assertArraysAreEqual(List<SObject> expected, List<SObject> actual) {

    }
    global static void assertConfirmMessagesExist() {

    }
    global static void assertEquals(Set<Blob> b1, Set<Blob> b2) {

    }
    global static void assertEquals(Set<Boolean> b1, Set<Boolean> b2) {

    }
    global static void assertEquals(Set<Date> d1, Set<Date> d2) {

    }
    global static void assertEquals(Set<Datetime> d1, Set<Datetime> d2) {

    }
    global static void assertEquals(Set<Decimal> d1, Set<Decimal> d2) {

    }
    global static void assertEquals(Set<Double> d1, Set<Double> d2) {

    }
    global static void assertEquals(Set<Integer> i1, Set<Integer> i2) {

    }
    global static void assertEquals(Set<Long> l1, Set<Long> l2) {

    }
    global static void assertEquals(Set<Object> expected, Set<Object> actual) {

    }
    global static void assertEquals(Set<String> s1, Set<String> s2) {

    }
    global static void assertEquals(Set<Time> t1, Set<Time> t2) {

    }
    global static void assertErrorMessagesExist() {

    }
    global static void assertFatalMessagesExist() {

    }
    global static void assertInfoMessagesExist() {

    }
    global static void assertMessagesAtLevelExist(ApexPages.Severity level, Boolean includeHigher) {

    }
    global static void assertNoConfirmMessagesExist() {

    }
    global static void assertNoErrorMessagesExist() {

    }
    global static void assertNoFatalMessagesExist() {

    }
    global static void assertNoInfoMessagesExist() {

    }
    global static void assertNoMessagesAtLevelExist(ApexPages.Severity level, Boolean includeHigher) {

    }
    global static void assertNoWarningMessagesExist() {

    }
    global static void assertWarningMessagesExist() {

    }
    global static Set<Object> blobToObject(Set<Blob> blobSet) {
        return null;
    }
    global static Set<Object> booleanToObject(Set<Boolean> booleanSet) {
        return null;
    }
    global static String capitalize(String str) {
        return null;
    }
    global static String capitalizeFully(String str) {
        return null;
    }
    global static String capitalizeFully(String str, List<String> delimiters) {
        return null;
    }
    global static String capitalize(String str, List<String> delimiters) {
        return null;
    }
    global static String center(String str, Integer size) {
        return null;
    }
    global static String center(String str, Integer size, String padStr) {
        return null;
    }
    global static String charAt(String str, Integer index) {
        return null;
    }
    global static String chomp(String str) {
        return null;
    }
    global static String chomp(String str, String separator) {
        return null;
    }
    global static String chop(String str) {
        return null;
    }
    global static Boolean contains(String str, String searchStr) {
        return null;
    }
    global static Boolean containsAny(String str, String searchChars) {
        return null;
    }
    global static Boolean containsIgnoreCase(String str, String searchStr) {
        return null;
    }
    global static Boolean containsNone(String str, String invalidChars) {
        return null;
    }
    global static Boolean containsOnly(String str, String valid) {
        return null;
    }
    global static SObject copyFields(SObject source, SObject destination) {
        return null;
    }
    global static Integer countMatches(String str, String sub) {
        return null;
    }
    global static List<SObject> createEmptySObjectList(SObject prototype) {
        return null;
    }
    global static Set<Object> dateToObject(Set<Date> dateSet) {
        return null;
    }
    global static Set<Object> datetimeToObject(Set<Datetime> datetimeSet) {
        return null;
    }
    global static void debugLimits() {

    }
    global static Set<Object> decimalToObject(Set<Decimal> decimalSet) {
        return null;
    }
    global static String defaultIfEmpty(String str, String defaultStr) {
        return null;
    }
    global static String defaultString(String str) {
        return null;
    }
    global static String defaultString(String str, String defaultStr) {
        return null;
    }
    global static String deleteWhitespace(String str) {
        return null;
    }
    global static String difference(String str1, String str2) {
        return null;
    }
    global static Set<Object> doubleToObject(Set<Double> doubleSet) {
        return null;
    }
    global static String encodeVariable(String variable) {
        return null;
    }
    global static Boolean endsWith(String str, String suffix) {
        return null;
    }
    global static Boolean endsWithIgnoreCase(String str, String suffix) {
        return null;
    }
    global static String ensureStringStartsEndsWithChar(String str, String charc) {
        return null;
    }
    global static Boolean equals(String str1, String str2) {
        return null;
    }
    global static Boolean equalsIgnoreCase(String str1, String str2) {
        return null;
    }
    global static Boolean equals(Map<String,String> map1, Map<String,String> map2) {
        return null;
    }
    global static Boolean equals(Set<Blob> b1, Set<Blob> b2) {
        return null;
    }
    global static Boolean equals(Set<Boolean> b1, Set<Boolean> b2) {
        return null;
    }
    global static Boolean equals(Set<Date> d1, Set<Date> d2) {
        return null;
    }
    global static Boolean equals(Set<Datetime> d1, Set<Datetime> d2) {
        return null;
    }
    global static Boolean equals(Set<Decimal> d1, Set<Decimal> d2) {
        return null;
    }
    global static Boolean equals(Set<Double> d1, Set<Double> d2) {
        return null;
    }
    global static Boolean equals(Set<Integer> i1, Set<Integer> i2) {
        return null;
    }
    global static Boolean equals(Set<Long> l1, Set<Long> l2) {
        return null;
    }
    global static Boolean equals(Set<Object> expected, Set<Object> actual) {
        return null;
    }
    global static Boolean equals(Set<String> s1, Set<String> s2) {
        return null;
    }
    global static Boolean equals(Set<Time> t1, Set<Time> t2) {
        return null;
    }
    global static String get(String param) {
        return null;
    }
    global static List<System.SelectOption> getAllLanguageSelectOptions() {
        return null;
    }
    global static List<System.SelectOption> getAllLanguageSelectOptions(String displayLanguageCode) {
        return null;
    }
    global static Map<String,String> getAllLanguages() {
        return null;
    }
    global static Map<String,String> getAllLanguages(String displayLanguageCode) {
        return null;
    }
    global static String getBase(String url) {
        return null;
    }
    global static List<String> getBlankFields(SObject obj, List<String> fields) {
        return null;
    }
    global static String getCommonPrefix(List<String> strs) {
        return null;
    }
    global static Id getCurrentUserPortalAccountID() {
        return null;
    }
    global static List<ApexPages.Message> getErrorMessagesOnly() {
        return null;
    }
    global static List<ApexPages.Message> getErrorMessages() {
        return null;
    }
    global static String getLangCodeByBrowser() {
        return null;
    }
    global static String getLangCodeByBrowserOrIfNullThenHttpParam() {
        return null;
    }
    global static String getLangCodeByBrowserOrIfNullThenUser() {
        return null;
    }
    global static String getLangCodeByHttpParam() {
        return null;
    }
    global static String getLangCodeByHttpParamOrIfNullThenBrowser() {
        return null;
    }
    global static String getLangCodeByHttpParamOrIfNullThenUser() {
        return null;
    }
    global static String getLangCodeByUser() {
        return null;
    }
    global static String getLanguageName(String displayLanguageCode, String languageCode) {
        return null;
    }
    global static Integer getLevenshteinDistance(String s, String t) {
        return null;
    }
    global static List<ApexPages.Message> getMessagesAtLevel(ApexPages.Severity level, Boolean includeParents) {
        return null;
    }
    global static List<SObject> getObject(SObject prototype, Integer count) {
        return null;
    }
    global static List<SObject> getObject(SObject prototype, Integer count, Map<String,String> mString) {
        return null;
    }
    global static List<SObject> getObject(SObject prototype, Integer count, Map<String,String> mString, Boolean doInsert) {
        return null;
    }
    global static Map<String,String> getParameters(String param) {
        return null;
    }
    global static Map<String,String> getParams(String url) {
        return null;
    }
    global static Object getQuietly(SObject sobj, String fieldName) {
        return null;
    }
    global static Integer getType(String character) {
        return null;
    }
    global static Set<Object> idToObject(Set<Id> idSet) {
        return null;
    }
    global static Integer indexOf(String str, String searchStr) {
        return null;
    }
    global static Integer indexOf(String str, String searchStr, Integer startPos) {
        return null;
    }
    global static Integer indexOfAny(String str, String searchChars) {
        return null;
    }
    global static Integer indexOfAnyBut(String str, String searchChars) {
        return null;
    }
    global static Integer indexOfAny(String str, List<String> searchStrs) {
        return null;
    }
    global static Integer indexOfDifference(String str1, String str2) {
        return null;
    }
    global static Integer indexOfDifference(List<String> strs) {
        return null;
    }
    global static String initials(String str) {
        return null;
    }
    global static String initials(String str, List<String> delimiters) {
        return null;
    }
    global static Set<Object> integerToObject(Set<Integer> integerSet) {
        return null;
    }
    global static Boolean isAlpha(String str) {
        return null;
    }
    global static Boolean isAlphaSpace(String str) {
        return null;
    }
    global static Boolean isAlphanumeric(String str) {
        return null;
    }
    global static Boolean isAlphanumericSpace(String str) {
        return null;
    }
    global static Boolean isAnyFieldBlank(SObject obj, List<String> fields) {
        return null;
    }
    global static Boolean isAscii(String character) {
        return null;
    }
    global static Boolean isAsciiAlpha(String character) {
        return null;
    }
    global static Boolean isAsciiAlphaLower(String character) {
        return null;
    }
    global static Boolean isAsciiAlphaUpper(String character) {
        return null;
    }
    global static Boolean isAsciiAlphanumeric(String character) {
        return null;
    }
    global static Boolean isAsciiControl(String character) {
        return null;
    }
    global static Boolean isAsciiNumeric(String character) {
        return null;
    }
    global static Boolean isAsciiPrintable(String character) {
        return null;
    }
    global static Boolean isBlank(String str) {
        return null;
    }
    global static Boolean isCurrentUserPortalUser() {
        return null;
    }
    global static Boolean isCurrentUserSysAdmin() {
        return null;
    }
    global static Boolean isDigit(String character) {
        return null;
    }
    global static Boolean isEmpty(String str) {
        return null;
    }
    global static Boolean isEmpty(List<Object> objectArray) {
        return null;
    }
    global static Boolean isEmpty(List<SObject> objectArray) {
        return null;
    }
    global static Boolean isFalse(Boolean bool) {
        return null;
    }
    global static Boolean isLetter(String character) {
        return null;
    }
    global static Boolean isLetterOrDigit(String character) {
        return null;
    }
    global static Boolean isLowerCase(String character) {
        return null;
    }
    global static Boolean isMessageAtLevelOrHigher(ApexPages.Message message, ApexPages.Severity level) {
        return null;
    }
    global static Boolean isNotBlank(String str) {
        return null;
    }
    global static Boolean isNotEmpty(String str) {
        return null;
    }
    global static Boolean isNotEmpty(List<Object> objectArray) {
        return null;
    }
    global static Boolean isNotEmpty(List<SObject> objectArray) {
        return null;
    }
    global static Boolean isNotFalse(Boolean bool) {
        return null;
    }
    global static Boolean isNotTrue(Boolean bool) {
        return null;
    }
    global static Boolean isNumeric(String str) {
        return null;
    }
    global static Boolean isNumericSpace(String str) {
        return null;
    }
    global static Boolean isTitleCase(String character) {
        return null;
    }
    global static Boolean isTrue(Boolean bool) {
        return null;
    }
    global static Boolean isUpperCase(String character) {
        return null;
    }
    global static Boolean isWhitespace(String character) {
        return null;
    }
    global static String joinArray(List<Object> objectArray) {
        return null;
    }
    global static String joinArray(List<Object> objectArray, String separator) {
        return null;
    }
    global static String joinArray(List<Object> objectArray, String separator, Integer startIndex, Integer endIndex) {
        return null;
    }
    global static String joinMap(Map<String,String> theMap, String keyValueSeparator, String recordSeparator) {
        return null;
    }
    global static String joinSet(Set<Blob> blobSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Boolean> booleanSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Date> dateSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Datetime> datetimeSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Decimal> decimalSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Double> doubleSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Id> idSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Integer> integerSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Long> longSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Object> objectSet, String separator) {
        return null;
    }
    global static String joinSet(Set<String> stringSet, String separator) {
        return null;
    }
    global static String joinSet(Set<Time> timeSet, String separator) {
        return null;
    }
    global static String joinStrings(List<String> strings, String separator) {
        return null;
    }
    global static String joinStrings(Set<String> strings, String separator) {
        return null;
    }
    global static Integer lastIndexOf(String str, String searchStr) {
        return null;
    }
    global static Integer lastIndexOf(String str, String searchStr, Integer startPos) {
        return null;
    }
    global static Integer lastIndexOfAny(String str, List<String> searchStrs) {
        return null;
    }
    global static String left(String str, Integer len) {
        return null;
    }
    global static String leftPad(String str, Integer size) {
        return null;
    }
    global static String leftPad(String str, Integer size, String padStr) {
        return null;
    }
    global static Integer length(String str) {
        return null;
    }
    global static Set<Object> listToSet(List<Object> aList) {
        return null;
    }
    global static Set<String> listToSet(List<String> aList) {
        return null;
    }
    global static Set<Object> longToObject(Set<Long> longSet) {
        return null;
    }
    global static String lowerCase(String str) {
        return null;
    }
    global static List<System.SelectOption> mapToSelectOptions(Map<String,String> theMap) {
        return null;
    }
    global static List<Object> merg(List<Object> list1, List<Object> list2) {
        return null;
    }
    global static List<SObject> merg(List<SObject> list1, List<SObject> list2) {
        return null;
    }
    global static List<Object> mergex(List<Object> array1, List<Object> array2) {
        return null;
    }
    global static List<SObject> mergex(List<SObject> array1, List<SObject> array2) {
        return null;
    }
    global static String messagesToString() {
        return null;
    }
    global static String messagesToString(List<ApexPages.Message> messages) {
        return null;
    }
    global static String mid(String str, Integer pos, Integer len) {
        return null;
    }
    global static Boolean negate(Boolean bool) {
        return null;
    }
    global static Set<Blob> objectToBlob(Set<Object> objectSet) {
        return null;
    }
    global static Set<Boolean> objectToBoolean(Set<Object> objectSet) {
        return null;
    }
    global static Set<Date> objectToDate(Set<Object> objectSet) {
        return null;
    }
    global static Set<Datetime> objectToDatetime(Set<Object> objectSet) {
        return null;
    }
    global static Set<Decimal> objectToDecimal(Set<Object> objectSet) {
        return null;
    }
    global static Set<Double> objectToDouble(Set<Object> objectSet) {
        return null;
    }
    global static Set<Id> objectToID(Set<Object> objectSet) {
        return null;
    }
    global static Set<Integer> objectToInteger(Set<Object> objectSet) {
        return null;
    }
    global static Set<Long> objectToLong(Set<Object> objectSet) {
        return null;
    }
    global static Set<String> objectToString(Set<Object> objectSet) {
        return null;
    }
    global static Set<Time> objectToTime(Set<Object> objectSet) {
        return null;
    }
    global static Integer ordinalIndexOf(String str, String searchStr, Integer ordinal) {
        return null;
    }
    global static String overlay(String str, String overlay, Integer startIndex, Integer endIndex) {
        return null;
    }
    global static String param(String param) {
        return null;
    }
    global static String param(String param, String value) {
        return null;
    }
    global static Integer parseInt(String str, Integer radix) {
        return null;
    }
    global static Long parseLong(String str, Integer radix) {
        return null;
    }
    global static List<Object> pluck(List<SObject> objectArray, String fieldName) {
        return null;
    }
    global static String put(String param, String value) {
        return null;
    }
    global static Object putQuietly(SObject sobj, String fieldName, Object value) {
        return null;
    }
    global static List<Object> qsort(List<Object> theList) {
        return null;
    }
    global static List<Object> qsort(List<Object> theList, Boolean sortAsc) {
        return null;
    }
    global static List<Object> qsort(List<Object> theList, QIDC.ObjectComparator comparator) {
        return null;
    }
    global static List<Object> qsort(List<Object> theList, QIDC.ObjectComparator comparator, Boolean sortAsc) {
        return null;
    }
    global static List<SObject> qsort(List<SObject> theList, QIDC.ISObjectComparator comparator) {
        return null;
    }
    global static List<SObject> qsort(List<SObject> theList, QIDC.ISObjectComparator comparator, Boolean sortAsc) {
        return null;
    }
    global static String random(Integer count) {
        return null;
    }
    global static String random(Integer count, String chars) {
        return null;
    }
    global static String random(Integer count, Boolean letters, Boolean numbers) {
        return null;
    }
    global static String random(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers) {
        return null;
    }
    global static String random(Integer count, Integer startIndex, Integer endIndex, Boolean letters, Boolean numbers, String chars) {
        return null;
    }
    global static String randomAlphabetic(Integer count) {
        return null;
    }
    global static String randomAlphanumeric(Integer count) {
        return null;
    }
    global static String randomAscii(Integer count) {
        return null;
    }
    global static String randomNumeric(Integer count) {
        return null;
    }
    global static String randomUUID() {
        return null;
    }
    global static System.PageReference redirect(String url) {
        return null;
    }
    global static Boolean regionMatches(String str, Integer toffset, String other, Integer ooffset, Integer len) {
        return null;
    }
    global static Boolean regionMatches(String str, Boolean ignoreCase, Integer toffset, String other, Integer ooffset, Integer len) {
        return null;
    }
    global static Boolean regionMatchesIgnoreCase(String str, Integer toffset, String other, Integer ooffset, Integer len) {
        return null;
    }
    global static String remove(String str, String remove) {
        return null;
    }
    global static String removeEnd(String str, String remove) {
        return null;
    }
    global static String removeEndIgnoreCase(String str, String remove) {
        return null;
    }
    global static String removeStart(String str, String remove) {
        return null;
    }
    global static String removeStartIgnoreCase(String str, String remove) {
        return null;
    }
    global static String repeat(String str, Integer repeat) {
        return null;
    }
    global static String replace(String text, String searchString, String replacement) {
        return null;
    }
    global static String replace(String text, String searchString, String replacement, Integer max) {
        return null;
    }
    global static String replaceChars(String str, String searchChars, String replaceChars) {
        return null;
    }
    global static String replaceEachRepeatedly(String text, List<String> searchList, List<String> replacementList, Boolean repeat) {
        return null;
    }
    global static String replaceEach(String text, List<String> searchList, List<String> replacementList) {
        return null;
    }
    global static String replaceEach(String text, List<String> searchList, List<String> replacementList, Boolean repeat, Integer timeToLive) {
        return null;
    }
    global static String replaceOnce(String text, String searchString, String replacement) {
        return null;
    }
    global static String reverse(String str) {
        return null;
    }
    global static String reverseDelimited(String str, String separatorChar) {
        return null;
    }
    global static List<Object> reverse(List<Object> anArray) {
        return null;
    }
    global static List<SObject> reverse(List<SObject> anArray) {
        return null;
    }
    global static String right(String str, Integer len) {
        return null;
    }
    global static String rightPad(String str, Integer size) {
        return null;
    }
    global static String rightPad(String str, Integer size, String padStr) {
        return null;
    }
    global static void sendEmailWithStandardAttachments(List<String> recipients, String emailSubject, String body, Boolean useHTML, List<Attachment> stdAttachments) {

    }
    global static void sendEmailWithStandardAttachments(List<String> recipients, String emailSubject, String body, Boolean useHTML, List<Id> attachmentIDs) {

    }
    global static void sendEmail(List<String> recipients, String emailSubject, String body, Boolean useHTML, List<Messaging.EmailFileAttachment> fileAttachments) {

    }
    global static void sendHTMLEmail(List<String> recipients, String emailSubject, String htmlBody) {

    }
    global static void sendTextEmail(List<String> recipients, String emailSubject, String textBody) {

    }
    global static List<String> setToList(Set<String> aSet) {
        return null;
    }
    global static List<String> splitByCharacterTypeCamelCase(String str) {
        return null;
    }
    global static List<String> splitByCharacterType(String str) {
        return null;
    }
    global static List<String> splitByWholeSeparatorPreserveAllTokens(String str, String separator) {
        return null;
    }
    global static List<String> splitByWholeSeparatorPreserveAllTokens(String str, String separator, Integer max) {
        return null;
    }
    global static List<String> splitByWholeSeparator(String str, String separator) {
        return null;
    }
    global static List<String> splitByWholeSeparator(String str, String separator, Integer max) {
        return null;
    }
    global static List<String> splitPreserveAllTokens(String str) {
        return null;
    }
    global static List<String> splitPreserveAllTokens(String str, String separatorChars) {
        return null;
    }
    global static List<String> splitPreserveAllTokens(String str, String separatorChars, Integer max) {
        return null;
    }
    global static List<String> split(String str) {
        return null;
    }
    global static List<String> split(String str, String separatorChars) {
        return null;
    }
    global static List<String> split(String str, String separatorChars, Integer max) {
        return null;
    }
    global static Boolean startsWith(String str, String prefix) {
        return null;
    }
    global static Boolean startsWithIgnoreCase(String str, String prefix) {
        return null;
    }
    global static Boolean strToBoolean(String value) {
        return null;
    }
    global static Set<Object> stringToObject(Set<String> stringSet) {
        return null;
    }
    global static String strip(String str) {
        return null;
    }
    global static String strip(String str, String stripChars) {
        return null;
    }
    global static List<String> stripAll(List<String> strs) {
        return null;
    }
    global static List<String> stripAll(List<String> strs, String stripChars) {
        return null;
    }
    global static String stripEnd(String str, String stripChars) {
        return null;
    }
    global static String stripStart(String str, String stripChars) {
        return null;
    }
    global static String stripToEmpty(String str) {
        return null;
    }
    global static String stripToNull(String str) {
        return null;
    }
    global static List<Object> subset(List<Object> aList, Integer count) {
        return null;
    }
    global static List<Object> subset(List<Object> list1, Integer startIndex, Integer count) {
        return null;
    }
    global static List<SObject> subset(List<SObject> aList, Integer count) {
        return null;
    }
    global static List<SObject> subset(List<SObject> list1, Integer startIndex, Integer count) {
        return null;
    }
    global static String substring(String str, Integer startIndex) {
        return null;
    }
    global static String substring(String str, Integer startIndex, Integer endIndex) {
        return null;
    }
    global static String substringAfter(String str, String separator) {
        return null;
    }
    global static String substringAfterLast(String str, String separator) {
        return null;
    }
    global static String substringBefore(String str, String separator) {
        return null;
    }
    global static String substringBeforeLast(String str, String separator) {
        return null;
    }
    global static String substringBetween(String str, String tag) {
        return null;
    }
    global static String substringBetween(String str, String open, String close) {
        return null;
    }
    global static List<String> substringsBetween(String str, String open, String close) {
        return null;
    }
    global static String swapCase(String str) {
        return null;
    }
    global static Set<Object> timeToObject(Set<Time> timeSet) {
        return null;
    }
    global static String to18(String the15charID) {
        return null;
    }
    global static Integer toAscii(String character) {
        return null;
    }
    global static String toBinaryString(Integer i) {
        return null;
    }
    global static String toBinaryString(Long l) {
        return null;
    }
    global static Boolean toBoolean(Integer value) {
        return null;
    }
    global static Boolean toBoolean(Integer value, Integer trueValue, Integer falseValue) {
        return null;
    }
    global static Boolean toBooleanDefaultIfNull(Boolean bool, Boolean defaultVal) {
        return null;
    }
    global static String toChar(Integer ascii) {
        return null;
    }
    global static List<String> toCharArray(String str) {
        return null;
    }
    global static String toHexString(Integer i) {
        return null;
    }
    global static String toHexString(Long l) {
        return null;
    }
    global static Integer toInteger(Boolean bool) {
        return null;
    }
    global static String toLowerCase(String ch) {
        return null;
    }
    global static String toOctalString(Integer i) {
        return null;
    }
    global static String toOctalString(Long l) {
        return null;
    }
    global static String toString(SObject obj) {
        return null;
    }
    global static String toString(Integer i, Integer radix) {
        return null;
    }
    global static String toString(Long l, Integer radix) {
        return null;
    }
    global static String toString(Boolean bool, String trueString, String falseString) {
        return null;
    }
    global static String toStringYN(Boolean bool) {
        return null;
    }
    global static String toStringYesNo(Boolean bool) {
        return null;
    }
    global static String toString(List<Object> objectArray) {
        return null;
    }
    global static String toString(List<SObject> objectArray) {
        return null;
    }
    global static String toString(Map<String,String> theMap) {
        return null;
    }
    global static String toString(Set<Blob> blobSet) {
        return null;
    }
    global static String toString(Set<Boolean> booleanSet) {
        return null;
    }
    global static String toString(Set<Date> dateSet) {
        return null;
    }
    global static String toString(Set<Datetime> datetimeSet) {
        return null;
    }
    global static String toString(Set<Decimal> decimalSet) {
        return null;
    }
    global static String toString(Set<Double> doubleSet) {
        return null;
    }
    global static String toString(Set<Id> idSet) {
        return null;
    }
    global static String toString(Set<Integer> integerSet) {
        return null;
    }
    global static String toString(Set<Long> longSet) {
        return null;
    }
    global static String toString(Set<Object> objectSet) {
        return null;
    }
    global static String toString(Set<String> stringSet) {
        return null;
    }
    global static String toString(Set<Time> timeSet) {
        return null;
    }
    global static String toTitleCase(String ch) {
        return null;
    }
    global static String toUpperCase(String ch) {
        return null;
    }
    global static String trim(String str) {
        return null;
    }
    global static List<String> trimAll(List<String> aList) {
        return null;
    }
    global static Set<String> trimAll(Set<String> aList) {
        return null;
    }
    global static String trimToEmpty(String str) {
        return null;
    }
    global static String trimToNull(String str) {
        return null;
    }
    global static String uncapitalize(String str) {
        return null;
    }
    global static String uncapitalize(String str, List<String> delimiters) {
        return null;
    }
    global static String upperCase(String str) {
        return null;
    }
    global static void validateChar(String character) {

    }
    global static String wrap(String str, Integer wrapLength) {
        return null;
    }
    global static String wrap(String str, Integer wrapLength, String newLineStr, Boolean wrapLongWords) {
        return null;
    }
    global static Boolean xor(List<Boolean> boolArray) {
        return null;
    }
}
