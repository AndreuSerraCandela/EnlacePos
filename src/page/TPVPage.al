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
                field("Dirección 2"; Rec."Dirección 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica información adicional de la dirección del TPV.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el TPV.';
                }
                field("Código Postal"; Rec."Código Postal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del TPV.';
                }
                field("Provincia"; Rec."Provincia")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la provincia donde se encuentra el TPV.';
                }
                field("País"; Rec."País")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el país donde se encuentra el TPV.';
                }
                field("Teléfono"; Rec."Teléfono")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del TPV.';
                }
                field("Móvil"; Rec."Móvil")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de móvil del TPV.';
                }
                field("Email"; Rec."Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del TPV.';
                }
                field("Sitio Web"; Rec."Sitio Web")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección web del TPV.';
                }
                field("NIF/CIF"; Rec."NIF/CIF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de identificación fiscal del TPV.';
                }
                field("Contacto"; Rec."Contacto")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre de la persona de contacto del TPV.';
                }
                field("Fecha Alta"; Rec."Fecha Alta")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha de alta del TPV.';
                }
            }
        }
    }
}