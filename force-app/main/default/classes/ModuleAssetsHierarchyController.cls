public class ModuleAssetsHierarchyController {

public List<ModuleAssetsWrapper> wrappers {get; set;}
	private ModuleAssetsWrapper root {get; set;}
	public Id currentMAId {get; private set;}
	public Boolean hasRecords {get; set;}
	public String message {get; set;}

	public ModuleAssetsHierarchyController(ApexPages.StandardController stdController) {
		Module_Assets__c ma = (Module_Assets__c) stdController.getRecord();
		try {
			if(ma.Id != NULL) {
				this.hasRecords = true;
				currentMAId = ma.Id;
				ma = [
					SELECT
						Id, Name, Client_Account__c, Client_Account__r.Name, Days_Before__c, Full_Developer_Name__c, RecordType.Name, 
						Module__c, Module_formula__c, MA_Status__c, Module_Asset_Type__c, Notes_Description__c, Notification_Email_Template_Name__c, 
						Field_Name__c, Notification_Parameters__c, Notification_Type__c, Module_Asset__c, Module_Asset__r.Name
					FROM Module_Assets__c
					WHERE Id =: ma.Id
				];

				Module_Assets__c maRoot;

				if(ma.Module_Asset__c != null) {
					maRoot = [
					SELECT
						Id, Name, Client_Account__c, Client_Account__r.Name, Days_Before__c, Full_Developer_Name__c, RecordType.Name,
						Module__c, Module_formula__c, MA_Status__c, Module_Asset_Type__c, Notes_Description__c, Notification_Email_Template_Name__c, 
						Field_Name__c, Notification_Parameters__c, Notification_Type__c, Module_Asset__c
					FROM Module_Assets__c
					WHERE Id = :ma.Module_Asset__r.Id];
				}
				root = (maRoot != null) ? new ModuleAssetsWrapper(maRoot, 0) : new ModuleAssetsWrapper(ma, 0);

				selectChildModuleAssets();
				wrappers = root.inOneList();
				if(!wrappers.isEmpty()) {
					wrappers.add(0, root);
				} else {
					wrappers.add(root);
				}
			} else {
				this.hasRecords = false;
				this.message = 'No records to display!';
			}
		} catch(Exception e) {
			this.hasRecords = false;
			this.message = e.getMessage();
		}
	}

	private void selectChildModuleAssets() {
		Integer counter = 0;

		List<Module_Assets__c> last_ma = new List<Module_Assets__c>{root.ma};
		while(counter < 10 && !last_ma.isEmpty()) {
			Set<Id> ma_ids = getMAIds(last_ma);
			last_ma = [
				SELECT
					Id, Name, Client_Account__c, Client_Account__r.Name, Days_Before__c, Full_Developer_Name__c, RecordType.Name,
                    Module__c, Module_formula__c, MA_Status__c, Module_Asset_Type__c, Notes_Description__c, Notification_Email_Template_Name__c, 
                    Field_Name__c, Notification_Parameters__c, Notification_Type__c, 
                    Module_Asset__c, Module_Asset__r.Id
				FROM Module_Assets__c
				WHERE Module_Asset__c IN: ma_ids
				ORDER BY Name
			];

			for(Module_Assets__c ma : last_ma) {
				root.addChild(ma);
			}
			counter++;
		}
	}

	private Set<Id> getMAIds(List<Module_Assets__c> mas) {
		Set<Id> result = new Set<id>();
		for (Module_Assets__c ma: mas)
			result.add(ma.Id);
		return result;
	}

	public class ModuleAssetsWrapper {
		public Integer depth { get; set; }
		public Module_Assets__c ma { get; set; }
		public List<ModuleAssetsWrapper> childs { get; set; }

		public ModuleAssetsWrapper(Module_Assets__c ma, Integer depth) {
			this.ma = ma;
			this.depth = depth;
			this.childs = new List<ModuleAssetsWrapper>();
		}

		public Boolean addChild(Module_Assets__c ma) {
			if(this.ma.Id == ma.Module_Asset__r.Id) {
				childs.add(new ModuleAssetsWrapper(ma, depth + 1));
				return true;
			} else {
				for(ModuleAssetsWrapper child : childs) {
					if (child.addChild(ma)) {
						return true;
					}
				}
			}
			return false;
		}

		public List<ModuleAssetsWrapper> inOneList() {
			List<ModuleAssetsWrapper> result = new List<ModuleAssetsWrapper>();
			for(ModuleAssetsWrapper child : childs) {
				result.add(child);
				result.addAll(child.inOneList());
			}
			return result;
		}
	}

}