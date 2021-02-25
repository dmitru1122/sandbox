import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import StaticResources from '@salesforce/resourceUrl/HubNavigator';

// METHODS
import getAuthList from '@salesforce/apex/HubMemberController.getAuthList';
import getHubMembersList from '@salesforce/apex/HubMemberController.getHubMembersList';
import getStatus from '@salesforce/apex/HubMemberController.getStatus';
import openInBrowser from '@salesforce/apex/HubMemberController.openInBrowser';
import getDataToAuth from '@salesforce/apex/HubMemberController.getDataToAuth';
import getResponseInfo from '@salesforce/apex/HubMemberController.getResponseInfo';
import runDeploy from '@salesforce/apex/HubMemberController.runDeploy';
import getHistory from '@salesforce/apex/HubMemberController.getHistory';
import hideHubMember from '@salesforce/apex/HubMemberController.hideHubMember';
import deAuthorizeHubMember from '@salesforce/apex/HubMemberController.deAuthorizeHubMember';
import setMetadataSourceOrg from '@salesforce/apex/HubMemberController.setMetadataSourceOrg';
import getTenantId from '@salesforce/apex/HubMemberController.getTenantId';

// CONSTANTS
const LOADING_DATA = 'Loading data';
const LINK_IS_EMPTY = 'Link is empty';
const INTERNAL_SERVER_ERROR = 'Internal server error';
const DO_NOT_UPDATE_LAYOUTS = 'DO NOT UPDATE LAYOUTS';
const UNLINKED = 'UNLINKED';
const ERROR_LOADING_HISTORY = 'Error loading history';

export default class HubNavigator extends NavigationMixin(LightningElement) {
  title = 'Hub Navigator';
  unauthorizedSourceOrg = 'Unauthorized source org';
  dateNA = 'N/A';
  showTablesDevObject = false;
  instanceType = 'https://login.salesforce.com';
  loginPostfix = '/services/oauth2/authorize?response_type=code&prompt=login';

  @track firstLoading = true;
  @track isLoading = true;
  @track isSomethingSelected = false;

  @track authList = [];
  @track hubMembersList = [];
  @track tables = [];

  // COUNT
  @track countAll = 0;
  @track showCurrentEemployment = false;
  @track countProcesses = 0;
  @track countCheckboxes = 0;
  @track countHidden = 0;
  @track modal = {
    show: false,
    type: null,
    body: null,
    title: null,
    message: null,
    submitLabel: null,
    isSubmitDisabled: true
  };

  // AUTO REFRESH
  @track currentTime = null;
  @track lastAutoRefresh = null;
  @track autoRefreshTimmer = null;
  @track isLoadingAutoRefresh = false;
  @track autoRefreshTime = 1000 * 60; // 1 minute
  @track autoRefreshTitle = null;

  // HISTORY
  @track modalHistory = {
    show: false,
    isLoading: true,
    orgId: null,
    list: [],
    title: null,
    sort: {
      startTime: {
        order: 'asc',
        class: null
      },
      sourceName: {
        order: null,
        class: null
      },
      username: {
        order: null,
        class: null
      },
    }
  };

  // MODAL DE-AUTHORIZE
  @track modalDeAuthorize = {
    show: false,
    title: null,
    message: null,
    submitLabel: null,
    id: null,
    ordId: null
  }

  connectedCallback () {
    Promise.all([
      loadStyle(this, StaticResources + '/style.css'),
    ]).then(() => {
      getAuthList()
        .then(responseAuthList => {
          this.parseAuthList(responseAuthList);

          getHubMembersList()
            .then(responseHubMembersList => {
              this.parseHubMembersList(responseHubMembersList);
              this.generateTableMap();
              this.setAutoRefreshTimmer();
            })
            .catch(error => {
              this.showToast ('error', LOADING_DATA, error);
            });
        })
        .catch(error => {
          this.showToast ('error', LOADING_DATA, error);
        });
    });
  }

  renderedCallback() {
    if (this.firstLoading) {
      this.firstLoading = !this.firstLoading;

      this.template.addEventListener('keyup', (event) => {
        if (event.key == 'Escape' && event.code == 'Escape') {

          if (this.modal.show) {
            this.onClickToCloseModalValidateDeploy();
          }

          if (this.modalHistory.show && this.modalDetail.show) {
            this.onClickToCloseModalDetail();
          } else if (this.modalHistory.show && !this.modalDetail.show) {
            this.onClickToCloseModalHistory();
          }

          if (this.modalDeAuthorize.show) {
            this.onClickToCloseModalDeAuthorize();
          }

          if (this.modalUnlink.show) {
            this.onClickToCloseModalUnlink();
          }

          if (this.modalLinkToSource.show) {
            this.onClickToCloseModalLinkToSource();
          }
        }
      });
    }
  }

  parseAuthList (list) {
    // console.group('PARSE AUTH LIST');
    this.authList = [];
    if (list && Array.isArray(list) && list.length && list.length > 0) {
      list.forEach(item => {
        // console.log(item);
        let result = {
          id: this.isNotEmptyString(item.Id) ? item.Id : null,
          accessToken: this.isNotEmptyString(item.AccessToken__c) ? item.AccessToken__c : null,
          authorisedUser: this.isNotEmptyString(item.AuthorisedUser__c) ? item.AuthorisedUser__c : null,
          connectedAppType: this.isNotEmptyString(item.Connected_App_Type__c) ? item.Connected_App_Type__c : null,
          createdById: this.isNotEmptyString(item.CreatedById) ? item.CreatedById : null,
          createdDate: this.isNotEmptyString(item.CreatedDate) ? this.getParsedDate(item.CreatedDate) : null,
          createdDateTitle: this.isNotEmptyString(item.CreatedDate) ? this.getParsedDateTime(item.CreatedDate) : null,
          instanceURL: this.isNotEmptyString(item.InstanceURL__c) ? item.InstanceURL__c : null,
          isDeleted: item.isDeleted ? item.isDeleted : false,
          isExpired: item.Is_Expired__c ? item.Is_Expired__c : false,
          lastModifiedById: this.isNotEmptyString(item.LastModifiedById) ? item.LastModifiedById : null,
          lastModifiedDate: this.isNotEmptyString(item.LastModifiedDate) ? this.getParsedDateTime(item.LastModifiedDate) : null,
          name: this.isNotEmptyString(item.Name) ? item.Name : null,
          refreshToken: this.isNotEmptyString(item.RefreshToken__c) ? item.RefreshToken__c : null,
          setupOwnerId: this.isNotEmptyString(item.SetupOwnerId) ? item.SetupOwnerId : null,
          systemModstamp: this.isNotEmptyString(item.SystemModstamp) ? this.getParsedDateTime(item.SystemModstamp) : null,
        };
        // console.log(result);
        this.authList.push(result);
      });
    }
    // console.groupEnd();
  }

