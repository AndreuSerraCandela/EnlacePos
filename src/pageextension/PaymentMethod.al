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
            field(Tpv; Rec.Tpv)
            {
                Caption = 'Tpv';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("Mostrar Todo")
            {
                Caption = 'Mostrar Todo';
                Image = ClearFilter;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.SetRange(Tpv, false);

                end;
            }
        }
        addlast(Promoted)
        {
            actionref(MostrarTodoAction; "Mostrar Todo")
            {
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange(Tpv, true);
    end;
}
