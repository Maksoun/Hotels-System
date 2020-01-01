@IsTest
private class ReservationRecordTypeSwitcherTest {
    @IsTest
    static void testRecordTypeSwitcher() {
        Hotel__c hotel = new Hotel__c(City__c = 'Brest', Rating__c = '1 star');
        insert hotel;
        insert new Room__c(Hotel__c = hotel.Id, Room_Type__c =  'Single Room (1 bed)');

        List<Hotel__c> hotelList = [
                SELECT Id
                FROM Hotel__c
                LIMIT 1
        ];

        List<Room__c> roomsList = [
                SELECT Id
                FROM Room__c
                LIMIT 1
        ];

        IndexController.createReservation('example@test.com', 'Maksim', 'Grishchenko', roomsList[0].Id, Date.today(), Date.today().addDays(2));

        List<Reservation__c> reservationList = [
                SELECT Id
                FROM Reservation__c
                LIMIT 1
        ];
        ReservationRecordTypeSwitcher.switchReservationRecordType(null, null);
        ReservationRecordTypeSwitcher.switchReservationRecordType('Reservation', reservationList[0].Id);

        List<Reservation__c> reservations = [
                SELECT Id, RecordType.DeveloperName
                FROM Reservation__c
                LIMIT 1
        ];

        System.assertEquals('Reservation',  reservations[0].RecordType.DeveloperName);
    }


}