  parseHubMembersList (list) {
    // console.group('PARSE HUB MEMBERS LIST');
    this.hubMembersList = [];
    if (list && Array.isArray(list) && list.length && list.length > 0) {
      list.forEach((item, index) => {
        // console.log('hubItem', item);
        if (item.Hide_From_Hub_Navigator__c == false) {
          let result = {
            id: item.Id,
            orgId: null,
            name: null,
            metadataSourceOrg: null,
            selected: false,
            authorized: false,
            unlinked: false,
            iconSort: null,
            progress: false,
            progressTime: null,
            duration: null,

            lastValidate: null,

            lastSuccess: null,
            lastSuccessTitle: null,
            lastSuccessSort: null,

            lastFailure: null,
            lastFailureTitle: null,
            lastFailureSort: null,

            authorisedUser: null,
            connectedAppType: null,
            instanceURL: null,
            refreshToken: null,
            isExpired: false,
            isDoNotUpdate: false,
            createdDate: null,

            // STATUS
            showStatus: false,
            status: null,
            statusIconName: null,
            statusVariant: null,
            statusTitle: null,
            class: 'table__tr',

            // ACTIONS
            isDisabledActions: true,
            showShowHistory: false,
            showHideFromHubNavigator: false,

            // UNLINK
            unlinkTitle: 'Unlink'
          };

          // IF DEV ORG OR SANDBOX
          if (this.isNotEmptyString(item.MemberEntity__c)) {
            result.orgId = item.MemberEntity__c;

            if (this.isNotEmptyString(item.Name)) {
              result.name = item.Name;
            }

            if (item.Metadata_Source_Org__r && this.isNotEmptyString(item.Metadata_Source_Org__r.Name__c)) {
              result.metadataSourceOrg = item.Metadata_Source_Org__r.Name__c;
            }

          // IF PROD ORG
          } else {
            if (this.isNotEmptyString(item.MemberEntity)) {
              result.orgId = item.MemberEntity;

              if (this.isNotEmptyString(item.DisplayName)) {
                result.name = item.DisplayName;
              }
    
              if (item.Metadata_Source_Org__r && this.isNotEmptyString(item.Metadata_Source_Org__r.DisplayName)) {
                result.metadataSourceOrg = item.Metadata_Source_Org__r.DisplayName;
              }
            }
          }

          // INJECTING AUTH LIST
          this.authList.forEach(authItem => {
            if (result.orgId && authItem.name && authItem.name.includes(result.orgId)) {
              result.authorized = true;
              result.orgId = authItem.name || null;
              result.authorisedUser = authItem.authorisedUser || null;
              result.connectedAppType = authItem.connectedAppType || null;
              result.instanceURL = authItem.instanceURL || null;
              result.refreshToken = authItem.refreshToken || null;
              result.isExpired = authItem.isExpired || false;
              result.createdDate = authItem.createdDate || false;
              result.createdDateTitle = authItem.createdDateTitle || false;
            }
          });

          // DO NOT UPDATE LAYOUTS
          if (this.isNotEmptyString(item.DO_NOT_UPDATE__c) && item.DO_NOT_UPDATE__c === DO_NOT_UPDATE_LAYOUTS) {
            result.isDoNotUpdate = true;
          }

          this.hubMembersList.push(result);
        } else if (item.Hide_From_Hub_Navigator__c == true) {
          this.countHidden++;
        }
      });

      // console.log(JSON.parse(JSON.stringify(this.authList)));
      // console.log(JSON.parse(JSON.stringify(this.hubMembersList)));

      // ACTIONS
      this.updateAction();
    }

    // console.groupEnd();
  }

  generateTableMap () {
    // console.group('GENERATE TABLE MAP');
    if (this.hubMembersList.length && this.hubMembersList.length == 0) return;

    this.tables = [];
    let tables = {};

    // PARSE UNIQUE TABLE GROUP KEYS
    let groupKeys = [];
    this.hubMembersList.forEach(item => {
      if(!groupKeys.includes(item.metadataSourceOrg)){
        groupKeys.push(item.metadataSourceOrg);
      }
    });
    groupKeys.sort();
    // console.log('groupKeys', groupKeys);

    // GENERATE TABLE GROUPS
    groupKeys.forEach(item => {
      let groupName = item || UNLINKED;
      tables[groupName] = {
        id: null,
        key: null,
        name: groupName,
        orgId: null,
        authorized: false,
        unlinked: false,
        list: [],

        // COUNT
        count: 0,
        countAuth: 0,
        countSelected: 0,
        selected: false,
        class: '',

        // SORT
        sort: {
          iconSort: {
            order: null,
            class: 'slds-truncate table__sort',
          },
          name: {
            order: null,
            class: 'slds-truncate table__sort',
          },
          lastSuccessSort: {
            order: null,
            class: 'slds-truncate table__sort',
          },
          lastSuccessSort: {
            order: null,
            class: 'slds-truncate table__sort',
          }
        }
      };

      if (groupName === UNLINKED) {
        tables[groupName].unlinked = true;
        tables[groupName].class += ' hub-navigator__tbody-unlinked';
      }
    });

    // PARSE GRUOP INFORAMTION
    this.hubMembersList.forEach(item => {
      if (!item.metadataSourceOrg && groupKeys.includes(item.name)) {
        tables[item.name].id = item.id;
        tables[item.name].key = item.name;
        tables[item.name].authorized = item.authorized;
        tables[item.name].orgId = item.orgId;
        tables[item.name].instanceURL = item.instanceURL;
        tables[item.name].refreshToken = item.refreshToken;
      }
    });

    // FILL GRUOP ITEMS
    this.hubMembersList.forEach(item => {
      let groupName = item.metadataSourceOrg || UNLINKED;
      if (!groupKeys.includes(item.name)) {
        tables[groupName].list.push(item);
        tables[groupName].count++;
        if (item.authorized && !item.unlinked) {
          tables[groupName].countAuth++;
        }
      }
    });
    // console.log('tables', tables);

    Object.keys(tables).sort().forEach((key, index) => {
      this.tables.push(tables[key]);
    });

    // SORT LISTS
    this.sortMainTableList();

    // console.groupEnd();
  }

  isNotEmptyString (str) {
    if (str && typeof (str) === 'string' && str.length && str.length > 0) {
      return true;
    }
    return false;
  }

  showToast (variant, title, message) {
    let variants = ['info', 'success', 'warning', 'error'];

    if (!(this.isNotEmptyString(variant) && variants.includes(variant))) {
      variant = 'info';
    }

    if (title) {
      if (typeof (title) !== 'string') {
        title = JSON.stringify(title);
      }
    } else {
      title = 'Something happened';
    }

    if (message) {
      if (typeof (message) !== 'string') {
        message = JSON.stringify(message);
      }
    } else {
      message = '';
    }

    this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
  }

  getParsedDateTime (dateString) {
    return this.getParsedDate(dateString) + ' ' + this.getParsedTime(dateString);
  }

  getParsedDate (dateString) {
    return new Date(dateString).toLocaleDateString();
  }

  getParsedTime (dateString) {
    return new Date(dateString).toLocaleTimeString();
  }

  onChangeGroupCheckbox (event) {
    if (event.target.hasAttribute('data-id')) {
      let id = event.target.getAttribute('data-id');
      let value = event.target.checked;
      this.tables.forEach(group => {
        group.selected = value || false;
        if (group.id == id) {
          group.list.forEach(item => {
            if (item.authorized && !item.unlinked && !item.progress && !item.isDoNotUpdate) item.selected = value || false;
            else item.selected = false;
          });
        }
      });
    }
    this.countNumberOfSelected();
  }

