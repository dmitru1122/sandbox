public with sharing class LightningModulsHelper {

	@AuraEnabled(Cacheable=true)
	public static String getModules() {
	   
		List<ModuleWrapper> listOfModules = new List<ModuleWrapper>();
		for(Modules__c item : [SELECT Id, Name, Lightning_URL__c FROM Modules__c WHERE Id IN (SELECT Module__c FROM Module_Documenation__c)  ORDER BY Name]) listOfModules.add(new ModuleWrapper(item));
		return JSON.serialize(listOfModules);
	}

	@AuraEnabled(Cacheable=true)
	public static List<Module_Documenation__c> getModuleDocumentationList(String moduleId) {

		List<Module_Documenation__c> docum =  [
			SELECT Id, Name, Documentation_Type__c, Document_Key_Words__c, Document_Status__c, Document_Summary__c, Document_URL__c, Published_URL__c, 
			URL_is_Verified__c
			FROM Module_Documenation__c
			WHERE Module__c =: moduleId
			AND Document_Status__c = 'Active/Published'
			ORDER BY Name
		];

		for(Module_Documenation__c item : docum) {
			if(String.isNotBlank(item.Document_Summary__c)) item.Document_Summary__c = item.Document_Summary__c.stripHtmlTags();
		}

		return docum;
	}

	@AuraEnabled(Cacheable=true)
	public static String getModuleReleaseNotes() {

		List<Product_Development__c> listOfProductDevelopments = [
			SELECT Id, Release_Note_Subject__c, Release_Note__c, Package_Version__r.Name, Package_Version__r.Release_Date__c, RecordType.Name, Associated_Module__c
			FROM Product_Development__c
			WHERE Customer_Facing__c = true
			ORDER BY Package_Version__r.Name DESC
		];

		Map<String, Id> mapOfRecordType = new Map<String, Id>();

		Set<Compliatric_Package_Version__c> setOfPackageVersion = new Set<Compliatric_Package_Version__c>();

		Set<Id> setOfModuleId = new Set<Id>();

		for(Product_Development__c productDevelopment: listOfProductDevelopments){
			setOfPackageVersion.add(productDevelopment.Package_Version__r);
			setOfModuleId.add(productDevelopment.Associated_Module__c);
			mapOfRecordType.put(productDevelopment.RecordType.Name, productDevelopment.RecordType.Id);
		}

		List<ModuleReleaseNotesWrapper> listOfModules = new List<ModuleReleaseNotesWrapper>();

		for(Id id: setOfModuleId){

			List<Product_Development__c> productDevelopmentsGroupByAssociatedModule = groupByAssociatedModule(id, listOfProductDevelopments);

			List<PackageVersionReleaseNotesWrapper> listOfPackageVersionReleaseNotesWrapper = new List<PackageVersionReleaseNotesWrapper>();

			for(Compliatric_Package_Version__c packageVersion:setOfPackageVersion){

				List<Product_Development__c> productDevelopmentsGroupByVersion = groupByProductVersion(packageVersion, productDevelopmentsGroupByAssociatedModule);

				List<ProductDevelopmentWrapper> listOfProductDevelopmentWrapper = new List<ProductDevelopmentWrapper>();

				for(String recordTypeName: mapOfRecordType.keySet()){
					List<Product_Development__c> productDevelopmentsGroupByRecordType = groupByRecordtype(recordTypeName, productDevelopmentsGroupByVersion);

					if(!productDevelopmentsGroupByRecordType.isEmpty())
						listOfProductDevelopmentWrapper.add(new ProductDevelopmentWrapper(recordTypeName, productDevelopmentsGroupByRecordType));
				}

				if(!listOfProductDevelopmentWrapper.isEmpty())
					listOfPackageVersionReleaseNotesWrapper.add(new PackageVersionReleaseNotesWrapper(packageVersion, listOfProductDevelopmentWrapper));
			}

			if(!listOfPackageVersionReleaseNotesWrapper.isEmpty())
				listOfModules.add(new ModuleReleaseNotesWrapper(id, listOfPackageVersionReleaseNotesWrapper));

		}

		return JSON.serialize(listOfModules);
	}

	private static List<Product_Development__c> groupByProductVersion(Compliatric_Package_Version__c packageVersion, List<Product_Development__c> developments ){
		List<Product_Development__c> groupedListOfProductDevelopment = new List<Product_Development__c>();
		for(Product_Development__c productDevelopment: developments){
			if(packageVersion.Id.equals(productDevelopment.Package_Version__c)){
				groupedListOfProductDevelopment.add(productDevelopment);
			}
		}
		return groupedListOfProductDevelopment;
	}

	private static List<Product_Development__c> groupByAssociatedModule(Id moduleId, List<Product_Development__c> developments ){
		List<Product_Development__c> groupedListOfProductDevelopment = new List<Product_Development__c>();
		for(Product_Development__c productDevelopment: developments){
			if(moduleId.equals(productDevelopment.Associated_Module__c))
				groupedListOfProductDevelopment.add(productDevelopment);
		}
		return groupedListOfProductDevelopment;
	}

	private static List<Product_Development__c> groupByRecordType(String recordTypeName, List<Product_Development__c> developments ){
		List<Product_Development__c> groupedListOfProductDevelopment = new List<Product_Development__c>();
		for(Product_Development__c productDevelopment: developments){
			if(recordTypeName.equals(productDevelopment.RecordType.Name))
				groupedListOfProductDevelopment.add(productDevelopment);
		}
		return groupedListOfProductDevelopment;
	}

	public class ModuleWrapper{

		public Modules__c modul {set; get;}
		public String modulImg  {set; get;}

		ModuleWrapper(Modules__c md) {
			this.modul = md;
			this.modulImg = ''; 

			if(String.IsNotBlank(this.modul.Lightning_URL__c) && this.modul.Lightning_URL__c.containsIgnoreCase('drive.google.com')) {
				String reLutImgId = this.modul.Lightning_URL__c.substringBetween('d/','/view');

				if(String.isBlank(reLutImgId) && this.modul.Lightning_URL__c.containsIgnoreCase('open?id')) {
					reLutImgId = this.modul.Lightning_URL__c.substringAfter('open?id=');
				}

				if(String.isNotBlank(reLutImgId)) this.modulImg = 'https://drive.google.com/uc?export=view&id=' + reLutImgId;
			}
		}
	}

	public class ModuleReleaseNotesWrapper{

		public Id moduleId {set; get;}
		public List<PackageVersionReleaseNotesWrapper> releaseNoteWrappers  {set; get;}

		ModuleReleaseNotesWrapper(Id module, List<PackageVersionReleaseNotesWrapper> releaseNoteWrappers){
			this.moduleId = module;
			this.releaseNoteWrappers = releaseNoteWrappers;
		}

	}

	public class PackageVersionReleaseNotesWrapper{

		public Compliatric_Package_Version__c packageVersion {set; get;}
		public List<ProductDevelopmentWrapper> productDevelopmentWrappers  {set; get;}

		PackageVersionReleaseNotesWrapper(Compliatric_Package_Version__c packageVersion, List<ProductDevelopmentWrapper> productDevelopmentWrappers) {
			this.packageVersion = packageVersion;
			this.productDevelopmentWrappers = productDevelopmentWrappers;
		}
	}

	public class ProductDevelopmentWrapper{

		public String recordTypeName { set; get;}
		public List<Product_Development__c> productDevelopments  {set; get;}

		ProductDevelopmentWrapper(String recordTypeName, List<Product_Development__c> productDevelopments){
			this.recordTypeName = recordTypeName;
			this.productDevelopments = productDevelopments;
		}
	}


}