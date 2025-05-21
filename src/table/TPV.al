/// <summary>
/// Table TPV (ID 91120).
/// </summary>
table 91120 TPV
{
    Caption = 'TPV';
    DataClassification = CustomerContent;
    LookupPageId = "TPV List";

    fields
    {
        field(1; "No"; Code[20])
        {
            Caption = 'No';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(2; "Nombre"; Text[100])
        {
            Caption = 'Nombre';
            DataClassification = CustomerContent;
        }
        field(3; "Dirección"; Text[100])
        {
            Caption = 'Dirección';
            DataClassification = CustomerContent;
        }
        field(4; "Dirección 2"; Text[50])
        {
            Caption = 'Dirección 2';
            DataClassification = CustomerContent;
        }
        field(5; "Ciudad"; Text[30])
        {
            Caption = 'Ciudad';
            DataClassification = CustomerContent;
        }
        field(6; "Código Postal"; Code[20])
        {
            Caption = 'Código Postal';
            DataClassification = CustomerContent;
        }
        field(7; "Provincia"; Text[30])
        {
            Caption = 'Provincia';
            DataClassification = CustomerContent;
        }
        field(8; "País"; Code[10])
        {
            Caption = 'País';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(9; "Teléfono"; Text[30])
        {
            Caption = 'Teléfono';
            DataClassification = CustomerContent;
        }
        field(10; "Móvil"; Text[30])
        {
            Caption = 'Móvil';
            DataClassification = CustomerContent;
        }
        field(11; "Email"; Text[80])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(12; "Sitio Web"; Text[80])
        {
            Caption = 'Sitio Web';
            DataClassification = CustomerContent;
        }
        field(13; "NIF/CIF"; Text[20])
        {
            Caption = 'NIF/CIF';
            DataClassification = CustomerContent;
        }
        field(14; "Contacto"; Text[50])
        {
            Caption = 'Contacto';
            DataClassification = CustomerContent;
        }
        field(15; "Notas"; Text[250])
        {
            Caption = 'Notas';
            DataClassification = CustomerContent;
        }
        field(16; "Fecha Alta"; Date)
        {
            Caption = 'Fecha Alta';
            DataClassification = CustomerContent;
        }
        field(17; "Location Code"; Code[20])
        {
            Caption = 'Código Localización';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(18; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        //Numerador borrador facturas, numerador borrador abonos , numerador facturas registradas, numerador abonos registrados
        field(19; "Numerador facturas"; Code[20])
        {
            Caption = 'Numerador facturas';
            DataClassification = CustomerContent;
        }
        field(20; "Numerador abonos"; Code[20])
        {
            Caption = 'Numerador abonos';
            DataClassification = CustomerContent;
        }
        field(21; "Numerador facturas registradas"; Code[20])
        {
            Caption = 'Numerador facturas registradas';
            DataClassification = CustomerContent;
        }
        field(22; "Numerador abonos registrados"; Code[20])
        {
            Caption = 'Numerador abonos registrados';
            DataClassification = CustomerContent;
        }
        field(24; "% Descuento General"; Decimal)
        {
            Caption = '% Descuento General';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
        TPV: Record TPV;
    begin
        if "No" = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Nums. TPV");
            "No. Series" := SalesSetup."Nums. TPV";
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No" := NoSeries.GetNextNo("No. Series");
            TPV.ReadIsolation(IsolationLevel::ReadUncommitted);
            TPV.SetLoadFields("No");
            while TPV.Get("No") do
                "No" := NoSeries.GetNextNo("No. Series");
        end;
        if "Fecha Alta" = 0D then
            "Fecha Alta" := Today;
    end;

    procedure AssistEdit(OldTPV: Record TPV): Boolean
    var
        TPV: Record TPV;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        TPV := Rec;
        SalesSetup.Get();
        SalesSetup.TestField("Nums. TPV");
        if NoSeries.LookupRelatedNoSeries(SalesSetup."Nums. TPV", OldTPV."No. Series", TPV."No. Series") then begin
            TPV."No" := NoSeries.GetNextNo(TPV."No. Series");
            Rec := TPV;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        TPV: Record TPV;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if "No" <> xRec."No" then
            if not TPV.Get(Rec."No") then begin
                SalesSetup.Get();
                NoSeries.TestManual(SalesSetup."Nums. TPV");
                "No. Series" := '';
            end;
    end;
}