  @track lastSelectedId = null;
  @track lastSelectedGroupId = null;
  onClickItemCheckbox (event) {
    console.group('ONCLICK');
    if (event.shiftKey && event.target.hasAttribute('data-id') && event.target.hasAttribute('data-group-id')) {
      let id = event.target.getAttribute('data-id');
      let groupId = event.target.getAttribute('data-group-id');

      if (groupId == null || this.lastSelectedGroupId == null || groupId != this.lastSelectedGroupId) {
        this.lastSelectedId = null;
        this.lastSelectedGroupId = null;
        return;
      }

      // Get selected indexes
      let lastSelectedIndex = null;
      let selectIndex = null;
      if (this.lastSelectedId != null && this.lastSelectedGroupId != null && groupId == this.lastSelectedGroupId) {
        this.tables.forEach(group => {
          if (group.id == groupId) {
            group.list.forEach((item, index) => {
              if (item.id == this.lastSelectedId) lastSelectedIndex = index;
              if (item.id == id) selectIndex = index;
            });
          }
        });

        // Set selecting
        if (lastSelectedIndex != selectIndex) {
          this.lastSelectedId = id;
          this.lastSelectedGroupId = groupId;
  
          console.log('lastSelectedIndex', lastSelectedIndex);
          console.log('selectIndex', selectIndex);

          let minIndex;
          let maxIndex;
          if (lastSelectedIndex < selectIndex) {
            minIndex = lastSelectedIndex;
            maxIndex = selectIndex;
          } else {
            minIndex = selectIndex;
            maxIndex = lastSelectedIndex;
          }
          
          // Check selected items
          let isAllSelected = true;
          this.tables.forEach(group => {
            if (group.id == this.lastSelectedGroupId) {
              group.list.forEach((item, index) => {
                if (minIndex <= index && index <= maxIndex) {
                  if (!item.selected) isAllSelected = false;
                }
              });
            }
          });

          // Updated selected
          this.tables.forEach(group => {
            if (group.id == this.lastSelectedGroupId) {
              group.list.forEach((item, index) => {
                if (isAllSelected) {
                  if (minIndex <= index && index <= maxIndex) {
                    item.selected = false;
                  }
                } else {
                  if (minIndex <= index && index <= maxIndex) {
                    if (item.authorized && !item.unlinked && !item.progress && !item.isDoNotUpdate) {
                      item.selected = true;
                    }
                  }
                }
              });
            }
          });

          this.countNumberOfSelected();
        }

      } else {
        this.lastSelectedId = id;
        this.lastSelectedGroupId = groupId;
      }
    }
    console.groupEnd();
  }

  onChangeItemCheckbox (event) {
    if (event.target.hasAttribute('data-id')) {
      let id = event.target.getAttribute('data-id');
      let value = event.target.checked;
      this.tables.forEach(group => {
        group.list.forEach(item => {
          if (item.id == id) {
            this.lastSelectedId = id;
            this.lastSelectedGroupId = group.id;
            if (item.authorized && !item.unlinked) {
              item.selected = value || false;
            } else {
              item.selected = false;
            }
          }
        });
      });
    }
    this.countNumberOfSelected();
  }

  countNumberOfSelected () {
    let countAll = 0;
    let countProcesses = 0;
    let countCheckboxes = 0;

    this.tables.forEach(group => {
      let countSeleted = 0;
      let countInProcess = 0;

      let count = 0;
      let countAuth = 0;

      group.list.forEach(item => {
        count++;
        if (item.selected) countSeleted++;
        if (item.progress) {
          countInProcess++;
          countProcesses++;
        }

        if (
          !group.unlinked && group.authorized &&
          !item.unlinked && item.authorized &&
          !item.isDoNotUpdate
        ) {
          countAuth++;
        }
      });

      if (group.countAuth == countInProcess) {
        group.selected = false;
      } else if ((group.countAuth - countInProcess) == countSeleted) {
        group.selected = true;
      } else {
        group.selected = false;
      }

      group.count = count;
      group.countAuth = countAuth;
      group.countSelected = countSeleted;
      countAll += countSeleted;
      countCheckboxes += countAuth;
    });

    if (countAll > 0) {
      this.isSomethingSelected = true;
    } else {
      this.isSomethingSelected = false;
    }

    this.countAll = countAll;
    this.countProcesses = countProcesses;
    this.countCheckboxes = countCheckboxes;

    if (countProcesses > 0) {
      this.showCurrentEemployment = true;
    } else {
      this.showCurrentEemployment = false;
    }
  }

  //
  //  STATUSES
  //
  parseStatuses (response) {
    try {
      response = JSON.parse(response);
    } catch (e) {
      throw new Error('Can\'t parse response');
    }

    if (response.status == 'success') {

      // console.group('PARSE STATUSES');
      // console.log('response', response);
      // console.groupEnd();

      let listOfOptions = {};
      response.result.forEach(statusItem => {
        if (this.isNotEmptyString(statusItem.id)) {
          let options = {
            orgId: statusItem.id,
            status: {
              name: null,
              date: null, // number
            },
            progress: false, // boolean
            progressTime: null,
            lastSuccess: null, // number
            lastSuccessTitle: null,
            lastSuccessSort: null,
            lastFailure: null, // number
            lastFailureTitle: null,
            lastFailureSort: null,
            duration: null,
          };

          // STATUS
          if (
            statusItem.checkonly &&
            this.isNotEmptyString(statusItem.checkonly.status) &&
            (
              statusItem.checkonly.status.toLowerCase() == 'finished' ||
              statusItem.checkonly.status.toLowerCase() == 'error'
            ) &&
            statusItem.checkonly.date
          ) {
            if (statusItem.checkonly.status.toLowerCase() == 'finished') {
              options.status.name = 'success';
            } else {
              options.status.name = statusItem.checkonly.status.toLowerCase();
            }
            options.status.date = this.getParsedDateTime(statusItem.checkonly.date) || null;
          }

          // LAST VALIDATE
          if (options.status.date) {
            options.lastValidate = statusItem.checkonly.date;
          }

          // LAST SUCCESS
          if (statusItem.success) {
            options.lastSuccess = this.getParsedDate(statusItem.success) || null;
            options.lastSuccessTitle = this.getParsedDateTime(statusItem.success) || null;
            options.lastSuccessSort = statusItem.success || null;
          }

          // LAST FAILURE
          if (statusItem.error) {
            options.lastFailure = this.getParsedDate(statusItem.error) || null;
            options.lastFailureTitle = this.getParsedDateTime(statusItem.error) || null;
            options.lastFailureSort = statusItem.error || null;
          }

          // PROGRESS
          if (statusItem.progress != undefined) {
            options.progress = statusItem.progress ? true : false;
            options.progressTime = statusItem.progress;
          }

          // DURATION
          if (!options.progress && statusItem.duration) {
            options.duration = this.getParsedDuration(statusItem.duration);
          }

          // console.log(listOfOptions);
          listOfOptions[options.orgId] = options;
        }
      });

      this.setStatuses(listOfOptions);

    } else {
      throw new Error('Can\'t get statuses');
    }
  }

