({
    onInit : function(component, event, helper) {

    },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    resetPassword : function(component, event, helper) {
        component.find('search').resetPassword();
    },
    setPassword : function(component, event, helper) {
        component.find('search').setPassword();
    }
})