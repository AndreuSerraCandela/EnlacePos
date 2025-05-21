pageextension 91118 "Campaign Card Ext" extends "Campaign Card"
{
    CaptionML = ENU = 'Coupon',
                ESP = 'Ficha Cupón';
    layout
    {
        modify("Status Code")
        {
            Visible = false;
        }
        modify(Activated)
        {
            Visible = false;
        }
        modify("Salesperson Code")
        {
            Visible = false;
        }
        addafter(General)
        {
            group(Descuento)
            {
                Caption = 'Descuento';
                field("% Descuento"; Rec."% Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el porcentaje de descuento del cupón';
                }
                field("Importe Descuento"; Rec."Importe Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de descuento del cupón';
                }
                field("Importe Total Descontado"; Rec."Importe Total Descontado")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe total descontado del cupón';
                    Editable = false;
                }

            }

        }
        addfirst(factboxes)
        {
            part(DetalleCupon; "Detalle Cupón Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Código Cupón" = field("No.");
                UpdatePropagation = Both;
                Caption = 'Detalle Cupón';
            }
        }
    }
}