@isTest
private class HierarchyModuleAssetsControllerTest {
    private static Modules__c module;
    private static Module_Assets__c mainMA;
	private static Module_Assets__c firstMA;
	private static Module_Assets__c secondMA;
	private static Module_Assets__c singleMA;

	@isTest static void testController() {
		insertMAHierarchy();
		ApexPages.StandardController std_ctrl = new ApexPages.StandardController(module);
		Test.startTest();
			HierarchyModuleAssetsController ctrl = new HierarchyModuleAssetsController(std_ctrl);
		Test.stopTest();
		System.assertEquals(mainMA.Id, ctrl.getWrappers().get(0).ma.Id);

        Integer counter = 0;

		System.assertEquals(ctrl.getWrappers().get(counter).ma.Id, mainMA.Id);
		System.assertEquals(ctrl.getWrappers().get(counter).depth, 0);
        counter++;
		System.assertEquals(ctrl.getWrappers().get(counter).ma.Id, firstMA.Id);
		System.assertEquals(ctrl.getWrappers().get(counter).depth, 1);
        counter++;
        System.assertEquals(ctrl.getWrappers().get(counter).ma.Id, secondMA.Id);
		System.assertEquals(ctrl.getWrappers().get(counter).depth, 2);
		counter++;
		System.assertEquals(ctrl.getWrappers().get(counter).ma.Id, singleMA.Id);
		System.assertEquals(ctrl.getWrappers().get(counter).depth, 0);

		ctrl.sortExpression = 'Name';
		ctrl.sortTable();
		System.assertEquals(ctrl.getWrappers().get(0).ma.Id, singleMA.Id);
		System.assertEquals('DESC', ctrl.getSortDirection());

		ctrl.sortExpression = 'RecordType';
		ctrl.sortTable();
		System.assertEquals(ctrl.getWrappers().get(0).ma.Id, mainMA.Id);
		System.assertEquals('ASC', ctrl.getSortDirection());
		ctrl.sortExpression = 'RecordType';
		ctrl.sortTable();
		System.assertEquals('DESC', ctrl.getSortDirection());

		ctrl.sortExpression = 'Module__c';
		ctrl.sortTable();
		System.assertEquals(ctrl.getWrappers().get(0).ma.Id, mainMA.Id);
		
		ctrl.sortExpression = 'Error Field';
		ctrl.sortTable();
		System.assertEquals(ctrl.getWrappers().get(0).ma.Id, mainMA.Id);
	}

    static testMethod void testControllerErrorWrapper() {
		Modules__c module = new Modules__c(Name = 'Test Module');
		insert module;
		ApexPages.StandardController std_ctrl = new ApexPages.StandardController(module);
		Test.startTest();
			HierarchyModuleAssetsController ctrl = new HierarchyModuleAssetsController(std_ctrl);
		Test.stopTest();
		System.assertEquals(false, ctrl.hasRecords);
        System.assertEquals('No records to display!', ctrl.message);
	}

    private static void insertMAHierarchy() {
        String rt = Schema.SObjectType.Module_Assets__c.getRecordTypeInfosByDeveloperName().get('Module_Standard').getRecordTypeId();

        module = new Modules__c(Name = 'Test Module');
		Modules__c module2 = new Modules__c(Name = 'Test Module2');
        insert new  List<Modules__c>{module, module2};

		mainMA = new Module_Assets__c(Name = 'root', RecordTypeId = rt, Module__c = module.Id);
		insert mainMA;

		firstMA = new Module_Assets__c(Name = 'firstMa', Module_Asset__c = mainMA.Id, RecordTypeId = rt, Module__c = module.Id);
		insert firstMA;
		secondMA = new Module_Assets__c(Name = 'secondMa', Module_Asset__c = firstMA.Id, RecordTypeId = rt, Module__c = module2.Id);
		insert secondMA;

		singleMA = new Module_Assets__c(Name = 'singleMA', RecordTypeId = rt, Module__c = module.Id);
		insert singleMA;
	}
}