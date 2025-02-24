public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    List<Opportunity> triggerNew = new List<Opportunity>();
    List<Opportunity> triggerOld = new List<Opportunity>();
    Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();

    public OpportunityTriggerHandler() {
        this.triggerNew = (List<Opportunity>)Trigger.new;
        this.triggerOld = (List<Opportunity>)Trigger.old;
        this.triggerNewMap = (Map<Id, Opportunity>)Trigger.newMap;
    }

    OpportunityHelper helper = new OpportunityHelper();

    public void beforeInsertHandler(List<Opportunity> triggerNew) {
        helper.setDefaultType(triggerNew);
    }

    public void beforeUpdateHandler(List<Opportunity> triggerNew) {
        for (Opportunity opp : triggerNew){
            helper.amountValidator(opp);
        }

        helper.getContacts(triggerNew);
        
        helper.updateStageNameInDescription(triggerNew);
    }

    public void beforeDeleteHandler(List<Opportunity> triggerOld) {
        helper.preventDeleteForClosedOpps(triggerOld);
    }

    public void afterInsertHandler(List<Opportunity> triggerNew) {
        helper.createTasks(triggerNew);
    }

    public void afterDeleteHandler(List<Opportunity> triggerOld) {
        helper.notifyOwnersOpportunityDeleted(triggerOld);
    }

    public void afterUndeleteHandler(Map<Id, Opportunity> triggerNewMap) {
        helper.assignPrimaryContact(triggerNewMap);
    }

}