public with sharing class ViewerSuncLogComponentController {

    public RadEx__Error_Log__c fromDate { get; set; } 
	public RadEx__Error_Log__c toDate { get; set; }

    public Id AccountMainId {set; get;}
    public Integer LimitSize {
        get {
            return LimitSize == NULL ? 15 : LimitSize;
        }
        set;
    }

    public Boolean isSortDeskSuccessLog {get;set;}

    public List<SelectOption> contentTypeSync {get;set;}
    public String selectedTypeSync {get;set;}
    

    public Boolean isExtensionMode { get; set; }
    
	@TestVisible private integer OffsetSize = 0;
    @TestVisible private integer OffsetSizeError = 0;
    @TestVisible private integer OffsetSizeSelected = 0;
	@TestVisible private integer totalRecs = 0;
    @TestVisible private integer totalRecsError = 0;
    @TestVisible private integer totalRecsSelected = 0;

    public List<LogWrapper> listLogController { 
        get{
            return listLogGet();
    }}

    public String SelectedType { get; set; }

    private Set<String> allSuccessType { 
        get {
            return new Set<String>{
                'COURSE',
                'SLIDE',
                'PROGRAMM',
                'POLICY',
                'AGREEMENT',
                'TEST'
            };
    }}

    private Set<String> queryFields { 
        get {
            return new Set<String>{
               RadEx__Error_Log__c.RadEx__Date__c.getDescribe().getName(),
               RadEx__Error_Log__c.RadEx__Error_Code__c.getDescribe().getName(),
               RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName(),
               RadEx__Error_Log__c.RadEx__Event_Date__c.getDescribe().getName(),
               RadEx__Error_Log__c.RadEx__Error_Message__c.getDescribe().getName(),
               RadEx__Error_Log__c.RadEx__Severity__c.getDescribe().getName()
            
            };
    }}

    private String errorFieldForSort {
        get {
            if(String.isBlank(errorFieldForSort)) return RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName();
            return errorFieldForSort;
        }
        set {
            errorFieldForSort = queryFields.contains(value) ? value : RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName();
        }
    }

    private String successFieldForSort {
        get {
            if(String.isBlank(successFieldForSort)) return RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName();
            return successFieldForSort;
        }
        set {
            if(String.isNotBlank(value) &&  queryFields.contains(value)) {
                if(String.isNotBlank(successFieldForSort)  && successFieldForSort.endsWithIgnoreCase(value)) {
                    if(successSortAscending != NULL) {
                         successSortAscending = !successSortAscending;
                    } else {
                        successSortAscending = true;
                    }
                }
                successFieldForSort = value;
            } else {
                successFieldForSort = RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName();
            }
        }
    }

    private Boolean successSortAscending {
        get {
            return successSortAscending != NULL ? successSortAscending : true;
        }
        set;
    }


    private Set<String> selectedSuccessType {
        get {
            if(String.isBlank(selectedTypeSync)) return allSuccessType;
            return allSuccessType.contains(selectedTypeSync) ? new Set<String>{selectedTypeSync} : allSuccessType;
    }}

    public  ViewerSuncLogComponentController() {

        fromDate = new RadEx__Error_Log__c();
        toDate = new RadEx__Error_Log__c();
        Time t = Time.newInstance(0, 0, 0, 0);
        Date fromDateDate = Date.today().addMonths(-3);
        Date toDateDate =  Date.today().addDays(1); 

        DateTime fromDateFormat = DateTime.newInstance( fromDateDate, t );
        DateTime toDateFormat = DateTime.newInstance( toDateDate, t );
        fromDate.RadEx__Event_Date__c = fromDateFormat;
        toDate.RadEx__Event_Date__c = toDateFormat;

        contentTypeSync = new List<SelectOption>();
        contentTypeSync.add(new SelectOption('','-- All --'));
        for(String item : allSuccessType)   contentTypeSync.add(new SelectOption(item, item));
    }

    public List<LogWrapper> listLogErrorSelected { 

        get{
            List<LogWrapper> logResult = new List<LogWrapper>();
           
            if(AccountMainId == NULL ) return logResult;

            totalRecsError = [SELECT COUNT()
                FROM RadEx__Error_Log__c
                WHERE RadEx__ORG__c =: AccountMainId
                AND CreatedDate >: fromDate.RadEx__Event_Date__c AND CreatedDate <: toDate.RadEx__Event_Date__c
                AND RadEx__Severity__c = 'CONTENT_SYNC_ERROR'
            ];   

            DateTime eventDateFrom = fromDate.RadEx__Event_Date__c;
            DateTime eventDateTo =  toDate.RadEx__Event_Date__c;

            String queryIdstring = 'SELECT Id, ' ;
            queryIdstring += String.join(  new List<String>(queryFields) , ', ');
            queryIdstring += ' FROM ' + RadEx__Error_Log__c.getSobjectType().getDescribe().getName();
            queryIdstring += ' WHERE ' + RadEx__Error_Log__c.RadEx__ORG__c.getDescribe().getName() + '=\'' + AccountMainId + '\'';
            queryIdstring += ' AND CreatedDate > ' + eventDateFrom.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ';
            queryIdstring += ' AND CreatedDate < ' + eventDateTo.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ';
            queryIdstring += ' AND ' + RadEx__Error_Log__c.RadEx__Severity__c.getDescribe().getName() + '=\'CONTENT_SYNC_ERROR\'';   
            queryIdstring += ' ORDER BY ' + errorFieldForSort ;
            queryIdstring += ' LIMIT ' + LimitSize;
            queryIdstring += ' OFFSET ' + OffsetSizeError;

            List<RadEx__Error_Log__c>  tmpCountList = Database.query( queryIdstring );

            for(RadEx__Error_Log__c item : tmpCountList) logResult.add(new LogWrapper(item));
        
            return logResult;    
    }}
   
    public List<LogWrapper> listLogSelected { 

        get {
            List<LogWrapper> logResult = new List<LogWrapper>();

            if(String.isBlank(SelectedType) || AccountMainId == NULL ) return logResult;

            totalRecsSelected = [SELECT COUNT()
                FROM RadEx__Error_Log__c
                WHERE RadEx__ORG__c =: AccountMainId
                AND CreatedDate >: fromDate.RadEx__Event_Date__c AND CreatedDate <: toDate.RadEx__Event_Date__c
                AND RadEx__Severity__c = 'CONTENT_SYNC'
                AND RadEx__Class_Name__c =:SelectedType
                AND RadEx__Error_Code__c =:selectedSuccessType
            ];   

            DateTime eventDateFrom = fromDate.RadEx__Event_Date__c;
            DateTime eventDateTo =  toDate.RadEx__Event_Date__c;

            String queryIdstring = 'SELECT Id, ' ;
            queryIdstring += String.join(  new List<String>(queryFields) , ', ');
            queryIdstring += ' FROM ' + RadEx__Error_Log__c.getSobjectType().getDescribe().getName();
            queryIdstring += ' WHERE ' + RadEx__Error_Log__c.RadEx__ORG__c.getDescribe().getName() + '=\'' + AccountMainId + '\'';
            queryIdstring += ' AND CreatedDate > ' + eventDateFrom.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ';
            queryIdstring += ' AND CreatedDate < ' + eventDateTo.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ';
            queryIdstring += ' AND ' + RadEx__Error_Log__c.RadEx__Severity__c.getDescribe().getName() + '=\'CONTENT_SYNC\'';  

            queryIdstring += ' AND ' + RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName() + '=:SelectedType';
            queryIdstring += ' AND ' + RadEx__Error_Log__c.RadEx__Error_Code__c.getDescribe().getName() + '=:selectedSuccessType';    

            queryIdstring += ' ORDER BY ' + successFieldForSort;
            queryIdstring += successSortAscending ? ' ASC ' : ' DESC ';
            queryIdstring += ' LIMIT ' + LimitSize;
            queryIdstring += ' OFFSET ' + OffsetSizeError;

            List<RadEx__Error_Log__c>  tmpCountList = Database.query( queryIdstring );

            for(RadEx__Error_Log__c item : tmpCountList) logResult.add(new LogWrapper(item));
            return logResult;    
    }}

   
    public List<LogWrapper> listLogGet() {
        List<LogWrapper> logResult = new List<LogWrapper>();

        if(AccountMainId == NULL ) return logResult;
       // Time t = Time.newInstance(0, 0, 0, 0);

        List<AggregateResult>  tmpCountList = [
            SELECT  COUNT(Id) counter, MAX(RadEx__Date__c) data, MAX(RadEx__Error_Code__c) error, RadEx__Class_Name__c type
            FROM RadEx__Error_Log__c 
            WHERE RadEx__ORG__c =: AccountMainId
            AND RadEx__Class_Name__c != ''
            AND CreatedDate >: fromDate.RadEx__Event_Date__c AND CreatedDate <: toDate.RadEx__Event_Date__c
            AND RadEx__Severity__c = 'CONTENT_SYNC'
            AND RadEx__Error_Code__c =:selectedSuccessType
            GROUP BY RadEx__Class_Name__c 
            ORDER BY RadEx__Class_Name__c ASC
        ];
           
        totalRecs = tmpCountList.size();
       
        List<AggregateResult>  tmpCountListAgreeget = [
            SELECT  COUNT(Id) Id, MAX(RadEx__Date__c) data, MAX(RadEx__Error_Code__c) error, RadEx__Class_Name__c type
            FROM RadEx__Error_Log__c 
            WHERE RadEx__ORG__c =: AccountMainId
            AND RadEx__Class_Name__c != ''
            AND CreatedDate >: fromDate.RadEx__Event_Date__c AND CreatedDate <: toDate.RadEx__Event_Date__c
            AND RadEx__Severity__c = 'CONTENT_SYNC'
            AND RadEx__Error_Code__c =:selectedSuccessType
            GROUP BY RadEx__Class_Name__c 
            ORDER BY RadEx__Class_Name__c ASC
            LIMIT :LimitSize 
            OFFSET :OffsetSize
        ];

        for(AggregateResult item : tmpCountListAgreeget) {
            Integer count = (Integer)(item.get('Id') == NULL ? '1' : item.get('Id'));
            DateTime evetTime = (DateTime)(item.get('data') == NULL ? NULL : item.get('data'));
            String typeSt = (String)(item.get('error') == NULL ? '' : item.get('error'));
            String content = (String)(item.get('type') == NULL ? '' : item.get('type'));
            logResult.add(new LogWrapper(count, 'CONTENT_SYNC', evetTime, typeSt, content));
        } 
        return logResult;
    }

        
    public class LogWrapper {
        public RadEx__Error_Log__c log {set; get;}
        public String Severity   {set; get;}
        public DateTime EventDate {set; get;}
        public String Type  {set; get;}
        public String ContentName  {set; get;}
        public Integer Counter {set; get;}


        public LogWrapper(RadEx__Error_Log__c logItem) {
            this.Counter = 1;
            this.Severity = logItem.RadEx__Severity__c;
            this.log = logItem;
            this.EventDate = logItem.RadEx__Event_Date__c;
            this.Type = logItem.RadEx__Error_Code__c;
            this.ContentName = logItem.RadEx__Class_Name__c;
        }

        public LogWrapper(Integer count, String severit, DateTime evetTime, String typeSt, String content) {
            this.Counter = count;
            this.Severity = severit;
            this.EventDate = evetTime;
            this.Type = typeSt;
            this.ContentName = content;
        }
    }

    // CONTENT_SYNC

    public void FirstPage()	{
		OffsetSize = 0;
	}

	public void previous()	{
		OffsetSize = (OffsetSize-LimitSize);
	}

	public void next(){
		OffsetSize = OffsetSize + LimitSize;
	}

	public void LastPage() {
		OffsetSize = totalRecs - math.mod( totalRecs, LimitSize );
	}

	public boolean getnxt()	{
		return (OffsetSize + LimitSize) > totalRecs;
	}

	public boolean getprev() {
		return OffsetSize == 0;
	}

    // SELECTED CONTENT

    public void FirstPageSelected()	{
		OffsetSizeSelected = 0;
	}

	public void previousSelected()	{
		OffsetSizeSelected = (OffsetSizeSelected-LimitSize);
	}

	public void nextSelected(){
		OffsetSizeSelected = OffsetSizeSelected + LimitSize;
	}

	public void LastPageSelected() {
		OffsetSizeSelected = totalRecsSelected - math.mod( totalRecsSelected, LimitSize );
	}

	public boolean getnxtSelected()	{
		return (OffsetSizeSelected + LimitSize) > totalRecsSelected;
	}

	public boolean getprevSelected() {
		return OffsetSizeSelected == 0;
	}

    // ERROR CONTENT

    public void FirstPageError()	{
		OffsetSizeError = 0;
	}

	public void previousError()	{
		OffsetSizeError = (OffsetSizeError-LimitSize);
	}

	public void nextError(){
		OffsetSizeError = OffsetSizeError + LimitSize;
	}

	public void LastPageError() {
		OffsetSizeError = totalRecsError - math.mod( totalRecsError, LimitSize );
	}

	public boolean getnxtError()	{
		return (OffsetSizeError + LimitSize) > totalRecsError;
	}

	public boolean getprevError() {
		return OffsetSizeError == 0;
	}

    public void doResearchError() {
        String selectedfield = System.currentPageReference().getParameters().get('selectedfield');
        if(String.isNotBlank(selectedfield)) errorFieldForSort = selectedfield;
    }

    public void doResearchSuccess() {
        String selectedfieldsuccess = System.currentPageReference().getParameters().get('selectedfieldsuccess');
        if(String.isNotBlank(selectedfieldsuccess)) successFieldForSort = selectedfieldsuccess;
    }


    public void clearSelected() {
        OffsetSize = 0;
        OffsetSizeError = 0;
        OffsetSizeSelected = 0;
        SelectedType = '';
	}


}