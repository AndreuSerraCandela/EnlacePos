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
            ObsoleteState = Pending;
            Caption = 'Source Counter';
        }
        field(50102; "Source Counter2"; Integer)
        {
            Caption = 'Source Counter2';
        }

    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
        key(PS2; "Source Counter2")
        {

        }
    }

}

