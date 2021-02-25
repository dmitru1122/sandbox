@isTest(SeeAllData=true)
private class PartnerOrderSummaryControllerTest
{
    static testMethod void RunTest()
    {        
        Date dt = Date.newInstance(2018, 08, 31);        
        PartnerOrderSummaryController.PartnerOrderSummary p2 = new PartnerOrderSummaryController.PartnerOrderSummary();
        p2.CompanyId = 'a094B000001kyku';
        p2.CompanyName = 'Test';
        p2.DecimalTotalAdmin = 0;
        p2.DecimalTotalBasic = 10;
        p2.DecimalTotalPartnerAdmin = 1;
        p2.DecimalTotalPower = 4;
        p2.ServiceRenewalDate = dt;
        p2.TotalAdmin = 0;
        p2.TotalBasic = 10;
        p2.TotalLicenses = 15;
        p2.TotalPartnerAdmin = 1;
        p2.TotalPower = 4;
        PartnerOrderSummaryController p1 = new PartnerOrderSummaryController();        
        p1.PartnersOrderSummary.add(p2);

    }

}