public with sharing class OpportunityHelper {

    static final String VP_SALES = 'VP Sales';

    public Boolean hasAlreadyRun;
    
    public OpportunityHelper() {
        // This is the part that's not ideal practice (compared to just using the built-in recursion prevention in TriggerHandler)
        this.hasAlreadyRun = false;
    }

    public void amountValidator(Opportunity opp) {
        if(opp.Amount < 5000){
            opp.addError('Opportunity amount must be greater than 5000');
        }
    }

    public void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(); // I feel like we don't need a Map when we use the values method anyway?
        // Make a list to hold the Opps
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        // I need to move the SOQL query out of for loop
        // make a set of Account Ids to pull them from the Opps
        Set<Id> acctIds = new Set<Id>();

        // Learned the hard way that I have to query for records in Trigger.new instead of trying to modify directly
        List<Opportunity> triggerNewOpps = [SELECT Id, AccountId, Primary_Contact__c FROM Opportunity WHERE Id IN :oppNewMap.keySet()];

        for (Opportunity opp : triggerNewOpps) {
            acctIds.add(opp.AccountId);
        }
        // Make a map to hold Account ID to Contact
        Map<Id, Contact> acctToVpContactMap = new Map<Id, Contact>();
        for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE Title = :VP_SALES AND AccountId IN :acctIds]) {
            acctToVpContactMap.put(contact.AccountId, contact);
        }
        for (Opportunity opp : triggerNewOpps){            
            if (opp.Primary_Contact__c == null){ // if Primary Contact isn't filled out on the Opp
                opp.Primary_Contact__c = acctToVpContactMap.get(opp.AccountId).Id;
                oppsToUpdate.add(opp);
            }
        }
        update oppsToUpdate;
    } 

    public void createTasks(List<Opportunity> oppList) {
        // Bulkify by creating a List, adding to List within for loop, then inserting outside of loop
        List<Task> tasksToInsert = new List<Task>();
        // Create a new Task for newly inserted Opportunities
        for (Opportunity opp : oppList){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            tasksToInsert.add(tsk);
            System.debug('Task is: ' + tsk);
        }
        // Now we can safely insert the Task list
        // try {
            insert tasksToInsert;
        // } catch (Exception e) {
        //     System.debug('The following exception has occurred: ' + e.getMessage());
        // }
    }

    public void getContacts(List<Opportunity> oppList) {
        //Get contacts related to the opportunity account
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : oppList){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : oppList){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }

    public void notifyOwnersOpportunityDeleted(List<Opportunity> oppList) {
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            ownerIds.add(opp.OwnerId);
        }
        String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id IN :ownerIds].Email};
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : oppList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public void preventDeleteForClosedOpps(List<Opportunity> oppList) {
        //Account related to the opportunities 
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.old)]);
        for(Opportunity opp : oppList){
            if(opp.IsClosed == true){
                // Removing banking part because based on AnotherOpportunityTrigger,
                // it's all Opps that are closed, not industry-specific
                // if(accounts.get(opp.AccountId).Industry == 'Banking'){
                opp.addError('Cannot delete closed opportunity');
                //}
            }
        }
    }

    public void setDefaultType(List<Opportunity> oppList) {
        for (Opportunity opp : oppList) {
            if (opp.Type == null) {
                opp.Type = 'New Customer';
            } 
        }     
    }

    public void updateStageNameInDescription(List<Opportunity> oppList) {
        for (Opportunity opp : oppList) {
            opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
        }
    }
}