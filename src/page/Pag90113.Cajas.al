/// <summary>
/// Page Cajas (ID 90113).
/// </summary>
page 91113 "Cajas"
{
    Caption = 'Cajas';
    PageType = List;
    SourceTable = "Configuracion TPV";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."Id TPV")
                {
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
page 91114 "Caja Card"
{
    Caption = 'Caja';
    PageType = Card;
    SourceTable = "Configuracion TPV";
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."Id TPV")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la caja';
                }
                field("Nombre"; Rec.Descripcion)
                {
                    ApplicationArea = All;
                }
                field("TPV"; Rec."Tienda")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el TPV asociado a la caja';
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
            }
        }
    }
}