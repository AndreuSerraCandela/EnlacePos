tableextension 75205 TiendaExt extends Tiendas
{
    fields
    {
        field(90101; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(90102; "Fecha Alta"; Date)
        {
            Caption = 'Fecha Alta';
        }
        field(90103; "Contacto"; Text[100])
        {
            Caption = 'Contacto';
        }
        field(90104; "Notas"; Text[100])
        {
            Caption = 'Notas';
        }
        field(90105; "% Descuento General"; Decimal)
        {
            Caption = '% Descuento General';
        }
        field(90106; "Margen Cierre"; Decimal)
        {
            Caption = 'Margen Cierre';
        }

    }
    trigger OnInsert()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
        TPV: Record Tiendas;
    begin
        if "Cod. Tienda" = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Nums. TPV");
            "No. Series" := SalesSetup."Nums. TPV";
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Cod. Tienda" := NoSeries.GetNextNo("No. Series");
            TPV.ReadIsolation(IsolationLevel::ReadUncommitted);
            TPV.SetLoadFields("Cod. Tienda");
            while TPV.Get("Cod. Tienda") do
                "Cod. Tienda" := NoSeries.GetNextNo("No. Series");
        end;
        if "Fecha Alta" = 0D then
            "Fecha Alta" := Today;
    end;

    procedure AssistEdit(OldTPV: Record Tiendas): Boolean
    var
        TPV: Record Tiendas;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        TPV := Rec;
        SalesSetup.Get();
        SalesSetup.TestField("Nums. TPV");
        if NoSeries.LookupRelatedNoSeries(SalesSetup."Nums. TPV", OldTPV."No. Series", TPV."No. Series") then begin
            TPV."Cod. Tienda" := NoSeries.GetNextNo(TPV."No. Series");
            Rec := TPV;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        TPV: Record Tiendas;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if "Cod. Tienda" <> xRec."Cod. Tienda" then
            if not TPV.Get(Rec."Cod. Tienda") then begin
                SalesSetup.Get();
                NoSeries.TestManual(SalesSetup."Nums. TPV");
                "No. Series" := '';
            end;
    end;
}