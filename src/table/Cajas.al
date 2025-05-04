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

        }
        field(2; Nombre; Text[100])
        {
            Caption = 'Nombre De Caja';
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