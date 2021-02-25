({
    init : function(cmp) {
        var doNotUpdateLayoutsString = 'DO NOT UPDATE LAYOUTS';
        var unlinkedString = 'UNLINKED';
        var colorError = "slds-text-color_error";
        var colorDefault = "slds-text-color_default";
        var authList;
        var hubMembersList;
        var dataForTable = [];
        var targetsMap = new Map();
        var itemForTable;

        this.getAuths(cmp)
            .then(result => {
                authList = result;

                this.getHubMembers(cmp)
                    .then(result => {
                        hubMembersList = result;

                        hubMembersList.forEach(hubItem => {
                            itemForTable = {};
                            itemForTable.authorized = false;
                            itemForTable.isSource = false;
                            itemForTable.duration = 0;
                            itemForTable.IsExpired = true;
                            itemForTable.selected = false;
                            itemForTable.metadataSourceOrg = undefined;
                            itemForTable.lastSuccess = (hubItem.Last_Success__c == undefined ? 0 : this.getFormattedDate(new Date(hubItem.Last_Success__c).getTime()));
                            itemForTable.lastFailure = (hubItem.Last_Failure__c == undefined ? 0 : this.getFormattedDate(new Date(hubItem.Last_Failure__c).getTime()));
                            if(hubItem.MemberEntity__c != null){
                                itemForTable.orgName = hubItem.Name;
                                if(hubItem.Metadata_Source_Org__r != null && hubItem.Metadata_Source_Org__r != undefined){
                                    itemForTable.metadataSourceOrg = hubItem.Metadata_Source_Org__r.Name__c;
                                }
                                itemForTable.orgId = hubItem.MemberEntity__c;
                            }else{
                                if(hubItem.DisplayName != null){
                                    itemForTable.orgName = hubItem.DisplayName;
                                }
                                if(hubItem.Metadata_Source_Org__r != null){
                                    itemForTable.metadataSourceOrg = hubItem.Metadata_Source_Org__r.DisplayName;
                                }
                                itemForTable.orgId = hubItem.MemberEntity;
                            }
                            authList.forEach(authItem => {
                                if((hubItem.MemberEntity__c != null && authItem.Name.includes(hubItem.MemberEntity__c)) || 
                                    (hubItem.MemberEntity != null && authItem.Name.includes(hubItem.MemberEntity))){
                                    itemForTable.orgId = authItem.Name;
                                    itemForTable.authUser = authItem.AuthorisedUser__c;
                                    itemForTable.appType = authItem.Connected_App_Type__c;
                                    itemForTable.instance_uri = authItem.InstanceURL__c;
                                    itemForTable.refresh_token = authItem.RefreshToken__c;
                                    itemForTable.authorized = true;
                                    if(hubItem.DO_NOT_UPDATE__c == doNotUpdateLayoutsString){
                                        itemForTable.key = unlinkedString;
                                    }
                                    itemForTable.DO_NOT_UPDATE__c = hubItem.DO_NOT_UPDATE__c;
                                    itemForTable.IsExpired = authItem.Is_Expired__c;
                                    var dateArray = authItem.CreatedDate.split('T')[0].split('-');
                                    itemForTable.CreatedDate = dateArray[1] + '/' + dateArray[2] + '/' + dateArray[0];
                                }
                            })

                            itemForTable.CreatedDate = itemForTable.CreatedDate == undefined ? 0 : itemForTable.CreatedDate;

                            dataForTable.push(itemForTable);
                            targetsMap.set(itemForTable.orgId, itemForTable);
                        })

                        // get MetadataSources array
                        var sourceItemObject;
                        var dataMapArray = [];
                        var listsDataItem;
                        var listDataArray;
                        var sourcesList = [{key:undefined}];
                        var sourcesListTmp = [];
                        dataForTable.forEach(dataItem => {
                            if(!sourcesListTmp.includes(dataItem.metadataSourceOrg)){
                                sourcesListTmp.push(dataItem.metadataSourceOrg);
                            }
                        })

                        dataForTable.forEach(dataItem => {
                            if(dataItem.metadataSourceOrg == undefined && sourcesListTmp.includes(dataItem.orgName)){
                                let sourcesListItem = {};
                                sourcesListItem.key = dataItem.orgName;
                                sourcesListItem.orgId = dataItem.orgId;
                                sourcesListItem.refresh_token = dataItem.refresh_token;
                                sourcesListItem.instance_uri = dataItem.instance_uri;
                                sourcesListItem.authorized = dataItem.authorized;
                                sourcesList.push(sourcesListItem);    
                            }
                        })

                        sourcesListTmp.sort();

                        // get map of key-array of orgs
                        sourcesListTmp.forEach(sourceItem => {
                            sourcesList.forEach(source => {
                                if(source.key == sourceItem){
                                    sourceItemObject = source;
                                }
                            })
                            var countAuth = 0;
                            listsDataItem = {};
                            listDataArray = [];
                            listsDataItem.key = sourceItemObject.key;
                            listsDataItem.orgId = sourceItemObject.orgId;
                            listsDataItem.refresh_token = sourceItemObject.refresh_token;
                            listsDataItem.instance_uri = sourceItemObject.instance_uri;
                            listsDataItem.authorized = sourceItemObject.authorized;

                            if(sourceItemObject.key == undefined){
                                listsDataItem.key = unlinkedString;
                                listsDataItem.unlinked = true;
                                listsDataItem.colorClass = colorError;
                            }else{
                                listsDataItem.key = sourceItemObject.key.toUpperCase();
                                listsDataItem.unlinked = false;
                                listsDataItem.colorClass = colorDefault;
                            }

                            dataForTable.forEach(dataItem => {
                                if(dataItem.metadataSourceOrg == sourceItemObject.key){
                                    if(dataItem.authorized){
                                        countAuth += 1;
                                        listDataArray.splice(0, 0, dataItem);
                                    }else{
                                        listDataArray.push(dataItem);
                                    }
                                }
                            })

                            listsDataItem.data = listDataArray;
                            listsDataItem.count = listDataArray.length;
                            listsDataItem.countAuth = countAuth;
                            listsDataItem.selected = false;
                            listsDataItem.selectedCount = 0;
                            dataMapArray.push(listsDataItem);
                        });

                        dataMapArray.forEach(dataItem => {
                            if(dataItem.key == unlinkedString){
                                dataItem.data.forEach(data => {
                                    sourcesList.forEach(source => {
                                        if(!data.isSource){
                                            data.isSource = data.orgId == source.orgId ? true : false;
                                        }
                                    })
                                })
                            }
                        })

                        cmp.set("v.dataMapArray", dataMapArray);
                        console.log(dataMapArray);

                        // load statuses
                        this.getOrgsStatuses(cmp)
                            .then(result => {
                                cmp.set("v.statusesLoading", false);
                                this.updateComponentData(cmp, result);
                                this.updateData(cmp, result);
                                this.autorefreshData(cmp, this);
                            })
                            .catch(error => {
                                cmp.set("v.statusesLoading", false);
                                this.showToast(cmp, {"variant":"error", "title":"Get statuses error", "message":error.message})
                            })
                    })
                    .catch(error => {
                        this.showToast(cmp, {"variant":"error", "title":"Data loading error", "message":error})
                    })
            })
            .catch(error => {
                this.showToast(cmp, {"variant":"error", "title":"Data loading error", "message":error})
            })
    },

    getAuths : function(cmp){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.getAuthList");

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }else{
                    reject('Error get authentification orgs list.');
                }
            });
            $A.enqueueAction(action);
        })
    },

    getHubMembers: function(cmp){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.getHubMembersList");

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }else{
                    reject('Error get hub members list.')
                }
            });
            $A.enqueueAction(action);
        })
    },

    openOrg : function(cmp, orgId) {
        var action = cmp.get("c.openInBrowser");
        action.setParams({ 
            'orgId' : orgId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                if(response.getReturnValue() == ''){
                    location.reload();
                }else{
                    window.open(response.getReturnValue(),'_blank');
                }
            }else{
                helper.showToast(cmp, 
                    {"variant":"error", 
                    "title":"Open in browser error", 
                    "message":"An error occurred while trying to open an organization, please contact your system administrator."})
            }
        });
        $A.enqueueAction(action);
    },

    openHistoryModal : function(cmp, orgId) {        

    },

    handleMenuSelect : function(cmp, event){
        var selectedMenuItemValue = event.getParam("value").split('/')[1];
        var orgId = event.getParam("value").split('/')[0];

        if(selectedMenuItemValue == 'openInBrowser'){
            this.openOrg(cmp, orgId);
        }else if(selectedMenuItemValue == 'showHistory'){
            this.openHistoryModal(cmp, orgId);
        }
    },

    authOrgToHub : function(cmp) {
        var instanceType = 'https://login.salesforce.com';
        var loginUrl = instanceType+'/services/oauth2/authorize?response_type=code&prompt=login';

        this.getData(cmp)
            .then(
                result => {
                    let dataToAuth = JSON.parse(result);

                    let creds = dataToAuth.creds;
                    let dataLI = dataToAuth.dataLI;

                    loginUrl += '&client_id=' + encodeURI(creds.Consumer_Key_Auto__c) +
                                '&redirect_uri=' + encodeURI(creds.Redirect_URL_Hub__c) +
                                '&state=' + encodeURI(JSON.stringify(dataLI));

                    this.goToUrl(loginUrl);

                })
            .catch(error =>{
                helper.showToast(cmp, {"variant":"error", "title":"Authorization error", "message":error})
            })
    },

    goToUrl : function(loginUrl){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": loginUrl
        });
        alert(loginUrl);
        urlEvent.fire();
    },

    getData : function(cmp){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.getDataToAuth");

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }else{
                    reject('Error with retrieving data for authorization.');
                }
            });
            $A.enqueueAction(action);
        })
    },

    groupChange : function(cmp, event){
        var unlinkedString = 'UNLINKED';
        var groupKey = event.getSource().get("v.name");
        var selected = event.getSource().get("v.checked");
        var dataMapArray = cmp.get("v.dataMapArray");
        var selectedCount = cmp.get("v.selectedCount");

        var group = dataMapArray[groupKey];
        group.data.forEach(dataItem => {
            if(dataItem.authorized && dataItem.key != unlinkedString){
                if(selected){
                    if(!dataItem.selected){
                        group.selectedCount += 1;
                        selectedCount += 1;
                    }
                }else{
                    if(dataItem.selected){
                        group.selectedCount -= 1;
                        selectedCount -= 1;
                    }
                }
                
                dataItem.selected = selected;
            }
        })

        if(group.selectedCount < 0){
            group.selectedCount = 0;
        }

        this.setDeployDisable(cmp, selectedCount);

        cmp.set("v.dataMapArray", dataMapArray);
        cmp.set("v.selectedCount", selectedCount);
    },

    itemChange : function(cmp, event){
        var itemKey = event.getSource().get("v.name").split('/')[0];
        var groupKey = event.getSource().get("v.name").split('/')[1];
        var selected = event.getSource().get("v.checked");
        var dataMapArray = cmp.get("v.dataMapArray");
        var selectedCount = cmp.get("v.selectedCount");

        var group = dataMapArray[groupKey];
        var item = group.data[itemKey];

        if(selected){
            group.selectedCount += 1;
            selectedCount += 1;
        }else{
            group.selectedCount -= 1;
            selectedCount -= 1;
        }
        item.selected = selected;

        this.setDeployDisable(cmp, selectedCount);

        cmp.set("v.selectedCount", selectedCount);
    },

    setDeployDisable : function(cmp, selectedCount){
        var deployDisabled = true;
        if(selectedCount > 0){
            deployDisabled = false;
        }
        cmp.set("v.deployDisabled", deployDisabled);
    },

    getOrgProd : function(cmp){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.isProdOrg");
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    resolve(response.getReturnValue());
                }else{
                    reject({'message':'Error with get data from server.'});
                }
            });
            $A.enqueueAction(action);
        })
    },

    setValidateMode : function(cmp){
        this.openDeployModal(cmp, true);
    },

    setDeployMode : function(cmp){
        this.openDeployModal(cmp, false);
    },

    openDeployModal : function(cmp, validateMode){
        cmp.set("v.isValidateMode", validateMode);
        cmp.set("v.isModalOpen", true);

        this.getOrgProd(cmp)
            .then(result => {
                var dataMapArray = cmp.get("v.dataMapArray");
                var deployData = [];
                var selected = false;

                dataMapArray.forEach(dataMapItem => {
                    var sourceItem = {};
                    sourceItem.name = dataMapItem.key;
                    sourceItem.id = dataMapItem.orgId;
                    sourceItem.instance_uri = dataMapItem.instance_uri;
                    sourceItem.refresh_token = dataMapItem.refresh_token;
                    sourceItem.targets = [];

                    dataMapItem.data.forEach(dataItem => {
                        if(dataItem.selected){
                            var targetItem = {};
                            targetItem.name = dataItem.orgName;
                            targetItem.id = dataItem.orgId;
                            targetItem.instance_uri = dataItem.instance_uri;
                            targetItem.refresh_token = dataItem.refresh_token;

                            targetItem.test_mode = validateMode;

                            sourceItem.targets.push(targetItem);

                            selected = true;
                        }
                    })

                    if(selected){
                        deployData.push(sourceItem);
                        selected = false;
                    }
                })

                var outputString = 'You are going to apply on ';
                var selectedOrgs = 0;
                dataMapArray.forEach(dataMapItem => {
                    selectedOrgs += dataMapItem.selectedCount;
                })
                outputString += selectedOrgs + ' org(s).';

                var newDeployData = {};
                newDeployData.prod = result;
                newDeployData.tasks = deployData;

                console.log(newDeployData);

                cmp.set("v.deployData", newDeployData);
                cmp.set("v.deployDataText", outputString);
            })
            .catch(error => {
                this.showToast(cmp, {"variant":"error", "title":"Get data error", "message": error.message})
            })
    },

    deployDataToOrgs : function(cmp){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.runDeploy");
            var dataToDeploy = cmp.get("v.deployData");

            action.setParams({
                'body' : JSON.stringify(dataToDeploy)
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    if(response.getReturnValue() != ''){
                        resolve(response.getReturnValue());
                    }else{
                        reject({'message':'Empty response from server.'});
                    }
                }else{
                    reject({'message':'Error with send data to deploy.'});
                }
            });
            $A.enqueueAction(action);
        })
    },

    getOrgsStatuses : function(cmp){
        cmp.set("v.statusesLoading", true);

        return new Promise((resolve, reject) => {
            var action = cmp.get("c.getStatus");

            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    resolve(response.getReturnValue());
                }else{
                    reject({'message':'update statuses error'});
                }
            });
            $A.enqueueAction(action);
        })
    },

    autorefreshData : function(cmp, helper){
        window.setTimeout(
            $A.getCallback(function() {
                helper.getOrgsStatuses(cmp)
                    .then(result => {
                        cmp.set("v.statusesLoading", false);
                        helper.updateComponentData(cmp, result);
                        helper.updateData(cmp, result);
                        helper.autorefreshData(cmp, helper);
                    })
                    .catch(error => {
                        cmp.set("v.statusesLoading", false);
                        helper.showToast(cmp, {"variant":"error", "title":"Get statuses error", "message":error.message})
                    })
            }), 1000 * 60
        );
    },

    updateComponentData : function(cmp, result){
        var dataMapArray = cmp.get("v.dataMapArray");
        var statusData = JSON.parse(result);

        dataMapArray.forEach(deployDataItem => {
            deployDataItem.data.forEach(dataItem => {
                statusData.result.forEach(statusDataItem => {
                    if(dataItem.orgId == statusDataItem.id){
                        dataItem.lastSuccess = (statusDataItem.success != undefined ? this.getFormattedDate(statusDataItem.success) : 0);
                        dataItem.lastFailure = (statusDataItem.error != undefined ? this.getFormattedDate(statusDataItem.error) : 0);
                        dataItem.progress = (statusDataItem.progress != undefined ? statusDataItem.progress : false);
                        dataItem.duration = (statusDataItem.duration != undefined ? statusDataItem.duration : 0);

                        if(statusDataItem.checkonly != undefined){
                            dataItem.checkonly = true;
                            dataItem.checkonlyStatus = (statusDataItem.checkonly.status != undefined ? statusDataItem.checkonly.status : 0);
                            dataItem.checkonlyDate = (statusDataItem.checkonly.date != undefined ? this.getFormattedDate(statusDataItem.checkonly.date) : 0);
                            dataItem.checkonlyDuration = (statusDataItem.checkonly.duration != undefined ? statusDataItem.checkonly.duration : 0);
                        }else{
                            dataItem.checkonly = false;
                        }
                    }
                })
            })
        })

        cmp.set("v.dataMapArray", dataMapArray);
    },

    updateData : function(cmp, result){
        var action = cmp.get("c.updateStatusesData");
        var statusesData = [];
        var resultData = JSON.parse(result);

        resultData.result.forEach(resultItem => {
            var statusesItem = {};
            statusesItem.id = resultItem.id;
            statusesItem.lastSuccess = parseInt(resultItem.success);
            statusesItem.lastFailure = parseInt(resultItem.error);

            statusesData.push(statusesItem);
        })

        action.setParams({
            'jsonStatusesStr' : JSON.stringify(statusesData)
        })

        action.setCallback(this, function(response){
            if(response.getState() !== "SUCCESS"){
                this.showToast(cmp, {"variant":"error", "title":"Update data error", 'message':'Error with update data statuses.'});
            }
        })
        $A.enqueueAction(action);
    },

    getFormattedDate : function(dateString){
        var ms = parseInt(dateString);
        var date = new Date(ms);
        var month = date.getMonth() + 1;
        var day = date.getDate();
        var year = date.getFullYear();

        return month + '/' + day + '/' + year;
    },

    showToast : function(cmp, toastParams){
        cmp.find('notifLib').showToast({
            "variant": toastParams.variant,
            "title": toastParams.title,
            "message": toastParams.message
        });
    },
})