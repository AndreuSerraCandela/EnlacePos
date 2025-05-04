Page 91150 DetallePagoFactura
{
    Caption = 'Detalle Pago Factura';
    SourceTable = "Detalle Pago Factura";
    layout
    {
        area(Content)
        {
            repeater(DetallePagoFactura)
            {
                field(Document_Type; Rec."Document Type") { ApplicationArea = All; }
                field(Document_No_; Rec."Document No.") { ApplicationArea = All; }
                field(Line_No_; Rec."Line No.") { ApplicationArea = All; }
                // Campos personalizados para pago
                field(Forma_de_Pago; Rec."Forma de Pago")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la forma de pago utilizada';
                }
                field(Importe; Rec."Importe")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe pagado con este método de pago';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NuevaLinea)
            {
                ApplicationArea = All;
                Caption = 'Nueva Línea';
                ToolTip = 'Añade una nueva línea de detalle de pago';
                Image = NewItem;

                trigger OnAction()
                begin
                    Rec.Init();
                    Rec.Insert(true);
                end;
            }
        }
    }
}
page 91153 DetallePagoFacturaFactBox
{
    Caption = 'Detalle Pago Factura';
    PageType = ListPart;
    SourceTable = "Detalle Pago Factura";
    layout
    {
        area(Content)
        {
            repeater(DetallePagoFactura)
            {
                field(Forma_de_Pago; Rec."Forma de Pago")
                {
                    ApplicationArea = All;
                }
                field(Importe; Rec."Importe")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
