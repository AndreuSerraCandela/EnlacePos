tableextension 91114 PaymentMethodExtension extends "Payment Method"
{
    fields
    {
        //Añadir Dto
        field(91100; Dto; Decimal)
        {
            Caption = 'Dto';
            DecimalPlaces = 0 : 2;
        }
    }
}