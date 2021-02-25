class Org{
    constructor(orgId){
        this.authFunct;
        this.orgId = orgId;
        this.orgName = 'Test';
        this.auth;
        this.errors = '';
        this.callback;
        this.conn;
    }
}

const getNewOrg = (orgId) => {
    return new Org(orgId);
}

export { getNewOrg };