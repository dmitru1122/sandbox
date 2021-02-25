import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import jsforceFolder from '@salesforce/resourceUrl/migrationJS';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { callApexOnOrg, getAllUsers } from './modules/searches';
import getContact from '@salesforce/apex/SetResetPwdController.getContact';
import getConnectedOrgs from '@salesforce/apex/SetResetPwdController.getConnectedOrgs';
import getAccount from '@salesforce/apex/SetResetPwdController.getAccount';
import updateCaseData from '@salesforce/apex/SetResetPwdController.updateCaseData';


const RESET_TYPE = 'reset';
const SET_TYPE = 'set';

const USER_NAME_FIELD = 'Case.External_User_Name__c';
const CONTACT_NAME_FIELD = 'Case.ContactId';
const ACCOUNT_NAME_FIELD = 'Case.AccountId';
const CONTACT_EMAIL_FIELD = 'Case.ContactEmail';
const USER_ID_FIELD = 'Case.External_User_Id__c';
const ID_FIELD = 'Case.external_id__c';

const caseFields = [
    USER_NAME_FIELD,
    CONTACT_NAME_FIELD,
    CONTACT_EMAIL_FIELD,
    USER_ID_FIELD,
    ID_FIELD,
    ACCOUNT_NAME_FIELD
];

const columns = [
    { label: 'User Name', fieldName: 'Name'},
    { label: 'Email', fieldName: 'Username'},
    { label: 'Org Name', fieldName: 'orgName'},
    { label: 'Reset Password', fieldName: 'orgId', type: 'button', initialWidth: 120, typeAttributes: { name: 'ToReset', title: 'Reset',  label: 'Reset', variant: 'brand' }},
	{ label: 'Set Password', fieldName: 'orgId', type: 'button', initialWidth: 120, typeAttributes: { name: 'ToSet', title: 'Set',  label: 'Set', variant: 'brand' }}
];

const DELAY = 600;

export default class SetResetPwdLwc extends LightningElement {
    @api recordId;
    
    extUserName;
    accountName;
    contactName;
    contactEmail;
    contactData;
    accountData;
    orgId;
    userId;
    tmpId;
    orgs;

    searchKey = '';

    searchInputEnd = false;
    users = [];
    tmpUsers = [];
    columns = columns;

    progressBarValue = 0;
    orgsCount = 0;
    orgsLoaded = 0;
    usersLoaded = 0;

    viewConfirmDialog = false;
    confirmMessage = '';
    passwordActionType = '';
    selectedUser;

    jsForceInitialized = false;

