import {LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProjectId from '@salesforce/apex/AccountMilestonesLwcController.getProjectId';
import getMilestones from '@salesforce/apex/AccountMilestonesLwcController.getMilestones';

const columns = [
    { label: 'Milestone Task Name', fieldName: 'Name', type: 'link', hideDefaultActions: true	},
    { label: 'Estimated Milestone Complete Date', fieldName: 'RadEx__Estimated_Milestone_Complete_Date__c' , hideDefaultActions: true },
    { label: 'Milestone % Complete Bar', fieldName: 'RadEx__Milestone_Percent_Complete__c', hideDefaultActions: true },
];

export default class accountMilestones extends NavigationMixin(LightningElement) {


    projectId;
    errorId;
    errorData;
    existProject = false;
    columns = columns;
    dataFromMilestones;
    @api recordId;

    @wire(getProjectId, { goalId: '$recordId' })
    resultId(result){

        const { data, error } = result;

        if (data !== null) {

            this.existProject = true;
            this.projectId = data;

        } else if(data === null){

          this.existProject = false;

        } else if (error){

            this.errorId = error;
        }
    }

    @wire(getMilestones, { projectId: '$projectId' })
    resultData(result){

        const{data, error} = result;
        if(data){

            let dataModify = [];

            data.forEach(element => {

                let objectModify = new Object(null);

                for (let [keyItem, valueItem] of Object.entries(element)){

                    if(keyItem === 'RadEx__Milestone_Percent_Complete__c') {
                        valueItem = valueItem.split(':')[0];
                        objectModify[keyItem] = valueItem;
                    }  else {
                        objectModify[keyItem] = valueItem;
                    }
                }
                dataModify.push(objectModify)
            });

            this.dataFromMilestones = dataModify;
        } else if(error) {
            this.errorData = error;
        }
    }
}