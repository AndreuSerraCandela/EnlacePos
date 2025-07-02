pageextension 75204 ItemTemplateCardExt extends "Item Templ. Card"
{
    layout
    {
        addafter("VAT Prod. Posting Group")
        {
            field("VAT Bus. Posting Gr."; Rec."VAT Bus. Posting Gr. (Price)")
            {
                ApplicationArea = All;
            }
        }
    }
}