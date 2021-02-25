@isTest
public with sharing class LightningModulsHelperTest {


	@testSetup static void setup() {
		List<Modules__c> listOfModules = new List<Modules__c>();

		listOfModules.add(new Modules__c(Lightning_URL__c ='https://docs.google.com/document/d/1W4zF2pk-VXnKlERt4SwfLfeICI-m2-iFXMbHqXLfoVo/edit'));
		listOfModules.add(new Modules__c(Lightning_URL__c ='https://drive.google.com/file/d/0B7Jl48FU_VqmaHhERlZOd1QyOHc/preview'));
		listOfModules.add(new Modules__c(Lightning_URL__c ='pararam 3'));
		listOfModules.add(new Modules__c(Lightning_URL__c ='pararam 4'));

		insert listOfModules;

		List<Module_Documenation__c> documentationList = new List<Module_Documenation__c>();

		documentationList.add(new Module_Documenation__c( 
			Document_Summary__c = '<p>rrr</p>',
			Module__c = listOfModules[0].Id,
			Document_Status__c = 'Active/Published',
			Published_URL__c = 'https://docs.google.com/document/d/1W4zF2pk-VXnKlERt4SwfLfeICI-m2-iFXMbHqXLfoVo/edit'
		));

		documentationList.add(new Module_Documenation__c(
			Document_Summary__c = '<p>www</p>',
			Module__c = listOfModules[0].Id,
			Document_Status__c = 'Active/Published',
			Published_URL__c = 'https://drive.google.com/file/d/0B7Jl48FU_VqmaHhERlZOd1QyOHc/preview'
		));

		documentationList.add(new Module_Documenation__c(
			Document_Summary__c = '<p>mmm</p>',
			Module__c = listOfModules[1].Id,
			Document_Status__c = 'Active/Published',
			Published_URL__c = 'https://docs.google.com/document/d/e/2PACX-1vQAL6kJrrAFwxMWyXmXGKrUlBY31Q9cJwW9bxuD1w_asgGirXbgNf23h18GS-KPlAugp1IHMCRsQ64n/pub?embedded=true'
		));

		documentationList.add(new Module_Documenation__c(
			Document_Summary__c = '<p>ttt</p>',
			Module__c = listOfModules[1].Id,
			Document_Status__c = 'Active/Published',
			Published_URL__c = 'https://docs.google.com/document/d/e/2PACX-1vQ1jX_INAbdg7KwBKeys_Relfh4XQdYNCY_J8ASyz_W9u1IWiCnQs-Luwrqk0WCcU0_s2l4S1H-uNRf/pub?embedded=true'
		));

		insert documentationList;

		List<Compliatric_Package_Version__c> listOfPackageVersions = new List<Compliatric_Package_Version__c>();

		listOfPackageVersions.add(new Compliatric_Package_Version__c(Name='v196.7', Release_Date__c = Date.newInstance(2020,1,1)));
		listOfPackageVersions.add(new Compliatric_Package_Version__c(Name='v196.8', Release_Date__c = Date.newInstance(2020,2,1)));
		listOfPackageVersions.add(new Compliatric_Package_Version__c(Name='v194.7', Release_Date__c = Date.newInstance(2019,12,1)));
		listOfPackageVersions.add(new Compliatric_Package_Version__c(Name='v193.1', Release_Date__c = Date.newInstance(2019,11,1)));

		insert listOfPackageVersions;

		List<RecordType> listOfRecordType = [SELECT Id, Name from RecordType];

		List<Product_Development__c> listOfProductDevelopment = new List<Product_Development__c>();

		listOfProductDevelopment.add(new Product_Development__c(
				Development_Title__c = 'Title 1',
				Release_Note_Subject__c = 'Release Note Subject 1',
				Release_Note__c='Release Note Info 1',
				Customer_Facing__c = true,
				Package_Version__c = listOfPackageVersions[0].Id,
				Associated_Module__c = listOfModules[0].Id, RecordType = listOfRecordType[0]));

		listOfProductDevelopment.add(new Product_Development__c(
				Development_Title__c = 'Title 2',
				Release_Note_Subject__c = 'Release Note Subject 2',
				Release_Note__c='Release Note Info 2',
				Customer_Facing__c = true,
				Package_Version__c = listOfPackageVersions[1].Id,
				Associated_Module__c = listOfModules[1].Id, RecordType = listOfRecordType[1]));

		listOfProductDevelopment.add(new Product_Development__c(
				Development_Title__c = 'Title 3',
				Release_Note_Subject__c = 'Release Note Subject 3',
				Release_Note__c='Release Note Info 3',
				Customer_Facing__c = true,
				Package_Version__c = listOfPackageVersions[2].Id,
				Associated_Module__c = listOfModules[0].Id, RecordType = listOfRecordType[0]));

		listOfProductDevelopment.add(new Product_Development__c(
				Development_Title__c = 'Title 4',
				Release_Note_Subject__c = 'Release Note Subject 4',
				Release_Note__c='Release Note Info 4',
				Customer_Facing__c = false,
				Package_Version__c = listOfPackageVersions[3].Id,
				Associated_Module__c = listOfModules[3].Id, RecordType = listOfRecordType[1]));

		insert listOfProductDevelopment;
	}

	@isTest 
	static void testSuccess() {
		String JsonMiduleResult = LightningModulsHelper.getModules();
		List<LightningModulsHelper.ModuleWrapper> listOfModules = (List<LightningModulsHelper.ModuleWrapper>) JSON.deserialize(JsonMiduleResult, List<LightningModulsHelper.ModuleWrapper>.class);

		System.assertEquals( 2, listOfModules.size() );


		List<Module_Documenation__c> DocumentFirstModule = LightningModulsHelper.getModuleDocumentationList(String.valueOf(listOfModules[0].modul.Id));
		List<Module_Documenation__c> DocumentSecondModule = LightningModulsHelper.getModuleDocumentationList(String.valueOf(listOfModules[1].modul.Id));

		System.assertEquals( 2, DocumentFirstModule.size() );
		System.assertEquals( 2, DocumentSecondModule.size() );

	}

	@isTest
	static void testReleaseNoteSuccess() {

		String JsonReleaseNoteResult = LightningModulsHelper.getModuleReleaseNotes();

		List<LightningModulsHelper.ModuleReleaseNotesWrapper> listOfReleaseNotes = (List<LightningModulsHelper.ModuleReleaseNotesWrapper>) JSON.deserialize(JsonReleaseNoteResult, List<LightningModulsHelper.ModuleReleaseNotesWrapper>.class);

		System.assertEquals(2, listOfReleaseNotes.size());

		System.assertEquals(1, listOfReleaseNotes[0].releaseNoteWrappers.size());
		
		System.assertEquals(2, listOfReleaseNotes[1].releaseNoteWrappers.size());
	}
}