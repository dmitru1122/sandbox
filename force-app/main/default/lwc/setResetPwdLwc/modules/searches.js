import requestToServer from '@salesforce/apex/SetResetPwdController.requestToServer';

const getAllUsers = (org) => {
    return new Promise((resolve, reject) => {
        var queryString = "Select Id, Name, UserName, IsActive, Profile.UserLicense.Name From User Where IsActive = true AND (Profile.UserLicense.Name = 'Salesforce' OR Profile.UserLicense.Name = 'Salesforce Platform')";
        
        requestToServer({orgId : org.orgId, instanceURL : org.hostName, query : queryString, requestType : 'SOQL'}).then(data => {
            if(data != ''){
                resolve(JSON.parse(JSON.parse(data)))
            }else{
                resolve('');
            }
        })
        .catch(error => {reject(error);});
    })
}

const callApexOnOrg = (type, userId, orgId, hostName) => {
    return new Promise((resolve, reject) => {
        var queryString = "";
        if(type == 'reset'){
            queryString = "System.resetPassword('" + userId + "', " + true + ");";
        }else if(type == 'set'){
            var password = 'Compliatric';
            for(var i = 0; i < 4; i++){
                password = password + Math.floor(Math.random() * 10);
            }
            queryString = "System.setPassword('" + userId + "', '" + password + "');";
        }
        
        requestToServer({orgId : orgId, instanceURL : hostName, query : queryString, requestType : 'APEX'}).then(data => {
            // password and user data to data
            data = JSON.parse(JSON.parse(data));
            var response = {success: data.success, newPassword : password};
            resolve(response);
        })
        .catch(error => {reject(error);});
    })
}

export { callApexOnOrg, getAllUsers };