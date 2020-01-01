@IsTest
private class ReservationRecordTypeSwitcherTest {
    @IsTest
    static void testRecordTypeSwitcher() {
        Hotel__c hotel = new Hotel__c(City__c = 'Brest', Rating__c = '1 star');
        insert hotel;
        Room__c room = new Room__c(Hotel__c = hotel.Id, Room_Type__c =  'Single Room (1 bed)');
        insert room;
        
        Id reservationRTId = SObjectType.Reservation__c.getRecordTypeInfosByDeveloperName()
                .get('Pre_reservation').getRecordTypeId();
        Contact contact = new Contact(FirstName = 'name', LastName = 'last name', Email = 'email@sss.cpm');
        insert contact;
        Reservation__c reservation = new Reservation__c(
                Room__c = room.Id, Contact__c = contact.Id,
                Reservation_Start_Date__c = Date.today(),
                Reservation_End_Date__c = Date.today(),
                RecordTypeId = reservationRTId
        );
        insert reservation;

        ReservationRecordTypeSwitcher.switchReservationRecordType(null, null);
        ReservationRecordTypeSwitcher.switchReservationRecordType('Reservation', reservation.Id);

        List<Reservation__c> reservations = [
                SELECT Id, RecordType.DeveloperName
                FROM Reservation__c
                LIMIT 1
        ];

        System.assertEquals('Reservation',  reservations[0].RecordType.DeveloperName);
    }


}