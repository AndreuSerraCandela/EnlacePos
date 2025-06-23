tableextension 75211 CustomerExt extends Customer
{
    fields
    {
        field(90112; "POS Discount"; Decimal)
        {
            Caption = 'POS Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2 : 2;
            Description = 'Discount percentage to be applied at POS';
        }
        field(75212; "Source Counter"; Integer)
        {
            Caption = 'Source Counter';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
    }


}