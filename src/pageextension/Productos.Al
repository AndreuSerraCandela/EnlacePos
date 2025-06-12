pageextension 75216 Productos extends "Item List"
{
    trigger OnOpenPage()
    begin
        Rec.SetFilter("Unit Price", '<>%1', 0);
    end;
}
// pageextension 75217 Kits extends "Assembly BOM"
// {

// }