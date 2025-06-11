page 75257 "Headline RC TPV"
{
    Caption = 'Titular';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mensaje de bienvenida';
                    ShowCaption = false;
                    ToolTip = 'Muestra un mensaje de saludo personalizado';
                    Editable = false;
                }
            }
            group(Control2)
            {
                ShowCaption = false;
                Visible = TPVHeadlineVisible;
                field(TPVHeadlineText; TPVHeadlineText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Titular TPV';
                    ToolTip = 'Muestra información resumida de las ventas TPV del día';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        TPVRCHeadlinesImpl.OnDrillDown(TPVHeadlineType);
                    end;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                Visible = not (UserGreetingVisible and TPVHeadlineVisible);
                field(NoHeadlinesText; NoHeadlinesText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sin Titulares';
                    ToolTip = 'No hay titulares para mostrar en este momento';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not RCHeadlinesPageCommon.IsUserGreetingVisible() then
            UserGreetingVisible := false;

        GetTPVHeadline();
    end;

    local procedure GetTPVHeadline()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TotalToday: Decimal;
        TodayTransactions: Integer;
    begin
        // Create a simple headline with total sales for the day
        SalesInvHeader.SetRange("Posting Date", WorkDate());
        //SalesInvHeader.SetFilter("TPV", '<>%1', '');
        TodayTransactions := SalesInvHeader.Count;

        if TodayTransactions > 0 then begin
            TotalToday := 0;
            If SalesInvHeader.FindSet() then
                repeat
                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.CalcSums(Amount);
                    TotalToday += SalesInvLine.Amount;
                until SalesInvHeader.Next() = 0;
            TPVHeadlineText := StrSubstNo('Ventas TPV de hoy: %1 € en %2 transacción(es)', Format(TotalToday, 0, '<Precision,2:><Standard Format,0>'), TodayTransactions);
            TPVHeadlineType := 'TodaySales';
            TPVHeadlineVisible := true;
        end else begin
            TPVHeadlineText := 'No hay ventas TPV registradas hoy todavía. Cree una nueva factura TPV.';
            TPVHeadlineType := 'NoSales';
            TPVHeadlineVisible := true;
        end;
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        TPVRCHeadlinesImpl: Codeunit Importaciones;
        TPVHeadlineText: Text;
        TPVHeadlineType: Text;
        NoHeadlinesText: Label 'No hay titulares para mostrar en este momento.';
        UserGreetingVisible: Boolean;
        TPVHeadlineVisible: Boolean;
}