  setStatuses (listOfOptions) {
    // console.group('SET STATUSES');
    // console.log('listOfOptions', listOfOptions);
    this.tables.forEach(group => {
      group.list.forEach(item => {

        if (Object.keys(listOfOptions).includes(item.orgId)) {
          // SET VALUES
          // if (item.orgId == options.orgId) {
            if (listOfOptions[item.orgId].status.name) {
              item.status = listOfOptions[item.orgId].status.name;
              item.iconSort = listOfOptions[item.orgId].status.name;
              item.statusIconName = `utility:${listOfOptions[item.orgId].status.name}`;
              item.statusVariant = listOfOptions[item.orgId].status.name;
  
              if (listOfOptions[item.orgId].status.date) {
                if (listOfOptions[item.orgId].status.name == 'success') {
                  item.statusTitle = `Validation Succeeded on ${listOfOptions[item.orgId].status.date}`;
                  item.statusVariant = null;
                } else if (listOfOptions[item.orgId].status.name == 'error') {
                  item.statusTitle = `Validation Faield on ${listOfOptions[item.orgId].status.date}`;
                }
              }
              item.showStatus = true;
            }
  
            // PROGRESS
            if (listOfOptions[item.orgId].progress != null) {
              item.progress = listOfOptions[item.orgId].progress;
              if (listOfOptions[item.orgId].progress === true && listOfOptions[item.orgId].progressTime) {
                item.iconSort = 'progress';
                item.selected = false;
                item.progressTime = listOfOptions[item.orgId].progressTime;
              }
            }
  
            // OTHER OPTIONS
            if (listOfOptions[item.orgId].lastSuccess) item.lastSuccess = listOfOptions[item.orgId].lastSuccess;
            if (listOfOptions[item.orgId].lastSuccessTitle) item.lastSuccessTitle = listOfOptions[item.orgId].lastSuccessTitle;
            if (listOfOptions[item.orgId].lastSuccessSort) item.lastSuccessSort = listOfOptions[item.orgId].lastSuccessSort;
            if (listOfOptions[item.orgId].lastFailure) item.lastFailure = listOfOptions[item.orgId].lastFailure;
            if (listOfOptions[item.orgId].lastFailureTitle) item.lastFailureTitle = listOfOptions[item.orgId].lastFailureTitle;
            if (listOfOptions[item.orgId].lastFailureSort) item.lastFailureSort = listOfOptions[item.orgId].lastFailureSort;
            if (listOfOptions[item.orgId].lastValidate) item.lastValidate = listOfOptions[item.orgId].lastValidate;
            if (listOfOptions[item.orgId].duration) item.duration = listOfOptions[item.orgId].duration;
          // }
        } else {
          // SET DEFAULT VALUES
          item.showStatus = false;
          item.status = null;
          item.statusIconName = null;
          item.statusTitle = null;
          item.statusVariant = null;
          item.iconSort = null;
          item.lastValidate = null;
          item.lastSuccess = null;
          item.lastSuccessTitle = null;
          item.lastSuccessSort = null;
          item.lastFailure = null;
          item.lastFailureTitle = null;
          item.lastFailureSort = null;
        }

      });
    });
    this.updateAction();
    this.updateRowClass();
    this.updateProgressDuration();
    this.countNumberOfSelected();
    // console.groupEnd();
  }

  updateRowClass () {
    this.tables.forEach(group => {
      group.list.forEach(item => {
        let trClass = 'table__tr';

        if (item.progress) {
          trClass += ' table__tr-progress';
        } else {
          if (this.isNotEmptyString(item.status)) {
            if (item.status == 'success') {
              trClass += ' table__tr-validate';
  
            } else if (item.status == 'error') {
              trClass += ' table__tr-error';
            }
          }
        }

        if (item.isDoNotUpdate) {
          trClass += ' table__tr-donotupdate';
        }

        item.class = trClass;
      });
    });
  }

  //
  //  AUTO REFRESHS
  //
  setAutoRefreshTimmer (handleStart) {
    this.currentTime = Math.ceil(new Date().getTime() / 1000);
    if (this.autoRefreshTimmer) clearInterval(this.autoRefreshTimmer);

    if (handleStart) {
      this.autoRefreshTitle = null;
      this.isLoadingAutoRefresh = true;
    }

    if ((this.isLoading && this.lastAutoRefresh == null) || handleStart) {
      getStatus()
        .then(responseStatuses => {
          this.parseStatuses(responseStatuses);
          this.lastAutoRefresh = Math.ceil(new Date().getTime() / 1000);
          this.isLoading = false;
          this.isLoadingAutoRefresh = false;
        })
        .catch(error => {
          console.error(error);
          this.isLoading = false;
          this.isLoadingAutoRefresh = false;
          this.showToast ('error', LOADING_DATA, error.message);
        });
    }

    this.autoRefreshTimmer = window.setInterval(() => {
      if (!this.isLoadingAutoRefresh && !this.isLoading && this.lastAutoRefresh != null) {
        let difference = this.currentTime - this.lastAutoRefresh; 
        let autoRefreshTime = this.autoRefreshTime / 1000;
  
        if (difference < autoRefreshTime  && difference >= autoRefreshTime - 5) {
          this.autoRefreshTitle = `Refresh in ${autoRefreshTime - difference} second(s)`;
          
        } else if (difference >= autoRefreshTime) {
          this.autoRefreshTitle = null;
          this.isLoadingAutoRefresh = true;

          // GET STATUSES
          getStatus()
            .then(responseStatuses => {
              this.parseStatuses(responseStatuses);
              this.lastAutoRefresh = Math.ceil(new Date().getTime() / 1000);
              this.isLoadingAutoRefresh = false;
            })
            .catch(error => {
              console.error(error);
              this.isLoadingAutoRefresh = false;
              this.showToast ('error', LOADING_DATA, error.message);
            });

          // GET HISTORY
          if (this.modalHistory.show && !this.modalHistory.isLoading && this.modalHistory.orgId)  {
            getHistory({ orgId: this.modalHistory.orgId })
              .then(response => {
                if (this.isNotEmptyString(response)) {
                  response = JSON.parse(response);
                  if (response.status == 'success') {
                    this.parseHistory(response.result);
                    this.sortHistoryTableList();
                    this.modalHistory.isLoading = false;
    
                  } else {
                    this.onClickToCloseModalHistory();
                    this.showToast ('error', ERROR_LOADING_HISTORY);
                  }
                } else {
                  this.onClickToCloseModalHistory();
                  this.showToast ('error', ERROR_LOADING_HISTORY);
                }
                
              })
              .catch(error => {
                this.onClickToCloseModalHistory();
                this.showToast ('error', LOADING_DATA, error);
              });
          }

        } else {
          this.autoRefreshTitle = null;
        }
      }

      this.updateProgressDuration();
      this.currentTime++;
    }, 1000);

  }

  onClickToRefresh () {
    this.setAutoRefreshTimmer(true);
  }

  updateProgressDuration () {
    // MAIN TABLES
    this.tables.forEach(group => {
      group.list.forEach(item => {
        if (item.progress && item.progressTime) {
          item.duration = this.getParsedDuration((this.currentTime * 1000) - item.progressTime);
        } else if (item.status == 'error') {
          item.duration = null;
        }
      });
    });

    // MODAL HISTORY
    if (this.modalHistory.show) {
      this.modalHistory.list.forEach(item => {
        if (item.isProcess) {
          item.duration = this.getParsedDuration((this.currentTime * 1000) - item.startTime);
        }
      });
    }
  }

