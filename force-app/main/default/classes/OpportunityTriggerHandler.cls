public with sharing class OpportunityTriggerHandler extends TriggerHandler {
  List<Opportunity> triggerNew = new List<Opportunity>();
  List<Opportunity> triggerOld = new List<Opportunity>();
  Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();
  Map<Id, Opportunity> triggerOldMap = new Map<Id, Opportunity>();

  public OpportunityTriggerHandler() {
    this.triggerNew = (List<Opportunity>) Trigger.new;
    this.triggerOld = (List<Opportunity>) Trigger.old;
    this.triggerNewMap = (Map<Id, Opportunity>) Trigger.newMap;
    this.triggerOldMap = (Map<Id, Opportunity>) Trigger.oldMap;
  }

  OpportunityHelper helper = new OpportunityHelper();

  public override void beforeInsert() {
    helper.setDefaultType(triggerNew);
  }

  public override void beforeUpdate() {
    helper.amountValidator(triggerNew);

    helper.getContacts(triggerNew);

    helper.updateStageNameInDescription(triggerNew, triggerOldMap);
  }

  public override void beforeDelete() {
    helper.preventDeleteForClosedOpps(triggerOld);
  }

  public override void afterInsert() {
    helper.createTasks(triggerNew);
  }

  public override void afterDelete() {
    helper.notifyOwnersOpportunityDeleted(triggerOld);
  }

  public override void afterUndelete() {
    helper.assignPrimaryContact(triggerNewMap);
  }
}
