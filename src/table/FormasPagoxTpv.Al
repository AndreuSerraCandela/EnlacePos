table 75214 "Payment Method Det TPV"
{
    fields
    {
        field(1; "Payment Method"; Code[20])
        {
            Caption = 'Payment Method';
            TableRelation = "Payment Method";
        }
        field(2; Tienda; Code[20])
        {
            Caption = 'Tienda';
            TableRelation = "Tiendas";
        }


        //Añadir Dto
        field(91103; "Tipo Cuenta pago"; enum "Payment Balance Account Type")
        {
            Caption = 'Tipo Cuenta pago';

        }
        field(91104; "Cuenta pago"; Code[20])
        {
            Caption = 'Cuenta pago';
            TableRelation = if ("Tipo Cuenta pago" = const("G/L Account")) "G/L Account"
            else
            if ("Tipo Cuenta pago" = const("Bank Account")) "Bank Account";

        }


    }
}