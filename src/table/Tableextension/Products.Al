tableextension 75216 Products extends Item
{
    fields
    {
        field(75216; "Source Counter2"; Integer)
        {
            Caption = 'Source Counter';
        }
    }
    keys
    {
        key(PS; "Source Counter2")
        {

        }
    }

    trigger OnAfterInsert()
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("Source Counter2");
        if Item.FindLast() then
            Rec."Source Counter2" := Item."Source Counter2" + 1
        else
            Rec."Source Counter2" := 1;
    end;

    trigger OnAfterModify()
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("Source Counter2");
        if Item.FindLast() then
            Rec."Source Counter2" := Item."Source Counter2" + 1
        else
            Rec."Source Counter2" := 1;
        Rec.Modify();
    end;

    trigger OnAfterDelete()
    var
        RegistroBorrado: Record "Registro Borrado";
    begin
        RegistroBorrado.RecordId := Rec.RecordId;
        RegistroBorrado."Table No." := Database::Item;
        RegistroBorrado."Table Caption" := 'Item';
        RegistroBorrado.FechaHora := CurrentDateTime;
        RegistroBorrado.Insert();
    end;
}
tableextension 75222 "Kits" extends "BOM Component"
{
    fields
    {
        field(50101; "Source Counter"; Integer)
        {
            Caption = 'Source Counter';
        }
    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
    }

}