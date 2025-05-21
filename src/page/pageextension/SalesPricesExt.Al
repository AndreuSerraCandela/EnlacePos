pageextension 91120 "Sales Prices Ext" extends "Sales Prices"
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