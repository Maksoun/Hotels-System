public with sharing class IndexController {

    private static List<String> getPicklistValues(String objName, String fieldName){
        System.debug('objName ' + objName);
        System.debug('fieldName ' + fieldName);
        List<String> options = new List<String>();
        try {
            Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe()
                    .get(objName).getDescribe();
            Schema.DescribeFieldResult fieldResult = objResult.fields.getMap()
                    .get(fieldName).getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList) {
                options.add(p.getLabel());
            }
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            throw new AuraHandledException('Unable to get Picklist values for field ' + fieldName);
        }
        return options;
    }

    @AuraEnabled
    public static List<HotelWrapper> getHotels(String city) {
        List<HotelWrapper> results = new List<HotelWrapper>();
        List<Hotel__c> hotels = [
                SELECT Id, Name, Rating__c, City__c FROM Hotel__c
                WHERE City__c = :city
                LIMIT :Limits.getLimitQueryRows()
        ];
        for (Hotel__c hotel : hotels) {
            results.add(new HotelWrapper(hotel.Name, hotel.Rating__c, hotel.City__c, hotel.Id));
        }
        System.debug(JSON.serializePretty(results));
        return results;
    }

    @AuraEnabled
    public static List<Room__c> getRooms(String hotelId) {
        List<Room__c> rooms = [
                SELECT Id, Name, Additional_Service__c, Room_Type__c,
                        Additional_Service__r.Alcohol_drinks__c, Additional_Service__r.Internet__c,
                        Additional_Service__r.Sauna__c
                FROM Room__c
                WHERE Hotel__c = :hotelId
                LIMIT :Limits.getLimitQueryRows()
        ];
        return rooms;
    }

    @AuraEnabled
    public static String initReservation() {
        ReservationWrapper rw = new ReservationWrapper();
        rw.cities = getPicklistValues('Hotel__c', 'City__c');
        rw.drinks = getPicklistValues('Additional_service__c', 'Alcohol_drinks__c');
        return JSON.serialize(rw);
    }

    @AuraEnabled
    public static void createReservation(
            String emailAddress, String firstName, String lastName, Id roomId,
            Date startDate, Date endDate) {

        if (emailAddress == null || firstName == null || lastName == null || roomId == null ||
                startDate == null || endDate == null) {
            throw new AuraHandledException('Not all required parameters are passed. Please try again.');
        }
        List<Reservation__c> existingReservations = [
                SELECT Id
                FROM Reservation__c
                WHERE Room__c = :roomId
                AND (
                        (
                                Reservation_Start_Date__c >= :startDate AND
                                Reservation_End_Date__c <= :endDate
                        )
                        OR (
                                Reservation_Start_Date__c <= :startDate AND
                                Reservation_End_Date__c >= :endDate
                        ) OR (
                                Reservation_Start_Date__c >= :startDate AND
                                Reservation_End_Date__c >= :endDate AND
                                Reservation_Start_Date__c <= :endDate
                        ) OR (
                                Reservation_Start_Date__c <= :startDate AND
                                Reservation_End_Date__c <= :endDate AND
                                Reservation_End_Date__c >= :startDate
                        )
                )
        ];
        System.debug(JSON.serializePretty(existingReservations));
        if (!existingReservations.isEmpty()) {
            throw new AuraHandledException('This room has already been booked for these dates.');
        }
        try {
            Contact contact = new Contact(FirstName = firstName, LastName = lastName, Email = emailAddress);
            insert contact;
            Id reservationRTId = SObjectType.Reservation__c.getRecordTypeInfosByDeveloperName()
                    .get('Pre_reservation').getRecordTypeId();
            Reservation__c reservation = new Reservation__c(
                    Room__c = roomId, Contact__c = contact.Id,
                    Reservation_Start_Date__c = startDate,
                    Reservation_End_Date__c = endDate,
                    RecordTypeId = reservationRTId
            );
            insert reservation;
        } catch (Exception exp) {
            System.debug('Error on reservation creation  ' + exp.getMessage());
            throw new AuraHandledException('Unable to create reservation.  ' + exp.getMessage());
        }
    }

    public class ReservationWrapper {
        @AuraEnabled
        public List<String> cities;
        @AuraEnabled
        public List<String> drinks;
    }

    public class HotelWrapper {
        @AuraEnabled
        public String hotelName;
        @AuraEnabled
        public String hotelCity;
        @AuraEnabled
        public String hotelRating;
        @AuraEnabled
        public String hotelId;

        public HotelWrapper(String hotelName, String hotelRating, String hotelCity, String hotelId) {
            this.hotelCity = hotelCity;
            this.hotelName = hotelName;
            this.hotelRating = hotelRating;
            this.hotelId = hotelId;
        }
    }
}