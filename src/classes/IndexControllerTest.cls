@IsTest
private class IndexControllerTest {
    @TestSetup
    static void setup() {
        Hotel__c hotel = new Hotel__c(City__c = 'Brest', Rating__c = '1 star');
        insert hotel;
        insert new Room__c(Hotel__c = hotel.Id, Room_Type__c =  'Single Room (1 bed)');

    }

    @IsTest
    static void testHotels() {
        System.assertEquals(1, IndexController.getHotels('Brest').size());
    }

    @IsTest
    static void testRooms() {
        List<Hotel__c> hotelList = [
            SELECT Id
            FROM Hotel__c
            LIMIT 1
        ];
        System.assertEquals(1, IndexController.getRooms(hotelList[0].Id).size());
        System.assertEquals('Single Room (1 bed)', IndexController.getRooms(hotelList[0].Id)[0].Room_Type__c);
    }

    @IsTest
    static void testReservationWrapper() {
        String result = IndexController.initReservation();
        IndexController.ReservationWrapper n = (IndexController.ReservationWrapper) JSON.deserialize(
                result, IndexController.ReservationWrapper.class);
        System.assertEquals(
                IndexController.getPicklistValues('Hotel__c', 'City__c').size(),
                n.cities.size()
        );
        System.assertEquals(
                IndexController.getPicklistValues('Additional_service__c', 'Alcohol_drinks__c').size(),
                n.drinks.size()
        );
    }

    @IsTest
    static void testReservation() {
        List<Room__c> roomsList = [
                SELECT Id
                FROM Room__c
                LIMIT 1
        ];
        IndexController.createReservation('example@test.com', 'Maksim', 'Grishchenko', roomsList[0].Id, Date.today(), Date.today().addDays(2));
        System.assertEquals(1, [SELECT Id FROM Reservation__c].size());
        try {
            IndexController.createReservation('example@test.com', 'Maksim', 'Grishchenko', roomsList[0].Id, Date.today(), Date.today().addDays(2));
        } catch (Exception ex) {
            System.debug('Error123 ' + ex.getMessage());
        }
        System.assertEquals(1, [SELECT Id FROM Reservation__c].size());
        try {
            IndexController.createReservation('example@test.com', 'Maksim', 'Grishchenko', roomsList[0].Id, Date.today().addDays(3), Date.today().addDays(5));
        } catch (Exception ex) {
            System.debug('Inserted correct reservation');
        }
        System.assertEquals(2, [SELECT Id FROM Reservation__c].size());
    }
}