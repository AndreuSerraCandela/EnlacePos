/// <summary>
/// Table Cajas (ID 90105).
/// </summary>
tableextension 75206 CajasExt extends "Configuracion TPV"
{

    fields
    {
        field(50004; "No. Series"; Code[20])
        {
            Caption = 'No. Serie';
            TableRelation = "No. Series";
        }
        field(50005; "No. Series NFC Facturas"; Code[20])
        {
            Caption = 'No. Serie NFC Facturas';
            TableRelation = "No. Series" WHERE("Tipo Documento" = CONST(Factura));
        }
        field(50006; "No. Series NFC Remision"; Code[20])
        {
            Caption = 'No. Serie NFC Remision';
            TableRelation = "No. Series" WHERE("Tipo Documento" = CONST(Remision));
        }
        field(50007; "No. Serie NCF Abonos"; Code[20])
        {
            Caption = 'No. Serie NCF Abonos';
            DataClassification = ToBeClassified;
            Description = 'DSLoc1.01';
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