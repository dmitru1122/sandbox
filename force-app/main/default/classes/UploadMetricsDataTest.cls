@isTest
private class  UploadMetricsDataTest {
	@isTest
	static void testSuccessInsert() {

		Account testAc = new Account(
			Name ='Test org', Org_Id__c='a1U0L000006zBn3456',
			RadEx__Inactive__c = false,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId()
		);
		insert testAc;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'POST');
		req.requestUri = '/services/apexrest/MetricsData'; 
		

		CustomerMetricsData.StatisticData DataObject = new CustomerMetricsData.StatisticData();
		DataObject.StartDate = Date.today().addDays(-15);
		DataObject.EndDate =  Date.today();
		DataObject.VersionPackage = '346534';
		DataObject.OrgId = 'a1U0L000006zBn3456';
		DataObject.Risk_Assessment_New = 5;
		DataObject.Program_New = 8;

		DataObject.listDependentObjects = new List<CustomerMetricsData.StatisticDataItem>();

		DataObject.listDependentObjects.add(
			new CustomerMetricsData.StatisticDataItem(Contact.getSObjectType().getDescribe().getLabel(), Contact.getSObjectType().getDescribe().getName(), 11,12,13)
		);
		

		DataObject.listDependentObjects.add(
			new CustomerMetricsData.StatisticDataItem(Account.getSObjectType().getDescribe().getLabel(), Account.getSObjectType().getDescribe().getName(), 21,22,23)
		);

		String jsomRez = JSON.serialize(DataObject);
		req.addParameter('dataReport', jsomRez);
		req.addParameter('typeRequest', 'v1/sendReport');
		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();

			UploadMetricsData.uploadContentPost(jsomRez, 'v1/sendReport');
			UploadMetricsData.uploadContentPost(jsomRez, 'v1/sendReport');

		Test.stopTest();
 
		List<Metrics_Data__c> metricList = [SELECT Id, Account__c, End_Date__c, Start_Date__c FROM Metrics_Data__c ];

		System.assertEquals(1, metricList.size());

		Metrics_Data__c newMetric =  metricList[0].clone(false, false, false, false);
		newMetric.Course_Not_External_Video__c = 1;
		insert newMetric;

		String startDate = String.valueOf(metricList[0].Start_Date__c);
		String EndDate =  String.valueOf(metricList[0].End_Date__c);

		String result = CustomerMetricsData.getOrgMetricData(startDate, EndDate, String.valueOf(metricList[0].Account__c) );
		Map<String, Object> mappingFields = (Map<String, Object>) JSON.deserializeUntyped(result);

		System.assert(mappingFields.containsKey('FIELDS'));
		System.assert(mappingFields.containsKey('DATA_RECORDS'));
		System.assert(mappingFields.containsKey(CustomerMetricsData.STATUS));
	}

	   
	public class FieldWrapper {
		public String FieldName {set; get;}
		public String FieldApiName {set; get;}
	
		
		public FieldWrapper(String name, String apiName) {
			this.FieldName = name;
			this.FieldApiName = apiName; 
		}
	}
}