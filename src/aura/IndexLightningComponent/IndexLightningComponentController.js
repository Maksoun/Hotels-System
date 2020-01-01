({
    handleClick : function (component, event, helper) {
        let emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!component.get('v.emailAddress')) {
            helper.notifyUser(component, 'Email Address is required to send confirmation', 'error');
        } else if (component.get('v.emailAddress') && !emailRegex.test(String(component.get('v.emailAddress')).toLowerCase())) {
            helper.notifyUser(component, 'Email Address has incorrect format', 'error');
        } else if (!component.get('v.firstName') || !component.get('v.lastName')) {
            helper.notifyUser(component, 'First and Last names are required', 'error');
        } else if (!component.get('v.startDate') || !component.get('v.endDate')) {
            helper.notifyUser(component, 'Please fill in reservation dates', 'error');
        } else {
            helper.submitReservation(component, event, helper);
        }
    },
    doInit : function(component, event, helper) {
        helper.fetchPicklistValues(component, event, helper);
    },
    closeNotification: function(component, event, helper) {
        component.set('v.visibilityClass', 'slds-hide');
    },
    onCityChange: function(component, event, helper) {
        helper.fetchHotels(component, event, helper);
        component.set('v.selectedHotelId', '');
        component.set('v.selectedRoomId', '');
    },
    onHotelChange: function(component, event, helper) {
        helper.fetchRooms(component, event, helper);
    },
    onRoomChange: function(component, event, helper) {
        helper.fetchAdditionalServices(component, event, helper);
    }
});