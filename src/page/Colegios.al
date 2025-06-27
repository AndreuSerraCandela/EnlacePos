page 75208 "Colegios"
{
    ApplicationArea = All;
    Caption = 'Colegios';
    PageType = List;
    SourceTable = Contact;
    UsageCategory = Lists;
    CardPageId = "Colegios Card";
    Editable = true;
    SourceTableView = where("Colegio Activo" = const(Yes));

    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field("Contacto"; Rec.Cargo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del contacto principal del colegio.';
                }
                field("Fecha Alta"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha en que se dio de alta el colegio en el sistema.';
                }

            }
        }
    }
}