  //
  //  ACTIONS
  //
  updateAction () {
    this.tables.forEach(group => {
      group.list.forEach(item => {
        item.isDisabledActions = false;

        if (group.name == UNLINKED) {
          item.showHideFromHubNavigator = true;
          
        } else {
          item.showHideFromHubNavigator = false;
          if (item.authorized || item.lastSuccess || item.lastFailure) {

            if (item.lastSuccess || item.lastFailure || item.lastValidate) {
              item.showShowHistory = true;
            } else {
              item.showShowHistory = false;
            }
          }

          // UNLINK
          if (group.name) {
            item.unlinkTitle = `Unlink from "${group.name}"`;
          }
        }
      });
    });
  }

  hideHubItemById (id) {
    this.tables.forEach(group => {
      let hubIndex = -1;
      group.list.forEach((item, index) => {
        if (item.id == id) hubIndex = index
      });
      if (hubIndex != -1) {
        group.list.splice(hubIndex, 1);
      }
    });
  }

  onClickOpenInBrowser (event) {
    if (event.target.value && event.target.value == 'openInBrowser' && event.target.hasAttribute('data-org-id')) {
      openInBrowser({orgId : event.target.getAttribute('data-org-id')})
        .then(response => {
          if (this.isNotEmptyString(response)) {
            this.navigateToUrl(response);
          } else {
            this.showToast ('error', LINK_IS_EMPTY);
          }
        })
        .catch(error => {
          this.showToast ('error', LOADING_DATA, error);
        });
    }
  }

  onClickShowHistory (event) {
    if (event.target.value && event.target.value == 'showHistory' && event.target.hasAttribute('data-org-id')) {
      let itemHub = null;
      this.tables.forEach(group => {
        group.list.forEach(item => {
          if (item.orgId == event.target.getAttribute('data-org-id')) {
            itemHub = item;
          }
        });
      });

      if (itemHub) {
        // HUB INFORATION
        this.modalHistory.title = itemHub.name;
        this.modalHistory.orgId = event.target.getAttribute('data-org-id');
        this.modalHistory.show = true;

        getHistory({ orgId: this.modalHistory.orgId })
          .then(response => {
            // console.group('GET HISTORY');
            // console.log(response);
            // console.groupEnd();
            if (this.isNotEmptyString(response)) {
              response = JSON.parse(response);
              if (response.status == 'success') {
                this.parseHistory(response.result);
                this.sortHistoryTableList();
                this.modalHistory.isLoading = false;

              } else {
                this.onClickToCloseModalHistory();
                this.showToast ('error', ERROR_LOADING_HISTORY);
              }
            } else {
              this.onClickToCloseModalHistory();
              this.showToast ('error', ERROR_LOADING_HISTORY);
            }
            
          })
          .catch(error => {
            this.onClickToCloseModalHistory();
            this.showToast ('error', LOADING_DATA, error);
          });
      }
    }
  }

  onClickHideFromHubNavigator (event) {
    if (event.target.value && event.target.value == 'hideFromHubNavigator' && event.target.hasAttribute('data-id')) {
      let id = event.target.getAttribute('data-id');
      hideHubMember({ id })
        .then(response => {
          if (response) {
            this.hideHubItemById(id);
            this.countHidden++;
          } else {
            this.showToast ('error', 'Can\'t hide this member, try again later');
          }
        })
        .catch(error => {
          console.error(error);
          this.showToast ('error', INTERNAL_SERVER_ERROR);
        });
    }
  }

  onClickDeAuthorize (event) {
    if (
      event.target.value && event.target.value == 'deAuthorize'&&
      event.target.hasAttribute('data-id') && event.target.hasAttribute('data-org-id')
    ) {
      let id = event.target.getAttribute('data-id');
      let ordId = event.target.getAttribute('data-org-id');
      let itemHub = null;

      this.tables.forEach(group => {
        group.list.forEach(item => {
          if (item.orgId == ordId) itemHub = item;
        });
      });

      if (itemHub) {
        this.modalDeAuthorize.id = id;
        this.modalDeAuthorize.ordId = ordId;
        this.modalDeAuthorize.title = 'De-Authorize Org';
        this.modalDeAuthorize.message = `You really want to delete the authorization for "${itemHub.name}"`;
        this.modalDeAuthorize.submitLabel = 'Yes, Delete the authorization';
        this.modalDeAuthorize.show = true;
      }
    }
  }

  //
  //  BUTTONS
  //
  get isDisabledValidationButton () {
    return !this.isSomethingSelected;
  }

  get isDisabledDeployButton () {
    return !this.isSomethingSelected;
  }

  getLoginUrl () {
    return this.instanceType + this.loginPostfix;
  }

  onClickToNewAuthorize () {
    let loginUrl = this.getLoginUrl();

    if (this.isNotEmptyString(loginUrl)) {
      getDataToAuth()
        .then(response => {
          let dataToAuth = JSON.parse(response);

          if (
            dataToAuth.creds &&
            dataToAuth.dataLI &&
            this.isNotEmptyString(dataToAuth.creds.Consumer_Key_Auto__c) &&
            this.isNotEmptyString(dataToAuth.creds.Redirect_URL_Hub__c)
          ) {
            let dataLI = JSON.stringify(dataToAuth.dataLI);

            loginUrl += '&client_id=' + encodeURI(dataToAuth.creds.Consumer_Key_Auto__c);
            loginUrl += '&redirect_uri=' + encodeURI(dataToAuth.creds.Redirect_URL_Hub__c);
            loginUrl += '&state=' + encodeURI(dataLI);

            this.navigateToUrl(loginUrl);
          }
        })
        .catch(error => {
          this.showToast ('error', LOADING_DATA, error);
        });
    }
  }

