tableextension 91100 SalesSetup extends "Sales & Receivables Setup"
{
    fields
    {
        field(90100; CustomerTemplate; Code[20])
        {
            Caption = 'CustomerTemplate';
            DataClassification = ToBeClassified;
            TableRelation = "Customer Templ.".Code;
        }
        field(90102; "Nums. Turno"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(90103; "Nums. Caja"; Code[20])
        {
            Caption = 'Números de Caja';
            TableRelation = "No. Series";
        }
        field(90104; "Nums. Colegio"; Code[20])
        {
            Caption = 'Números de Colegio';
            TableRelation = "No. Series";
        }
    }
}
tableextension 91101 PurchSetup extends 312
{
    fields
    {
        field(90100; VendorTemplate; Code[20])
        {
            Caption = 'VendorTemplate';
            DataClassification = ToBeClassified;
            TableRelation = "Vendor Templ.".Code;
        }
    }
}
tableextension 91103 ITemSetup extends 313
{
    fields
    {
        field(90100; ItemTemplate; Code[20])
        {
            Caption = 'ItemTemplate';
            DataClassification = ToBeClassified;
            TableRelation = "Item Templ.".Code;
        }
    }
}