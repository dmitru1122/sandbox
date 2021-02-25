@RestResource(urlMapping='/MetricsData/*')
global with sharing class UploadMetricsData {
	private static final String STATUS_OK ='OK';
	private static final String STATUS = 'StatusInfo';
	private static final String MESSAGE = 'MessageInfo';
	private static final String STATUS_ERROR ='ERROR';

	private static Set<Id> availableAccountRecordTypeIds {
		get {
			return new Set<Id>{
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId(),
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Start_up_Customer').getRecordTypeId()
			};
	}}


	@HttpPost
	global static String uploadContentPost(String dataReport, String typeRequest) {

		if(String.isBlank(typeRequest)) return '';

		Map<String, Object> response = new Map<String, Object>();
		
		if(typeRequest.containsIgnoreCase('v1/sendReport') && String.isNotBlank(dataReport)) {

			try {
				CustomerMetricsData.StatisticData DataObject = (CustomerMetricsData.StatisticData) JSON.deserialize(dataReport, CustomerMetricsData.StatisticData.class);
			
				if(DataObject != NULL && String.isNotBlank(DataObject.OrgId)) {

					String shortId = DataObject.OrgId.left(15) + '%';

					List<Account> acclist = [
					    SELECT Id, RecordTypeId, RecordType.DeveloperName
					    FROM Account
					    WHERE Org_Id__c LIKE :shortId 
					    AND RadEx__Inactive__c = false
					    AND RecordTypeId=: availableAccountRecordTypeIds
					    LIMIT 1
					];
					
					if(!acclist.isEmpty() && String.isNotBlank(DataObject.OrgId) && DataObject.StartDate != NULL && DataObject.EndDate != NULL) {
						Metrics_Data__c externalStatistic = DataObject.getStatisticObject();
                        
                        List<Metrics_Data__c> existMetric = [
							SELECT Id , End_Date__c,
							(
								SELECT Id, Action_Create__c, Action_Edit__c, Action_View__c, Metrics_Data__c, Object_Api_Name__c, Object_Label__c
								FROM Metrics_Data_Items__r
							)
							FROM Metrics_Data__c
							WHERE Start_Date__c =: externalStatistic.Start_Date__c
							AND Org_Id__c =: externalStatistic.Org_Id__c
							AND Account__c =: acclist[0].Id
						    LIMIT 1
						];

						if(existMetric.isEmpty()) {
							externalStatistic.Account__c = acclist[0].Id;
							insert externalStatistic;

							if(DataObject.listDependentObjects != NULL && !DataObject.listDependentObjects.isEmpty()) {
								List<Metrics_Data_Item__c> metricItemsObject = CustomerMetricsData.prepareStatisticItems(
									externalStatistic.Id, DataObject.listDependentObjects, new List<Metrics_Data_Item__c>()
								);
								insert metricItemsObject;
							}
							
						} else {

							if(existMetric[0].End_Date__c <= externalStatistic.End_Date__c ) {
								externalStatistic.Id = existMetric[0].Id;
								update externalStatistic;

								List<Metrics_Data_Item__c> metricItemsObject = CustomerMetricsData.prepareStatisticItems(
									externalStatistic.Id, DataObject.listDependentObjects, existMetric[0].Metrics_Data_Items__r
								);

								Database.upsert(metricItemsObject, false);
							}
						}
					}
				}
				response.put(STATUS, 'OK');

			} catch (Exception e) {		response.put(STATUS, STATUS_ERROR);	response.put(MESSAGE, e.getMessage() + ' ' + e.getLineNumber()); }

		} 
		return JSON.serialize(response);
	}
}