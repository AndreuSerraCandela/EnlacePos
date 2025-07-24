page 75251 "Detalle Pago Factura Page"
{
    Caption = 'Detalle Pago Factura';
    PageType = List;
    SourceTable = "Detalle Pago Factura";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Detalles)
            {
                field(Document_Type; Rec."Document Type") { ApplicationArea = All; }
                field(Document_No_; Rec."Document No.") { ApplicationArea = All; }
                field(Fecha; FFecha()) { ApplicationArea = All; }
                field(Cliente; FCliente()) { ApplicationArea = All; }
                field("Documeto Definitivo"; DocumetoDefinitivo())
                { ApplicationArea = All; }
                field(Pendiente; PPendiente())
                {
                    ApplicationArea = All;
                    Caption = 'Pendiente';
                    ToolTip = 'Indica si el documento está pendiente de pago';
                }
                field(Line_No_; Rec."Line No.") { ApplicationArea = All; }
                field(Forma_de_Pago; Rec."Forma de Pago")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la forma de pago utilizada';
                }
                field(Importe; Rec."Importe")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe pagado con este método de pago';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Contabilizar Cobro")
            {
                ApplicationArea = All;
                Caption = 'Nueva Línea';
                ToolTip = 'Añade una nueva línea de detalle de pago';
                Image = NewItem;

                trigger OnAction()
                var
                    SlesInvoiceLine: Record "Sales Invoice Line";
                    Detallepago: Record "Detalle Pago Factura";
                    SalesCrMemoLine: Record "Sales Cr.Memo Line";
                    Importe: Decimal;
                    ImportePagado: Decimal;
                    Descuento: Decimal;
                    GenJnlLine: Record "Gen. Journal Line";
                    PaymentMethod: Record "Payment Method";
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
                begin
                    //cONTABILIZAR LINEAS DE PAGO
                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", Rec."Document No.");
                    If Not SalesCrMemoHeader.FindFirst() then
                        SalesCrMemoHeader.Init();
                    SalesInvoiceHeader.SetRange("Pre-Assigned No.", Rec."Document No.");
                    If Not SalesInvoiceHeader.FindFirst() then
                        SalesInvoiceHeader.Init();
                    If (SalesInvoiceHeader."No." <> '') and (PPendiente()) then begin
                        SlesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                        If SlesInvoiceLine.FindSet() then begin
                            Repeat
                                Importe := Importe + SlesInvoiceLine."Amount Including VAT";
                            Until SlesInvoiceLine.Next() = 0;
                        end;
                        if (Importe > 0) and (SalesInvoiceHeader."No." <> '') then begin
                            Detallepago.SetRange("Document No.", Rec."Document No.");
                            if Detallepago.FindSet() then begin
                                Repeat
                                    GenJnlLine.Init();
                                    GenJnlLine."Document No." := SalesInvoiceHeader."No.";
                                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                                    GenJnlLine."Line No." := Detallepago."Line No.";
                                    GenJnlLine."Posting Date" := SalesInvoiceHeader."Posting Date";
                                    PaymentMethod.Get(Detallepago."Forma de Pago");
                                    case PaymentMethod."Tipo Cuenta pago" of
                                        PaymentMethod."Tipo Cuenta pago"::"Bank Account":
                                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                                        PaymentMethod."Tipo Cuenta pago"::"G/L Account":
                                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";

                                    end;
                                    GenJnlLine.Validate("Account No.", PaymentMethod.CuentaPago(PaymentMethod."Cuenta pago", SalesInvoiceHeader.Tienda));
                                    GenJnlLine.Description := 'Pago de factura ' + SalesInvoiceHeader."No.";
                                    GenJnlLine.Validate(Amount, Detallepago."Importe");
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Account Type"::Customer;
                                    GenJnlLine.Validate("Bal. Account No.", SalesInvoiceHeader."Bill-to Customer No.");
                                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                                    GenJnlLine."Applies-to Doc. No." := SalesInvoiceHeader."No.";
                                    ImportePagado := ImportePagado + Detallepago."Importe";
                                    GenJnlLine."Shortcut Dimension 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
                                    GenJnlLine."Shortcut Dimension 2 Code" := SalesInvoiceHeader."Shortcut Dimension 2 Code";
                                    if GenJnlLine."Dimension Set ID" = 0 then
                                        GenJnlLine."Dimension Set ID" := SalesInvoiceHeader."Dimension Set ID";
                                    GenJnlPostLine.Run(GenJnlLine);
                                Until Detallepago.Next() = 0;

                            end;
                        end;
                    end;
                    if (SalesCrMemoHeader."No." <> '') and (PPendiente()) then begin
                        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                        If SalesCrMemoLine.FindSet() then begin
                            Repeat
                                Importe := Importe + SalesCrMemoLine."Amount Including VAT";
                            Until SalesCrMemoLine.Next() = 0;
                        end;

                        if (Importe <> 0) and (SalesCrMemoHeader."No." <> '') then begin
                            Detallepago.SetRange("Document No.", Rec."Document No.");
                            if Detallepago.FindSet() then begin
                                Repeat
                                    GenJnlLine.Init();
                                    GenJnlLine."Document No." := SalesCrMemoHeader."No.";
                                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                                    GenJnlLine."Line No." := Detallepago."Line No.";
                                    GenJnlLine."Posting Date" := SalesCrMemoHeader."Posting Date";
                                    PaymentMethod.Get(Detallepago."Forma de Pago");
                                    case PaymentMethod."Tipo Cuenta pago" of
                                        PaymentMethod."Tipo Cuenta pago"::"Bank Account":
                                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                                        PaymentMethod."Tipo Cuenta pago"::"G/L Account":
                                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";

                                    end;
                                    GenJnlLine.Validate("Account No.", PaymentMethod.CuentaPago(PaymentMethod."Cuenta pago", SalesCrMemoHeader.Tienda));
                                    GenJnlLine."Bal. Account Type" := GenJnlLine."Account Type"::Customer;
                                    GenJnlLine.Validate("Bal. Account No.", SalesCrMemoHeader."Bill-to Customer No.");
                                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                                    GenJnlLine."Applies-to Doc. No." := SalesCrMemoHeader."No.";
                                    GenJnlLine.Description := 'Liq.Nota crédito ' + SalesCrMemoHeader."No.";
                                    GenJnlLine.Validate(Amount, -Detallepago."Importe");

                                    GenJnlLine."Shortcut Dimension 1 Code" := SalesCrMemoHeader."Shortcut Dimension 1 Code";
                                    GenJnlLine."Shortcut Dimension 2 Code" := SalesCrMemoHeader."Shortcut Dimension 2 Code";
                                    if GenJnlLine."Dimension Set ID" = 0 then
                                        GenJnlLine."Dimension Set ID" := SalesCrMemoHeader."Dimension Set ID";
                                    GenJnlPostLine.Run(GenJnlLine);
                                Until Detallepago.Next() = 0;
                            end;
                        end;
                    end;
                end;

            }




        }
    }

    local procedure DocumetoDefinitivo(): Text
    var
        Factura: Record "Sales Invoice Header";
        Abono: Record "Sales Cr.Memo Header";
    begin
        If Rec."Document Type" = Rec."Document Type"::Invoice then begin
            Factura.SetRange("Pre-Assigned No.", Rec."Document No.");
            If Factura.FindFirst() then
                exit(Factura."No.");
            exit('');
        end;
        If Rec."Document Type" = Rec."Document Type"::"Credit Memo" then begin
            Abono.SetRange("Pre-Assigned No.", Rec."Document No.");
            If Abono.FindFirst() then
                exit(Abono."No.");
            exit('');
        end;
        exit('');
    end;

    local procedure PPendiente(): Boolean
    var
        MovCliente: Record "Cust. Ledger Entry";
    begin
        MovCliente.SetRange("Document No.", Rec."Document No.");
        MovCliente.SetRange("Document Type", Rec."Document Type");
        If MovCliente.FindFirst() then
            exit(MovCliente.Open);
        exit(false);
    end;

    local procedure FFecha(): Date
    var
        MovCliente: Record "Cust. Ledger Entry";
        SalesHeader: Record "Sales Header";
    begin
        MovCliente.SetRange("Document No.", Rec."Document No.");
        MovCliente.SetRange("Document Type", Rec."Document Type");
        If MovCliente.FindFirst() then
            exit(MovCliente."Posting Date");
        If SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit(SalesHeader."Posting Date");
        exit(0D);
    end;

    local procedure FCliente(): Text
    var
        SalesHeader: Record "Sales Header";
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        If SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit(SalesHeader."Sell-to Customer Name");
        CustomerLedgerEntry.SetRange("Document No.", Rec."Document No.");
        CustomerLedgerEntry.SetRange("Document Type", Rec."Document Type");
        If CustomerLedgerEntry.FindFirst() then
            exit(CustomerLedgerEntry."Customer Name");
        exit('')
    end;
}