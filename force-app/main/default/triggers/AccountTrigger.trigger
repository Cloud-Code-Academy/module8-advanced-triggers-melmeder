/*
AccountTrigger Overview

This trigger performs several operations on the Account object during its insertion. Depending on the values and conditions of the newly created Account, this trigger can:

1. Set the account's type to 'Prospect' if it's not already set.
2. Copy the shipping address of the account to its billing address.
3. Assign a rating of 'Hot' to the account if it has Phone, Website, and Fax filled.
4. Create a default contact related to the account after it's inserted.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `AccountTrigger` class as is.
2. Use the `AccountTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `AccountTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.

Let's dive into the specifics of each operation:
*/
trigger AccountTrigger on Account (before insert, after insert) {

    // After much confusion, I think I kind of understand how to use instances and 'this' - TBD I guess as you review!
    // My understanding of why bother using instance variables rather than static is that it saves some steps in the handler class
    // because you only need to pass in Trigger.new once in the constructor, then you can reference it each time
    // rather than needing to pass a List<Account> parameter explicitly in each method.
    // To use this framework, we need to instantiate the AccountTriggerHandler class so it can pull in Trigger.new:

    AccountTriggerHandler handler = new AccountTriggerHandler();

    /*
    * Account Trigger covers three things Before Insert (all via the AccountTriggerHandler):
    * 1. When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
    * 2. When an account is inserted copy the shipping address to the billing address.
    * 3. When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax is not empty.
    */

    if (Trigger.isBefore && Trigger.isInsert) {
        handler.beforeInsertHandler(Trigger.new);
    }

    /*
    * Account Trigger
    * When an account is inserted create a contact related to the account with the following default values:
    * LastName = 'DefaultContact'
    * Email = 'default@email.com'
    * Trigger should only fire on insert. --> Since we can't handle updates on related objects before, must be after.
    */    
    if(Trigger.isAfter && Trigger.isInsert){     
        handler.afterInsertHandler(Trigger.new);
    }
}