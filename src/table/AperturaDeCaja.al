/// <summary>
/// Table AperturaDeCaja (ID 90102).
/// </summary>
table 91102 AperturaDeCaja
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Integer)
        {
            Caption = 'ID';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Cajero; Code[20])
        {
            Caption = 'Cajero';
            TableRelation = Employee;
        }
        field(3; FechaDeApertura; Date)
        {
            Caption = 'Fecha De Apertura';
        }
        field(4; ImporteDeApertura; Decimal)
        {
            Caption = 'Importe De Apertura';
            DecimalPlaces = 0 : 2;
        }
        field(5; Estado; Option)
        {
            Caption = 'Estado';
            OptionMembers = Cerrado,Abierto,"Turno Generado";
            OptionCaption = 'Cerrado,Abierto,Turno Generado';
        }
        field(6; Caja; Code[20])
        {
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        field(7; Turno; Code[20])
        {
            Caption = 'Turno';
            TableRelation = Turno.No;
        }
        field(8; HoraDeApertura; Time)
        {
            Caption = 'Hora De Apertura';
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