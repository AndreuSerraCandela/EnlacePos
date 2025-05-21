table 91100 "TPV Cue"
{
    Caption = 'TPV Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(3; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(4; "Date Filter2"; Date)
        {
            Caption = 'Date Filter2';
            FieldClass = FlowFilter;
        }
        field(10; "TPV Invoices - Today"; Integer)
        {
            CalcFormula = count("Sales Invoice Header" where("Posting Date" = field("Date Filter"),
                                                             "TPV" = filter(<> '')
                                                             ));
            Caption = 'TPV Invoices - Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "TPV Credit Memos - Today"; Integer)
        {
            CalcFormula = count("Sales Cr.Memo Header" where("Posting Date" = field("Date Filter"),
                                                            "TPV" = filter(<> '')
                                                            ));
            Caption = 'TPV Credit Memos - Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "TPV Invoices - Last Week"; Integer)
        {
            CalcFormula = count("Sales Invoice Header" where("Posting Date" = field("Date Filter"),
                                                             "TPV" = filter(<> '')
                                                             ));
            Caption = 'TPV Invoices - Last Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "TPV Credit Memos - Last Week"; Integer)
        {
            CalcFormula = count("Sales Cr.Memo Header" where("Posting Date" = field("Date Filter"),
                                                            "TPV" = filter(<> '')
                                                            ));
            Caption = 'TPV Credit Memos - Last Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Pending Coupons"; Integer)
        {
            Caption = 'Pending Coupons';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count(Campaign where("Importe Total Descontado" = filter(0)));
            trigger OnLookup()
            var
                Campaign: Record Campaign;
            begin
                Campaign.SetRange("Importe Total Descontado", 0);
                Page.Run(Page::"Campaign List", Campaign);
            end;
        }
        field(15; "Used Coupons"; Integer)
        {
            Caption = 'Used Coupons';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count(Campaign where("Importe Total Descontado" = filter(> 0)));
            trigger OnLookup()
            var
                Campaign: Record Campaign;
            begin
                Campaign.SetFilter("Importe Total Descontado", '>%1', 0);
                Page.Run(Page::"Campaign List", Campaign);
            end;
        }

        // field(14; "TPV Sales Amount - Today"; Decimal)
        // {
        //     CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date" = field("Date Filter"),
        //                                                        "TPV" = filter(<>'')
        //                                                        ));
        //     Caption = 'TPV Sales Amount - Today';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(15; "TPV Returns Amount - Today"; Decimal)
        // {
        //     CalcFormula = sum("Sales Cr.Memo Line".Amount where("Posting Date" = field("Date Filter"),
        //                                                       ));
        //     Caption = 'TPV Returns Amount - Today';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        field(16; "Pending Transactions"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = filter(Invoice),
                                                             "Posting Date" = field("Date Filter"),
                                                             "TPV" = filter(<> '')
                                                             ));
            Caption = 'Pending Transactions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Pending Creit Memo"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = filter("Credit Memo"),
                                                             "Posting Date" = field("Date Filter"),
                                                             "TPV" = filter(<> '')
                                                             ));
            Caption = 'Pending Credit Memo';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "TPV Sales Updated On"; DateTime)
        {
            Caption = 'TPV Sales Updated On';
            Editable = false;
        }
        field(21; "Average Transaction Value"; Decimal)
        {
            Caption = 'Average Transaction Value';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(22; "Global Dimension 1 Filter"; Code[20])
        {

            Caption = 'Global Dimension 1 Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure SetRespCenterFilter()
    var
        UserSetup: Record "User Setup";
        RespCenter: Record "Responsibility Center";
    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Sales Resp. Ctr. Filter" <> '' then
                if RespCenter.Get(UserSetup."Sales Resp. Ctr. Filter") then
                    if RespCenter."Global Dimension 1 Code" <> '' then
                        SetFilter("Global Dimension 1 Filter", RespCenter."Global Dimension 1 Code");
        end;
    end;

    procedure DrillDownTodayInvoices()
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        SalesInvHeader.SetRange("Posting Date", Today());
        SalesInvHeader.SetFilter("TPV", '<>%1', '');
        Page.Run(Page::"Posted Sales Invoices", SalesInvHeader);
    end;

    procedure DrillDownTodayCreditMemos()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.SetRange("Posting Date", Today());
        SalesCrMemoHeader.SetFilter("TPV", '<>%1', '');
        Page.Run(Page::"Posted Sales Credit Memos", SalesCrMemoHeader);
    end;

    procedure DrillDownPendingTransactions()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Posting Date", Today());
        SalesHeader.SetFilter("TPV", '<>%1', '');
        Page.Run(Page::"Sales Invoice List", SalesHeader);
    end;

    procedure DrillDownPendingCreditMemos()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Posting Date", Today());
        SalesHeader.SetFilter("TPV", '<>%1', '');
        Page.Run(Page::"Sales Credit Memos", SalesHeader);
    end;

    procedure CalcTPVStatistics()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TotalAmount: Decimal;
        TotalTransactions: Integer;
    begin
        // Calculate average transaction value
        SalesInvHeader.SetRange("Posting Date", Today());
        SalesInvHeader.SetFilter("TPV", '<>%1', '');
        TotalTransactions := SalesInvHeader.Count;

        if TotalTransactions > 0 then begin
            if SalesInvHeader.FindSet() then
                repeat
                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.CalcSums(Amount);
                    TotalAmount += SalesInvLine.Amount;
                until SalesInvHeader.Next() = 0;

            Rec."Average Transaction Value" := TotalAmount / TotalTransactions;
        end else
            Rec."Average Transaction Value" := 0;

        Rec."TPV Sales Updated On" := CurrentDateTime;
        Rec.Modify();
    end;
}