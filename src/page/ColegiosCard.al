page 75209 "Colegios Card"
{
    Caption = 'Ficha de Colegio';
    PageType = Card;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No"; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código único del colegio.';
                }
                field("Nombre"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del colegio.';
                }
                field("NIF/CIF"; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el NIF o CIF del colegio.';
                }
                field("Fecha Alta"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha en que se dio de alta el colegio en el sistema.';
                }
            }
            group(ContactoInfo)
            {
                Caption = 'Información de Contacto';

                field("Dirección"; Rec."Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del colegio.';
                }
                field("Dirección 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica información adicional de la dirección del colegio.';
                }
                field("Código Postal"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del colegio.';
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
                field("País"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el país donde se encuentra el colegio.';
                }
                field("Teléfono"; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del colegio.';
                }
                field("Móvil"; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de móvil de contacto del colegio.';
                }
                field("Email"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del colegio.';
                }
                field("Sitio Web"; Rec."Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección del sitio web del colegio.';
                }
                field("ContactoPrincipal"; Rec.Cargo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del contacto principal del colegio.';
                }
            }
            // group(Notas)
            // {
            //     Caption = 'Notas';

            //     field(NotasField; Rec.Comment)
            //     {
            //         ApplicationArea = All;
            //         ToolTip = 'Especifica notas adicionales sobre el colegio.';
            //         MultiLine = true;
            //     }
            // }
        }
    }
}