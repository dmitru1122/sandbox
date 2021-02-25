({
    init : function(cmp, event, helper) {
        helper.init(cmp);
    },

    authOrg : function(cmp, event, helper) {
        helper.authOrgToHub(cmp, event);
    },

    groupChange : function(cmp, event, helper){
        helper.groupChange(cmp, event);
    },

    itemChange : function(cmp, event, helper){
        helper.itemChange(cmp, event);
    },

    openDeployModal : function(cmp, event, helper){
        helper.setDeployMode(cmp);
    },

    openValidateModal : function(cmp, event, helper){
        helper.setValidateMode(cmp);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.isModalOpen", false);
    },

    deployToOrgs : function(cmp, event, helper){
        var validationMode = cmp.get("v.isValidateMode");

        helper.deployDataToOrgs(cmp)
            .then(result =>{
                if(validationMode){
                    helper.showToast(cmp, {"variant":"success", "title":"Validation started"});
                }else{
                    helper.showToast(cmp, {"variant":"success", "title":"Deploy started"});
                }
                cmp.set("v.isModalOpen", false);
            })
            .catch(error => {
                if(validationMode){
                    helper.showToast(cmp, {"variant":"error", "title":"Validation start error", "message":error.message})
                }else{
                    helper.showToast(cmp, {"variant":"error", "title":"Deploy start error", "message":error.message})
                }
            })
    },

    handleMenuSelect : function(cmp, event, helper){
        helper.handleMenuSelect(cmp, event);
    }
})