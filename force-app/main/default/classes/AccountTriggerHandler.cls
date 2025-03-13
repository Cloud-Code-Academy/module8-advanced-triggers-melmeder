public with sharing class AccountTriggerHandler extends TriggerHandler {
    List<Account> triggerNew = new List<Account>();
    
    AccountHelper helper = new AccountHelper();
    
    public AccountTriggerHandler() {
        this.triggerNew = (List<Account>)Trigger.new;
    } 
    
    public void beforeInsertHandler(List<Account> triggerNew) {
        helper.setTypeProspect(this.triggerNew);

        helper.addressCopy(this.triggerNew);

        helper.setRating(this.triggerNew);
    }

    public void afterInsertHandler(List<Account> triggerNew) {
        helper.defaultContact(this.triggerNew);
    }
}