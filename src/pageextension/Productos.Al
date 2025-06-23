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
        }
    }

}
pageextension 75219 Kits extends "Assembly BOM"
{
    layout
    {
        addlast(control1)
        {
            field("Source Counter"; Rec."Source Counter")
            {
                Caption = 'Source Counter';
                Editable = false;
                ApplicationArea = All;
            }
        }
    }
}