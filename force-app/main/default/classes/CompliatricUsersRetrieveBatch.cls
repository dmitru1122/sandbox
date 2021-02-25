public with sharing  class CompliatricUsersRetrieveBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	private static final String IDENTIFICATION_FIELD = 'Email';

	public Set<String> Profiles { get {
		return new Set<String> { 'Compliatric Customer', 'Compliatric Start-up Customer' };
	}} 
		
	String query;

	public CompliatricUsersRetrieveBatch(String orgId) { 
		query = 'SELECT Id, Org_Id__c, Compliatric_Users_Retrieve_Last_Update__c, Compliatric_Users_Retrieve_Status__c  FROM Account '; 
		query += ' WHERE RecordType.Name =: Profiles  AND Org_Id__c <> NULL AND Active__c =  \'Yes\'';

		if( String.isNotBlank( orgId ) ) query += '  AND Id =\''  + orgId + '\'' ;
	}
	
	public CompliatricUsersRetrieveBatch() { 
		this('');
	} 
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator( query );
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {

		Map<Id, Account> accountList = new Map<Id, Account>( (List<Account>) scope );

		Set<String> orsIds = new Set<String>();

		for( Account item : accountList.values()) {
			if( String.isNotBlank( item.Org_Id__c )) orsIds.add(item.Org_Id__c);   
		}

		Map<String,AuthorizationDetails__c> mappingDetail = new Map<String,AuthorizationDetails__c>();
		for( AuthorizationDetails__c item : [SELECT Name, RefreshToken__c, InstanceURL__c FROM AuthorizationDetails__c WHERE Name LIKE : orsIds]) mappingDetail.put( item.Name, item );

		Map<Id, List<Map<String, Object>>> mappingResultUsers = new Map<Id, List<Map<String, Object>>>();
		Set<String> usersIdentification = new Set<String>();

		for( Account item : accountList.values()) {
			if( String.isNotBlank( item.Org_Id__c ) && mappingDetail.containsKey( item.Org_Id__c )  ) {
				//System.debug('strrrp 1');
				item.Compliatric_Users_Retrieve_Last_Update__c = Datetime.now();

				Map<String,Object> result = CompliatricUserManagement.getAllUsersFromOrg( item.Org_Id__c, mappingDetail.get( item.Org_Id__c ));
				//System.debug('strrrp 2');
				if( result.containsKey( CompliatricUserManagement.STATUS ) &&
					result.get( CompliatricUserManagement.STATUS ) == CompliatricUserManagement.STATUS_OK &&
					result.containsKey(CompliatricUserManagement.RESULT_REQUEST )) {
					//	System.debug('strrrp 3');
					List<Object> usersList = (List<Object>) result.get( CompliatricUserManagement.RESULT_REQUEST );
					//System.debug('strrrp 4 ' + usersList);
					for( Object itemObject : usersList) {
						Map<String, Object> itemObjectMap = (Map<String, Object>) itemObject;
						//System.debug('strrrp 5 ' + itemObjectMap);
					//	System.debug('strrrp 5-1 ' + itemObjectMap.keySet());
						//System.debug('strrrp 5-2 ' + IDENTIFICATION_FIELD);

						if( itemObjectMap.containsKey( IDENTIFICATION_FIELD ) ) {
						//	System.debug('strrrp 6');
							usersIdentification.add( (String) itemObjectMap.get( IDENTIFICATION_FIELD ) );
							List<Map<String, Object>> mappingUserByAccount = mappingResultUsers.containsKey( item.Id ) ? mappingResultUsers.get( item.Id ) : new List<Map<String, Object>>();
							mappingUserByAccount.add( itemObjectMap );
							mappingResultUsers.put( item.Id,  mappingUserByAccount);
						}
					}
					item.Compliatric_Users_Retrieve_Status__c = 'Success';

				} else  if( result.containsKey(CompliatricUserManagement.STATUS)  && result.get(CompliatricUserManagement.STATUS) == CompliatricUserManagement.STATUS_ERROR ) {

					if( result.containsKey(CompliatricUserManagement.MESSAGE)) {
						System.debug('CompliatricUserManagement.MESSAGE ' + result.get( CompliatricUserManagement.MESSAGE ) );
						Integer classNameLength  = Account.Compliatric_Users_Retrieve_Status__c.getDescribe().getLength();
						String errorMessage = (String)  String.valueOf( result.get( CompliatricUserManagement.MESSAGE) ) ;
						item.Compliatric_Users_Retrieve_Status__c = errorMessage.left( classNameLength );
						item.Compliatric_Users_Retrieve_Last_Update__c = Datetime.now();
					}
				}
			}
		}
		Map<String,Contact> contactMapping = new Map<String,Contact>();
		for( Contact item : [SELECT Id, Name, Email, Title, external_id__c, AccountId, RadEx__Active__c FROM Contact WHERE Email =:usersIdentification]) contactMapping.put( item.Email, item );
		List<Contact> contactsToUpdate = new List<Contact>();
		System.debug('step --*0*- ' + contactMapping.keySet() );
		System.debug('step --**- ' + contactMapping.size() );
		System.debug('step --*1*- ' + mappingResultUsers.size() );
		System.debug('step --*2*- ' + usersIdentification );
		
		for( Id AccountId : mappingResultUsers.keySet() ) {
			List<Map<String, Object>> mappingUserByAccount = mappingResultUsers.get( AccountId );
			System.debug('step 12 ' + mappingUserByAccount);
			for( Map<String, Object> UserWithFields : mappingUserByAccount) {
				System.debug('step 12*1 ' + UserWithFields );
				String IdentificationField = (String) UserWithFields.get( IDENTIFICATION_FIELD );
				System.debug('step 13 ' + IdentificationField );
				IdentificationField.trim().toLowerCase();
				System.debug('step 14 ' + IdentificationField );
				if( contactMapping.containsKey( IdentificationField ) ) {
					System.debug('step 15 ' );
					// existing Contact
					Contact itemContact = contactMapping.get( IdentificationField );
					Boolean isNeedUpdate = false;

					if( UserWithFields.containsKey( 'Name' ) && !itemContact.Name.equalsIgnoreCase( String.valueOf(UserWithFields.get( 'Name' )) ) ) {
						isNeedUpdate = true;
						itemContact.LastName = String.valueOf(UserWithFields.get( 'Name' ));
					}

					String externalId = UserWithFields.containsKey( 'Id' ) ? ( String.valueOf(UserWithFields.get( 'Id' ))) : '';

					if( itemContact.external_id__c == NULL || ( itemContact.external_id__c != NULL && !itemContact.external_id__c.equalsIgnoreCase( externalId ) )) {
						isNeedUpdate = true;
						itemContact.external_id__c = externalId;
					}

					Boolean isActive = UserWithFields.containsKey( 'IsActive' ) ? ( Boolean.valueOf( UserWithFields.get( 'IsActive' ))) : false;

					if( itemContact.RadEx__Active__c != isActive) {
						isNeedUpdate = true;
						itemContact.RadEx__Active__c = isActive;
					}

					if( UserWithFields.containsKey( 'Title' ) && !itemContact.Name.equalsIgnoreCase( String.valueOf(UserWithFields.get( 'Title' )) ) ) {
						isNeedUpdate = true;
						itemContact.Title = String.valueOf(UserWithFields.get( 'Title' ));
					}

					if( UserWithFields.containsKey( 'Email' ) && !itemContact.Email.equalsIgnoreCase( String.valueOf( UserWithFields.get( 'Email' ) )  ) ) {
						isNeedUpdate = true;
						itemContact.Email =  String.valueOf(UserWithFields.get( 'Email' ));
					}

					if( isNeedUpdate ) {
						System.debug('step 16 ' );
						contactsToUpdate.add( itemContact );
					} 


				} else {
					System.debug('step 17 ' + UserWithFields);
					String externalId = UserWithFields.containsKey( 'Id' ) ? ( String.valueOf(UserWithFields.get( 'Id' ))) : '';
					Boolean isActive = UserWithFields.containsKey( 'IsActive' ) ? ( Boolean.valueOf(UserWithFields.get( 'IsActive' ))) : false;

					Contact itemContact = new Contact(
						LastName = String.valueOf(UserWithFields.get( 'Name' )),
						external_id__c = externalId,
						RadEx__Active__c = isActive,
						AccountId = AccountId
					);

					if( UserWithFields.containsKey( 'Title' ) ) itemContact.Title = String.valueOf(UserWithFields.get( 'Title' ));
					
					if( UserWithFields.containsKey( 'Email' ) ) itemContact.Email = String.valueOf(UserWithFields.get( 'Email' ));
					System.debug('step 18 ' + itemContact );	
					contactsToUpdate.add( itemContact );
				}
			}
		}

		upsert contactsToUpdate;
		update accountList.values();
	}

	public void finish(Database.BatchableContext BC) { 

	}


}