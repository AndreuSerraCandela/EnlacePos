/// <summary>
/// Page CierreDeCajaDetalle (ID 90112).
/// </summary>
page 91112 "CierreDeCajaDetalle"
{
    Caption = 'Detalle de Cierre De Caja';
    PageType = List;
    SourceTable = CierreDeCajaDetalle;
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(item; Rec.item)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID del detalle';
                    Editable = false;
                }
                field(idCierre; Rec.idCierre)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID del cierre relacionado';
                }
                field(idApertura; Rec.idApertura)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la apertura relacionada';
                }
                field(idFormaPago; Rec.idFormaPago)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código de la forma de pago';
                }
                field(DesFormaPago; Rec.DesFormaPago)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la descripción de la forma de pago';
                    Editable = false;
                }
                field(MontoPago; Rec.MontoPago)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el monto pagado con esta forma de pago';
                }
            }
        }
    }
}