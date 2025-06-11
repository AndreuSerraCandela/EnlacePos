page 75251 "Detalle Pago Factura Page"
{
    Caption = 'Detalle Pago Factura';
    PageType = List;
    SourceTable = "Detalle Pago Factura";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Detalles)
            {
                field(Document_Type; Rec."Document Type") { ApplicationArea = All; }
                field(Document_No_; Rec."Document No.") { ApplicationArea = All; }
                field(Line_No_; Rec."Line No.") { ApplicationArea = All; }
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