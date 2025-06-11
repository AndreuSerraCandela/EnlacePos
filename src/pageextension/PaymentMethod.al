pageextension 75215 PaymentMethodListExt extends "Payment Methods"
{
    layout
    {
        addafter(Description)
        {
            field(Dto; Rec.Dto)
            {
                Caption = 'Dto';
                DecimalPlaces = 0 : 2;
                ApplicationArea = All;
            }
        }
    }
}
