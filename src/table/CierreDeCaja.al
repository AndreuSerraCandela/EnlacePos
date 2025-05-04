/// <summary>
/// Table CierreDeCaja (ID 90103).
/// </summary>
table 91103 CierreDeCaja
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
            TableRelation = "Salesperson/Purchaser";
        }
        field(3; ImporteDeApertura; Decimal)
        {
            Caption = 'Importe De Apertura';
            DecimalPlaces = 0 : 2;
        }
        field(4; FechaDeApertura; Date)
        {
            Caption = 'Fecha De Apertura';
        }
        field(5; ImporteDeCierreBS; Decimal)
        {
            Caption = 'Importe De Cierre BS';
            DecimalPlaces = 0 : 2;
        }
        field(6; ImporteDeCierreUS; Decimal)
        {
            Caption = 'Importe De Cierre US';
            DecimalPlaces = 0 : 2;
        }
        field(7; ImporteDeCierreEUR; Decimal)
        {
            Caption = 'Importe De Cierre EUR';
            DecimalPlaces = 0 : 2;
        }
        field(8; ArqueoBS; Decimal)
        {
            Caption = 'Arqueo BS';
            DecimalPlaces = 0 : 2;
        }
        field(9; ArqueoUS; Decimal)
        {
            Caption = 'Arqueo US';
            DecimalPlaces = 0 : 2;
        }
        field(10; ArqueoEUR; Decimal)
        {
            Caption = 'Arqueo EUR';
            DecimalPlaces = 0 : 2;
        }
        field(11; FechaDeCierre; DateTime)
        {
            Caption = 'Fecha De Cierre';
        }
        field(12; Estado; Option)
        {
            Caption = 'Estado';
            OptionMembers = Abierto,Cerrado;
            OptionCaption = 'Abierto,Cerrado';
        }
        field(13; idApertura; Integer)
        {
            Caption = 'ID Apertura';
            TableRelation = AperturaDeCaja.No;
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