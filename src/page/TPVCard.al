/// <summary>
/// Page TPV Card (ID 75271).
/// </summary>
page 75271 "TPV Card"
{
    Caption = 'Ficha de TPV/Tienda';
    PageType = Card;
    SourceTable = Tiendas;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';


                field("No"; Rec."Cod. Tienda")
                {
                    ApplicationArea = All;
                    Caption = 'Nº';
                    ToolTip = 'Especifica el identificador único del TPV.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Nombre"; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre';
                    ToolTip = 'Especifica el nombre del TPV.';
                }
                field("Location Code"; Rec."Cod. Almacen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la localización asociada al TPV.';
                }
            }
            group(Comunicación)
            {
                Caption = 'Comunicación';
                field("Dirección"; Rec."Direccion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del TPV.';
                }
                field("Dirección 2"; Rec."Direccion 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica información adicional de la dirección del TPV.';
                }
                field("Código Postal"; Rec."Codigo Postal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del TPV.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el TPV.';
                }
                // field("Provincia"; Rec."Provincia")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Especifica la provincia donde se encuentra el TPV.';
                // }
                field("País"; Rec."Cod. Pais")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el país donde se encuentra el TPV.';
                }
                field("Teléfono"; Rec.Telefono)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del TPV.';
                }
                field("Móvil"; Rec."Telefono 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de móvil del TPV.';
                }
                field("Email"; Rec."e-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del TPV.';
                }
                field("Sitio Web"; Rec."Pagina web")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección web del TPV.';
                }
            }
            group(Fiscal)
            {
                Caption = 'Información Fiscal';
                field("NIF/CIF"; Rec."No. Identificacion Fiscal")
                {
                    ApplicationArea = All;
                    Caption = '★ NIF/CIF';
                    ToolTip = 'Especifica el NIF/CIF del TPV.';
                }
            }
            group(Otros)
            {
                Caption = 'Otros Datos';
                field("% Descuento General"; Rec."% Descuento General")
                {
                    ApplicationArea = All;
                    Caption = '★ % Descuento General';
                    ToolTip = 'Especifica el porcentaje de descuento general del TPV.';
                }
                field("Margen Cierre"; Rec."Margen Cierre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de fuente del TPV.';
                }
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
    var

}