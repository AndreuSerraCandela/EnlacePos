tableextension 75207 ControlTpvExt extends "Control de TPV"
{
    fields
    {
        field(91106; ImporteDeApertura; Decimal)
        {
            Caption = 'Importe de apertura';
        }
        field(91107; ImporteDeCierre; Decimal)
        {
            Caption = 'Importe de cierre';
        }
        field(91108; Turno; Integer)
        {
            Caption = 'Turno';
        }
        field(91109; ImporteDeCierreBS; Decimal)
        {
            Caption = 'Importe de cierre BS';
        }
        field(91110; ImporteDeCierreUS; Decimal)
        {
            Caption = 'Importe de cierre US';
        }
        field(91111; ImporteDeCierreEUR; Decimal)
        {
            Caption = 'Importe de cierre EUR';
        }
        field(91112; ArqueoBS; Decimal)
        {
            Caption = 'Arqueo BS';
        }
        field(91113; ArqueoUS; Decimal)
        {
            Caption = 'Arqueo US';
        }
        field(91114; ArqueoEUR; Decimal)
        {
            Caption = 'Arqueo EUR';
        }
        field(91115; FechaDeCierre; DateTime)
        {
            Caption = 'Fecha de cierre';
        }
        modify("Usuario apertura")
        {
            TableRelation = Cajeros."Id";
        }
        modify("Usuario cierre")
        {
            TableRelation = Cajeros."Id";
        }
        modify("Usuario reapertura")
        {
            TableRelation = Cajeros."Id";
        }
    }
}