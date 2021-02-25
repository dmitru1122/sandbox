public with sharing class ViewerSuncLogExtentionController {

	public ViewerSuncLogExtentionController(ApexPages.StandardController stdController) {}

	public void actionOnLoadPage() {
		DeleteSuncLogsScheduler.scheduleIt();
	}
}