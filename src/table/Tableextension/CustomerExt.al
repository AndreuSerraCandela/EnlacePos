tableextension 91111 CustomerExt extends Customer
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

    }
}