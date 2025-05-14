pageextension 91112 CustomerCardExt extends "Customer Card"
{
    layout
    {
        addafter("Payment Terms Code")
        {
            field("POS Discount"; Rec."POS Discount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the discount percentage to be applied at point of sale (POS)';
            }
        }
    }
}