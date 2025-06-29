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
                TestField("Cuenta descuento");
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
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                if "Bal. Account No." <> '' then
                    Error('No se puede tener una cuenta de pago y una cuenta de contrapartida');


            end;
        }

    }
}