    renderedCallback() {
        if (this.jsForceInitialized) {
            return;
        }
        this.jsForceInitialized = true;

        Promise.all([
            loadScript(this, jsforceFolder + '/js/jsforce-1.7.0.min.js')
        ])
        .then(() => {
            this.loadData();
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error jsForce lib initialization: ' + error.body.message,
                    variant: 'error'
                })
            );
        })
    }

    @wire(getRecord, { recordId: '$recordId', fields: caseFields })
    loadCase({error, data}){
        if(!error){
            this.extUserName = getFieldValue(data, USER_NAME_FIELD);
            this.accountName = getFieldValue(data, ACCOUNT_NAME_FIELD);
            this.contactName = getFieldValue(data, CONTACT_NAME_FIELD);
            this.contactEmail = getFieldValue(data, CONTACT_EMAIL_FIELD);
            this.userId = getFieldValue(data, USER_ID_FIELD);
            this.tmpId = getFieldValue(data, ID_FIELD);
        }else{
            console.log('error in loadCase: ' + error);
        }
    }

    loadData(){
        getContact({contactId : this.contactName})
        .then(value => {
            this.contactData = value;
            getAccount({accountId : this.accountName})
            .then(value2 => {
                this.accountData = value2;
                this.startUsersLoad();
            })
        })
    }

    startUsersLoad(){
        if(this.contactData != null && this.contactData.Name != ''){
            this.searchKey = this.contactData.Name;
        }else if(this.contactEmail != null && this.contactEmail != ''){
            this.searchKey = this.contactEmail;
        }else if(this.extUserName != null && this.extUserName != ''){
            this.searchKey = this.extUserName;
        }

        if(this.accountData != null && this.accountData.Org_Id__c != ''){
            this.orgId = this.accountData.Org_Id__c;
        }

       if(!this.orgId){
           this.orgId = '';
       }

       this.allOrgUsersLoad();
    }

    allOrgUsersLoad(){
        var self = this;
        this.tmpUsers = [];
        this.searchInputEnd = false;
        this.progressBarValue = 0;
        this.users = [];
        this.usersLoaded = 0;

        getConnectedOrgs({orgId : this.orgId}).then(orgs => {
            let orgsParsed = JSON.parse(orgs);
            self.orgsCount = orgsParsed.length;

            orgsParsed.forEach(org => {
                getAllUsers(org).then(records => {
                    if(records != ''){
                        records.forEach(record => {
                            record.orgName = org.orgName;
                            record.orgId = org.orgId;
                            record.orgHost = org.hostName;
                        })
                        self.users = self.users.concat(records);
                        self.usersLoaded = self.usersLoaded + records.length;
                    }
    
                    self.searchInputEnd = true;
                    self.orgsLoaded = self.orgsLoaded + 1;
                    self.progressBarValue = (self.orgsLoaded / self.orgsCount) * 100;

                    self.filterUserList(self);
                })
                .catch(error => {
                    console.log(error);
                    let errorMessage = (error.body == undefined ? error : error.body.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: errorMessage,
                            variant: 'error'
                        })
                    );
                });
            })
            this.searchInProgress = false;
        })
        .catch(error => {
            console.log(error);
            let errorMessage = (error.body == undefined ? error : error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        });
    }

    filterUserList(context){
        context.users.forEach(usersElement => {
            let find = context.tmpUsers.find(record => {
                return record.Username === usersElement.Username && record.Name === usersElement.Name && record.orgId === usersElement.orgId;
            });

            if(!find){
                context.tmpUsers.push(usersElement);
            }
        });
        context.users = [];

        for(var i = 0; i < context.tmpUsers.length; i++){
            if(context.tmpUsers[i].Username.toLowerCase().includes(context.searchKey.toLowerCase()) || 
            context.tmpUsers[i].Name.toLowerCase().includes(context.searchKey.toLowerCase())){
                context.users.push(context.tmpUsers[i]);
            }
        }
    }

    handleKeyChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;
		this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;

            if(this.tmpUsers.length == 0){
                this.tmpUsers = this.users;
            }

            this.users = [];

            for(var i = 0; i < this.tmpUsers.length; i++){
                if(this.tmpUsers[i].Username.toLowerCase().includes(this.searchKey.toLowerCase()) || 
                   this.tmpUsers[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())){
                        this.users.push(this.tmpUsers[i]);
                }
            }
		}, DELAY);
    }

    handleRowActionUser(event) {
		const action = event.detail.action;
        const rowId = event.detail.row.Id;
		if(this.users) {
            let selectedUser = this.users.find(elem => elem.Id == rowId);
			if(selectedUser) {
				switch (action.name) {
					case 'ToReset':
                        this.resetPassword(selectedUser.Id);
						break;
					case 'ToSet':
                        this.setPassword(selectedUser.Id);
						break;
				}
			}
		}
		
	}

    setPassword(recordId){
        this.passwordActionType = SET_TYPE;
        this.selectedUser = this.users.find(elem => elem.Id == recordId);
        this.viewConfirmDialog = true;
        this.confirmMessage = 'Are you sure to set a new password for the user ' + this.selectedUser.Username + '?';
    }

    resetPassword(recordId){
        this.passwordActionType = RESET_TYPE;
        this.selectedUser = this.users.find(elem => elem.Id == recordId);
        this.viewConfirmDialog = true;
        this.confirmMessage = 'Are you sure to reset the password for the user ' + this.selectedUser.Username + '?';
    }

    confirmYes(){
        this.viewConfirmDialog = false;

        callApexOnOrg(this.passwordActionType, this.selectedUser.Id, this.selectedUser.orgId, this.selectedUser.orgHost).then(data => {
            if(data.success){
                this.updateCase(data.newPassword, 'Agent Responded').then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Password updated',
                            variant: 'success'
                        })
                    );
                })
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error on Apex operation',
                        variant: 'error'
                    })
                );
            }
        });
    }

    confirmYesAndClose(){
        this.viewConfirmDialog = false;

        callApexOnOrg(this.passwordActionType, this.selectedUser.Id, this.selectedUser.orgId, this.selectedUser.orgHost).then(data => {
            if(data.success){
                this.updateCase(data.newPassword, 'Closed').then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Password updated, case closed',
                            variant: 'success'
                        })
                    );
                })
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error on Apex operation.',
                        variant: 'error'
                    })
                );
            }
        });
    }

    confirmNo(){
        this.viewConfirmDialog = false;
    }

    updateCase(password, caseStatus){
        return new Promise((resolve, reject) => {
            updateCaseData({caseId : this.recordId, caseStatus : caseStatus, tmpRassword : password}).then(() => {
                resolve();
            })
        })
        .then(() => {return})
        .catch(error => {reject(error);});
    }
}