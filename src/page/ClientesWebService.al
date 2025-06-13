page 75218 "Clientes Web Service"
{
    ApplicationArea = All;
    Caption = 'Clientes Web Service';
    PageType = List;
    SourceTable = Customer;
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del cliente.';
                }
                field("Direccion"; Rec."Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección principal del cliente.';
                }
                field("Direccion_2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la segunda línea de la dirección del cliente.';
                }
                field("Poblacion"; Rec."City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la ciudad donde se encuentra el cliente.';
                }
                field("Cod_Postal"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código postal del cliente.';
                }
                field("Pais"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código del país/región del cliente.';
                }
                field("Telefono"; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono del cliente.';
                }
                field("Mobil"; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de teléfono móvil del cliente.';
                }
                field("E_Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la dirección de correo electrónico del cliente.';
                }
                field("Customer_Price_Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el grupo de precios del cliente.';
                }
                field("Contacto"; Rec."Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del contacto principal del cliente.';
                }
                field("Numero_Identificacion_fiscal"; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el número de identificación fiscal del cliente.';
                }
                field("POS_Discount"; Rec."POS Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código de descuento POS del cliente.';
                }
            }
        }
    }
}