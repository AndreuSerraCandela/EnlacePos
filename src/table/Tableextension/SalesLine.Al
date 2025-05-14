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
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        field(50104; Turno; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Turno';
            TableRelation = Turno.No;
        }
        field(50105; TPV; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'TPV';
            TableRelation = TPV."No";
        }
    }
}
tableextension 91112 SalesInvoiceLineExtension extends "Sales Invoice header"
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
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        field(50104; Turno; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Turno';
            TableRelation = Turno.No;
        }
        field(50105; TPV; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'TPV';
            TableRelation = TPV."No";
        }
    }
}
tableextension 91113 SalesCrHdExtension extends "Sales Cr.Memo Header"
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
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        field(50104; Turno; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Turno';
            TableRelation = Turno.No;
        }
        field(50105; TPV; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'TPV';
            TableRelation = TPV."No";
        }
    }

}
