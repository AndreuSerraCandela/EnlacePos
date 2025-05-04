/// <summary>
/// Table Turno (ID 90107).
/// </summary>
table 91107 Turno
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Code[20])
        {
            Caption = 'ID';
            Editable = false;
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