({
    doStuff : function(component, event, helper) {
         //alert(component.get("v.recordId"));
		 window.location.href ="/flow/ProductDevelopmentToTrello?ProdDevId=" + component.get("v.recordId") + "&retURL=/"+component.get("v.recordId");
        alert("Trello Card Created");
	}
    /*onload: function(component, event, helper) {
        var urlRedirect= $A.get("e.force:navigateToURL");
            urlRedirect.setParams({
                "url": "/flow/ProductDevelopmentToTrello&ProdDevId=" + component.get("v.recordId")
            });
            urlRedirect.fire();
    }*/
})