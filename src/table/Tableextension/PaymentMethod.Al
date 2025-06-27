tableextension 75214 PaymentMethodExtension extends "Payment Method"
{
    fields
    {
        //Añadir Dto
        field(91100; Dto; Decimal)
        {
            Caption = 'Dto';
            DecimalPlaces = 0 : 2;
        }
        field(91101; Tpv; Boolean)
        {
            Caption = 'Tpv';
        }
    }
}