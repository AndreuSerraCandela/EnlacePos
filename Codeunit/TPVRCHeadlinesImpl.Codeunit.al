codeunit 91101 "TPV RC Headlines Impl."
{
    procedure OnDrillDown(HeadlineType: Text)
    var
        TPVInvoicePage: Page "Sales List";
        SalesHeader: Record "Sales Header";
        PostedSalesInvoicesPage: Page "Posted Sales Invoices";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        case HeadlineType of
            'TodaySales':
                begin
                    SalesInvHeader.SetRange("Posting Date", WorkDate());
                    SalesInvHeader.SetFilter("TPV", '<>%1', '');
                    PostedSalesInvoicesPage.SetTableView(SalesInvHeader);
                    PostedSalesInvoicesPage.Run();
                end;
            'NoSales':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                    SalesHeader.SetRange("Posting Date", WorkDate());
                    SalesHeader.SetFilter("TPV", '<>%1', '');
                    TPVInvoicePage.SetTableView(SalesHeader);
                    TPVInvoicePage.RunModal();
                end;

        end;
    end;
}