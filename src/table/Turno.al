/// <summary>
/// Table Turno (ID 90107).
/// </summary>
table 75207 Turno
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Integer)
        {
            Caption = 'ID';
            Editable = false;
            AutoIncrement = true;
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

    }

    keys
    {
        key(PK; No)
        {
            Clustered = true;
        }

    }






}