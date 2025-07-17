pageextension 75216 Productos extends "Item List"
{
    layout
    {
        addlast(control1)
        {
            field("Source Counter"; Rec."Source Counter2")
            {
                Caption = 'Source Counter';
                Editable = false;
                ApplicationArea = All;
            }
            field("barcode"; ItemCrossReference(Rec."No."))
            {
                Caption = 'barcode';
                Editable = false;
                ApplicationArea = All;
            }
            field(PorIva; ReturnPorIva(Rec."VAT Prod. Posting Group")) { ApplicationArea = All; }
        }
    }

    local procedure ItemCrossReference(ItemNo: Code[20]): Text
    var
        ItemCrossReference: Record "Item Reference";
    begin
        ItemCrossReference.SetRange("Item No.", ItemNo);
        ItemCrossReference.SetRange("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
        if ItemCrossReference.FindFirst() then
            exit(ItemCrossReference."Reference No.");
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange(Blocked, false);
    end;

    local procedure ReturnPorIva(VatPostingGroup: Code[20]): Decimal
    var
        VatSetup: Record "VAT Posting Setup";
        GrupoNegocio: Code[20];
        Setup: Record "Inventory Setup";
        ItemTemplate: Record "Item Templ.";
    begin
        Setup.Get();
        Setup.TestField("ItemTemplate");
        ItemTemplate.Get(Setup."ItemTemplate");
        ItemTemplate.TestField("VAT Bus. Posting Gr. (Price)");
        GrupoNegocio := ItemTemplate."VAT Bus. Posting Gr. (Price)";
        if VatSetup.Get(GrupoNegocio, VatPostingGroup) then
            exit(VatSetup."VAT %");
    end;
}
pageextension 75219 Kits extends "Assembly BOM"
{
    layout
    {
        addlast(control1)
        {
            field("Source Counter"; Rec."Source Counter2")
            {
                Caption = 'Source Counter';
                Editable = false;
                ApplicationArea = All;
            }
        }
    }
}