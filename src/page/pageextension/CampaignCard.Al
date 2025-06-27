pageextension 75218 "Campaign Card Ext" extends "Campaign Card"
{
    CaptionML = ENU = 'Campaign',
                ESP = 'Cupones y Campañas';
    layout
    {

        addafter(General)
        {
            field("Es Cupón"; Rec."Cupon")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica si el cupón es un cupón';
            }
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


            part(DetalleCupon; "Detalle Cupón Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Código Cupón" = field("No.");
                UpdatePropagation = Both;
                Caption = 'Detalle Cupón';
            }
        }
    }
    trigger OnOpenPage()
    begin
        ExtendedPriceEnabledNew := PriceCalculationMgtNew.IsExtendedPriceCalculationEnabled();
    end;

    var
        ExtendedPriceEnabledNew: Boolean;
        PriceCalculationMgtNew: Codeunit "Price Calculation Mgt.";
}