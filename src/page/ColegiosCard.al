page 75209 "Colegios Card"
{
    Caption = 'Ficha de Colegio';
    PageType = Card;
    SourceTable = Colegios;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No"; Rec."No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código único del colegio.';
                }
                field("Nombre"; Rec."Nombre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del colegio.';
                }
                field("NIF/CIF"; Rec."NIF/CIF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el NIF o CIF del colegio.';
                }
                field("Fecha Alta"; Rec."Fecha Alta")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha en que se dio de alta el colegio en el sistema.';
                }
            }
            group(ContactoInfo)
            {
                Caption = 'Información de Contacto';

                field("Dirección"; Rec."Dirección")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del colegio.';
                }
                field("Dirección 2"; Rec."Dirección 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica información adicional de la dirección del colegio.';
                }
                field("Código Postal"; Rec."Código Postal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del colegio.';
                }
                field("Ciudad"; Rec."Ciudad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el colegio.';
                }
                field("Provincia"; Rec."Provincia")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la provincia donde se encuentra el colegio.';
                }
                field("País"; Rec."País")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el país donde se encuentra el colegio.';
                }
                field("Teléfono"; Rec."Teléfono")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del colegio.';
                }
                field("Móvil"; Rec."Móvil")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de móvil de contacto del colegio.';
                }
                field("Email"; Rec."Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del colegio.';
                }
                field("Sitio Web"; Rec."Sitio Web")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del sitio web del colegio.';
                }
                field("ContactoPrincipal"; Rec."Contacto")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del contacto principal del colegio.';
                }
            }
            group(Notas)
            {
                Caption = 'Notas';

                field(NotasField; Rec."Notas")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica notas adicionales sobre el colegio.';
                    MultiLine = true;
                }
            }
        }
    }
}