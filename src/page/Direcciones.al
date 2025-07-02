page 75228 "Direcciones"
{
    ApplicationArea = All;
    Caption = 'Direcciones';
    PageType = List;
    SourceTable = 222;
    UsageCategory = Lists;
    Editable = true;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("CustomerNo"; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código único del colegio.';
                }
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código único de la dirección.';
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del colegio.';
                }
                field("Ciudad"; Rec."City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el colegio.';
                }
                field("Provincia"; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la provincia donde se encuentra el colegio.';
                }
                field("Teléfono"; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del colegio.';
                }
                field("Email"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del colegio.';
                }



            }
        }
    }
}