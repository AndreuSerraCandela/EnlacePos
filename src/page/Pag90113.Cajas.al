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
                }
                field("Nombre"; Rec.Nombre)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre descriptivo de la caja';
                }
            }
        }
    }
}