tableextension 75221 "Sales Price Ext" extends "Sales Price"
{
    fields
    {
        modify("Sales Code")
        {
            TableRelation = if ("Sales Type" = const(Customer)) Customer
            else if ("Sales Type" = const("Customer Price Group")) "Customer Discount Group"
            else if ("Sales Type" = const(Campaign)) Campaign
            else if ("Sales Type" = const(Colegio)) Contact;
        }
        field(50101; "Source Counter"; Integer)
        {
            Caption = 'Source Counter';
        }

    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
    }

}

