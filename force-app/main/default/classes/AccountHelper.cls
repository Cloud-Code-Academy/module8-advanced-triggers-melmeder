/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
  private final String DEFAULT_LAST_NAME = 'DefaultContact';
  private final String DEFAULT_EMAIL = 'default@email.com';

  public AccountHelper() {
    // getting a warning about leaving this blank, but I can't think of what to put in here that's actually useful
  }

  public void setTypeProspect(List<Account> accountList) {
    for (Account acc : accountList) {
      if (acc.Type == null) {
        acc.Type = 'Prospect';
      }
    }
  }

  public void addressCopy(List<Account> accountList) {
    for (Account acc : accountList) {
      if (!String.isBlank(acc.ShippingStreet)) {
        acc.BillingStreet = acc.ShippingStreet;
      }

      if (!String.isBlank(acc.ShippingCity)) {
        acc.BillingCity = acc.ShippingCity;
      }

      if (!String.isBlank(acc.ShippingState)) {
        acc.BillingState = acc.ShippingState;
      }

      if (!String.isBlank(acc.ShippingPostalCode)) {
        acc.BillingPostalCode = acc.ShippingPostalCode;
      }

      if (!String.isBlank(acc.ShippingCountry)) {
        acc.BillingCountry = acc.ShippingCountry;
      }
    }
  }

  public void setRating(List<Account> accountList) {
    for (Account acc : accountList) {
      if (
        !String.isBlank(acc.Phone) &&
        !String.isBlank(acc.Website) &&
        !String.isBlank(acc.Fax)
      ) {
        acc.Rating = 'Hot';
      }
    }
  }

  public void defaultContact(List<Account> accountList) {
    List<Contact> contacts = new List<Contact>();
    for (Account acc : accountList) {
      Contact con = new Contact();
      con.LastName = DEFAULT_LAST_NAME;
      con.Email = DEFAULT_EMAIL;
      con.AccountId = acc.Id;
      contacts.add(con);
    }
    insert contacts;
  }
}
