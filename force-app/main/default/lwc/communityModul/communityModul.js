import { LightningElement, wire, api, track } from 'lwc';
import getModules from '@salesforce/apex/LightningModulsHelper.getModules';

import getModuleDocumentationList from '@salesforce/apex/LightningModulsHelper.getModuleDocumentationList';
import getModuleReleaseNotes from '@salesforce/apex/LightningModulsHelper.getModuleReleaseNotes';

export default class CommunityModul extends LightningElement {
	@track openModul = [];
	@track Step = 1;
	@track ModullName = '';
	@track recordModuls = [];
	@track recordReleaseNotes = [];
	@track cssTooltipStyle = '';
	@track recordModuleReleaseNotes = [];
	@track openModuleReleaseNotes = [];

	@wire(getModules)
	wireListResult(result) {
		const { data, error } = result;
		if (data) {
			this.recordModuls = JSON.parse(data);
		} else if (error) {	}
	}

	@wire(getModuleReleaseNotes)
	wireListReleaseNoteResult(result) {
		const { data, error } = result;
		if (data) {
			this.recordReleaseNotes = JSON.parse(data);
		} else if (error) { }
	}

	@track openedDocument;
	imageUrl = '/sfc/servlet.shepherd/version/download/0681D000000lxJD';

	get isOpenVideo() {
		return this.openedDocument && this.openedDocument.Documentation_Type__c && this.openedDocument.Documentation_Type__c === 'Video';
	}

	get ModuleDocumentNotEmpty() {
		return this.openModul !== null && this.openModul.length > 0;
	}

	get ReleaseNoteNotEmpty() {
		return this.recordModuleReleaseNotes.length > 0;
	}

	get OpenModuleReleaseNoteNotEmpty() {
		return this.openModuleReleaseNotes.length > 0;
	}

	get showBackButton() {
		return this.Step == 2 || this.Step == 3;
	}

	get MainPageStep() {
		return this.Step == 1;
	}

	get ListDocumentStep() {
		return this.Step == 2;
	}

	get DocumentStep() {
		return this.Step == 3;
	}

	get tabClass() {
		return this.OpenModuleReleaseNoteNotEmpty ? 'slds-size_1-of-2' : 'slds-size_2-of-2';
	}

	openModuleRecord(event) {
		const moduleId = event.currentTarget.dataset.id;
		const moduleName = event.currentTarget.dataset.name;
		if(moduleId && moduleName) {
			this.ModullName = moduleName;
			event.stopPropagation();
			const result = this.recordReleaseNotes.find(character => character.moduleId === moduleId);
			if(result){
				this.openModuleReleaseNotes = result.releaseNoteWrappers;
			}else {
				this.openModuleReleaseNotes = [];
			}
			getModuleDocumentationList({moduleId: moduleId }).then(result => {
				if(result) {
					this.Step = 2;
					this.openModul = result;
				}
			}).catch(error => { });

		}
	}

	openDocument(event) {
		const moduleDocumeId = event.currentTarget.dataset.id;

		if(moduleDocumeId) {
			event.stopPropagation(); 
			const resultDocument = this.openModul.find(character => character.Id === moduleDocumeId);
			if(resultDocument) {
				this.openedDocument = resultDocument;
				this.Step = 3;
			}
		}
	}

	handleClickBack() {
		if(this.Step === 3) {
			this.Step = 2;
		} else if(this.Step === 2) {
			this.Step = 1;
		}
	}

	handleMouseLeave(){
		var divReleaseNote = this.template.querySelector('[data-type="divReleaseNote"]');
		if(divReleaseNote){
			this.template.querySelector('[data-type="divReleaseNote"]').classList.add('slds-hide');
			this.recordModuleReleaseNotes = [];
		}
	}

	handleMouseEnter(event){
		const moduleId = event.currentTarget.dataset.id;
		let element = this.template.querySelector('[data-id='+ moduleId + ']');
		let left = element.getBoundingClientRect().left;
		let top = element.getBoundingClientRect().top + 20;

		const result = this.recordReleaseNotes.find(character => character.moduleId === moduleId);
		if(result){
			this.recordModuleReleaseNotes = result.releaseNoteWrappers;
		}
		if(this.recordModuleReleaseNotes.length > 0) {
			this.cssTooltipStyle = 'left:' + left + 'px; top:' + top + 'px;';
			var divReleaseNote = this.template.querySelector('[data-type="divReleaseNote"]');
			if (divReleaseNote) {
				this.template.querySelector('[data-type="divReleaseNote"]').classList.remove('slds-hide');
			}
		}
	}

}