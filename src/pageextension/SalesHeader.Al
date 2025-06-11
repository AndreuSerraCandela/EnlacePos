pageextension 75207 "Sales Invoice Header Ext" extends "Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Name"; Nombre)
            {
                Caption = 'Nombre Cliente';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Rec."Sell-to Customer Name" := Nombre;
                end;
            }
            group(Pos)
            {
                field(Colegio; Rec.Colegio)
                {
                    Caption = 'Colegio';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el colegio asociado al cliente';
                }
                field(Caja; Rec.TPV)
                {
                    Caption = 'Caja/Tpv';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la caja asociada a la factura';
                }
                field(Tienda; Rec.Tienda)
                {
                    Caption = 'Tienda';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el TPV asociado a la factura';
                }
                field(Turno; Rec.Turno)
                {
                    Caption = 'Turno';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el turno asociado a la factura';
                }
                field(Cupon; Rec."Cupon de descuento")
                {
                    Caption = 'Cupón';
                    ApplicationArea = All;
                    ToolTip = 'Especifica los cupones asociados a la factura';
                }
                field("Tipo Detalle"; Rec."Tipo Detalle")
                {
                    Caption = 'Tipo Detalle';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el tipo de detalle asociado a la factura';
                }
                field("No. Detalle"; Rec."No. Detalle")
                {
                    Caption = 'No. Detalle';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de detalle asociado a la factura';
                }
            }
        }

        addafter("Invoice Details")
        {
            part(DetallePagoFacturaFactBox; DetallePagoFacturaFactBox)
            {
                ApplicationArea = All;
                Caption = 'Detalle Pago Factura';
                SubPageLink = "Document Type" = field("Document Type"),
                              "Document No." = field("No.");
            }
        }
    }



    var
        Nombre: Text[50];


    trigger OnAfterGetRecord()
    begin
        Nombre := Rec."Sell-to Customer Name";

    end;
}
pageextension 75208 "Sales Invoices Ext" extends "Sales Invoice List"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field(Colegio; Rec.Colegio)
            {
                Caption = 'Colegio';
                ApplicationArea = All;
            }
            field(TPV; Rec.TPV)
            {
                Caption = 'TPV';
                ApplicationArea = All;
            }
        }
    }

}
