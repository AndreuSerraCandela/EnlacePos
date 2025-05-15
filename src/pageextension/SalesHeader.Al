pageextension 91107 "Sales Invoice Header Ext" extends "Sales Invoice"
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
            field(Colegio; Rec.Colegio)
            {
                Caption = 'Colegio';
                ApplicationArea = All;
                ToolTip = 'Especifica el colegio asociado al cliente';
            }
            field(Caja; Rec.Caja)
            {
                Caption = 'Caja';
                ApplicationArea = All;
                ToolTip = 'Especifica la caja asociada a la factura';
            }
            field(TPV; Rec.TPV)
            {
                Caption = 'TPV';
                ApplicationArea = All;
                ToolTip = 'Especifica el TPV asociado a la factura';
            }
            field(Turno; Rec.Turno)
            {
                Caption = 'Turno';
                ApplicationArea = All;
                ToolTip = 'Especifica el turno asociado a la factura';
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
pageextension 91108 "Sales Invoices Ext" extends "Sales Invoice List"
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
