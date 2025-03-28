// /*
// AnotherOpportunityTrigger Overview

// This trigger was initially created for handling various events on the Opportunity object. It was developed by a prior developer and has since been noted to cause some issues in our org.

// IMPORTANT:
// - This trigger does not adhere to Salesforce best practices.
// - It is essential to review, understand, and refactor this trigger to ensure maintainability, performance, and prevent any inadvertent issues.

// ISSUES:
// Avoid nested for loop - 1 instance - removed on line 60: not necessary to reference Trigger.old as well
// Avoid DML inside for loop - 1 instance - removed starting on line 43
// Bulkify Your Code - 1 instance - updated on line 25: access entire Trigger.new rather than only the first index position
// Avoid SOQL Query inside for loop - 2 instances - 1 was in notifyOwnersOpportunityDeleted method, 1 was in assignPrimaryContact method
// Stop recursion - 1 instance - this is happening on line 66: addressing in OpportunityHandler class

// RESOURCES: 
// https://www.salesforceben.com/12-salesforce-apex-best-practices/
// https://developer.salesforce.com/blogs/developer-relations/2015/01/apex-best-practices-15-apex-commandments
// */

trigger AnotherOpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
//     static final String VP_SALES = 'VP Sales';
    
//     if (Trigger.isBefore){
//         if (Trigger.isInsert){
//             // Set default Type for new Opportunities
//             for (Opportunity opp : Trigger.New) {
//             // Opportunity opp = Trigger.new[0];
//                 if (opp.Type == null){
//                     opp.Type = 'New Customer';
//                 } 
//             }       
//         } else if (Trigger.isDelete){
//             // Prevent deletion of closed Opportunities
//             for (Opportunity oldOpp : Trigger.old){
//                 if (oldOpp.IsClosed){
//                     oldOpp.addError('Cannot delete closed opportunity');
//                 }
//             }
//         }
//     }

//     if (Trigger.isAfter){
//         Boolean hasAlreadyRun = false;
//         if (Trigger.isInsert){
//             // Bulkify by creating a List, adding to List within for loop, then inserting outside of loop
//             List<Task> tasksToInsert = new List<Task>();
//             // Create a new Task for newly inserted Opportunities
//             for (Opportunity opp : Trigger.new){
//                 Task tsk = new Task();
//                 tsk.Subject = 'Call Primary Contact';
//                 tsk.WhatId = opp.Id;
//                 tsk.WhoId = opp.Primary_Contact__c;
//                 tsk.OwnerId = opp.OwnerId;
//                 tsk.ActivityDate = Date.today().addDays(3);
//                 tasksToInsert.add(tsk);
//             }
//             // Now we can safely insert the Task list
//             insert tasksToInsert;
//         } else if (Trigger.isUpdate && hasAlreadyRun == false){
//             // Append Stage changes in Opportunity Description
//             for (Opportunity opp : Trigger.new){
//                 //for (Opportunity oldOpp : Trigger.old){ 
//                 if (opp.StageName != null){
//                     opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
//                 }
//                 //}                
//             }
//             // This update is where recursion is happening
//             // Let's add a Boolean variable to prevent it - not best practice though 
//             // so I'll separate it into handler when I combine them
//             // If our Boolean is false, we haven't entered the Trigger already in this transaction, so go ahead with the update
//             if (hasAlreadyRun == false) {
//                 // Set Boolean to true so it won't run again
//                 hasAlreadyRun = true;
//                 update Trigger.new;
//             }
//             // Else do nothing --> recursion prevented
//         }
//         // Send email notifications when an Opportunity is deleted 
//         else if (Trigger.isDelete){
//             notifyOwnersOpportunityDeleted(Trigger.old);
//         } 
//         // Assign the primary contact to undeleted Opportunities
//         else if (Trigger.isUndelete){
//             assignPrimaryContact(Trigger.newMap);
//         }
//     }

//     /*
//     notifyOwnersOpportunityDeleted:
//     - Sends an email notification to the owner of the Opportunity when it gets deleted.
//     - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
//     */
//     private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
//         Set<Id> ownerIds = new Set<Id>();
//         for (Opportunity opp : opps) {
//             ownerIds.add(opp.OwnerId);
//         }
//         String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id IN :ownerIds].Email};
//         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
//         for (Opportunity opp : opps){
//             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//             mail.setToAddresses(toAddresses);
//             mail.setSubject('Opportunity Deleted : ' + opp.Name);
//             mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
//             mails.add(mail);
//         }        
        
//         try {
//             Messaging.sendEmail(mails);
//         } catch (Exception e){
//             System.debug('Exception: ' + e.getMessage());
//         }
//     }
// // ORIGINAL:
// /*    private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
//         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
//         for (Opportunity opp : opps){
//             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//             String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email LIMIT 1};
//             mail.setToAddresses(toAddresses);
//             mail.setSubject('Opportunity Deleted : ' + opp.Name);
//             mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
//             mails.add(mail);
//         }        
        
//         try {
//             Messaging.sendEmail(mails);
//         } catch (Exception e){
//             System.debug('Exception: ' + e.getMessage());
//         }
//     } */

//     /*
//     assignPrimaryContact:
//     - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
//     - Only updates the Opportunities that don't already have a primary contact.
//     */
//     private static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
//         //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(); // I feel like we don't need a Map when we use the values method anyway?
//         // Make a list to hold the Opps
//         List<Opportunity> oppsToUpdate = new List<Opportunity>();
//         // I need to move the SOQL query out of for loop
//         // make a set of Account Ids to pull them from the Opps
//         Set<Id> acctIds = new Set<Id>();

//         // Learned the hard way that I have to query for records in Trigger.new instead of trying to modify directly
//         List<Opportunity> triggerNewOpps = [SELECT Id, AccountId, Primary_Contact__c FROM Opportunity WHERE Id IN :oppNewMap.keySet()];

//         for (Opportunity opp : triggerNewOpps) {
//             acctIds.add(opp.AccountId);
//         }
//         // Make a map to hold Account ID to Contact
//         Map<Id, Contact> acctToVpContactMap = new Map<Id, Contact>();
//         for (Contact contact : [SELECT Id, AccountId FROM Contact WHERE Title = :VP_SALES AND AccountId IN :acctIds]) {
//             acctToVpContactMap.put(contact.AccountId, contact);
//         }
//         for (Opportunity opp : triggerNewOpps){            
//             if (opp.Primary_Contact__c == null){ // if Primary Contact isn't filled out on the Opp
//                 opp.Primary_Contact__c = acctToVpContactMap.get(opp.AccountId).Id;
//                 oppsToUpdate.add(opp);
//             }
//         }
//         update oppsToUpdate;
//     } 

//     // Original : 
//     /* private static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
//         Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
//         for (Opportunity opp : oppNewMap.values()){            
//             Contact primaryContact = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId = :opp.AccountId LIMIT 1];
//             if (opp.Primary_Contact__c == null){
//                 Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
//                 oppToUpdate.Primary_Contact__c = primaryContact.Id;
//                 oppMap.put(opp.Id, oppToUpdate);
//             }
//         }
//         update oppMap.values();
//     }*/
 }