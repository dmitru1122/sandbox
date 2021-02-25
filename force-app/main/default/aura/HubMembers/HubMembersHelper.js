({
	getData : function(cmp, code){
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.getTokens");
            action.setParams({ 
				'code' : code
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
					console.log(response.getReturnValue());
                    resolve(response.getReturnValue());
                }else{
                    reject('Get data to auth error');
                }
            });
            $A.enqueueAction(action);
        })
	},
})