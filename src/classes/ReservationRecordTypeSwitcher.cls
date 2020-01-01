public with sharing class ReservationRecordTypeSwitcher {

    @AuraEnabled
    public static void switchReservationRecordType(String recordTypeDevName, Id recordId) {
        if (recordTypeDevName == null || recordId == null) {
            return ;
        }
        try {
            Id reservationRTId = SObjectType.Reservation__c.getRecordTypeInfosByDeveloperName()
                    .get(recordTypeDevName).getRecordTypeId();
            Reservation__c reservation = new Reservation__c(Id = recordId);
            reservation.RecordTypeId = reservationRTId;
            update reservation;
        } catch (Exception exp) {
            System.debug('ERROR on switching record type  ' + exp.getMessage());
        }
    }
}