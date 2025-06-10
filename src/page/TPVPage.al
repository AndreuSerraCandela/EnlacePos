/// <summary>
/// Page TPV List (ID 91170).
/// </summary>
page 91170 "TPV List"
{
    Caption = 'TPV';
    PageType = List;
    SourceTable = Tiendas;
    CardPageId = "TPV Card";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No"; Rec."Cod. Tienda")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el identificador único del TPV.';
                }
                field("Nombre"; Rec.Descripcion)
                {
                    Caption = 'Nombre';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del TPV.';
                }
                field("Location Code"; Rec."Cod. Almacen")
                {
                    Caption = 'Código Localización';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la localización asociada al TPV.';
                }
                field("Dirección"; Rec."Direccion")
                {
                    Caption = 'Dirección';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del TPV.';
                }
                field("Dirección 2"; Rec."Direccion 2")
                {
                    Caption = 'Dirección 2';
                    ApplicationArea = All;
                    ToolTip = 'Especifica información adicional de la dirección del TPV.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    Caption = 'Ciudad';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el TPV.';
                }
                field("Código Postal"; Rec."Codigo Postal")
                {
                    Caption = 'Código Postal';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del TPV.';
                }
                // field("Provincia"; Rec."Provincia")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Especifica la provincia donde se encuentra el TPV.';
                // }
                field("País"; Rec."Cod. Pais")
                {
                    Caption = 'País';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el país donde se encuentra el TPV.';
                }
                field("Teléfono"; Rec.Telefono)
                {
                    Caption = 'Teléfono';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del TPV.';
                }
                field("Móvil"; Rec."Telefono 2")
                {
                    Caption = 'Móvil';
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de móvil del TPV.';
                }
                field("Email"; Rec."e-mail")
                {
                    Caption = 'Email';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del TPV.';
                }
                field("Sitio Web"; Rec."Pagina web")
                {
                    Caption = 'Sitio Web';
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección web del TPV.';
                }
                field("NIF/CIF"; Rec."No. Identificacion Fiscal")
                {
                    Caption = 'NIF/CIF';
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