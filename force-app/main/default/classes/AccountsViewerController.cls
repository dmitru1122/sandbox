public without sharing class AccountsViewerController {
	private static final String DUE_NOW = 'Due Now';
	private static final String DUE_TOMORROW = 'Due Tomorrow';
	private static final String NEXT_2_DAYS = 'Due in 2 Days';
	private static final String NEXT_3_DAYS = 'Due in 3 Days';
	private static final String NEXT_4_DAYS = 'Due in 4 Days';
	private static final String DUE_FUTURE = 'Due in the Future';
	private static final String UNDEFINED = 'undefined';

	private static final String RECORD_TYPE_SET_COOKIE = 'record_type_set';
	private static final String EMPTY_RECORDS_COOKIE = 'empty_records';
	private static final String PRIMARY_CONTACT_COOKIE = 'primary_contact';
	private static final String MY_ACCOUNT_COOKIE = 'my_account';
	private static final String FILTER_NAME_COOKIE = 'filter';
	private static final String BASED_ON_TYPE_COOKIE = 'based_on';
	private static final String FIELD_SET_COOKIE = 'fieldset';
	private static final String ONLY_ACTIVE_COOKIE = 'only_active';
	private static final String DATE_FIELD_COOKIE = 'date_field';
	private static final String USER_FILTER_COOKIE = 'user_filter';

	private static final String RECORD_TYPE_SET_URL = 'rts';
	private static final String EMPTY_RECORDS_URL = 'er';
	private static final String PRIMARY_CONTACT_URL = 'pc';
	private static final String MY_ACCOUNT_URL = 'ma';
	private static final String FILTER_NAME_URL = 'f';
	private static final String BASED_ON_TYPE_URL = 'bo';
	private static final String FIELD_SET_URL = 'fs';
	private static final String ONLY_ACTIVE_URL = 'oa';
	private static final String DATE_FIELD_URL = 'df';

	private static final String BASED_RECORD_TYPE = 'record_type';
	private static final String BASED_DATE = 'date';
	private static final String BASED_OWNER = 'owner';
	private static final String BASED_IMPLEMENTATION_PHASE = 'implementation_phase';
	
	private final Set<String> excludedFields = new Set<String>{'CreatedDate', 'LastModifiedDate', 'SystemModstamp', 'LastActivityDate', 'LastViewedDate', 'LastReferencedDate'};

	public Map<String, String> recTypes {get; set;}
	private Map<String, AccountsWraper> accountsByTypes;
	private Map<String, List<Account>> allTypesAccounts;
	public String selectedIdType {get; set;}
	public String selectedRTypes {get; set;}
	public Integer pageSize {get; set;}

	public String searchValue {get; set;}
	public Boolean showEmptyTypes {get; set;}
	public Boolean showPrimaryContact {get; set;}
	public Boolean showMyAccounts {get; set;}
	public Boolean activeOnly {get; set;}

	public List<SelectOption> filtersOptions {get; set;}
	public Map<String, RadEx__Filter__c> mapFilters;

	public String selectedFilter {get; set;}
	public Boolean showError {get; set;}

	public String errorMessage {get; set;}

	public String selectedFieldSet {get; set;}
	public List<SelectOption> allFieldSets {get; set;}
	public Map<String, String> setFields {get; set;}
	public List<String> orderedFilds {get; set;}

	public String selectedAccountCard {get; set;}
	public String selectedRecordType {get; set;}
	public String selectedDate {get; set;}

	public Boolean showCards {get; set;}
	public String settings {get; set;}

	public List<SelectOption> presentationOptions {get; set;}
	public String selectedPresentation {get; set;}

	public List<SelectOption> allDateFields {get; set;}
	private Set<String> setDateFields = new Set<String>();
	public String selectedDateField {get; set;}

	public Map<String, String> implementationPhases {get; set;}
	public Map<String, String> ownersIds {get; set;}

	public String selectedUser {get; set;}
	public List<SelectOption> allUsers {get; set;}
	

	public AccountsViewerController() {
		this.selectedPresentation = BASED_RECORD_TYPE;
		this.presentationOptions = getPresentationOptions();
		this.allDateFields = getAllDateFields();
		this.implementationPhases = getPickListValuesPhase();
		this.showCards = false;
		this.accountsByTypes = new Map<String, AccountsWraper>();
		this.allTypesAccounts = new Map<String, List<Account>>();
		this.ownersIds = new Map<String, String>();
		this.countRecordsPerPage = '10';
		this.itemsCounts = getItems();
		this.recTypes = getAllRecordTypes();
		this.filtersOptions = getAccountFilters();
		this.showError = false;
		this.allFieldSets = getOptionsFieldSet();
		this.setFields = new Map<String, String>();
		this.orderedFilds = new List<String>();
		this.allUsers = getOptionsUsers();

		/* getPageParams();
		if(String.isBlank(this.selectedRTypes)) { */
			getPageCookies();
		//}

		if(String.isNotBlank(this.selectedRTypes)) {
			Map<String, String> mapSettings = new Map<String, String>{'recordTypeSet' => this.selectedRTypes,
																	'showEmptyTypes' => String.valueOf(this.showEmptyTypes),
																	'showPrimaryContact' => String.valueOf(this.showPrimaryContact),
																	'showMyAccounts' => String.valueOf(this.showMyAccounts),
																	'activeOnly' => String.valueOf(this.activeOnly),
																	'presentationType' => this.selectedPresentation,
																	'filter' => this.selectedFilter};
			this.settings = JSON.serialize(mapSettings);
			doShowRecords();
			this.showCards = true;
		}
	}

	private void getPageCookies() {
		this.selectedRTypes = ApexPages.currentPage().getCookies().get(RECORD_TYPE_SET_COOKIE) == NULL ? NULL : ApexPages.currentPage().getCookies().get(RECORD_TYPE_SET_COOKIE).getValue();
		this.showEmptyTypes = ApexPages.currentPage().getCookies().get(EMPTY_RECORDS_COOKIE) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getCookies().get(EMPTY_RECORDS_COOKIE).getValue());
		this.showPrimaryContact = ApexPages.currentPage().getCookies().get(PRIMARY_CONTACT_COOKIE) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getCookies().get(PRIMARY_CONTACT_COOKIE).getValue());
		this.showMyAccounts = ApexPages.currentPage().getCookies().get(MY_ACCOUNT_COOKIE) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getCookies().get(MY_ACCOUNT_COOKIE).getValue());
		this.selectedFilter = ApexPages.currentPage().getCookies().get(FILTER_NAME_COOKIE) == NULL ? NULL : ApexPages.currentPage().getCookies().get(FILTER_NAME_COOKIE).getValue();
		this.selectedPresentation = ApexPages.currentPage().getCookies().get(BASED_ON_TYPE_COOKIE) == NULL ? BASED_RECORD_TYPE : ApexPages.currentPage().getCookies().get(BASED_ON_TYPE_COOKIE).getValue();
		this.selectedFieldSet = ApexPages.currentPage().getCookies().get(FIELD_SET_COOKIE) == NULL ? 'none' : ApexPages.currentPage().getCookies().get(FIELD_SET_COOKIE).getValue();
		this.activeOnly = ApexPages.currentPage().getCookies().get(ONLY_ACTIVE_COOKIE) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getCookies().get(ONLY_ACTIVE_COOKIE).getValue());
		this.selectedDateField = ApexPages.currentPage().getCookies().get(DATE_FIELD_COOKIE) == NULL ? NULL : ApexPages.currentPage().getCookies().get(DATE_FIELD_COOKIE).getValue();
		this.selectedUser = ApexPages.currentPage().getCookies().get(USER_FILTER_COOKIE) == NULL ? '' : ApexPages.currentPage().getCookies().get(USER_FILTER_COOKIE).getValue();
	}

	/* private void getPageParams() {
		this.selectedRTypes = ApexPages.currentPage().getParameters().get(RECORD_TYPE_SET_URL) == NULL ? NULL : ApexPages.currentPage().getParameters().get(RECORD_TYPE_SET_URL);
		this.showEmptyTypes = ApexPages.currentPage().getParameters().get(EMPTY_RECORDS_URL) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get(EMPTY_RECORDS_URL));
		this.showPrimaryContact = ApexPages.currentPage().getParameters().get(PRIMARY_CONTACT_URL) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get(PRIMARY_CONTACT_URL));
		this.showMyAccounts = ApexPages.currentPage().getParameters().get(MY_ACCOUNT_URL) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get(MY_ACCOUNT_URL));
		this.selectedFilter = ApexPages.currentPage().getParameters().get(FILTER_NAME_URL) == NULL ? NULL : ApexPages.currentPage().getParameters().get(FILTER_NAME_URL);
		this.selectedPresentation = ApexPages.currentPage().getParameters().get(BASED_ON_TYPE_URL) == NULL ? BASED_RECORD_TYPE : ApexPages.currentPage().getParameters().get(BASED_ON_TYPE_URL);
		this.selectedFieldSet = ApexPages.currentPage().getParameters().get(FIELD_SET_URL) == NULL ? 'none' : ApexPages.currentPage().getParameters().get(FIELD_SET_URL);
		this.activeOnly = ApexPages.currentPage().getParameters().get(ONLY_ACTIVE_URL) == NULL ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get(ONLY_ACTIVE_URL));
		this.selectedDateField = ApexPages.currentPage().getParameters().get(DATE_FIELD_URL) == NULL ? NULL : ApexPages.currentPage().getParameters().get(DATE_FIELD_URL);
	} */

	public List<SelectOption> getOptionsFieldSet() {
		List<SelectOption> optList = new List<SelectOption>();
		List<String> listOfFieldSetApiNames = new List<String>();

		Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(Account.getSObjectType().getDescribe().getName());
		if( sObjType != NULL ) {
			Map<String, Schema.FieldSet> fieldSetNameToItsRecord = sObjType.getDescribe().fieldsets.getMap();
			listOfFieldSetApiNames.addAll( fieldSetNameToItsRecord.keySet() );
		}
		selectedFieldSet = 'none';
		optList.add(new SelectOption(selectedFieldSet, '-- none --'));
		for(String name : listOfFieldSetApiNames) {
			optList.add(new SelectOption(name, sObjType.getDescribe().FieldSets.getMap().get(name).getLabel()));
		}
		return optList;
	}

	public Map<String, String> getAllRecordTypes() {
		Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Account').getDescribe();
		List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
		Map<String, String> rTypes = new Map<String, String>();
		for(Schema.RecordTypeInfo info : recordTypeInfo){
			rTypes.put(info.getRecordTypeId(), info.getName());
		}
		return rTypes;
	}

	public void doShowRecords() {
		this.showError = false;
		List<Object> types = (List<Object>) JSON.deserializeUntyped(selectedRTypes);
		this.accountsByTypes = new Map<String, AccountsWraper>();
		this.allTypesAccounts = new Map<String, List<Account>>();
		List<Account> accs;
		this.setFields.clear();
		this.orderedFilds.clear();
		try {
			if(!types.isEmpty()) {
				if(!this.selectedPresentation.equalsIgnoreCase(BASED_DATE)) {
					accs = getListAccount(types);
				}
				if(this.selectedPresentation.equalsIgnoreCase(BASED_DATE)) {
					getAccountsBasedDate(getListAccount(types));
				} else if(this.selectedPresentation.equalsIgnoreCase(BASED_OWNER)) {
					getAccountsBasedOwner(accs);
				} else if(this.selectedPresentation.equalsIgnoreCase(BASED_IMPLEMENTATION_PHASE)) {
					getAccountsBasedImplementationPhase(accs);
				} else {
					getAccountsBasedRecordTypes(accs, types);
				}
			}
			getOrderedAccounts();
			setPageCookies();
		} catch (Exception e) {
			this.showError = true;
			this.errorMessage = e.getMessage();
		}
	}

	private List<sObject> getListAccount(List<Object> types) {
		List<sObject> accs = new List<sObject>();
		String query = 'Select Id, RecordTypeId, RecordType.Name, Name, Owner.SmallPhotoUrl, Owner.FullPhotoUrl, Owner.Name, Owner.Id, Implementation_Phase__c';
		if(String.isNotBlank(this.selectedDateField)) {
			query += ', ' + this.selectedDateField;
		}

		if(this.showPrimaryContact) {
			query += ', RadEx__Default_Survey_Contact__r.Name, RadEx__Default_Survey_Contact__r.Id, RadEx__Default_Survey_Contact__r.Phone, RadEx__Default_Survey_Contact__r.Email';
		}
		if(this.allFieldSets.size() > 1 && !this.selectedFieldSet.equals('none')) {
			this.orderedFilds = new List<String>();
			String queryFieldSet = '';
			for(Schema.FieldSetMember fieldSetMemberObj : Schema.getGlobalDescribe().get('Account').getDescribe().FieldSets.getMap().get(this.selectedFieldSet).getFields()) {
				if(!fieldSetMemberObj.getFieldPath().equals('Name') 
									&& !fieldSetMemberObj.getFieldPath().equals('RecordTypeId') 
									&& !fieldSetMemberObj.getFieldPath().equals('Id') 
									&& fieldSetMemberObj.getFieldPath() != this.selectedDateField) {
					queryFieldSet += ', ' + fieldSetMemberObj.getFieldPath();

				}
				this.setFields.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel());
				this.orderedFilds.add(fieldSetMemberObj.getFieldPath());
			}
			query += queryFieldSet;
		}
		query += ' FROM Account WHERE RecordTypeId IN (' + listToString(types) + ')';
		if(String.isNotEmpty(searchValue)) {
			query += ' AND Name LIKE \'%' + searchValue + '%\'';
		}
		if(mapFilters.containsKey(selectedFilter)) {
			query += ' AND ' + mapFilters.get(selectedFilter).RadEx__Query_Expression__c;
		}

		if(this.showMyAccounts) {
			Id userId = UserInfo.getUserId();
			query += ' AND OwnerId =: userId';
		} else if(String.isNotBlank(this.selectedUser)) {
			query += ' AND OwnerId =: selectedUser';
		}
		if(this.activeOnly) {
			query += ' AND Active__c = \'Yes\'';
		}

		query += ' ORDER BY Name ' + sortDirection + ' LIMIT 4000';
		accs = Database.query(query);
		return accs;
	}

	private void getAccountsBasedRecordTypes(List<Account> accs, List<Object> types) {
		if(this.showEmptyTypes) {
			for(Object obj : types) {
				this.allTypesAccounts.put(String.valueOf(obj), new List<Account>());
			}
		}
		
		for(Account a : accs) {
			if(!this.allTypesAccounts.containsKey(a.RecordTypeId)) {
				this.allTypesAccounts.put(a.RecordTypeId, new List<Account>());
			}
			this.allTypesAccounts.get(a.RecordTypeId).add(a);
		}
	}

	private void getAccountsBasedDate(List<sObject> accs) {
		if(this.showEmptyTypes) {
			this.allTypesAccounts =  new Map<String, List<Account>>{DUE_NOW => new List<Account>(), 
																	DUE_TOMORROW => new List<Account>(), 
																	NEXT_2_DAYS => new List<Account>(),
																	NEXT_3_DAYS => new List<Account>(),
																	NEXT_4_DAYS => new List<Account>(),
																	DUE_FUTURE => new List<Account>()};
		}
		
		DateTime dtToday = Date.today();
		DateTime dtTomorrow = Date.today().addDays(1);
		DateTime dtNext2Days = Date.today().addDays(2);
		DateTime dtNext3Days = Date.today().addDays(3);
		DateTime dtNext4Days = Date.today().addDays(4);
		List<Account> undefinedDate = new List<Account>();
		for(sObject a : accs) {
			DateTime currentDate = (DateTime)a.get(this.selectedDateField);
			if(currentDate != NULL) {
				if(currentDate <= dtToday) {
					if(!this.allTypesAccounts.containsKey(DUE_NOW)){
						this.allTypesAccounts.put(DUE_NOW, new List<Account>());
					}
					this.allTypesAccounts.get(DUE_NOW).add((Account)a);
				} else if(currentDate == dtTomorrow) {
					if(!this.allTypesAccounts.containsKey(DUE_TOMORROW)) {
						this.allTypesAccounts.put(DUE_TOMORROW, new List<Account>());
					}
					this.allTypesAccounts.get(DUE_TOMORROW).add((Account)a);
				} else if(currentDate == dtNext2Days){
					if(!this.allTypesAccounts.containsKey(NEXT_2_DAYS)) {
						this.allTypesAccounts.put(NEXT_2_DAYS, new List<Account>());
					}
					this.allTypesAccounts.get(NEXT_2_DAYS).add((Account)a);
				} else if(currentDate == dtNext3Days) {
					if(!this.allTypesAccounts.containsKey(NEXT_3_DAYS)) {
						this.allTypesAccounts.put(NEXT_3_DAYS, new List<Account>());
					}
					this.allTypesAccounts.get(NEXT_3_DAYS).add((Account)a);
				} else if(currentDate == dtNext4Days) {
					if(!this.allTypesAccounts.containsKey(NEXT_4_DAYS)) {
						this.allTypesAccounts.put(NEXT_4_DAYS, new List<Account>());
					}
					this.allTypesAccounts.get(NEXT_4_DAYS).add((Account)a);
				} else {
					if(!this.allTypesAccounts.containsKey(DUE_FUTURE)) {
						this.allTypesAccounts.put(DUE_FUTURE, new List<Account>());
					}
					this.allTypesAccounts.get(DUE_FUTURE).add((Account)a);
				}
			}  else {
				undefinedDate.add((Account)a);
			}

			if(!undefinedDate.isEmpty()) {
				this.allTypesAccounts.put(UNDEFINED, undefinedDate);
			}
		}
	}

	private void getAccountsBasedOwner(List<Account> accs) {
		this.ownersIds = new Map<String, String>();
		List<Account> undefinedOwner = new List<Account>();
		for(Account a : accs) {
			if(!this.allTypesAccounts.containsKey(a.Owner.Id) && a.Owner.Id != NULL){
				this.allTypesAccounts.put(a.Owner.Id, new List<Account>());
			}
			
			if(a.Owner.Id == NULL) {
				undefinedOwner.add(a);
			} else {
				this.ownersIds.put(a.Owner.Id, a.Owner.Name);
				this.allTypesAccounts.get(a.Owner.Id).add(a);
			}
		}

		if(!undefinedOwner.isEmpty()) {
			this.ownersIds.put(UNDEFINED, UNDEFINED);
			this.allTypesAccounts.put(UNDEFINED, undefinedOwner);
		}
	}

	private void getAccountsBasedImplementationPhase(List<Account> accs) {
		if(this.showEmptyTypes) {
			for(String phase : this.implementationPhases.keySet()) {
				this.allTypesAccounts.put(phase, new List<Account>());
			}
		}

		List<Account> undefinedPhase = new List<Account>();
		
		for(Account a : accs) {
			if(!this.allTypesAccounts.containsKey(a.Implementation_Phase__c) && String.isNotBlank(a.Implementation_Phase__c)){
				this.allTypesAccounts.put(a.Implementation_Phase__c, new List<Account>());
			} 
			if(String.isNotBlank(a.Implementation_Phase__c)) {
				this.allTypesAccounts.get(a.Implementation_Phase__c).add(a);
			} else {
				undefinedPhase.add(a);
			}
			if(!undefinedPhase.isEmpty()) {
				this.allTypesAccounts.put(UNDEFINED, undefinedPhase);
			}
		}
	}

	private void getOrderedAccounts() {
		this.size = Integer.valueOf(countRecordsPerPage);
		for(String accId : allTypesAccounts.keySet()) {	
			List<Account> curentAccs = new List<Account>();
			Integer endIndex = 0;
			if(!allTypesAccounts.get(accId).isEmpty()) {
				if(allTypesAccounts.get(accId).size() < size && allTypesAccounts.get(accId).size() != 0) {
					endIndex = allTypesAccounts.get(accId).size();
				} else {
					endIndex = size;
				}

				for(Integer i = 0 ; i< endIndex ; i++) {
					curentAccs.add(allTypesAccounts.get(accId).get(i));
				}
			}
			this.accountsByTypes.put(accId, new AccountsWraper(curentAccs, 
																allTypesAccounts.get(accId).size(), 
																getHasNext(size, endIndex, allTypesAccounts.get(accId).size()),
																getHasPrevious(size, 0, allTypesAccounts.get(accId).size()),
																0,
																endIndex));
		}
	}

	public Map<String, AccountsWraper> getAccountRecords() {
		return this.accountsByTypes;
	}

	private String listToString(List<Object> ids) {
		String tmpStr = '';
		Boolean oneParametr = true;
		for (Object rec : ids) {
			if (!oneParametr) {
				tmpStr += ',';
			}
			tmpStr += '\'' + String.valueOf(rec) + '\'';
			oneParametr = false;
		}
		return tmpStr ;
	}

	public PageReference doSearch() {
		doShowRecords();
		return NULL;
	}

	public List<SelectOption> getAccountFilters() {
        filtersOptions = new List<SelectOption>();
        String obj = Account.getSObjectType().getDescribe().getName();
        mapFilters = new Map<String, RadEx__Filter__c>([SELECT Id, Name, RadEx__Query_Expression__c FROM RadEx__Filter__c WHERE RadEx__Object__c =: obj AND RadEx__Point__c = 'AccountCardViewer']);
        filtersOptions.add(new SelectOption('All', 'All'));
        for(RadEx__Filter__c filter : mapFilters.values()) {
            filtersOptions.add(new SelectOption(filter.Id, filter.Name));
        }
        return filtersOptions;
    }

	/* public PageReference doFilterDetail() {
		if(mapFilters.containsKey(selectedFilter)) {
			return new PageReference( '/apex/RadEx__FilterDetail?id=' + selectedFilter + '&retURL=' + getRetURL());
		}
		return NULL;
	} */
 
	public PageReference doChangeCard() {
		String query = 'SELECT Id, RecordTypeId, OwnerId, Implementation_Phase__c';
		if(String.isNotBlank(this.selectedDateField)) {
			query += ', ' + this.selectedDateField;
		}

		query += ' FROM Account WHERE ID =: selectedAccountCard LIMIT 1';
		sObject acc = Database.query(query);
		try {
			if(this.selectedPresentation.equalsIgnoreCase(BASED_DATE)) {
				acc.put(this.selectedDateField, Date.valueOf(this.selectedDate));
			} if(this.selectedPresentation.equalsIgnoreCase(BASED_OWNER)) {
				acc.put('OwnerId',  this.selectedRecordType);
			} else if(this.selectedPresentation.equalsIgnoreCase(BASED_IMPLEMENTATION_PHASE)) {
				acc.put('Implementation_Phase__c', this.implementationPhases.get(this.selectedRecordType));
			} else if(this.selectedPresentation.equalsIgnoreCase(BASED_RECORD_TYPE)) {
				acc.put('RecordTypeId', this.selectedRecordType);
			}
			update acc;
			doShowRecords();
		} catch (Exception e) {
			this.showError = true;
			this.errorMessage = e.getMessage();
		}
		return NULL;
	}

	private void setPageCookies() {
		ApexPages.currentPage().setCookies(new Cookie[]{new Cookie(RECORD_TYPE_SET_COOKIE, selectedRTypes, null, -1, false),
														new Cookie(EMPTY_RECORDS_COOKIE, String.valueOf(showEmptyTypes) , null, -1, false),
														new Cookie(PRIMARY_CONTACT_COOKIE, String.valueOf(showPrimaryContact), null, -1, false),
														new Cookie(MY_ACCOUNT_COOKIE, String.valueOf(showMyAccounts), null, -1, false),
														new Cookie(FILTER_NAME_COOKIE, selectedFilter, null, -1, false),
														new Cookie(BASED_ON_TYPE_COOKIE, selectedPresentation, null, -1, false),
														new Cookie(FIELD_SET_COOKIE, selectedFieldSet, null, -1, false),
														new Cookie(ONLY_ACTIVE_COOKIE, String.valueOf(activeOnly), null, -1, false),
														new Cookie(DATE_FIELD_COOKIE, String.valueOf(selectedDateField), null, -1, false),
														new Cookie(USER_FILTER_COOKIE, selectedUser, null, -1, false)});
	}

	/* public String getRetURL() {
		String retURL = Page.AccountsCardViewer.getUrl() + '?';
		retURL += RECORD_TYPE_SET_URL + '=' + selectedRTypes;
		retURL += '&' + EMPTY_RECORDS_URL + '=' + String.valueOf(showEmptyTypes);
		retURL += '&' + PRIMARY_CONTACT_URL + '=' + String.valueOf(showPrimaryContact);
		retURL += '&' + MY_ACCOUNT_URL + '=' + String.valueOf(showMyAccounts);
		retURL += '&' + FILTER_NAME_URL + '=' + selectedFilter;
		retURL += '&' + BASED_ON_TYPE_URL + '=' + selectedPresentation;
		retURL += '&' + FIELD_SET_URL + '=' + selectedFieldSet;
		retURL += '&' + ONLY_ACTIVE_URL + '=' + String.valueOf(activeOnly);
		retURL += '&' + DATE_FIELD_URL + '=' + String.valueOf(selectedDateField);
		return retURL;
	} */

	public List<SelectOption> getPresentationOptions() {
		List<SelectOption> optList = new List<SelectOption>();

		optList.add(new SelectOption(BASED_RECORD_TYPE, 'RecordType'));
		optList.add(new SelectOption(BASED_DATE, 'Date'));
		optList.add(new SelectOption(BASED_OWNER, 'Owner'));
		optList.add(new SelectOption(BASED_IMPLEMENTATION_PHASE, 'Implementation Phase'));

		return optList;
	}

	public Map<String, String> getPickListValuesPhase(){
       Map<String, String> pickListValuesList= new Map<String, String>();
		Schema.DescribeFieldResult fieldResult = Account.Implementation_Phase__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.put(pickListVal.getLabel(), pickListVal.getValue());
		}     
		return pickListValuesList;
    }

	public List<SelectOption> getAllDateFields() {
		List<SelectOption> optList = new List<SelectOption>();
		optList.add(new SelectOption('', '-- none --'));
		Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
		for(schema.SObjectField field : r.fields.getMap().values()) {
			Schema.DescribeFieldResult dfield = field.getDescribe();
			if((String.valueOf(dfield.getType()).equalsIgnoreCase('DATE') || String.valueOf(dfield.getType()).equalsIgnoreCase('DATETIME')) && !this.excludedFields.contains(String.valueOf(dfield.getName()))) {
				optList.add(new SelectOption(dfield.getName(), dfield.getLabel()));
				this.setDateFields.add(dfield.getName());
			}
		}

		return optLIst;
	}

	private List<SelectOption> getOptionsUsers() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', 'All'));
		for(User usr : [SELECT Id, Name FROM User ORDER BY Name]) {
			options.add(new SelectOption(usr.Id, usr.Name));
		}
		return options;
	}

	/**
	* ****************************
	* * Pagination. *
	* ****************************
	*/
	public Integer size {get;set;}
	public String countRecordsPerPage {get; set;}
	public List<SelectOption> itemsCounts {get; set;}

	private Boolean getHasNext(Integer size, Integer endItem, Integer numberRec) {
		if(numberRec <= size || endItem == numberRec || numberRec == 0) {
			return false;
		} else {
			return true;
		}
	} 
																	
	private Boolean getHasPrevious(Integer size, Integer start, Integer numberRec) {
		if(start == 0 || numberRec == 0) {
			return false;
		} else {
			return true;
		}
	}

	public void previous() {
		if(this.accountsByTypes.get(selectedIdType).hasPrevious) {
			Integer startIndex = this.accountsByTypes.get(selectedIdType).startItem;
			Integer endIndex = this.accountsByTypes.get(selectedIdType).startItem;
			if((startIndex - this.size) > 0) {
				startIndex -= this.size;
			} else {
				startIndex = 0;
			}
			List<Account> curentAccs = new List<Account>();
			for(Integer i = startIndex; i < endIndex; i++) {
				curentAccs.add(allTypesAccounts.get(selectedIdType).get(i));
			}
			this.accountsByTypes.get(selectedIdType).setData(curentAccs,
															getHasNext(this.size, endIndex, this.accountsByTypes.get(selectedIdType).countRecord),
															getHasPrevious(this.size, startIndex, this.accountsByTypes.get(selectedIdType).countRecord),
															startIndex,
															endIndex);
		}
    }

	public void next() {
		if(this.accountsByTypes.get(selectedIdType).hasNext) {
			Integer startIndex = this.accountsByTypes.get(selectedIdType).endItem;
			Integer endIndex = this.accountsByTypes.get(selectedIdType).endItem;
			if((endIndex + this.size) < this.accountsByTypes.get(selectedIdType).countRecord) {
				endIndex += this.size;
			} else {
				endIndex = this.accountsByTypes.get(selectedIdType).countRecord;
			}
			List<Account> curentAccs = new List<Account>();
			for(Integer i = startIndex; i < endIndex; i++) {
				curentAccs.add(allTypesAccounts.get(selectedIdType).get(i));
			}
			this.accountsByTypes.get(selectedIdType).setData(curentAccs,
															getHasNext(this.size, endIndex, this.accountsByTypes.get(selectedIdType).countRecord),
															getHasPrevious(this.size, startIndex, this.accountsByTypes.get(selectedIdType).countRecord),
															startIndex,
															endIndex);
		}
    }

	public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('25','25'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('100','100'));
        return options;
    }

	public String sortDirection = 'ASC';
	public PageReference sortingTable() {
        sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
        doShowRecords();
        return null;
    }

	public class AccountsWraper {
		public List<Account> accounts {get; set;}
		public Integer countRecord {get; set;}
		public Boolean hasNext {get; set;}
		public Boolean hasPrevious {get; set;}
		public Integer startItem {get; set;}
		public Integer endItem {get; set;}

		public AccountsWraper(List<Account> accs, 
								Integer count, 
								Boolean hasNext, 
								Boolean hasPrevious, 
								Integer startItem,
								Integer endItem) {
			this.accounts = accs;
			this.countRecord = count;
			this.hasNext = hasNext;
			this.hasPrevious = hasPrevious;
			this.startItem = startItem;
			this.endItem = endItem;
		}

		public void setData(List<Account> accs, 
								Boolean hasNext, 
								Boolean hasPrevious,
								Integer startItem,
								Integer endItem){
			this.accounts = accs;
			this.hasNext = hasNext;
			this.hasPrevious = hasPrevious;
			this.startItem = startItem;
			this.endItem = endItem;
		}
	}


}