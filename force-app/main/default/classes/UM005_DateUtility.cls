/**
   * @author Dario Correnti
   * @date 13/05/2020
   * @Utility methods to manipulate dates
*/
public with sharing class UM005_DateUtility {
    public static final List<Integer> quarterlyMonths = new List<Integer> {1, 4, 7, 10};
        public static final List<Integer> semiannualMonths = new List<Integer> {1, 7};
            public static final Map<String, Integer> monthsMap = new Map<String, Integer>{
                'Jan'  => 1,
                    'Feb' => 2,
                    'Mar' => 3,
                    'Apr'  => 4,
                    'May' => 5,
                    'Jun' => 6,
                    'Jul' => 7,
                    'Aug' => 8,
                    'Sep' => 9,
                    'Oct' => 10,
                    'Nov' => 11,   
                    'Dec' => 12    
                    };

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
*/

    
    public static Date lastDayOfDatePeriod(Date theDate,List<Integer>  periodsMonths){
        Date newDate = null;
        Integer theDateMonth;
        if(theDate !=null){
            theDateMonth=theDate.month();
            for(Integer x=0;x<periodsMonths.size();x++){
               if (x == periodsMonths.size()-1 ){
                     newDate = Date.newinstance(theDate.addYears(1).year(), periodsMonths.get(0), 1);
                	 break;
                }
                else if( periodsMonths.get(x)<=theDateMonth && theDateMonth <periodsMonths.get(x+1)){
                    newDate = Date.newinstance(theDate.year(), periodsMonths.get(x+1), 1);
                    break;
                } 
            }
        }
        return newDate.addDays(-1);
    }
    

 public static Date lastDayOfYear(Date theDate){
      return Date.newinstance(theDate.Year(),12,31);
    }
    
    public static Integer getMonthNumberByString(String month){
        if(String.isNotBlank(month) && month.length() > 2 && monthsMap.containsKey(month.substring(0, 3))){
            return monthsMap.get(month.substring(0, 3));
        }
        return null;
    }

}