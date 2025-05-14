/// <summary>
/// Page Cajas (ID 90113).
/// </summary>
page 91113 "Cajas"
{
    Caption = 'Cajas';
    PageType = List;
    SourceTable = Cajas;
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la caja';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Nombre"; Rec.Nombre)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre descriptivo de la caja';
                }
                field("TPV"; Rec.TPV)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el TPV asociado a la caja';
                }
            }
        }
    }
}