/// <summary>
/// Table CierreDeCajaDetalle (ID 90104).
/// </summary>
table 91104 CierreDeCajaDetalle
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; item; Integer)
        {
            Caption = 'ID';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; idCierre; Code[20])
        {
            Caption = 'ID Cierre';
            TableRelation = "Control de TPV"."Id Replicacion";
        }
        field(3; idApertura; Code[20])
        {
            Caption = 'ID Apertura';
            TableRelation = "Control de TPV"."Id Replicacion";
        }
        field(4; idFormaPago; Code[20])
        {
            Caption = 'Código Forma Pago';
            TableRelation = "Payment Method".Code;
        }
        field(5; DesFormaPago; Text[100])
        {
            Caption = 'Descripción Forma Pago';
            FieldClass = FlowField;
            CalcFormula = lookup("Payment Method".Description where(Code = field(idFormaPago)));
            Editable = false;
        }
        field(6; MontoPago; Decimal)
        {
            Caption = 'Monto Pago';
            DecimalPlaces = 0 : 2;
        }
    }

    keys
    {
        key(PK; item)
        {
            Clustered = true;
        }
        key(Relation; idCierre, idApertura)
        {
        }
    }
}