public class checkRecursive {
	public static Set<Id> setofIDs = new Set<Id>();
    private static boolean firstRun = true;
    
    public static boolean isFirstRun() {
        if(firstRun) {
            firstRun = false;
            return true;
        }
        else {
            return firstRun;
        }
    }
}