  navigateToUrl (url) {
    if (this.isNotEmptyString(url)) {
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {url}
      });
    }
  }

  onClickToValidation () {
    this.modal.title = 'Run Validation';
    this.modal.message = `You are going to apply on ${this.countAll} org(s).`;
    this.modal.submitLabel = 'Yes, I need to validate';
    this.prepareValidationDeploy('validate');
  }

  onClickToDeploy () {
    this.modal.title = 'Run Deploy';
    this.modal.message = `You are going to apply on ${this.countAll} org(s).`;
    this.modal.submitLabel = 'Yes, I need to deploy';
    this.prepareValidationDeploy('deploy');
  }

  prepareValidationDeploy (type) {
    getTenantId()
      .then(currTenantId => {
        getResponseInfo()
          .then(response => {
            // console.group('GET RESPONSE INFO');
            response = JSON.parse(response);
            // console.log(response);

            this.modal.body = {
              prod: response.prod || false, // true/false - production/sandbox
              tenantId: currTenantId,
              test_mode: type == 'validate' ? true : false, // true/false - валидация/деплой
              executor: {
                id: response.executor && response.executor.id || null, 
                name: response.executor && response.executor.name || null, 
                email: response.executor && response.executor.email || null, 
              },
              tasks: []
            };

            this.tables.forEach(group => {
              let isSelected = false;
              let targets = [];

              group.list.forEach(item => {
                if (item.selected) {
                  targets.push({
                    id: item.orgId,
                    name: item.name,
                    instance_uri: item.instanceURL,
                    refresh_token: item.refreshToken
                  });
                  isSelected = true;
                }
              });

              if (isSelected) {
                this.modal.body.tasks.push({
                  id: group.orgId,
                  name: group.name,
                  instance_uri: group.instanceURL,
                  refresh_token: group.refreshToken,
                  targets
                });
              }
            });

            this.modal.isSubmitDisabled = false;
            this.modal.type = type;
            this.modal.show = true;

            // console.log(JSON.parse(JSON.stringify(this.modal.body)));
            // console.groupEnd();
          })
          .catch(error => {
            console.error(error);
            this.showToast ('error', LOADING_DATA, error);
          });
      })
    
  }

  onClickToCloseModalValidateDeploy () {
    this.modal = {
      show: false,
      type: null,
      body: null,
      title: null,
      message: null,
      submitLabel: null,
      isSubmitDisabled: true
    };
  }

  onClickToSubmitModalValidateDeploy () {
    if (this.modal.type && this.modal.body) {
      runDeploy({body: JSON.stringify(this.modal.body)})
        .then(response => {
          try {
            response = JSON.parse(response);
          } catch (e) {
            throw new Error('Can\'t parse response');
          }
  
          if (response.status == 'success') {
            // Close modal
            this.onClickToCloseModalValidateDeploy();

            // Get statuses
            setTimeout(() => {
              getStatus()
                .then(responseStatuses => {
                  this.parseStatuses(responseStatuses);
                  this.countNumberOfSelected();
                })
                .catch(error => {
                  console.error(error);
                  this.showToast ('error', LOADING_DATA, error.message);
                });
            }, 500);

          } else {
            if (this.isNotEmptyString(response.message)) {
              this.showToast ('error', response.message);
            } else {
              if (this.modal.type == 'validate') {
                this.showToast ('success', 'Validation started');
              } else if (this.modal.type == 'deploy') {
                this.showToast ('success', 'Deploy started');
              }
              console.error(response);
            }
          }
          
        })
        .catch(error => {
          console.error(error);
          this.showToast ('error', error.message);
        });
    }
  }

  //
  //  HISTORY
  //
  parseHistory (list) {
    // console.group('PARSE HISTORY');
    this.modalHistory.list = [];
    if (list && Array.isArray(list) && list.length && list.length > 0) {
      // console.log('list', list);

      list.forEach((item, index) => {
        let result = {
          index,
          sourceId: item.source && this.isNotEmptyString(item.source.id) ? item.source.id : null,
          sourceName: item.source && this.isNotEmptyString(item.source.name) ? item.source.name : null,
          runId: item.runId ? item.runId : null,
          mode: item.testMode ? 'validate' : 'deploy', // true/false - валидация/деплой
          status: null,
          statusTitle: null,
          isProcess: false,
          startTime: item.started ? item.started : null,
          startDate: item.started ? this.getParsedDate(item.started) : null,
          startDateTime: item.started ? this.getParsedTime(item.started) : null,
          startDateTitle: item.started ? this.getParsedDateTime(item.started) : null,
          finishDate: item.finished ? this.getParsedDate(item.finished) : null,
          finishDateTime: item.finished ? this.getParsedTime(item.finished) : null,
          finishDateTitle: item.finished ? this.getParsedDateTime(item.finished) : null,
          durationTime: null,
          duration: null,
          fromVersion: this.isNotEmptyString(item.fromVersion) ? item.fromVersion : null,
          toVersion: this.isNotEmptyString(item.toVersion) ? item.toVersion : null,
          versionTitle: null,
          errorMessage: this.isNotEmptyString(item.error) ? item.error : null,

          // style
          class: 'table__tr',
          statusIconName: 'utility:success',
          statusVariant: null,

          isDisabledActions: item.runId ? false : true,

          // USER / EXECUTOR
          username: item.user && this.isNotEmptyString(item.user.name) ? item.user.name : '',

          // AGENT
          agentMessage: null,
          agentName: null,
          agentVersion: null,

          // COMPONENTS
          components: []
        };

        // STATUS
        if (this.isNotEmptyString(item.status)) {
          if (item.status == 'finished') {
            result.status = 'success';

          } else if (item.status == 'error') {
            result.status = 'error';
            result.class += ' table__tr-error';
            result.statusIconName = 'utility:error';
            result.statusVariant = 'error';
            
          } else if (item.status == 'created') {
            result.status = 'created';
            result.isProcess = true;
            result.class += ' table__tr-progress';

          } else if (item.status == 'started') {
            result.status = 'started';
            result.isProcess = true;
            result.class += ' table__tr-progress';
            
          } else if (item.status == 'cancelled') {
            result.status = 'cancel';
            result.statusIconName = 'utility:close';
            result.statusVariant = 'error';
          }
        }

        // STATUS TITLE
        if (result.mode == 'deploy') {
          if (result.status == 'success') {
            result.statusTitle = 'Deployment success';
            result.class += ' table__tr-success';
            result.statusVariant = 'success';

          } else if (result.status == 'error') result.statusTitle = 'Deployment error';
          else if (result.status == 'created') result.statusTitle = 'Deployment is created';
          else if (result.status == 'started') result.statusTitle = 'Deployment in process';
          else if (result.status == 'cancel') result.statusTitle = 'Deployment сancelled';

        } else if (result.mode == 'validate') {
          result.class += ' table__tr-validate';
          if (result.status == 'success') result.statusTitle = 'Validation success';
          else if (result.status == 'error') {
            result.class += ' table__tr-error';
            result.statusTitle = 'Validation error';
          }
          else if (result.status == 'created') result.statusTitle = 'Validate is created';
          else if (result.status == 'started') result.statusTitle = 'Validate in process';
          else if (result.status == 'cancel') {
            result.class += ' table__tr-сancelled';
            result.statusTitle = 'Validation сancelled';
          }
        }

        // DURATION
        if (item.started && item.finished) {
          result.durationTime = item.finished - item.started;
        }
        if (result.durationTime) {
          result.duration = this.getParsedDuration(result.durationTime);
        }

        if (result.isProcess) {
          result.duration = this.getParsedDuration((this.currentTime * 1000) - result.startTime);
        }

        // VERSION
        if (!result.fromVersion && !result.toVersion) {
          result.versionTitle = '-';
        } else {
          result.versionTitle = `${result.fromVersion || '-'} -> ${result.toVersion || '-'}`
        }

        // AGENT
        if (item.agent && this.isNotEmptyString(item.agent.name) && this.isNotEmptyString(item.agent.version)) {
          result.agentMessage = `Agent: ${item.agent.name} ; Version: ${item.agent.version}`
          result.agentName = item.agent.name
          result.agentVersion = item.agent.version
        }

        // COMPONENTS
        if (item.components) {
          result.components = [];
          Object.keys(item.components).forEach((key, index) => {
            result.components.push({
              index,
              name: key.slice(0,1).toUpperCase() + key.slice(1),
              deploy: item.components[key].deploy || 0,
              exclude: item.components[key].exclude || 0
            });
          });
        }
  
        this.modalHistory.list.push(result);
      });

      // console.log(JSON.parse(JSON.stringify(this.modalHistory.list)));
    }
    // console.groupEnd();
  }

  getParsedDuration (durationTime) {
    // console.log('durationTime', durationTime)
    if (durationTime <= 0) return null;

    let hour = null;
    let min = null;
    let sec = null;

    let tmpDuration = Math.trunc(durationTime / 1000); // All seconds
    if (Math.trunc(tmpDuration / (60 * 60)) != 0) {
      hour = Math.trunc(tmpDuration / (60 * 60));
      tmpDuration -= hour * 60 * 60;
    }
    if (Math.trunc(tmpDuration / 60) != 0) {
      min = Math.trunc(tmpDuration / 60);
      tmpDuration -= min * 60;
    }
    sec = tmpDuration;

    let result = '';
    if (hour) result += hour + ' hr ';

    if (min) result += min + ' min ';
    if (! min && hour) result += '0 min';

    if (sec) result += sec + ' sec';
    if (!sec && (hour || min)) result += '0 sec';

    return result || null;
  }

  onClickToCloseModalHistory () {
    this.modalHistory.show = false;
    this.modalHistory.isLoading = true;
    this.modalHistory.orgId = null;
    this.modalHistory.list = [];
    this.modalHistory.title = null;
  }

  onClickDetails (event) {
    if (event.target.value && event.target.value == 'details' && event.target.hasAttribute('data-run-id')) {
      // console.group('ONCLICK DETAILS');
      let runId = event.target.getAttribute('data-run-id');
      // console.log('runId', runId);
      this.showModalDetail(runId);
      // console.groupEnd();
    }
  }

  //
  //  MODAL DE-AUTHORIZE
  //
  deAuthorizeTableItem (id, ordId) {
    this.tables.forEach(group => {
      group.list.forEach(item => {
        if (item.id == id && item.orgId == ordId) {
          item.authorisedUser = null;
          item.connectedAppType = null;
          item.instanceURL = null;
          item.refreshToken = null;
          item.authorized = false;
          item.orgId = item.id;
          item.showStatus = false;
          item.status = null;
          item.statusIconName = null;
          item.statusTitle = null;
          item.statusVariant = null;
          item.selected = false;
        }
      });
    });

    this.onClickToCloseModalDeAuthorize();
    this.updateAction();
    this.updateRowClass();
    this.countNumberOfSelected();
  }

  onClickToCloseModalDeAuthorize () {
    this.modalDeAuthorize.show = false;
    this.modalDeAuthorize.title = null;
    this.modalDeAuthorize.message = null;
    this.modalDeAuthorize.submitLabel = null;
    this.modalDeAuthorize.id = null;
    this.modalDeAuthorize.ordId = null;
  }

  onClickToSubmitModalDeAuthorize () {
    if (this.modalDeAuthorize.id && this.modalDeAuthorize.ordId) {
      deAuthorizeHubMember({ orgId: this.modalDeAuthorize.ordId })
        .then(response => {
          if (response) {
            this.deAuthorizeTableItem(this.modalDeAuthorize.id, this.modalDeAuthorize.ordId);
            this.showToast ('success', 'Authorization was successfully deleted');
          } else {
            this.showToast ('error', 'Authorization not removed, please try again later');
          }
        })
        .catch(error => {
          console.error(error);
          this.showToast ('error', INTERNAL_SERVER_ERROR);
        });
    }
  }

  //
  //  SORTING
  //
  orderOptions = ['asc', 'desc'];
  mainTableSortingColumns = ['name', 'iconSort', 'lastSuccessSort', 'lastFailureSort'];
  historyTableSortingColumns = ['startTime'];

  onClickToSortMainTable (event) {
    if (event.target.hasAttribute('data-key') && event.target.hasAttribute('data-group-name')) {
      let key = event.target.getAttribute('data-key');
      let groupName = event.target.getAttribute('data-group-name');
      this.sortMainTableList(key, groupName);
    }
  }

  sortMainTableList (key, groupName) {
    // console.group('SORT MAIN TABLE LIST');
    // console.log(JSON.parse(JSON.stringify(this.tables)));
    // console.log('key', key);
    // console.log('groupName', groupName);

    if (!this.isNotEmptyString(key) || !this.mainTableSortingColumns.includes(key)) {
      key = this.mainTableSortingColumns[0];
    }

    if (!this.isNotEmptyString(groupName)) groupName = 'all';

    this.tables.forEach(group => {
      if (groupName == 'all' || group.name == groupName) {
        let previousOrder = null;

        // Set default sort
        this.mainTableSortingColumns.forEach(itemKey => {
          if (key == itemKey) {
            previousOrder = group.sort[itemKey].order;
          }

          group.sort[itemKey] = {
            order: null,
            class: 'slds-truncate table__sort'
          };
        });

        // Update sort settings
        let order = this.orderOptions[0];
        let sortClass = 'slds-truncate table__sort';

        if (this.isNotEmptyString(previousOrder)) {
          if (previousOrder == this.orderOptions[0]) order = this.orderOptions[1];
          else if (previousOrder == this.orderOptions[1]) order = this.orderOptions[0];
        }

        if (this.isNotEmptyString(order) && this.orderOptions.includes(order)) {
          sortClass += ' table__sort-' + order;
        }

        group.sort[key] = {
          order,
          class: sortClass
        };

        let tmpNullItems = [];
        let tmpDoNotUpdateItems = [];
        let tmpNotAuthItems = [];
        let tmpNotNullItems = [];

        group.list.forEach(item => {
          if (item.isDoNotUpdate) tmpDoNotUpdateItems.push(item);
          else if (!item.authorized) tmpNotAuthItems.push(item);
          else if (item[key]) tmpNotNullItems.push(item);
          else tmpNullItems.push(item);
        });

        this.sortArray(tmpNotNullItems, key, order);
        this.sortArray(tmpNullItems, key, order);
        this.sortArray(tmpNotAuthItems, key, order);
        this.sortArray(tmpDoNotUpdateItems, key, order);

        group.list = tmpNotNullItems.concat(tmpNullItems).concat(tmpNotAuthItems).concat(tmpDoNotUpdateItems);
      }
    });
    // console.groupEnd();
  }

  sortArray (arr, key, order) {
    return arr.sort((a, b) => {
      if (order == this.orderOptions[1]) {
        if (a[key] > b[key]) return -1;
        if (a[key] < b[key]) return 1;
        return 0;
      } else {
        if (a[key] > b[key]) return 1;
        if (a[key] < b[key]) return -1;
        return 0;
      }
    });
  }

  onClickToSortHistoryTable (event) {
    if (event.target.hasAttribute('data-key')) {
      let key = event.target.getAttribute('data-key');
      this.sortHistoryTableList(key);
    }
  }

  sortHistoryTableList (key) {
    if (!this.isNotEmptyString(key) || !this.historyTableSortingColumns.includes(key)) {
      key = this.historyTableSortingColumns[0];
      this.modalHistory.sort[key].order = 'asc';
    }

    let previousOrder = null;

    // Set default sort
    this.historyTableSortingColumns.forEach(itemKey => {
      if (key == itemKey) {
        previousOrder = this.modalHistory.sort[itemKey].order;
      }
      this.modalHistory.sort[itemKey].order = null;
      this.modalHistory.sort[itemKey].class = 'slds-truncate table__sort';
    });

    // Update sort settings
    let order = this.orderOptions[0];
    let sortClass = 'slds-truncate table__sort';

    if (this.isNotEmptyString(previousOrder)) {
      if (previousOrder == this.orderOptions[0]) order = this.orderOptions[1];
      else if (previousOrder == this.orderOptions[1]) order = this.orderOptions[0];
    }

    if (this.isNotEmptyString(order) && this.orderOptions.includes(order)) {
      sortClass += ' table__sort-' + order;
    }

    this.modalHistory.sort[key].order = order;
    this.modalHistory.sort[key].class = sortClass;

    // Sort
    if (order == this.orderOptions[1]) {
      this.modalHistory.list.sort((a, b) => {
        if (a[key] > b[key]) return -1;
        if (a[key] < b[key]) return 1;
        return 0;
      });
    } else {
      this.modalHistory.list.sort((a, b) => {
        if (a[key] > b[key]) return 1;
        if (a[key] < b[key]) return -1;
        return 0;
      });
    }
  }

  //
  //  MODAL DETAIL
  //
  @track modalDetail = {
    show: false,
    detail: null
  }

  showModalDetail (runId) {
    // console.group('SHOW MODAL DETAIL');
    this.modalHistory.list.forEach(item => {
      if (item.runId == runId) {
        // console.log(JSON.parse(JSON.stringify(item)));
        this.modalDetail.detail = JSON.parse(JSON.stringify(item));
      }
    });
    this.modalDetail.show = true;
    // console.groupEnd();
  }

  onClickToCloseModalDetail () {
    this.modalDetail.show = false;
    this.modalDetail.detail = null;
  }

  //
  // UNLINK
  //
  @track modalUnlink = {
    show: false,
    id: null,
    groupId: null,
    title: null,
    message: null
  };

  onClickUnlink (event) {
    if (
      event.target.value && event.target.value == 'unlinkHubNavigator' &&
      event.target.hasAttribute('data-id') && event.target.hasAttribute('data-group-id')
    ) {
      let id = event.target.getAttribute('data-id');
      let groupId = event.target.getAttribute('data-group-id');

      this.tables.forEach(group => {
        group.list.forEach(item => {
          if (item.id == id) {
            this.modalUnlink.title = `Unlink "${item.name}"`;
            this.modalUnlink.message = `Are you sure to unlink "${item.name}" from "${group.name}"?`;
            this.modalUnlink.id = id;
            this.modalUnlink.groupId = groupId;
            this.modalUnlink.show = true;
          }
        });
      });
    }
  }

  onClickToCloseModalUnlink () {
    this.modalUnlink.show = false;
    this.modalUnlink.id = null;
    this.modalUnlink.groupId = null;
    this.modalUnlink.title = null;
    this.modalUnlink.message = null;
  }

  onClickToSubmitModalUnlink () {
    if (this.modalUnlink.id && this.modalUnlink.groupId) {
      setMetadataSourceOrg({ id: this.modalUnlink.id, sourceOrgId: null })
        .then (response => {
          if (response) {

            // Search and remove item
            let itemOrg = null;
            this.tables.forEach(group => {
              if (group.id == this.modalUnlink.groupId) {
                let deleteIndex = null;

                group.list.forEach((item, index) => {
                  if (item.id == this.modalUnlink.id) {
                    deleteIndex = index;
                    itemOrg = JSON.parse(JSON.stringify(item));
                  }
                });

                if (deleteIndex != null) {
                  group.list.splice(deleteIndex, 1);
                }
              }
            });

            // Push item to unlinked
            if (itemOrg) {
              this.tables.forEach(group => {
                if (group.name == UNLINKED) {
                  group.list.push(itemOrg);
                }
              });
            }

            this.updateAction();
            this.countNumberOfSelected();
            this.sortMainTableList();
            this.sortMainTableList();

            this.showToast ('success', 'Link removed successfully');
          } else {
            this.showToast ('error', 'Can\'t to delete link');
          }

          this.onClickToCloseModalUnlink();
        })
        .catch (error => {
          this.onClickToCloseModalUnlink();
          this.showToast ('error', INTERNAL_SERVER_ERROR, error);
        });
    }
  }

  //
  //  LINK TO SOURCE
  //
  @track modalLinkToSource = {
    show: false,
    title: null,
    message: null,
    id: null,
    value: null,
    options: []
  };

  get modalLinkToSourceSubmitIsDisable () {
    return this.modalLinkToSource.value ? false : true;
  }

  onClickLinkToSource (event) {
    if (
      event.target.value && event.target.value == 'linkToSource' &&
      event.target.hasAttribute('data-id')
    ) {
      let id = event.target.getAttribute('data-id');

      this.tables.forEach(group => {
        group.list.forEach(item => {
          if (item.id == id) {
            this.modalLinkToSource.title = `Link ${item.name} to source`;
            this.modalLinkToSource.message = `Select the source org for the connection:`;
            this.modalLinkToSource.id = id;
            this.modalLinkToSource.show = true;

            this.modalLinkToSource.options = [];
            this.tables.forEach(group => {
              if (group.name != UNLINKED) {
                this.modalLinkToSource.options.push({
                  label: group.name,
                  value: group.id
                });
              }
            });
          }
        });
      });
    }
  }

  onClickToCloseModalLinkToSource () {
    this.modalLinkToSource.show = false;
    this.modalLinkToSource.title = null;
    this.modalLinkToSource.message = null;
    this.modalLinkToSource.id = null;
    this.modalLinkToSource.value = null;
    this.modalLinkToSource.options = [];
  }

  onChangeSelectModalLinkToSource (event) {
    this.modalLinkToSource.value = event.detail.value;
  }

  onClickToSubmitModalLinkToSource () {
    if (this.modalLinkToSource.id && this.modalLinkToSource.value) {
      setMetadataSourceOrg({ id: this.modalLinkToSource.id, sourceOrgId: this.modalLinkToSource.value })
      .then (response => {
          if (response) {

            // Search and remove item
            let itemOrg = null;
            this.tables.forEach(group => {
              if (group.name == UNLINKED) {
                let deleteIndex = null;

                group.list.forEach((item, index) => {
                  if (item.id == this.modalLinkToSource.id) {
                    deleteIndex = index;
                    itemOrg = JSON.parse(JSON.stringify(item));
                  }
                });

                if (deleteIndex != null) {
                  group.list.splice(deleteIndex, 1);
                }
              }
            });

            // Push item to unlinked
            if (itemOrg) {
              this.tables.forEach(group => {
                if (group.id == this.modalLinkToSource.value) {
                  group.list.push(itemOrg);
                }
              });
            }

            this.updateAction();
            this.countNumberOfSelected();
            this.sortMainTableList();
            this.sortMainTableList();

            this.showToast ('success', 'Link installed successfully');
          } else {
            this.showToast ('error', 'Can\'t to set link');
          }

          this.onClickToCloseModalLinkToSource();
        })
        .catch (error => {
          this.onClickToCloseModalLinkToSource();
          this.showToast ('error', INTERNAL_SERVER_ERROR, error);
        });
    } else {
      this.showToast ('error', 'Please select an Source org');
    }
  }

}