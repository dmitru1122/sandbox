@isTest
private class ModuleAssetsHierarchyControllerTest {
    private static Module_Assets__c mainMA;
	private static Module_Assets__c leftMA;
	private static Module_Assets__c rightMA;

	@isTest static void testController() {
		insertMAHierarchy();
		ApexPages.StandardController std_ctrl = new ApexPages.StandardController(mainMA);
		Test.startTest();
			ModuleAssetsHierarchyController ctrl = new ModuleAssetsHierarchyController(std_ctrl);
		Test.stopTest();
		System.assertEquals(mainMA.Id, ctrl.wrappers.get(0).ma.Id);

        Integer counter = 0;

		System.assertEquals(ctrl.wrappers.get(counter).ma.Id, mainMA.Id);
		System.assertEquals(ctrl.wrappers.get(counter).depth, 0);
        counter++;
		System.assertEquals(ctrl.wrappers.get(counter).ma.Id, leftMA.Id);
		System.assertEquals(ctrl.wrappers.get(counter).depth, 1);
        counter++;
        System.assertEquals(ctrl.wrappers.get(counter).ma.Id, rightMA.Id);
		System.assertEquals(ctrl.wrappers.get(counter).depth, 1);
	}

	static testMethod void testControllerEmptyWrapper() {
        String rt = Schema.SObjectType.Module_Assets__c.getRecordTypeInfosByDeveloperName().get('Module_Standard').getRecordTypeId();
		mainMA = new Module_Assets__c(Name = 'Root', RecordTypeId = rt);
		insert mainMA;
		ApexPages.StandardController std_ctrl = new ApexPages.StandardController(mainMA);
		
		Test.startTest();
			ModuleAssetsHierarchyController ctrl = new ModuleAssetsHierarchyController(std_ctrl);
		Test.stopTest();
		System.assertEquals(mainMA.Id, ctrl.wrappers.get(0).ma.Id);
	}

    static testMethod void testControllerErrorWrapper() {
		Module_Assets__c mainMA = new Module_Assets__c(Name = 'Root');
		ApexPages.StandardController std_ctrl = new ApexPages.StandardController(mainMA);
		Test.startTest();
			ModuleAssetsHierarchyController ctrl = new ModuleAssetsHierarchyController(std_ctrl);
		Test.stopTest();
		System.assertEquals(false, ctrl.hasRecords);
        System.assertEquals('No records to display!', ctrl.message);
	}

    private static void insertMAHierarchy() {
        String rt = Schema.SObjectType.Module_Assets__c.getRecordTypeInfosByDeveloperName().get('Module_Standard').getRecordTypeId();

		mainMA = new Module_Assets__c(Name = 'root', RecordTypeId = rt);
		insert mainMA;

		leftMA = new Module_Assets__c(Name = 'leftAcc', Module_Asset__c = mainMA.Id, RecordTypeId = rt);
		rightMA = new Module_Assets__c(Name = 'rightAcc', Module_Asset__c = mainMA.Id, RecordTypeId = rt);
		insert new List<Module_Assets__c> {leftMA, rightMA};
	}
}