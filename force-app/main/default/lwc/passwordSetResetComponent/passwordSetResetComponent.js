import { LightningElement, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SearchUser from '@salesforce/apex/PasswordSetResetController.SearchUser';
import ResetPassowrd from '@salesforce/apex/PasswordSetResetController.ResetPassowrd';
import SetPassowrd from '@salesforce/apex/PasswordSetResetController.SetPassowrd';
import { showError } from 'c/componentHelper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DELAY = 600;

const columnsUser = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'User Name', fieldName: 'Username' },
    { label: 'Email', fieldName: 'Email' },
	{ label: 'Reset Password', fieldName: 'Id', type: 'button', initialWidth: 150, typeAttributes: { name: 'ToReset', title: 'Reset',  label: 'Reset', variant: 'brand' }}
	// ,
	// { label: 'Set Password', fieldName: 'Id', type: 'button', initialWidth: 150, typeAttributes: { name: 'ToSet', title: 'Set',  label: 'Set', variant: 'brand' }}
];

export default class PasswordSetResetComponent extends NavigationMixin(LightningElement) {
	@api recordId;
	searchKey = '';
	columnsUser = columnsUser;

	handleKeyChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchKey = searchKey;
		}, DELAY);
	}
	
	@wire(SearchUser, { searchKey: '$searchKey' })
	UserList;

	handleRowActionUser(event) {
		const action = event.detail.action;
		const rowId = event.detail.row.Id;
		if(this.UserList &&  this.UserList.data) {
			let selectedAdditional = this.UserList.data.find(elem => elem.Id == rowId);
			if(selectedAdditional) {
				switch (action.name) {
					case 'ToReset':
						this.ResetPassword(selectedAdditional.Id);
						break;
					case 'ToSet':
						this.SetPassword(selectedAdditional.Id);
						break;
				}
			}
		}
		
	}

	async ResetPassword(userId) {
		try {
			
			await ResetPassowrd({
				UserId: userId,
				CaseId: this.recordId
			})
			const eventToast = new ShowToastEvent({
				"title": "Success",
				"message": 'Password cleared',
				"variant": "success",
				"mode":"dismissable"
			});
			this.dispatchEvent(eventToast);
			
		} catch(e) {
			showError(e, false);
		}
	}

	async SetPassword(userId) {
		try {
			await SetPassowrd({
				UserId: userId,
				CaseId: this.recordId
			})

			const eventToast = new ShowToastEvent({
				"title": "Success",
				"message": 'Password set',
				"variant": "success",
				"mode":"dismissable"
			});
			this.dispatchEvent(eventToast);
		} catch(e) {
			showError(e, false);
		}
	}
}