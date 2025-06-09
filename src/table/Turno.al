/// <summary>
/// Table Turno (ID 90107).
/// </summary>
table 91107 Turno
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Integer)
        {
            Caption = 'ID';
            Editable = false;
            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(2; "Descripcion Turno"; Text[50])
        {
            Caption = 'Turno';
        }
        field(3; HorarioInicio; Time)
        {
            Caption = 'Horario Inicio';
        }
        field(4; HorarioFin; Time)
        {
            Caption = 'Horario Fin';
        }
        field(5; "No. Series"; Code[20])
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

    procedure AssistEdit(OldTurno: Record Turno): Boolean
    var
        Turno: Record Turno;
        SalesSetup: Record "Sales & Receivables Setup";
        Self: Record Turno;
    begin
        Turno := Rec;
        //SalesSetup.Get();
        //SalesSetup.TestField("Nums. Turno");
        if Self.FindLast() then
            Turno."No" := Self."No" + 1
        else
            Turno."No" := 1;
        Rec := Turno;
        exit(true);
    end;

    local procedure TestNoSeries()
    var
        Turno: Record Turno;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if "No" <> xRec."No" then
            if not Turno.Get(Rec."No") then begin
                SalesSetup.Get();
                NoSeries.TestManual(SalesSetup."Nums. Turno");
                "No. Series" := '';
            end;
    end;

}