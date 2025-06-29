table 75250 "Detalle Pago Factura"
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
        field(50002; "Descuento"; Decimal)
        {
            Caption = 'Descuento';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            trigger OnValidate()
            var
                PaymentMethod: Record "Payment Method";
                SalesLine: Record "Sales Line";
                SalesLine2: Record "Sales Line";
                LineNo: Integer;
            begin
                // PaymentMethod.Get("Forma de Pago");
                // SalesLine.SetRange("Document No.", "Document No.");
                // If SalesLine.FindLast() then begin
                //     LineNo := SalesLine."Line No." + 1;
                //     SalesLine2 := SalesLine;
                //     SalesLine2."Line No." := LineNo;
                //     SalesLine2.Validate("Quantity", -1);
                //     SalesLine2.Type := SalesLine2.Type::"G/L Account";
                //     SalesLine2.Validate("No.", PaymentMethod."Cuenta descuento");
                //     SalesLine2.Validate("Unit Price", "Descuento");
                //     SalesLine2.Validate("Line Discount %", 0);
                //     SalesLine2.Insert();
                // end;

            end;
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