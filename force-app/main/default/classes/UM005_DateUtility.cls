/**
   * @author Dario Correnti
   * @date 13/05/2020
   * @Utility methods to manipulate dates
*/
public with sharing class UM005_DateUtility {
    public static final List<Integer> quarterlyMonths = new List<Integer> {1, 4, 7, 10};
    public static final List<Integer> semiannualMonths = new List<Integer> {1, 7};

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

        /*
    public static Date lastDayOfQuarterPeriod (Date theDate) {
        Date newDate = null;
        if (theDate != null) {
            Double dQuarter = Double.valueOf(theDate.month()) / Double.valueOf(3);
            Integer quarterIndex = Integer.valueOf(Math.floor(dQuarter));
            Date firstDateNextQuarter = quarterIndex < quarterlyMonths.size() - 1
                ? Date.newinstance(theDate.year(), quarterlyMonths.get(quarterIndex + 1), 1)
                : Date.newinstance(theDate.addYears(1).year(), quarterlyMonths.get(0), 1);

            newDate = firstDateNextQuarter.addDays(-1);  // add -1 day to the 1st day of next quarter
        }
        return newDate;
    }
    */

    public static Date lastDayOfDatePeriod (Date theDate, List<Integer> periodsMonths) { // Quaterly / Semiannual periods
        Date newDate = null;
        if (theDate != null) {
            Double dperiod = Double.valueOf(theDate.month()) / Double.valueOf(periodsMonths.size());
            Integer periodIndex = Integer.valueOf(Math.floor(dperiod));
            Date firstDateNextPeriod = periodIndex < periodsMonths.size() - 1
                ? Date.newinstance(theDate.year(), periodsMonths.get(periodIndex + 1), 1)
                : Date.newinstance(theDate.addYears(1).year(), periodsMonths.get(0), 1);

            newDate = firstDateNextPeriod.addDays(-1);  // add -1 day to the 1st day of next quarter
        }
        return newDate;
    }

}
