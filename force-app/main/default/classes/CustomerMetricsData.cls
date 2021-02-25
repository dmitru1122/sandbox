public with sharing class CustomerMetricsData {
	public static final String STATUS = 'STATUS';
	public static final String ERROR = 'ERROR';

	private static Set<Id> availableAccountRecordTypeIds {
		get {
			return new Set<Id>{
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId(),
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Start_up_Customer').getRecordTypeId()
			};

	}} 
   
	public class StatisticData {
		public Date StartDate {set; get; }
		public Date EndDate {set; get; }
	 	public String VersionPackage {set; get;}
		public String OrgId {set; get;}
		public Integer Employees_New_Activ {set;get;}
		public Integer Employees_Updated_Active {set;get;}
		public Integer COI_New {set;get;}
		public Integer COI_Updated {set;get;}
		public Integer Equipment_New {set;get;}
		public Integer Equipment_Updated {set;get;}
		public Integer Goals_New {set;get;}
		public Integer Goals_Updated {set;get;}
		public Integer Performance_Review_New {set;get;}
		public Integer Performance_Review_Updated {set;get;}
		public Integer Risk_Registry_New {set;get;}
		public Integer Risk_Registry_Updated {set;get;}
		public Integer ROI_New {set;get;}
		public Integer ROI_Updated {set;get;}
		public Integer Risk_Assessment_New {set;get;}
		public Integer Risk_Assessment_Updated {set;get;}
		public Integer Reports_New {set;get;}
		public Integer Reports_Updated {set;get;}
		public Integer Dashboards_New {set;get;}
		public Integer Dashboards_Updated {set;get;}
		public Integer Referral_New {set;get;}
		public Integer Referral_Updated {set;get;}
		public Integer Project_New {set;get;}
		public Integer Project_Updated {set;get;}
		public Integer Program_New {set;get;}
		public Integer Program_Updated {set;get;}
		public Integer Position_New {set;get;}
		public Integer Position_Updated {set;get;}
		public Integer Grant_New {set;get;}
		public Integer Grant_Updated {set;get;}
		public Integer Meetings_New {set;get;}
		public Integer Meetings_Updated  {set;get;}
		public Integer EDU_Session_New {set;get;}
		public Integer EDU_Session_Updated {set;get;}
		public Integer Codes_New {set;get;}
		public Integer Codes_Updated {set;get;}
		public Integer Auditing_New {set;get;}
		public Integer Auditing_Updated {set;get;}
		public Integer Account_New {set;get;}
		public Integer Account_Updated {set;get;}
		public Integer Task_By_Power_User {set;get;}
		public Integer eSignature_New {set;get;}
		public Integer eSignature_Updated  {set;get;}
		public Integer Agreement_Management_New {set;get;}
		public Integer Agreement_Management_Updated {set;get;}
		public Integer Agreement_Management_Expired {set;get;}
		public Integer Course_Slide_Set_New {set;get;}
		public Integer Course_Slide_Set_Updated {set;get;}
		public Integer Course_Slide_Set_Updated_per_External_ID {set;get;}
		public Integer Courses_New {set;get;}
		public Integer Courses_Updated {set;get;}
		public Integer Courses_Non_Assigned {set;get;}
		public Integer Courses_Self_Assignment {set;get;}
		public Integer Courses_Total_Number {set;get;}
		public Integer Course_Not_External_Attachment {set;get;}
		public Integer Course_Not_External_Website {set;get;}
		public Integer Course_Not_External_Policy {set;get;}
		public Integer Course_Not_External_Slide_Set {set;get;}
		public Integer Course_Not_External_Video {set;get;}
		public Integer Course_Assignments_New {set;get;}
		public Integer Course_Assignments_Completion {set;get;}
		public Integer Course_Assignments_Total_Not_Completed  {set;get;}
		public Integer Policy_past_Review_Date {set;get;}
		public Integer Learning_Themes_New {set;get;}
		public Integer Learning_Themes_Updated {set;get;}
		public Integer Contacts_New {set;get;}
		public Integer Contacts_Updated {set;get;}
		public Integer Inciden_New  {set;get;}
		public Integer Incident_Not_Closed {set;get;}
		public Integer Incident_Closed_This_Month {set;get;}
		public Integer Exclusions_Resolved_This_Month {set;get;}
		public Integer Exclusions_All_Time  {set;get;}
		public Integer Account_Business_Associate {set;get;}
		public Integer Account_Business_Associate_with_a_BAA {set;get;}
		public Integer Sms_Twilio_Sent_Messages {set;get;}
		public List<StatisticDataItem> listDependentObjects  {set;get;}
	 

	public Metrics_Data__c getStatisticObject() {
		Metrics_Data__c metric = new Metrics_Data__c();
		metric.Start_Date__c = this.StartDate;
		metric.End_Date__c = this.EndDate;
		metric.Org_Id__c = this.OrgId;
		if(this.VersionPackage  != NULL) metric.Version_Package__c  = this.VersionPackage;
		if(this.Employees_New_Activ  != NULL) metric.Employees_New_Active__c = this.Employees_New_Activ;
		if(this.Employees_Updated_Active  != NULL) metric.Employees_Updated_Active__c = this.Employees_Updated_Active;
		if(this.COI_New  != NULL) metric.COI_New__c = this.COI_New;
		if(this.COI_Updated  != NULL) metric.COI_Updated__c = this.COI_Updated;
		if(this.Equipment_New  != NULL) metric.Equipment_New__c = this.Equipment_New;
		if(this.Equipment_Updated  != NULL) metric.Equipment_Updated__c = this.Equipment_Updated;
		if(this.Goals_New  != NULL) metric.Goals_New__c = this.Goals_New;
		if(this.Goals_Updated  != NULL) metric.Goals_Updated__c = this.Goals_Updated;
		if(this.Performance_Review_New  != NULL) metric.Performance_Review_New__c = this.Performance_Review_New;
		if(this.Performance_Review_Updated  != NULL) metric.Performance_Review_Updated__c = this.Performance_Review_Updated;
		if(this.Risk_Registry_New  != NULL) metric.Risk_Registry_New__c = this.Risk_Registry_New;
		if(this.Risk_Registry_Updated  != NULL) metric.Risk_Registry_Updated__c = this.Risk_Registry_Updated;
		if(this.ROI_New  != NULL) metric.ROI_New__c = this.ROI_New;
		if(this.ROI_Updated  != NULL) metric.ROI_Updated__c = this.ROI_Updated;
		if(this.Risk_Assessment_New  != NULL) metric.Risk_Assessment_New__c = this.Risk_Assessment_New;
		if(this.Risk_Assessment_Updated  != NULL) metric.Risk_Assessment_Updated__c = this.Risk_Assessment_Updated;
		if(this.Reports_New  != NULL) metric.Reports_New__c = this.Reports_New;
		if(this.Reports_Updated  != NULL) metric.Reports_Updated__c = this.Reports_Updated;
		if(this.Dashboards_New  != NULL) metric.Dashboards_New__c = this.Dashboards_New;
		if(this.Dashboards_Updated  != NULL) metric.Dashboards_Updated__c = this.Dashboards_Updated;
		if(this.Referral_New  != NULL) metric.Referral_New__c = this.Referral_New;
		if(this.Referral_Updated  != NULL) metric.Referral_Updated__c = this.Referral_Updated;
		if(this.Project_New  != NULL) metric.Project_New__c = this.Project_New;
		if(this.Project_Updated  != NULL) metric.Project_Updated__c = this.Project_Updated;
		if(this.Program_New  != NULL) metric.Program_New__c = this.Program_New;
		if(this.Program_Updated  != NULL) metric.Program_Updated__c = this.Program_Updated;
		if(this.Position_New  != NULL) metric.Position_New__c = this.Position_New;
		if(this.Position_Updated  != NULL) metric.Position_Updated__c = this.Position_Updated;
		if(this.Grant_New  != NULL) metric.Grant_New__c = this.Grant_New;
		if(this.Grant_Updated != NULL) metric.Grant_Updated__c = this.Grant_Updated;
		if(this.Meetings_New  != NULL) metric.Meetings_New__c = this.Meetings_New;
		if(this.Meetings_Updated   != NULL) metric.Meetings_Updated__c = this.Meetings_Updated;
		if(this.EDU_Session_New  != NULL) metric.EDU_Session_New__c = this.EDU_Session_New;
		if(this.EDU_Session_Updated  != NULL) metric.EDU_Session_Updated__c = this.EDU_Session_Updated;
		if(this.Codes_New  != NULL) metric.Codes_New__c = this.Codes_New;
		if(this.Codes_Updated  != NULL) metric.Codes_Updated__c = this.Codes_Updated;
		if(this.Auditing_New  != NULL) metric.Auditing_New__c = this.Auditing_New;
		if(this.Auditing_Updated  != NULL) metric.Auditing_Updated__c = this.Auditing_Updated;
		if(this.Account_New  != NULL) metric.Account_New__c = this.Account_New;
		if(this.Account_Updated  != NULL) metric.Account_Updated__c = this.Account_Updated;
		if(this.Task_By_Power_User  != NULL) metric.Task_By_Power_User__c = this.Task_By_Power_User;
		if(this.eSignature_New  != NULL) metric.eSignature_New__c = this.eSignature_New;
		if(this.eSignature_Updated   != NULL) metric.eSignature_Updated__c = this.eSignature_Updated;
		if(this.Agreement_Management_New  != NULL) metric.Agreement_Management_New__c = this.Agreement_Management_New;
		if(this.Agreement_Management_Updated  != NULL) metric.Agreement_Management_Updated__c = this.Agreement_Management_Updated;
		if(this.Agreement_Management_Expired  != NULL) metric.Agreement_Management_Expired__c = this.Agreement_Management_Expired;
		if(this.Course_Slide_Set_New  != NULL) metric.Course_Slide_Set_New__c = this.Course_Slide_Set_New;
		if(this.Course_Slide_Set_Updated  != NULL) metric.Course_Slide_Set_Updated__c = this.Course_Slide_Set_Updated;
		if(this.Course_Slide_Set_Updated_per_External_ID  != NULL) metric.Course_Slide_Set_Updated_per_External_ID__c = this.Course_Slide_Set_Updated_per_External_ID;
		if(this.Courses_New  != NULL) metric.Courses_New__c = this.Courses_New;
		if(this.Courses_Updated  != NULL) metric.Courses_Updated__c = this.Courses_Updated;
		if(this.Courses_Non_Assigned  != NULL) metric.Courses_Non_Assigned__c = this.Courses_Non_Assigned;
		if(this.Courses_Self_Assignment  != NULL) metric.Courses_Self_Assignment__c = this.Courses_Self_Assignment;
		if(this.Courses_Total_Number  != NULL) metric.Courses_Total_Number__c = this.Courses_Total_Number;
		if(this.Course_Not_External_Attachment  != NULL) metric.Course_Not_External_Attachment__c = this.Course_Not_External_Attachment;
		if(this.Course_Not_External_Website  != NULL) metric.Course_Not_External_Website__c = this.Course_Not_External_Website;
		if(this.Course_Not_External_Policy  != NULL) metric.Course_Not_External_Policy__c = this.Course_Not_External_Policy;
		if(this.Course_Not_External_Slide_Set  != NULL) metric.Course_Not_External_Slide_Set__c = this.Course_Not_External_Slide_Set;
		if(this.Course_Not_External_Video  != NULL) metric.Course_Not_External_Video__c = this.Course_Not_External_Video;
		if(this.Course_Assignments_New  != NULL) metric.Course_Assignments_New__c = this.Course_Assignments_New;
		if(this.Course_Assignments_Completion  != NULL) metric.Course_Assignments_Completion__c = this.Course_Assignments_Completion;
		if(this.Course_Assignments_Total_Not_Completed   != NULL) metric.Course_Assignments_Total_Not_Completed__c = this.Course_Assignments_Total_Not_Completed;
		if(this.Policy_past_Review_Date  != NULL) metric.Policy_past_Review_Date__c = this.Policy_past_Review_Date;
		if(this.Learning_Themes_New  != NULL) metric.Learning_Themes_New__c = this.Learning_Themes_New;
		if(this.Learning_Themes_Updated  != NULL) metric.Learning_Themes_Updated__c = this.Learning_Themes_Updated;
		if(this.Contacts_New  != NULL) metric.Contacts_New__c = this.Contacts_New;
		if(this.Contacts_Updated  != NULL) metric.Contacts_Updated__c = this.Contacts_Updated;
		if(this.Inciden_New   != NULL) metric.Inciden_New__c = this.Inciden_New;
		if(this.Incident_Not_Closed  != NULL) metric.Incident_Not_Closed__c = this.Incident_Not_Closed;
		if(this.Incident_Closed_This_Month  != NULL) metric.Incident_Closed_This_Month__c = this.Incident_Closed_This_Month;
		if(this.Exclusions_Resolved_This_Month  != NULL) metric.Exclusions_Resolved_This_Month__c = this.Exclusions_Resolved_This_Month;
		if(this.Exclusions_All_Time   != NULL) metric.Exclusions_All_Time__c = this.Exclusions_All_Time;
		if(this.Account_Business_Associate  != NULL) metric.Account_Business_Associate__c = this.Account_Business_Associate;
		if(this.Account_Business_Associate_with_a_BAA  != NULL) metric.Account_Business_Associate_with_a_BAA__c = this.Account_Business_Associate_with_a_BAA;
		if(this.Sms_Twilio_Sent_Messages != NULL) metric.Sms_Twilio_Sent_Messages__c = this.Sms_Twilio_Sent_Messages;

		return metric;
	}
}

	public class StatisticDataItem {
		public String ObjectLabel {set;get;}
		public String ObjectApiName {set;get;}
		public Integer ActionView {set;get;}
		public Integer ActionCreate {set;get;}
		public Integer ActionEdit {set;get;}
		public Integer NumberOfObjects {set;get;}
		public String Description {set;get;}
		
		public StatisticDataItem(String label, String NameObject, Integer view, Integer create, Integer edit) {
			this.ObjectLabel = label;
			this.ObjectApiName = NameObject;
			this.ActionView = view;
			this.ActionCreate = create;
			this.ActionEdit = edit;
		}
	}


	public class FieldWrapper {
		public String FieldName {set; get;}
		public String FieldApiName {set; get;}
		public String FieldType {set; get;}

		
		public FieldWrapper(String name, String apiName, String type) {
			this.FieldName = name;
			this.FieldApiName = apiName; 
			this.FieldType = type; 
		}
	}

	public static List<Metrics_Data_Item__c> prepareStatisticItems( Id metricId, List<StatisticDataItem> listItems, List<Metrics_Data_Item__c> existingMetricItems ) {

		Map<String,Id> mappintExistingMetrics = new Map<String,Id>();

		if( existingMetricItems != NULL ) {
			for( Metrics_Data_Item__c item : existingMetricItems ) {
				if(String.isNotBlank(item.Object_Api_Name__c)) mappintExistingMetrics.put(item.Object_Api_Name__c, item.Id);
			}
		}

		List<Metrics_Data_Item__c> resiltList = new List<Metrics_Data_Item__c>();
		if( metricId == NULL || listItems == NULL ) return resiltList;

		for( StatisticDataItem item : listItems ) {

			resiltList.add( new Metrics_Data_Item__c(
				Metrics_Data__c = metricId,
				Object_Api_Name__c = item.ObjectApiName,
				Object_Label__c = item.ObjectLabel,
				Action_Create__c = item.ActionCreate,
				Action_Edit__c  = item.ActionEdit,
				Action_View__c = item.ActionView,
				Description__c = String.isNotBlank(item.Description)  ? item.Description.left(249) : '',
				Number_Of_Objects__c =  item.NumberOfObjects != NULL ? item.NumberOfObjects : 0,
				Id = mappintExistingMetrics.containsKey(item.ObjectApiName) ? mappintExistingMetrics.get(item.ObjectApiName) : NULL
			));
		}

		return resiltList;
	}


	@AuraEnabled(Cacheable=true)
	public static String getOrgMetricData(String startDate, String EndDate, String account) {
		Map<String,Object> result = new Map<String,Object>();
		List<FieldWrapper> filedWrapperList = new List<FieldWrapper>();

		result.put(STATUS, false);
		if(String.isBlank(startDate) || String.isBlank(EndDate)) result.put(ERROR, 'Date is Empty');

		try {
			Date startDateCompleted = Date.valueOf(startDate.removeEnd('T'));
			Date EndDateCompleted = Date.valueOf(EndDate.removeEnd('T'));

			List<Schema.FieldSetMember> listItems = SObjectType.Metrics_Data__c.FieldSets.Home_Page_Fields.getFields();
			Set<String> onlyFields = new Set<String>();

			for(Schema.FieldSetMember item : listItems) {
				String patch = item.getFieldPath();
				if(!patch.equalsIgnoreCase('ConnectionSentId') && !patch.equalsIgnoreCase('ConnectionReceivedId') && !patch.equalsIgnoreCase('RecordTypeId')) {
					filedWrapperList.add(new FieldWrapper(item.getLabel(), patch, String.valueOf(item.getType())));
					onlyFields.add(patch);
				}
			}

			onlyFields.add('Id');
			onlyFields.add('Account__c');
			onlyFields.add('Account__r.Name');

			String soqlQuery = 'SELECT ';
			soqlQuery += String.join(  new List<String>(onlyFields), ', ');
			soqlQuery += ' FROM Metrics_Data__c WHERE Start_Date__c >= ' + String.valueOf(startDateCompleted) + ' AND End_Date__c <= ' + String.valueOf(EndDateCompleted) + ' ';
			if(String.isNotBlank(account)) soqlQuery += ' AND Account__c =\'' + account + '\'';

			soqlQuery += ' AND Account__r.RecordTypeId IN: availableAccountRecordTypeIds';
			
			List<Metrics_Data__c> metricList  = Database.query(soqlQuery);

			Map<String, Metrics_Data__c> metricMapping = new Map<String, Metrics_Data__c>();
			for(Metrics_Data__c item : metricList) {
				if(item.Account__c != NULL) {
					Metrics_Data__c itemTmp = item;
			
					// is Record with this account already exist in map 
					if(metricMapping.containsKey(item.Account__c)) {
						itemTmp = metricMapping.get(item.Account__c);

						for(FieldWrapper itemField : filedWrapperList) {
							if(itemField.FieldType.containsIgnoreCase('DOUBLE')) {
								// get value another record this account 
								if(item.get(itemField.FieldApiName) != NULL && itemTmp.get(itemField.FieldApiName) != NULL) {
									Integer fieldIntegerResultNew = Integer.valueOf(item.get(itemField.FieldApiName));
									Integer fieldIntegerResultOld = Integer.valueOf(itemTmp.get(itemField.FieldApiName));
									Integer fieldResult = fieldIntegerResultNew + fieldIntegerResultOld;
									itemTmp.put(itemField.FieldApiName, fieldResult);
								}
							}
						}
					} 
					metricMapping.put(item.Account__c, itemTmp);
				}
			}
			result.put('DATA_RECORDS', metricMapping.values());
			result.put(STATUS, true);
			result.put('FIELDS', filedWrapperList);
		} catch (Exception e) { result.put(ERROR, e.getMessage());	}

		return  JSON.serialize(result);
	}




}