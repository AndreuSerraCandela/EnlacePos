/// <summary>
/// Table Cajas (ID 90105).
/// </summary>
table 91105 Cajas
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Code[20])
        {
            Caption = 'ID de Caja';
            trigger OnValidate()
            begin
                TestNoSeries();
            end;

        }
        field(2; Nombre; Text[100])
        {
            Caption = 'Nombre De Caja';
        }
        field(3; TPV; Code[20])
        {
            Caption = 'TPV';
            TableRelation = TPV."No";
        }
        field(4; "No. Series"; Code[20])
        {
            Caption = 'No. Serie';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; No)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        TestNoSeries();
    end;

    procedure AssistEdit(OldCaja: Record Cajas): Boolean
    var
        Caja: Record Cajas;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        Caja := Rec;
        SalesSetup.Get();
        SalesSetup.TestField("Nums. Caja");
        if NoSeries.LookupRelatedNoSeries(SalesSetup."Nums. Caja", OldCaja."No. Series", Caja."No. Series") then begin
            Caja."No" := NoSeries.GetNextNo(Caja."No. Series");
            Rec := Caja;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        Caja: Record Cajas;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if "No" <> xRec."No" then
            if not Caja.Get(Rec."No") then begin
                SalesSetup.Get();
                NoSeries.TestManual(SalesSetup."Nums. Caja");
                "No. Series" := '';
            end;
    end;
}