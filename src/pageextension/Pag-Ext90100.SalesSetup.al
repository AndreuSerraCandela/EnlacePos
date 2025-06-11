/// <summary>
/// PageExtension SalesSetup (ID 90100) extends Record Sales  Receivables Setup.
/// </summary>
pageextension 75200 SalesSetup extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Customer Nos.")
        {
            field(CustomerTemplate; Rec.CustomerTemplate)
            {
                ApplicationArea = All;
            }
            field("Nums. Turno"; Rec."Nums. Turno")
            {
                ApplicationArea = All;
            }
            field("Nums. Caja"; Rec."Nums. Caja")
            {
                ApplicationArea = All;
            }
            field("Nums. Colegio"; Rec."Nums. Colegio")
            {
                ApplicationArea = All;
            }
            field("Nums. TPV"; Rec."Nums. TPV")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica la serie de números a utilizar para los TPVs';
            }
        }
    }
}
pageextension 75201 PurchSetup extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Vendor Nos.")
        {
            field(VendorTemplate; Rec.VendorTemplate)
            {
                ApplicationArea = All;
            }
        }
    }
}
pageextension 75202 InvSetup extends 461
{
    layout
    {
        addafter("Item Nos.")
        {
            field(ItemTemplate; Rec.ItemTemplate)
            {
                ApplicationArea = All;
            }
        }
    }
}