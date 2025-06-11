pageextension 75213 CustomerListExt extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field(Direcccion; Rec.Address)
            {
                ApplicationArea = All;
            }
            field("Direccion 2"; Rec."Address 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies additional address information';
            }
            field("Poblacion"; Rec."City")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the city of the customer';
            }
            field("Cod. Postal"; Rec."Post Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the postal code';
            }
            field("Pais"; Rec."Country/Region Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the country or region of the address';
            }
            field("Telefono"; Rec."Phone No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer''s phone number';
            }
            field("Mobil"; Rec."Mobile Phone No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer''s mobile phone number';
            }
            // field("E-Mail"; Rec."E-Mail")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the customer''s email address';
            // }
            field("Contacto"; Rec."Contact")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the name of the person to contact at the customer';
            }
            field("Numero Identificacion fiscal"; Rec."VAT Registration No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Payment Terms Code")
        {
            field("POS Discount"; Rec."POS Discount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the discount percentage to be applied at point of sale (POS)';
                Visible = true;
            }
        }
    }
}