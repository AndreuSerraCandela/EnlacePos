codeunit 90101 Eventos
{

    Permissions = tabledata "Sales Line" = RIMD,
                  tabledata "VAT Posting Setup" = RIMD,
                  tabledata "VAT Product Posting Group" = RIMD,
                  tabledata "No Taxable Entry" = RIMD;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SII XML Creator", 'OnAfterFillDetalleIVANode', '', false, false)]

    procedure AddRebuToDetalleIVANode(var XmlNodeInnerXml: Text; TempVATEntry: Record "VAT Entry" temporary; UseSign: Boolean; Sign: Integer; FillEUServiceNodes: Boolean; NonExemptTransactionType: Option S1,S2,S3,Initial; RegimeCodes: array[3] of Code[2]; AmountNodeName: Text; var IsHandled: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        // Filtrar líneas de ventas asociadas al documento actual
        SalesLine.SetRange("Document Type", TempVATEntry."Document Type");
        SalesLine.SetRange("Document No.", TempVATEntry."Document No.");

        if SalesLine.FindSet() then begin
            repeat
                // Comprobar si alguna línea aplica REBU
                if SalesLine."Apply REBU" then begin
                    // Añadir información del REBU al XML
                    XmlNodeInnerXml += '<REBUOperation>Yes</REBUOperation>';
                    exit; // Salir del bucle si se encuentra al menos una línea con REBU
                end;
            until SalesLine.Next() = 0;
        end;
    end;
    // Validate succsess Vat Registruion No en Sales Header
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateVATRegistrationNo', '', false, false)]
    local procedure OnBeforeValidateVATRegistrationNo(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        Cust: Record Customer;
    begin
        IsHandled := true;
        If Cust.Get(SalesHeader."Sell-to Customer No.") then begin
            if (Cust."VAT Registration No." <> SalesHeader."VAT Registration No.") and
            (SalesHeader."Sell-to Customer Name" = Cust.Name) then
                Message('El Nombre del cliente coincide con el de la cabecera de venta, pero el NIF, no');
        end;
        SalesHeader."Succeeded VAT Registration No." := SalesHeader."VAT Registration No.";
    end;

    // OnAfterValidateEvent Unit Cost (LCY) Sales Line
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Unit Cost (LCY)', false, false)]
    procedure ValidateUnitCost(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        // Obtener el grupo de IVA asociado a la línea de venta
        if VatPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group") then begin
            // Comprobar si el grupo de IVA aplica REBU
            if VatPostingSetup.Rebu then begin
                // Marcar la línea de venta para aplicar REBU
                Rec.Validate("Valor Compra", Rec."Unit Cost (LCY)" * Rec."Quantity");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    procedure ValidateQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        // Obtener el grupo de IVA asociado a la línea de venta
        if VatPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group") then begin
            // Comprobar si el grupo de IVA aplica REBU
            if VatPostingSetup.Rebu then begin
                // Marcar la línea de venta para aplicar REBU
                If Rec."Valor Compra" = 0 Then
                    Rec.Validate("Valor Compra", Rec."Unit Cost (LCY)" * Rec."Quantity")
                else
                    Rec.Validate("Valor Compra", Rec."Valor Compra");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Vat Prod. Posting Group', false, false)]
    procedure ValidateVatProfPostingGroup(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        // Obtener el grupo de IVA asociado a la línea de venta
        if VatPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group") then begin
            // Comprobar si el grupo de IVA aplica REBU
            if VatPostingSetup.Rebu then begin
                // Marcar la línea de venta para aplicar REBU
                Rec."Apply REBU" := true;
                if Rec."Valor Compra" = 0 Then
                    Rec.Validate("Valor Compra", Rec."Unit Cost (LCY)" * Rec."Quantity")
                else
                    Rec.Validate("Valor Compra", Rec."Valor Compra");

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnUpdateVATAmountsOnAfterCalculateNormalVAT', '', false, false)]
    procedure CalculateVAT(var SalesLine: Record "Sales Line"; var Currency: Record Currency)
    var
        TotalSales: Decimal;
        TotalPurchases: Decimal;
        TotalVat: Decimal;
        REBUVAT: Decimal;
        SalesHeader: Record "Sales Header";
        MargenConIVA: Decimal;
    begin
        TotalVAT := 0;
        REBUVAT := 0;
        If not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then SalesHeader.Init();
        // Recorrer las líneas de venta
        if (SalesLine."Apply REBU") and (not SalesHeader."Prices Including VAT") then begin
            // Calcular el margen para REBU
            TotalSales := SalesLine."Line Amount";
            TotalPurchases := SalesLine."Valor Compra"; // Campo personalizado para almacenar el precio de compra
            SalesLine."VAT Base Amount" := (TotalSales - TotalPurchases) / (1 + SalesLine."VAT %" / 100);
            SalesLine."Amount Including VAT" := SalesLine."Line Amount" + (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100);
            If SalesLine."VAT %" = 0 Then
                SalesLine."VAT base Amount" := 0;
        end;
        if (SalesLine."Apply REBU") and (SalesHeader."Prices Including VAT") then begin
            // Calcular el margen para REBU
            SalesLine."Amount Including VAT" := SalesLine."Line Amount"; // Ya que los precios incluyen IVA
            TotalSales := SalesLine."Amount Including VAT"; // Precio de venta IVA incluido
            TotalPurchases := SalesLine."Valor Compra"; // Precio de compra

            // Calcular Margen con IVA
            MargenConIVA := TotalSales - TotalPurchases;

            // Calcular Base Imponible
            SalesLine."VAT Base Amount" := Round(MargenConIVA / (1 + (SalesLine."VAT %" / 100)), Currency."Amount Rounding Precision");

            // Mantener Line Amount igual a Amount Including VAT
            SalesLine."Line Amount" := SalesLine."Amount Including VAT"; // Ya que los precios incluyen IVA
            SalesLine.Amount := Round(SalesLine."Amount Including VAT" - (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
            If SalesLine."VAT %" = 0 Then
                SalesLine."VAT base Amount" := 0;
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeCalcVATBaseAmount', '', false, false)]
    local procedure OnBeforeCalcVATBaseAmount(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var TempVATAmountLineRemainder: Record "VAT Amount Line" temporary; Currency: Record Currency; var IsHandled: Boolean)
    var
        TotalSales: Decimal;
        TotalPurchases: Decimal;
        TotalVat: Decimal;
        REBUVAT: Decimal;
        EntryNo: Integer;
        MargenConIVA: Decimal;
    begin
        TotalVAT := 0;
        REBUVAT := 0;
        // Recorrer las líneas de venta
        if (SalesLine."Apply REBU") and (SalesHeader."Prices Including VAT" = false) then begin
            // Calcular el margen para REBU
            if SalesHeader."Currency Code" <> '' then Currency.Get(SalesHeader."Currency Code");
            TotalSales := SalesLine."Line Amount";
            TotalPurchases := SalesLine."Valor Compra"; // Campo personalizado para almacenar el precio de compra
            SalesLine."VAT Base Amount" := Round((TotalSales - TotalPurchases) / (1 + SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
            SalesLine."Amount Including VAT" := Round(SalesLine."Line Amount" + (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
            IsHandled := true;
            If SalesLine."VAT %" = 0 Then
                SalesLine."VAT base Amount" := 0;

        end;
        if (SalesLine."Apply REBU") and (SalesHeader."Prices Including VAT" = true) then begin
            SalesLine."Amount Including VAT" := SalesLine."Line Amount"; // Ya que los precios incluyen IVA
            TotalSales := SalesLine."Amount Including VAT"; // Precio de venta IVA incluido
            TotalPurchases := SalesLine."Valor Compra"; // Precio de compra

            // Calcular Margen con IVA
            MargenConIVA := TotalSales - TotalPurchases;

            // Calcular Base Imponible
            SalesLine."VAT Base Amount" := Round(MargenConIVA / (1 + (SalesLine."VAT %" / 100)), Currency."Amount Rounding Precision");
            // Mantener Line Amount igual a Amount Including VAT
            SalesLine."Line Amount" := SalesLine."Amount Including VAT"; // Ya que los precios incluyen IVA
            SalesLine.Amount := Round(SalesLine."Amount Including VAT" - (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");


        end;
    end;
    //Document Totals
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Totals", 'OnBeforeSalesDeltaUpdateTotals', '', false, false)]
    local procedure OnBeforeSalesDeltaUpdateTotals(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; var TotalSalesLine: Record "Sales Line"; var VATAmount: Decimal; var InvoiceDiscountAmount: Decimal; var InvoiceDiscountPct: Decimal; var IsHandled: Boolean)
    var
        TotalSales: Decimal;
        TotalPurchases: Decimal;
        TotalVat: Decimal;
        REBUVAT: Decimal;
        currency: Record Currency;
        SaleslsHeader: Record "Sales Header";
        MargenConIVA: Decimal;
    begin
        TotalVAT := 0;
        REBUVAT := 0;
        If Not SaleslsHeader.Get(SalesLine."Document Type", SalesLine."Document No.") Then SaleslsHeader.Init();
        // Recorrer las líneas de venta
        if (SalesLine."Apply REBU") and (SaleslsHeader."Prices Including VAT" = false) then begin
            // Calcular el margen para REBU
            if SaleslsHeader."Currency Code" <> '' then currency.Get(SaleslsHeader."Currency Code");
            TotalSales := SalesLine."Line Amount";
            TotalPurchases := SalesLine."Valor Compra"; // Campo personalizado para almacenar el precio de compra
            SalesLine."VAT Base Amount" := Round((TotalSales - TotalPurchases) / (1 + SalesLine."VAT %" / 100), currency."Amount Rounding Precision");
            SalesLine."Amount Including VAT" := Round(SalesLine."Line Amount" + (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), currency."Amount Rounding Precision");
            IsHandled := true;
            If SalesLine."VAT %" = 0 Then
                SalesLine."VAT base Amount" := 0;

        end;
        if (SalesLine."Apply REBU") and (SaleslsHeader."Prices Including VAT" = true) then begin
            SalesLine."Amount Including VAT" := SalesLine."Line Amount"; // Ya que los precios incluyen IVA
            TotalSales := SalesLine."Amount Including VAT"; // Precio de venta IVA incluido
            TotalPurchases := SalesLine."Valor Compra"; // Precio de compra

            // Calcular Margen con IVA
            MargenConIVA := TotalSales - TotalPurchases;

            // Calcular Base Imponible
            SalesLine."VAT Base Amount" := Round(MargenConIVA / (1 + (SalesLine."VAT %" / 100)), currency."Amount Rounding Precision");
            // Mantener Line Amount igual a Amount Including VAT
            SalesLine."Line Amount" := SalesLine."Amount Including VAT"; // Ya que los precios incluyen IVA
            SalesLine.Amount := Round(SalesLine."Amount Including VAT" - (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
        end;
    end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostGLAndCustomer', '', false, false)]
    // local procedure OnAfterPostGLAndCustomer(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; TotalSalesLine: Record "Sales Line"; TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean;
    //     WhseShptHeader: Record "Warehouse Shipment Header"; WhseShip: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header"; var SalesInvHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    //     var CustLedgEntry: Record "Cust. Ledger Entry"; var SrcCode: Code[10]; GenJnlLineDocNo: Code[20]; GenJnlLineExtDocNo: Code[35]; var GenJnlLineDocType: Enum "Gen. Journal Document Type"; PreviewMode: Boolean; DropShipOrder: Boolean)
    // var
    //     EntryNo: Integer;
    //     NonTaxableSales: Record "No Taxable Entry";
    //     SalesLine: Record "Sales Line";
    //     TotalAmount: Decimal;
    //     TotalAmountInclVat: Decimal;
    //     TotalVat: Decimal;
    //     TotalSales: Decimal;
    //     TotalPurchases: Decimal;
    //     Currency: Record Currency;
    // begin
    //     SalesLine.SetRange("Document Type", SalesHeader."Document Type");
    //     SalesLine.SetRange("Document No.", SalesHeader."No.");
    //     SalesLine.SetRange("Apply REBU", true);
    //     if not SalesLine.FindSet() then exit;
    //     repeat
    //         if SalesHeader."Currency Code" <> '' then Currency.Get(SalesHeader."Currency Code");
    //         TotalSales := SalesLine."Line Amount";
    //         TotalPurchases := SalesLine."Valor Compra"; // Campo personalizado para almacenar el precio de compra
    //         SalesLine."VAT Base Amount" := Round((TotalSales - TotalPurchases) / (1 + SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
    //         SalesLine."Amount Including VAT" := Round(SalesLine."Line Amount" + (SalesLine."VAT Base Amount" * SalesLine."VAT %" / 100), Currency."Amount Rounding Precision");
    //         TotalAmount += SalesLine."VAT Base Amount";
    //         TotalAmountInclVat += SalesLine."Amount Including VAT";
    //     until SalesLine.Next() = 0;
    //     if NonTaxableSales.FindLast() then
    //         EntryNo := NonTaxableSales."Entry No." + 1
    //     else
    //         EntryNo := 1;
    //     NonTaxableSales.Init();
    //     NonTaxableSales."Entry No." := CustLedgEntry."Entry No.";
    //     NonTaxableSales."Document No." := CustLedgEntry."Document No.";
    //     NonTaxableSales."Document Type" := CustLedgEntry."Document Type";
    //     NonTaxableSales."Document Date" := SalesHeader."Document Date";
    //     NonTaxableSales."Posting Date" := SalesHeader."Posting Date";
    //     NonTaxableSales.Type := NonTaxableSales.Type::Sale;
    //     NonTaxableSales."Source No." := SalesHeader."Bill-to Customer No.";
    //     // Base(LCY) Añado la dierencia a sumar a la base para que al sumarle el iva me de el Amount Incl. Vat
    //     NonTaxableSales."Base (LCY)" := TotalAmountInclVat - TotalAmount;
    //     If not NonTaxableSales.Insert() then begin
    //         NonTaxableSales."Entry No." := EntryNo;
    //         NonTaxableSales.Insert();
    //     end;
    // end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SII XML Creator", 'OnBeforeCalculateTotalVatAndBaseAmounts', '', false, false)]
    local procedure OnBeforeCalculateTotalVatAndBaseAmounts(LedgerEntryRecRef: RecordRef; var TotalBaseAmount: Decimal; var TotalNonExemptVATBaseAmount: Decimal; var TotalVATAmount: Decimal; var IsHandled: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VATEntry: Record "VAT Entry";
        NoTaxableEntry: Record "No Taxable Entry";
        SIIManagement: Codeunit "SII Management";
        Rebu: Boolean;
        VatPostingSetup: Record "VAT Posting Setup";

    begin
        Rebu := false;
        if SIIManagement.FindVatEntriesFromLedger(LedgerEntryRecRef, VATEntry) then
            repeat
                if VatPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
                    If Rebu = false Then
                        Rebu := VatPostingSetup.Rebu;
                TotalBaseAmount += VATEntry.Base + VATEntry."Unrealized Base";
                if VATEntry."VAT %" <> 0 then
                    TotalNonExemptVATBaseAmount += VATEntry.Base + VATEntry."Unrealized Base";

                if VATEntry."VAT Calculation Type" <> VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
                    TotalVATAmount += VATEntry.Amount + VATEntry."Unrealized Amount";
            until VATEntry.Next() = 0;
        if Rebu = false Then exit;
        IsHandled := true;
        SIIManagement.FindNoTaxableEntriesFromLedger(LedgerEntryRecRef, NoTaxableEntry);
        NoTaxableEntry.CalcSums(NoTaxableEntry."Base (LCY)");
        TotalBaseAmount += NoTaxableEntry."Base (LCY)";
        LedgerEntryRecRef.SetTable(CustLedgerEntry);
        CustLedgerEntry.CalcFields(Amount);
        TotalBaseAmount := -CustLedgerEntry.Amount - TotalVATAmount;
    end;



    [EventSubscriber(ObjectType::Table, Database::"Vat Posting Setup", 'OnAfterValidateEvent', 'VAT Prod. Posting Group', false, false)]
    procedure ValidateVatProdPostingGroup(var Rec: Record "Vat Posting Setup"; var xRec: Record "Vat Posting Setup"; CurrFieldNo: Integer)
    var
        VatProdGroup: Record "VAT Product Posting Group";
    begin
        If VatProdGroup.Get(Rec."VAT Prod. Posting Group") Then Rec.Rebu := VatProdGroup.Rebu;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vat Amount Line", 'OnInsertLineOnBeforeModify', '', false, false)]
    local procedure OnInsertLineOnBeforeModify(var VATAmountLine: Record "VAT Amount Line"; FromVATAmountLine: Record "VAT Amount Line")
    begin
        VATAmountLine."Apply REBU" := FromVATAmountLine."Apply REBU";
        VATAmountLine."Valor Compra" := FromVATAmountLine."Valor Compra";
        if VATAmountLine."Apply REBU" then begin
            VATAmountLine."VAT Base" := (VATAmountLine."Line Amount" - VATAmountLine."Valor Compra") / (1 + VATAmountLine."VAT %" / 100);
            VATAmountLine."Amount Including VAT" := VATAmountLine."Line Amount" + (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);
            VATAmountLine."VAT Amount" := (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vat Amount Line", 'OnInsertLineOnBeforeInsert', '', false, false)]
    local procedure OnInsertLineOnBeforeInsert(var VATAmountLine: Record "VAT Amount Line"; var FromVATAmountLine: Record "VAT Amount Line")
    begin
        VATAmountLine."Apply REBU" := FromVATAmountLine."Apply REBU";
        VATAmountLine."Valor Compra" := FromVATAmountLine."Valor Compra";
        if VATAmountLine."Apply REBU" then begin
            VATAmountLine."VAT Base" := (VATAmountLine."Line Amount" - VATAmountLine."Valor Compra") / (1 + VATAmountLine."VAT %" / 100);
            VATAmountLine."Amount Including VAT" := VATAmountLine."Line Amount" + (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);
            VATAmountLine."VAT Amount" := (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnUpdateLinesOnAfterCalcAmountIncludingVATNormalVAT', '', false, false)]
    local procedure OnUpdateLinesOnAfterCalcAmountIncludingVATNormalVAT(var VATAmountLine: Record "VAT Amount Line"; PrevVATAmountLine: Record "VAT Amount Line"; var Currency: Record Currency; VATBaseDiscountPerc: Decimal; PricesIncludingVAT: Boolean)
    var
    begin
        if VATAmountLine."Apply REBU" then begin
            VATAmountLine."VAT Base" := (VATAmountLine."Line Amount" - VATAmountLine."Valor Compra") / (1 + VATAmountLine."VAT %" / 100);
            VATAmountLine."Amount Including VAT" := VATAmountLine."Line Amount" + (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);
            VATAmountLine."VAT Amount" := (VATAmountLine."VAT Base" * VATAmountLine."VAT %" / 100);

        end;

    end;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnCalcVATAmountLinesOnAfterInsertNewVATAmountLine', '', false, false)]
    // local procedure OnCalcVATAmountLinesOnAfterInsertNewVATAmountLine(var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line")
    // begin
    //     VATAmountLine."Apply REBU" := SalesLine."Apply REBU";
    //     VATAmountLine."Valor Compra" := SalesLine."Valor Compra";

    // end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnSumVATAmountLineOnBeforeModify', '', false, false)]
    local procedure OnSumVATAmountLineOnBeforeModify(var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line")
    begin
        VATAmountLine."Apply REBU" := SalesLine."Apply REBU";
        If SalesLine."Apply REBU" then
            VATAmountLine."Valor Compra" += SalesLine."Valor Compra";

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeValidatePostingAndDocumentDate', '', false, false)]
    local procedure OnBeforeValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    var
        Cust: Record Customer;
        SalesLine: Record "Sales Line";
        It: Decimal;
    begin
        If Cust.Get(SalesHeader."Sell-to Customer No.") then
            if Cust."VAT Registration No." <> SalesHeader."VAT Registration No." then begin
                Cust."VAT Registration No." := '';
                Cust.Modify();
            end;
        If salesHeader."Importe total" <> 0 Then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then begin
                repeat
                    It += SalesLine."Line Amount";
                until SalesLine.Next() = 0;
            end;
            If (Abs(It) - Abs(SalesHeader."Importe total")) > 0.01 Then
                Error('El importe total no coincide con la suma de las líneas');

        end

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header";
    var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20];
    SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway:
    Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        SalesInvLines: Record "Sales Invoice Line";
        SalesCrMemoLines: Record "Sales Cr.Memo Line";
        TotalSales: Decimal;
        TotalPurchases: Decimal;
        Margen: Decimal;
        Base: Decimal;
        Currency: Record Currency;
        GlAccountVenta: Code[20];
        GlAccountIva: Code[20];
        ConfPostingSetup: Record "General Posting Setup";
        VatPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20];
    begin
        //Todo
        //Pongo 21%, a corregir
        If Not Currency.Get(SalesHeader."Currency Code") Then
            Currency.InitRoundingPrecision();
        If SalesInvHdrNo <> '' Then begin
            DocumentNo := SalesInvHdrNo;
            SalesInvLines.SetRange("Document No.", SalesInvHdrNo);
            SalesInvLines.SetRange("Apply REBU", true);
            SalesInvLines.SetRange("VAT %", 0);
            If SalesInvLines.FindSet() Then begin
                repeat
                    If SalesInvLines.Type = SalesInvLines.Type::"G/L Account" then begin
                        GlAccountVenta := SalesInvLines."No.";

                    end else begin
                        ConfPostingSetup.Get(SalesInvLines."Gen. Prod. Posting Group", SalesInvLines."Gen. Bus. Posting Group");
                        If GlAccountVenta = '' Then begin
                            ConfPostingSetup.TestField("Sales Account");
                            GlAccountVenta := ConfPostingSetup."Sales Account";
                        end;

                    end;
                    VatPostingSetup.Get(SalesInvLines."VAT Bus. Posting Group", SalesInvLines."VAT Prod. Posting Group");
                    if GlAccountIva = '' Then begin
                        VatPostingSetup.TestField("Sales VAT Account");
                        GlAccountIva := VatPostingSetup."Sales VAT Account";
                    end;
                    TotalSales += SalesInvLines."Amount"; // Precio de venta IVA incluido
                    TotalPurchases += SalesInvLines."Valor Compra"; // Precio de compra
                until SalesInvLines.Next() = 0;
                Margen := TotalSales - TotalPurchases;
                Base := Round(Margen / 1.21, Currency."Amount Rounding Precision");
            end;
        end;
        If SalesCrMemoHdrNo <> '' Then begin
            DocumentNo := SalesCrMemoHdrNo;
            SalesCrMemoLines.SetRange("Document No.", SalesCrMemoHdrNo);
            SalesCrMemoLines.SetRange("Apply REBU", true);
            SalesCrMemoLines.SetRange("VAT %", 0);
            If SalesCrMemoLines.FindSet() Then begin
                repeat
                    If SalesInvLines.Type = SalesInvLines.Type::"G/L Account" then begin
                        GlAccountVenta := SalesInvLines."No.";

                    end else begin
                        ConfPostingSetup.Get(SalesInvLines."Gen. Prod. Posting Group", SalesInvLines."Gen. Bus. Posting Group");
                        If GlAccountVenta = '' Then begin
                            ConfPostingSetup.TestField("Sales Account");
                            GlAccountVenta := ConfPostingSetup."Sales Account";
                        end;

                    end;
                    VatPostingSetup.Get(SalesInvLines."VAT Bus. Posting Group", SalesInvLines."VAT Prod. Posting Group");
                    if GlAccountIva = '' Then begin
                        VatPostingSetup.TestField("Sales VAT Account");
                        GlAccountIva := VatPostingSetup."Sales VAT Account";
                    end;
                    TotalSales += SalesCrMemoLines."Amount"; // Precio de venta IVA incluido
                    TotalPurchases += SalesCrMemoLines."Valor Compra"; // Precio de compra
                until SalesCrMemoLines.Next() = 0;
                Margen := TotalSales - TotalPurchases;
                Base := -Round(Margen / 1.21, Currency."Amount Rounding Precision");
            end;
        end;
        If Base <> 0 Then begin
            GenerarApuntrContable(GlAccountVenta, GlAccountIva, Base, DocumentNo,
            CustLedgerEntry."Journal Templ. Name", CustLedgerEntry."Journal Batch Name",
            CustLedgerEntry."Posting Date", CustLedgerEntry.Description, CustLedgerEntry."Reason Code",
            CustLedgerEntry."Currency Code", CustLedgerEntry."Global Dimension 1 Code",
            CustLedgerEntry."Global Dimension 2 Code", CustLedgerEntry."Dimension Set ID", CustLedgerEntry."Source Code"
            , CustLedgerEntry."Customer No.");
        end;
    end;

    local procedure GenerarApuntrContable(GlAccountVenta: Code[20];
    GlAccountIva: Code[20]; Base: Decimal; DocumentNo: Code[20];
    par_Diario: Code[10]; par_Seccion: Code[10];
    podingDate: Date; PostrDescripcion: Text[50]; ReasonCode: Code[10]; CurrencyCode: Code[10];
    Dim1: Code[20]; Dim2: Code[20]; DimSetEntry: Integer; SourceCode: Code[20]; bilToCustomerNo: Code[20])

    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Currency: Record Currency;
    begin
        // Get the default general journal template and batch
        If Not Currency.Get(CurrencyCode) Then
            Currency.InitRoundingPrecision();
        // Initialize the general journal line for the sales account
        GenJnlLine.INIT;
        GenJnlLine."Journal Template Name" := par_Diario;
        GenJnlLine."Journal Batch Name" := par_Seccion;
        GenJnlLine."Posting Date" := podingDate;
        GenJnlLine."Document Date" := podingDate;

        GenJnlLine.Description := PostrDescripcion;

        GenJnlLine."Reason Code" := ReasonCode;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := GlAccountVenta;
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine.Amount := Round(Base * 0.21, Currency."Amount Rounding Precision");
        GenJnlLine."Source Currency Code" := CurrencyCode;
        GenJnlLine."Source Currency Amount" := ROUND(Base * 0.21, Currency."Amount Rounding Precision");
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine."Shortcut Dimension 1 Code" := Dim1;
        GenJnlLine."Shortcut Dimension 2 Code" := Dim2;
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Bal. Account No." := GlAccountIva;
        GenJnlLine."Dimension Set ID" := DimSetEntry;
        GenJnlLine."Source Code" := "SourceCode";
        GenJnlLine."Bill-to/Pay-to No." := bilToCustomerNo;
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := bilToCustomerNo;
        GenJnlLine."Posting No. Series" := '';
        GenJnlPostLine.RunWithCheck(GenJnlLine);


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCustomerEntry', '', false, false)]
    local procedure OnBeforePostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header"; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        Cust: Record Customer;
        VatRegNo: Text[20];
    begin
        If Cust.Get(SalesHeader."Sell-to Customer No.") then
            VatRegNo := Cust."VAT Registration No.";
        if SalesHeader."VAT Registration No." = VatRegNo then
            SalesHeader."VAT Registration No." := SalesHeader."Succeeded VAT Registration No.";
        If SalesHeader."VAT Registration No." <> '' then begin
            GenJnlLine."VAT Registration No." := SalesHeader."VAT Registration No.";
            GenJnlLine."Succeeded VAT Registration No." := SalesHeader."VAT Registration No.";
        end else begin
            if GenJnlLine."Succeeded VAT Registration No." <> '' then
                GenJnlLine."VAT Registration No." := GenJnlLine."Succeeded VAT Registration No.";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header"; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line"; PreviewMode: Boolean; SuppressCommit: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        If SalesHeader."VAT Registration No." <> '' then begin
            GenJnlLine."VAT Registration No." := SalesHeader."VAT Registration No.";
            GenJnlLine."Succeeded VAT Registration No." := SalesHeader."VAT Registration No.";
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SII XML Creator", 'OnFillThirdPartyIdOnBeforeAssignValues', '', false, false)]
    local procedure OnFillThirdPartyIdOnBeforeAssignValues(SIIDocUploadState: Record "SII Doc. Upload State"; var CountryCode: Code[20]; var Name: Text; var VatNo: Code[20]; IsIntraCommunity: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case SIIDocUploadState."Document Type" of
            SIIDocUploadState."Document Type"::Invoice:
                begin
                    if not SalesInvoiceHeader.Get(SIIDocUploadState."Document No.") then
                        exit;
                    if SalesInvoiceHeader."VAT Registration No." <> '' then
                        VatNo := SalesInvoiceHeader."VAT Registration No.";
                    if SalesInvoiceHeader."Sell-to Customer Name" <> '' then
                        Name := SalesInvoiceHeader."Sell-to Customer Name";
                    if SalesInvoiceHeader."Sell-to Country/Region Code" <> '' then
                        CountryCode := SalesInvoiceHeader."Sell-to Country/Region Code";
                end;

            SIIDocUploadState."Document Type"::"Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(SIIDocUploadState."Document No.") then
                        exit;
                    if SalesCrMemoHeader."VAT Registration No." <> '' then
                        VatNo := SalesCrMemoHeader."VAT Registration No.";
                    if SalesCrMemoHeader."Sell-to Customer Name" <> '' then
                        Name := SalesCrMemoHeader."Sell-to Customer Name";
                    if SalesCrMemoHeader."Sell-to Country/Region Code" <> '' then
                        CountryCode := SalesCrMemoHeader."Sell-to Country/Region Code";
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SII XML Creator", 'OnAfterGetCustomerByGLSetup', '', false, false)]
    local procedure OnAfterGetCustomerByGLSetup(var Customer: Record Customer; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case CustLedgerEntry."Document Type" of
            CustLedgerEntry."Document Type"::Invoice:
                begin
                    if not SalesInvoiceHeader.Get(CustLedgerEntry."Document No.") then
                        exit;
                    UpdateCustomerFromHeader(Customer,
                        SalesInvoiceHeader."VAT Registration No.",
                        SalesInvoiceHeader."sell-to Customer Name",
                        SalesInvoiceHeader."Sell-to Country/Region Code",
                        SalesInvoiceHeader."sell-to County",
                        SalesInvoiceHeader."sell-to Post Code",
                        SalesInvoiceHeader."sell-to City",
                        SalesInvoiceHeader."sell-to Address",
                        SalesInvoiceHeader."sell-to Address 2");
                end;
            CustLedgerEntry."Document Type"::"Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(CustLedgerEntry."Document No.") then
                        exit;
                    UpdateCustomerFromHeader(Customer,
                        SalesCrMemoHeader."VAT Registration No.",
                        SalesCrMemoHeader."sell-to Customer Name",
                        SalesCrMemoHeader."sell-to Country/Region Code",
                        SalesCrMemoHeader."sell-to County",
                        SalesCrMemoHeader."sell-to Post Code",
                        SalesCrMemoHeader."sell-to City",
                        SalesCrMemoHeader."sell-to Address",
                        SalesCrMemoHeader."sell-to Address 2");
                end;
        end;
    end;

    local procedure UpdateCustomerFromHeader(var Customer: Record Customer;
        VATRegNo: Text[20];
        Name: Text[100];
        CountryCode: Code[10];
        County: Text[30];
        PostCode: Code[20];
        City: Text[30];
        Address: Text[100];
        Address2: Text[50])
    begin
        if VATRegNo <> '' then
            Customer."VAT Registration No." := VATRegNo;
        if Name <> '' then
            Customer.Name := Name;
        if CountryCode <> '' then
            Customer."Country/Region Code" := CountryCode;
        if County <> '' then
            Customer.County := County;
        if PostCode <> '' then
            Customer."Post Code" := PostCode;
        if City <> '' then
            Customer.City := City;
        if Address <> '' then
            Customer.Address := Address;
        if Address2 <> '' then
            Customer."Address 2" := Address2;
    end;

}


