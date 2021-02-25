import { LightningElement, track, wire, api  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrgMetricData from '@salesforce/apex/CustomerMetricsData.getOrgMetricData';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation'; 

const DELAY = 1000;

export default class StatisticsUserReport extends NavigationMixin(LightningElement) {
	startDate;
	endDate;
	_refreshable;
	fields = [];
	@track data_records = [];
	accountSearch = '';
	@track showLoading = true;
	
	
	constructor() {
		super();
		const today =  new Date();
		this.startDate = this.firstDayMonth().toISOString();
		this.endDate = today.toISOString();
	}

	@wire(getOrgMetricData, {startDate: '$startDate', EndDate: '$endDate', account :'$accountSearch'})
	wiredSharings(result) {
		this._refreshable = result;
		if (result.error) {
			this.showError(error, false);
		} else if (result.data) {
			this.showLoading = false;
			const dataResult = JSON.parse(result.data);
			this.data_records = [];
			if(dataResult && dataResult.STATUS) {
				if(dataResult.FIELDS && this.fields.length == 0 ) this.fields = dataResult.FIELDS;

				if(dataResult.DATA_RECORDS) {
					let data_recordsTmp = [];
					for(let keyData in  dataResult.DATA_RECORDS) {
						if ( dataResult.DATA_RECORDS.hasOwnProperty(keyData)) { 
							let recordResult =  dataResult.DATA_RECORDS[keyData];
							let MappingResult = []; 
							for(let key in this.fields) {
								if (this.fields.hasOwnProperty(key)) {
									let fieldResult = recordResult.hasOwnProperty(this.fields[key].FieldApiName) ? recordResult[this.fields[key].FieldApiName] : '';
									MappingResult.push({ value: fieldResult, key: this.fields[key].FieldApiName});
								}
							}
							data_recordsTmp.push({ key: recordResult.Account__c, value: MappingResult, accName: recordResult.Account__r.Name, Id : recordResult.Id });
						}
					}
					this.data_records = data_recordsTmp;
					this.showLoading = false;
				}
			} else if(dataResult && dataResult.ERROR) {
				this.showError(dataResult.ERROR, true);
				this.showLoading = false;
			}
		}
	}

	firstDayMonth() {
		var date = new Date(), y = date.getFullYear(), m = date.getMonth();
		var firstDay = new Date(y, m, 1, 13 );
		return firstDay;
	}

	showError(error, isInternal) {
		if(!isInternal) {
			if (error) {
				if (Array.isArray(error.body)) {
					this.error = error.body.map(e => e.message).join(', ');
				} else if (typeof error.body.message === 'string') {
					this.error = error.body.message;
				}
			} else {
				this.error = '';
			}
		} else {
			this.error = error;
		}
		if(this.error) {
			const eventToast = new ShowToastEvent({
				"title": "Error",
				"message": this.error,
				"variant": "error",
				"mode":"sticky"
			});
			this.dispatchEvent(eventToast);
		}
	}
	
	
	openRecord(event) {
		const recordId = event.target.dataset.id; 
		if(recordId) {
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: recordId,
					actionName: 'view'
				}
			});
		}
	}

	handleAccountChange(event) {
		event.stopPropagation();
		const valueEn = event.detail.value;
		if(valueEn) {
			const valueEnStr = valueEn.toString();
			if (this.accountSearch === valueEnStr) {
				return;
			} else {
				window.clearTimeout(this.delayTimeout);
				this.delayTimeout = setTimeout(() => {
					this.accountSearch = valueEnStr;
					this.showLoading = true;
				}, DELAY);
			}
		}
	}

	handleStartDateChange(event) {
		event.stopPropagation();
		
		const valueEn = event.detail.value;
		if(valueEn) {
			const valueEnStr = valueEn.toString();
			
			if (this.startDate === valueEnStr) {
				return;
			} else {
				window.clearTimeout(this.delayTimeout);
				
				this.delayTimeout = setTimeout(() => {
					this.startDate = valueEnStr;
					this.showLoading = true;
				}, DELAY);
			}
		}
	}

	handleEndDateChange(event) {
		event.stopPropagation();
	
		const valueEn = event.detail.value;
		if(valueEn) {
			const valueEnStr = valueEn.toString();
			if (this.endDate === valueEnStr) {
				return;
			} else {
				window.clearTimeout(this.delayTimeout);
				
				this.delayTimeout = setTimeout(() => {
					this.endDate = valueEnStr;
					this.showLoading = true;
				}, DELAY);
			}
		}
	}







}