/// <summary>
/// Page TPV List (ID 91170).
/// </summary>
page 91170 "TPV List"
{
    Caption = 'TPV';
    PageType = List;
    SourceTable = TPV;
    CardPageId = "TPV Card";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No"; Rec."No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el identificador único del TPV.';
                }
                field("Nombre"; Rec."Nombre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del TPV.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la localización asociada al TPV.';
                }
                field("Dirección"; Rec."Dirección")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del TPV.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el TPV.';
                }
                field("Teléfono"; Rec."Teléfono")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del TPV.';
                }
            }
        }
    }
}