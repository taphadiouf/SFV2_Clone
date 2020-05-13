/**
   * @author Dario Correnti
   * @date 13/05/2020
   * @Utility methods to manipulate dates
*/
public with sharing class UM005_DateUtility {
    public static Date setDayOnDate (Integer day, Date theDate) {
        Date newDate = null;
        if (day != null && day <= 31 && theDate != null) {
            newDate = Date.newinstance(theDate.year(), theDate.month(), day);
        }
        return newDate;
    }

    public static Date lastDateOfMonth (Date theDate) {
        Date newDate = null;
        if (theDate != null) {
            Date tmpNextMonth = theDate.addMonths(1);
            newDate = Date.newinstance(tmpNextMonth.year(), tmpNextMonth.month(), 1).addDays(-1);  // add -1 day to the 1st day of next month
        }
        return newDate;
    }
}
