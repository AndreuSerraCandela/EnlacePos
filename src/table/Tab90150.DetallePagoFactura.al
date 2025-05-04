table 91150 "Detalle Pago Factura"
{
    Caption = 'Detalle Pago Factura';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        // CUSTOM FIELDS FOR PAYMENT DETAILS
        field(50000; "Forma de Pago"; Code[20])
        {
            Caption = 'Forma de Pago';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(50001; "Importe"; Decimal)
        {
            Caption = 'Importe';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
}