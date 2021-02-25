public class HierarchyModuleAssetsController {
    private Map<String, List<ModuleAssetsWrapper>> wrappersDraft;
	private List<ModuleAssetsWrapper> sortedRootWrappers;
	private List<ModuleAssetsWrapper> wrappers;
	public Boolean hasRecords {get; set;}
	public String message {get; set;}
	private Map<String, ModuleAssetsWrapper> rootWrappers;

	public HierarchyModuleAssetsController(ApexPages.StandardController stdController) {
		Modules__c ma = (Modules__c) stdController.getRecord();
		Map<String, Module_Assets__c> currentMA = new Map<String, Module_Assets__c>();
		this.sortedRootWrappers = new List<ModuleAssetsWrapper>();
		try {
			this.hasRecords = true;
			currentMA = new Map<String, Module_Assets__c>([
				SELECT
					Id, Name,  Module_Asset__c, Module_Asset__r.Name
				FROM Module_Assets__c
				WHERE Module__c =: ma.Id
			]);
			if(!currentMA.isEmpty()) {
				Map<String, Module_Assets__c> maRoots;
				Set<String> setRoots = new Set<String>();

				for(Module_Assets__c maCurrent : currentMA.values()) {
					if(maCurrent.Module_Asset__c != null) {
						if(!currentMA.containsKey(maCurrent.Module_Asset__c)){
							setRoots.add(maCurrent.Module_Asset__r.Id);
						}
					} else {
						setRoots.add(maCurrent.Id);
					}
				}

				if(!setRoots.isEmpty()) {
					maRoots = new Map<String, Module_Assets__c>([
							SELECT
								Id, Name, Client_Account__c, Client_Account__r.Name, Days_Before__c, Full_Developer_Name__c, RecordType.Name,
								Module__c, Module__r.Name, Module_formula__c, MA_Status__c, Module_Asset_Type__c, Notes_Description__c, Notification_Email_Template_Name__c, 
								Field_Name__c, Notification_Parameters__c, Notification_Type__c, Module_Asset__c
							FROM Module_Assets__c
							WHERE Id IN: setRoots]);
				}
				this.rootWrappers = new Map<String, ModuleAssetsWrapper>();

				for(Module_Assets__c maCurrent : maRoots.values()) {
					rootWrappers.put(maCurrent.Id, new ModuleAssetsWrapper(maCurrent, 0));
				}

				selectChildModuleAssets();
				wrappersDraft = new Map<String, List<ModuleAssetsWrapper>>();
				for(String maId : rootWrappers.keySet()) {
					wrappersDraft.put(maId, rootWrappers.get(maId).inOneList());
					if(!wrappersDraft.get(maId).isEmpty()) {
						wrappersDraft.get(maId).add(0, rootWrappers.get(maId));
					} else {
						wrappersDraft.get(maId).add(rootWrappers.get(maId));
					}
				}
				sortTable();
			} else {
				this.hasRecords = false;
				this.message = 'No records to display!';
			}
		} catch(Exception e) {
			this.hasRecords = false;
			this.message = e.getMessage();
		}
	}

	public List<ModuleAssetsWrapper> getWrappers() {
		this.wrappers = new List<ModuleAssetsWrapper>();
		for(ModuleAssetsWrapper keyModule : this.sortedRootWrappers) {
		 	this.wrappers.addAll(this.wrappersDraft.get(keyModule.ma.Id));
		}
		return this.wrappers;
	}

	public void sortTable() {
		this.sortedRootWrappers = this.rootWrappers.values();
		for(ModuleAssetsWrapper maw : this.sortedRootWrappers) {
			maw.compareField = this.sortExpression;
			maw.compareDirection = getSortDirection();
		}
		this.sortedRootWrappers.sort();
	}

	private void selectChildModuleAssets() {
		Map<String, List<Module_Assets__c>> mapingModuleToParent = new Map<String, List<Module_Assets__c>>();
		for(Module_Assets__c ma : [SELECT
								Id, Name, Client_Account__c, Client_Account__r.Name, Days_Before__c, Full_Developer_Name__c, RecordType.Name,
								Module__c, Module_formula__c, MA_Status__c, Module_Asset_Type__c, Notes_Description__c, Notification_Email_Template_Name__c, 
								Field_Name__c, Notification_Parameters__c, Notification_Type__c, 
								Module_Asset__c, Module_Asset__r.Id
							FROM Module_Assets__c
							ORDER BY Name LIMIT 10000]) {
			if(ma.Module_Asset__c != NULL) {
				if(!mapingModuleToParent.containsKey(ma.Module_Asset__r.Id)) {
					mapingModuleToParent.put(ma.Module_Asset__r.Id, new List<Module_Assets__c>());
				}
				mapingModuleToParent.get(ma.Module_Asset__r.Id).add(ma);
			}
		}

		Set<String> findedMA = new Set<String>();
		for(ModuleAssetsWrapper rootMA : rootWrappers.values()) {
			Module_Assets__c last_ma = rootMA.ma;

			Integer counter = 0;
			Boolean isfind = false;
			while(counter < 20 && last_ma != NULL && !isfind) {
				for(List<Module_Assets__c> maList : mapingModuleToParent.values()) {
					if(!maList.isEmpty()) {
						for(Module_Assets__c ma : maList) {
							if(!findedMA.contains(ma.Id)) {
								isfind = rootMA.addChild(ma);
							}
							if(isfind) {
								findedMA.add(ma.Id);
							}
							
							last_ma = ma;
						}
					} else {
						last_ma = NULL;
					}
					counter++;
				}
			}
		}
		Set<String> duplicates = new Set<String>();
		for(String rootMA : rootWrappers.keySet()) {
			for(ModuleAssetsWrapper maw : rootWrappers.get(rootMA).childs) {
				if(rootWrappers.containsKey(maw.ma.Id)) {
					duplicates.add(maw.ma.Id);
				}
			}
		}
		for(String strId : duplicates) {
			rootWrappers.remove(strId);
		}
	}

	private String sortDirection = 'ASC';
    private String sortExp = 'Name';

    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            if (value == sortExp) {
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
			} else{
                sortDirection = 'ASC';
			}
            sortExp = value;
        }
    }

    public String getSortDirection() {
        if (String.isBlank(sortExpression)){
            return 'ASC';
        } else {
            return sortDirection;
        }
    }

	public class ModuleAssetsWrapper implements Comparable {
		public Integer depth { get; set; }
		public Module_Assets__c ma { get; set; }
		public List<ModuleAssetsWrapper> childs { get; set; }
		public Boolean isCurrent {get; set;}
		public String compareField {get; set;}
		public String compareDirection {get; set;}

		public ModuleAssetsWrapper(Module_Assets__c ma, Integer depth) {
			this.ma = ma;
			this.depth = depth;
			this.childs = new List<ModuleAssetsWrapper>();
			this.isCurrent = false;
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

		// Implement the compareTo() method
		public Integer compareTo(Object compareTo) {
			ModuleAssetsWrapper compareToObj = (ModuleAssetsWrapper)compareTo;
			if(String.isBlank(compareField) || String.isBlank(compareDirection)) {
				return 0;
			}
			try {
				String val1;
				String val2;
				if(compareField.equalsIgnoreCase('RecordType')) {
					val1 = String.valueOf(ma.RecordType.Name);
					val2 = String.valueOf(compareToObj.ma.RecordType.Name);
				} else if(compareField.equalsIgnoreCase('Client_Account__c')) {
					val1 = String.valueOf(ma.Client_Account__r.Name);
					val2 = String.valueOf(compareToObj.ma.Client_Account__r.Name);
				} else if(compareField.equalsIgnoreCase('Module__c')){
					val1 = String.valueOf(ma.Module__r.Name);
					val2 = String.valueOf(compareToObj.ma.Module__r.Name);
				} else {
					val1 = String.valueOf(ma.get(compareField));
					val2 = String.valueOf(compareToObj.ma.get(compareField));
				}
				return compareDirection.equalsIgnoreCase('DESC') ? compareDESC(val1, val2) : compareASC(val1, val2);
			} catch(Exception e) {
				return 0;
			}
		}

		private Integer compareASC(String val1, String val2){
			if(val1 < val2){
				return -1;
			} else if(val1 > val2){
				return 1;
			} else {
				return 0;
			}
		}

		private Integer compareDESC(String val1, String val2){
			if(val1 < val2){
				return 1;
			} else if(val1 > val2){
				return -1;
			} else {
				return 0;
			}
		}
	}
}