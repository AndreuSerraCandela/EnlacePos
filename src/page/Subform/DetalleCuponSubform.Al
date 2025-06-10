page 91119 "Detalle Cupón Subform"
{
    Caption = 'Detalle Cupón';
    PageType = ListPart;
    SourceTable = "Detalle Cupón";


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tipo Detalle"; Rec."Tipo Detalle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el tipo de detalle del cupón';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número según el tipo de detalle';
                }
                field("% Descuento"; Rec."% Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el porcentaje de descuento';
                }
                field("Importe Descuento"; Rec."Importe Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de descuento';
                }
                field("Importe Total Descontado"; Rec."Importe Total Descontado")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe total descontado';
                    Editable = false;
                }
            }
        }
    }
}