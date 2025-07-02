pageextension 75213 CustomerListExt extends "Customer List"
{
    layout
    {
        modify(Address)
        {
            Visible = true;
        }
        modify("Address 2")
        {
            Visible = true;
        }
        addafter(Name)
        {
            field(Direccion; Rec.Address)
            {
                Caption = 'Direccion';
                ApplicationArea = All;
            }
            field("Direccion 2"; Rec."Address 2")
            {
                Caption = 'Direccion 2';
                ApplicationArea = All;
                ToolTip = 'Specifies additional address information';
            }
            field(Dirección; Rec.Address)
            {
                Caption = 'Dirección';
                ApplicationArea = All;
            }
            field("Dirección 2"; Rec."Address 2")
            {
                Caption = 'Dirección 2';
                ApplicationArea = All;
                ToolTip = 'Specifies additional address information';
            }

            field("Poblacion"; Rec."City")
            {
                Caption = 'Poblacion';
                ApplicationArea = All;
                ToolTip = 'Specifies the city of the customer';
            }
            field("Cod. Postal"; Rec."Post Code")
            {
                Caption = 'Cod. Postal';
                ApplicationArea = All;
                ToolTip = 'Specifies the postal code';
            }
            field("Pais"; Rec."Country/Region Code")
            {
                Caption = 'Pais';
                ApplicationArea = All;
                ToolTip = 'Specifies the country or region of the address';
            }
            field("Telefono"; Rec."Phone No.")
            {
                Caption = 'Telefono';
                ApplicationArea = All;
                ToolTip = 'Specifies the customer''s phone number';
            }
            field("Mobil"; Rec."Mobile Phone No.")
            {
                Caption = 'Mobil';
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
                Caption = 'Contacto';
                ApplicationArea = All;
                ToolTip = 'Specifies the name of the person to contact at the customer';
            }
            field("Numero Identificacion fiscal"; Rec."VAT Registration No.")
            {
                Caption = 'Numero Identificacion fiscal';
                ApplicationArea = All;
            }
        }
        addafter("Payment Terms Code")
        {
            field("POS Discount"; Rec."POS Discount")
            {
                Caption = 'POS Discount';
                ApplicationArea = All;
                ToolTip = 'Specifies the discount percentage to be applied at point of sale (POS)';
                Visible = true;
            }
            field("Tipo Documento SrI"; Rec."Tipo Documento")
            {
                Caption = 'Tipo Documento SrI';
                ApplicationArea = All;
                ToolTip = 'Specifies the type of document SrI';
            }
        }
    }
}