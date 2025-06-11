pageextension 75221 "Sales Discounts Ext" extends "Sales Line Discounts"
{
    layout
    {
        modify("Sales Type")
        {
            OptionCaptionML = ENU = 'Customer,Customer Disc. Group,All Customers,Campaign',
                              ESP = 'Cliente,Grupo dto. cliente,Todos clientes,Cupón';
        }
    }
}