/// <summary>
/// Page TPV Card (ID 91171).
/// </summary>
page 91171 "TPV Card"
{
    Caption = 'Ficha de TPV';
    PageType = Card;
    SourceTable = TPV;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No"; Rec."No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el identificador único del TPV.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
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
            }
            group(Comunicación)
            {
                Caption = 'Comunicación';
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
                field("Código Postal"; Rec."Código Postal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del TPV.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el TPV.';
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
            }
            group(Fiscal)
            {
                Caption = 'Información Fiscal';
                field("NIF/CIF"; Rec."NIF/CIF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el NIF/CIF del TPV.';
                }
            }
            group(Otros)
            {
                Caption = 'Otros Datos';
                field("Contacto"; Rec."Contacto")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre de la persona de contacto del TPV.';
                }
                field("Notas"; Rec."Notas")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica notas adicionales sobre el TPV.';
                }
                field("Fecha Alta"; Rec."Fecha Alta")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha de alta del TPV.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la serie de números utilizada para este TPV.';
                    Editable = false;
                }
            }
        }
    }
}