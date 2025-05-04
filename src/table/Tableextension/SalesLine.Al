

tableextension 91109 SalesHeaderExtension extends "Sales Header"
{
    fields
    {

        field(50101; "Importe total"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Colegio; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Colegios;
        }
    }
}