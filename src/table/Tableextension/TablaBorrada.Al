table 75209 "Registro Borrado"
{
    fields
    {
        field(1; RecordId; RecordId)
        {
            Caption = 'RecordId';
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(3; "Table Caption"; Text[250])
        {
            Caption = 'Table Caption';
        }
        field(4; FechaHora; DateTime)
        {
            Caption = 'FechaHora';
        }

    }
    keys
    {
        key(PK; RecordId)
        {
            Clustered = true;
        }
    }

}