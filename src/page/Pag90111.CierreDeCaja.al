/// <summary>
/// Page CierreDeCaja (ID 90111).
/// </summary>
page 75211 "CierreDeCaja"
{
    Caption = 'Cierre De Caja';
    PageType = List;
    SourceTable = "Control de TPV";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."Id Replicacion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID del cierre de caja';
                    Editable = false;
                }
                field(Cajero; Rec."Usuario cierre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código del cajero';
                }
                field(ImporteDeApertura; Rec.ImporteDeApertura)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe inicial en la apertura de caja';
                }
                field(FechaDeApertura; Rec.Fecha)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha de apertura de caja';
                }
                field(ImporteDeCierreBS; Rec.ImporteDeCierreBS)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de cierre en Bolívares';
                }
                field(ImporteDeCierreUS; Rec.ImporteDeCierreUS)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de cierre en Dólares';
                }
                field(ImporteDeCierreEUR; Rec.ImporteDeCierreEUR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de cierre en Euros';
                }
                field(ArqueoBS; Rec.ArqueoBS)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el arqueo en Bolívares';
                }
                field(ArqueoUS; Rec.ArqueoUS)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el arqueo en Dólares';
                }
                field(ArqueoEUR; Rec.ArqueoEUR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el arqueo en Euros';
                }
                field(FechaDeCierre; Rec.FechaDeCierre)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha y hora de cierre';
                }
                field(Estado; Rec.Estado)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el estado actual del cierre de caja';
                }
                field(idApertura; Rec."Id Replicacion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID de la apertura relacionada';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(VerDetalle)
            {
                ApplicationArea = All;
                Caption = 'Ver Detalle';
                ToolTip = 'Muestra el detalle del cierre de caja';
                Image = ViewDetails;

                trigger OnAction()

                var
                    CierreDetalle: Record CierreDeCajaDetalle;
                    CierreDetallePage: Page CierreDeCajaDetalle;
                begin
                    CierreDetalle.SetRange(idCierre, Rec."Id Replicacion");
                    CierreDetallePage.SetTableView(CierreDetalle);
                    CierreDetallePage.Run();
                end;

            }
        }
    }
}