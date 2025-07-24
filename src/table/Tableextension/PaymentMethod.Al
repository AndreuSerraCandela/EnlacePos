tableextension 75214 PaymentMethodExtension extends "Payment Method"
{
    fields
    {
        //Añadir Dto
        field(91100; Dto; Decimal)
        {
            Caption = 'Dto';
            DecimalPlaces = 0 : 2;
            trigger OnValidate()
            begin
                // TestField("Cuenta descuento");
            end;
        }
        field(91101; Tpv; Boolean)
        {
            Caption = 'Tpv';
            trigger OnValidate()
            begin
                TestField("Tipo Cuenta pago");
                "Bal. Account No." := '';
            end;
        }
        field(91102; "Cuenta descuento"; Code[20])
        {
            Caption = 'Cuenta descuento';
            TableRelation = "G/L Account";

        }
        field(91103; "Tipo Cuenta pago"; enum "Payment Balance Account Type")
        {
            Caption = 'Tipo Cuenta pago';

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(91104; "Cuenta pago"; Code[20])
        {
            Caption = 'Cuenta pago';
            TableRelation = if ("Tipo Cuenta pago" = const("G/L Account")) "G/L Account"
            else
            if ("Tipo Cuenta pago" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                if "Bal. Account No." <> '' then
                    Error('No se puede tener una cuenta de pago y una cuenta de contrapartida');


            end;
        }
        field(91105; "Tipo Pago"; enum "TipoPago")
        {
            Caption = 'Tipo Pago';

        }

    }
    procedure CuentaPago(pCode: Code[20]; Tienda: Code[20]): Code[20]
    var
        Dedtalle: Record "Payment Method Det TPV";
    begin
        Dedtalle.SetRange("Payment Method", "pCode");
        Dedtalle.SetRange("Tienda", Tienda);
        if Dedtalle.FindFirst() then
            exit(Dedtalle."Cuenta pago");
        Error('No se ha encontrado la cuenta de pago para la tienda %1 y el método de pago %2', Tienda, pCode);
    end;
}