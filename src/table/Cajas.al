/// <summary>
/// Table Cajas (ID 90105).
/// </summary>
tableextension 91106 CajasExt extends "Configuracion TPV"
{

    fields
    {
        field(4; "No. Series"; Code[20])
        {
            Caption = 'No. Serie';
            TableRelation = "No. Series";
        }
    }


    trigger OnInsert()
    begin
        TestNoSeries();
    end;

    procedure AssistEdit(OldCaja: Record "Configuracion TPV"): Boolean
    var
        Caja: Record "Configuracion TPV";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        Caja := Rec;
        SalesSetup.Get();
        SalesSetup.TestField("Nums. Caja");
        if NoSeries.LookupRelatedNoSeries(SalesSetup."Nums. Caja", OldCaja."No. Series", Caja."No. Series") then begin
            Caja."Id TPV" := NoSeries.GetNextNo(Caja."No. Series");
            Rec := Caja;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        Caja: Record "Configuracion TPV";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if "Id TPV" <> xRec."Id TPV" then
            if not Caja.Get(Rec."Tienda", Rec."Id TPV") then begin
                SalesSetup.Get();
                NoSeries.TestManual(SalesSetup."Nums. Caja");
                "No. Series" := '';
            end;
    end;
}