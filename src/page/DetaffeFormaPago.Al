page 75217 "Detalle Forma Pago"
{
    Caption = 'Detaffe Forma Pago';
    PageType = List;
    SourceTable = "Payment Method Det TPV";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Tienda"; Rec."Tienda")
                {
                    ApplicationArea = All;
                }
                field("Tipo Cuenta pago"; Rec."Tipo Cuenta pago")
                {
                    ApplicationArea = All;
                }
                field("Cuenta pago"; Rec."Cuenta pago")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}