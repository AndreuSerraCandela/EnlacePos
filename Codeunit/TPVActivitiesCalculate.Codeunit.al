codeunit 91104 "TPV Activities Calculate"
{
    TableNo = "TPV Cue";

    trigger OnRun()
    begin
        CalcTPVStatistics(Rec);
    end;

    procedure CalcTPVStatistics(var TPVCue: Record "TPV Cue")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TotalAmount: Decimal;
        TotalTransactions: Integer;
    begin
        // Calculate average transaction value
        SalesInvHeader.SetRange("Posting Date", WorkDate());
        SalesInvHeader.SetFilter("TPV", '<>%1', '');
        TotalTransactions := SalesInvHeader.Count;

        if TotalTransactions > 0 then begin
            if SalesInvHeader.FindSet() then
                repeat
                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.CalcSums(Amount);
                    TotalAmount += SalesInvLine.Amount;
                until SalesInvHeader.Next() = 0;

            TPVCue."Average Transaction Value" := TotalAmount / TotalTransactions;
        end else
            TPVCue."Average Transaction Value" := 0;

        TPVCue."TPV Sales Updated On" := CurrentDateTime;
        TPVCue.Modify();
    end;

    procedure EvaluateResults(Results: Dictionary of [Text, Text]; var TPVCue: Record "TPV Cue")
    var
        AverageTransactionValue: Decimal;
        TPVSalesUpdatedOn: DateTime;
    begin
        if Results.ContainsKey('AverageTransactionValue') then
            Evaluate(AverageTransactionValue, Results.Get('AverageTransactionValue'));

        if Results.ContainsKey('TPVSalesUpdatedOn') then
            Evaluate(TPVSalesUpdatedOn, Results.Get('TPVSalesUpdatedOn'));

        TPVCue."Average Transaction Value" := AverageTransactionValue;
        TPVCue."TPV Sales Updated On" := TPVSalesUpdatedOn;
    end;

    procedure EncodeResults(TPVCue: Record "TPV Cue"): Dictionary of [Text, Text]
    var
        Results: Dictionary of [Text, Text];
    begin
        Results.Add('AverageTransactionValue', Format(TPVCue."Average Transaction Value"));
        Results.Add('TPVSalesUpdatedOn', Format(TPVCue."TPV Sales Updated On"));
        exit(Results);
    end;
}