/// <summary>
/// Page Cajas (ID 90113).
/// </summary>
page 75213 "Cajas"
{
    Caption = 'Cajas';
    PageType = List;
    SourceTable = "Configuracion TPV";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "Caja Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."Id TPV")
                {
                    Caption = 'No';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la caja';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Nombre"; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre descriptivo de la caja';
                }
                field("TPV"; Rec."Tienda")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el TPV asociado a la caja';
                }
            }
        }

    }
}
// Crear Card
page 75214 "Caja Card"
{
    Caption = 'Caja/TPV';
    PageType = Card;
    SourceTable = "Configuracion TPV";
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Tienda"; Rec."Tienda")
                {
                    Caption = 'Tienda';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el TPV asociado a la caja';
                }
                field(No; Rec."Id TPV")
                {
                    Caption = 'No';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la caja';
                }
                field("Nombre"; Rec.Descripcion)
                {
                    ApplicationArea = All;
                }

            }
            group(Numeradores)
            {
                Caption = 'Numeradores';
                field("Numerador facturas"; Rec."No. serie Facturas")
                {
                    ApplicationArea = All;
                }
                field("Numerador abonos"; Rec."No. serie notas credito")
                {
                    ApplicationArea = All;
                }
                field("Numerador facturas registradas"; Rec."No. serie facturas Reg.")
                {
                    ApplicationArea = All;
                }
                field("Numerador abonos registrados"; Rec."No. serie notas credito reg.")
                {
                    ApplicationArea = All;
                }
                field("Numerador remisiones"; Rec."No. Series NFC Remision")
                {
                    ApplicationArea = All;
                }
                field("Numerador facturas NFC"; Rec."No. Series NFC Facturas")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}