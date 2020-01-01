({
    doInit: function(component, event, helper) {
        component.set('v.showConfirmation', false);
        component.set('v.loaded', false);
        let action = component.get('c.switchReservationRecordType');
        action.setParams({
            'recordTypeDevName' : component.get('v.recordTypeDevName'),
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "related"
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})