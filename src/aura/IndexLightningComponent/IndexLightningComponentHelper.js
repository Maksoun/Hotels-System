({
    fetchPicklistValues: function(component, event, helper) {
        let action = component.get('c.initReservation');
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let wrappedOpts = JSON.parse(response.getReturnValue());
                let opt = [];
                opt.push(
                    {
                        label : 'Choose city',
                        id : '',
                        selected : true
                    }
                );
                for (let i = 0; i < wrappedOpts.cities.length; i++) {
                    opt.push(
                        {
                            label : wrappedOpts.cities[i],
                            id : wrappedOpts.cities[i],
                            selected : false
                        }
                    );
                }
                component.set('v.optionsForCities', opt);
                opt = [];
                for (let i = 0; i < wrappedOpts.drinks.length; i++) {
                    opt.push(
                        {
                            label : wrappedOpts.drinks[i],
                            value : wrappedOpts.drinks[i]
                        }
                    );
                }
                component.set('v.optionsForDrinks', opt);

            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' +
                            errors[0].message);
                        helper.notifyUser(component, errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchHotels: function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get('c.getHotels');
        action.setParams({ city : component.get('v.cityValue') });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let opts = [];
                if (response.getReturnValue().length === 0) {
                    opts.push(
                        {
                            label : 'No hotels were found in this city',
                            id : '',
                            selected : true
                        }
                    );
                } else {
                    opts.push(
                        {
                            label : 'Choose hotel',
                            id : '',
                            selected : true
                        }
                    );
                }
                for (let i = 0; i < response.getReturnValue().length; i++) {
                    opts.push(
                        {
                            label : response.getReturnValue()[i].hotelName
                                + ' (' + response.getReturnValue()[i].hotelRating + '), '
                                + response.getReturnValue()[i].hotelCity,
                            id : response.getReturnValue()[i].hotelId,
                            selected : false
                        }
                    );
                }
                component.set('v.optionsForHotels', opts);

            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' +
                            errors[0].message);
                        helper.notifyUser(component, errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchRooms: function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get('c.getRooms');
        action.setParams({ hotelId : component.get('v.selectedHotelId') });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let opts = [];
                if (response.getReturnValue().length === 0) {
                    opts.push(
                        {
                            label : 'No rooms are available in this hotel',
                            id : '',
                            selected : true
                        }
                    );
                } else {
                    opts.push(
                        {
                            label : 'Choose room',
                            id : '',
                            selected : true
                        }
                    );
                }
                let map = new Map();
                for (let i = 0; i < response.getReturnValue().length; i++) {
                    opts.push(
                        {
                            label : response.getReturnValue()[i].Name
                                + ' (' + response.getReturnValue()[i].Room_Type__c + ')',
                            id : response.getReturnValue()[i].Id,
                            selected : false
                        }
                    );
                    if (response.getReturnValue()[i].Additional_Service__r) {
                        map.set(
                            response.getReturnValue()[i].Id,
                            {
                                internet: response.getReturnValue()[i].Additional_Service__r.Internet__c,
                                sauna: response.getReturnValue()[i].Additional_Service__r.Sauna__c,
                                drinks: response.getReturnValue()[i].Additional_Service__r.Alcohol_drinks__c  ?
                                    response.getReturnValue()[i].Additional_Service__r.Alcohol_drinks__c.split(';') :
                                    null
                            }
                        );
                    }
                }
                component.set('v.roomIdToServices', map);
                component.set('v.optionsForRooms', opts);

            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' +
                            errors[0].message);
                        helper.notifyUser(component, errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchAdditionalServices: function(component, event, helper) {
        let service = component.get('v.roomIdToServices').get(component.get('v.selectedRoomId'));
        component.set('v.internetValue', service.internet);
        component.set('v.saunaValue', service.sauna);
        component.set('v.selectedDrinksList', service.drinks);
    },
    notifyUser: function(component, message, messageType) {
        let timeOut = 3000;
        if (messageType === 'error') {
            component.set('v.visibilityClass', 'slds-show');
            component.set('v.notificationMessage', 'Error: ' + message);
            component.set('v.notificationStyle', 'error');
            component.set('v.notificationIconStyle', 'error');
        } else if (messageType === 'success') {
            timeOut = 4000;
            component.set('v.visibilityClass', 'slds-show');
            component.set('v.notificationMessage',  message);
            component.set('v.notificationStyle', 'success');
            component.set('v.notificationIconStyle', 'success');
        }
        window.setTimeout(
            $A.getCallback(function() {
                component.set('v.visibilityClass', 'slds-hide');
                if (messageType === 'success') {
                    location.reload();
                }
            }), timeOut
        );
    },
    submitReservation: function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get('c.createReservation');
        action.setParams({
            emailAddress : component.get('v.emailAddress'),
            firstName : component.get('v.firstName'),
            lastName : component.get('v.lastName'),
            roomId : component.get('v.selectedRoomId'),
            startDate : component.get('v.startDate'),
            endDate : component.get('v.endDate')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isBooked', true);
                helper.notifyUser(
                    component,
                    'Thanks for booking a room. We will send an email confirmation soon.' ,
                    'success'
                );
            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' +
                            errors[0].message);
                        helper.notifyUser(component, errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    }
});