({
	init : function(cmp, event, helper) {
		var code = cmp.get("v.code");
		var tokenUpdateData;

		if(code != null && code != ''){
			helper.getData(cmp, code)
				.then(result => {
					tokenUpdateData = JSON.parse(result);
					if(tokenUpdateData.tokenUpdate){
						window.open(tokenUpdateData.instanceUrl,'_top')
					}else{
						console.log(tokenUpdateData.message);
					}
				})
				.catch(error => {
					console.log(error);
				})
		}
	},
})