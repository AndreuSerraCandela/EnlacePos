enum 75216 "Tipo Detalle"
{
    Extensible = true;
    value(0; TPV)
    {
        Caption = 'TPV';
    }
    value(1; Cliente)
    {
        Caption = 'Cliente';
    }
    value(2; GrupoCliente)
    {
        Caption = 'Grupo Cliente';
    }
    value(3; Colegio)
    {
        Caption = 'Colegio';
    }
}
enumextension 75217 salesPricetypeext extends "Sales Price Type"
{
    value(5; Colegio)
    {
        Caption = 'Colegio';
    }
}
enum 75217 TipoPago
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Efectivo")
    {
        Caption = 'Efectivo';
    }
    value(2; "Tarjeta")
    {
        Caption = 'Tarjeta';
    }
    value(3; "Cheque")
    {
        Caption = 'Cheque';
    }
    value(4; "Transferencia")
    {
        Caption = 'Transferencia';
    }

}
