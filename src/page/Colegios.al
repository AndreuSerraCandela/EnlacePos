page 75208 "Colegios"
{
    ApplicationArea = All;
    Caption = 'Colegios';
    PageType = List;
    SourceTable = Colegios;
    UsageCategory = Lists;
    CardPageId = "Colegios Card";
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field("Teléfono"; Rec."Teléfono")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del colegio.';
                }
                field("Email"; Rec."Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del colegio.';
                }
                field("Contacto"; Rec."Contacto")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del contacto principal del colegio.';
                }
                field("Fecha Alta"; Rec."Fecha Alta")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha en que se dio de alta el colegio en el sistema.';
                }
            }
        }
    }
}