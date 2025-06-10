/// <summary>
/// Page AperturaDeCaja (ID 90110).
/// </summary>
page 91110 "AperturaDeCaja"
{
    Caption = 'Apertura De Caja';
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
                    ToolTip = 'Especifica el ID de la apertura de caja';
                    Editable = false;
                }
                field(Cajero; Rec."Usuario apertura")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código del cajero';
                }
                field(FechaDeApertura; Rec.Fecha)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la fecha de apertura de caja';
                }
                field(HoraDeApertura; Rec."Hora apertura")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la hora de apertura de caja';
                }
                field(ImporteDeApertura; Rec.ImporteDeApertura)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe inicial en la apertura de caja';
                }
                field(Estado; Rec.Estado)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el estado actual de la apertura de caja';
                }
                field(Caja; Rec."No. TPV")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código de la caja asignada';
                }
                field(Tienda; Rec."No. Tienda")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código de la tienda asignada';
                }
                field(Turno; Rec.Turno)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el turno asignado a esta apertura de caja';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AbrirCaja)
            {
                ApplicationArea = All;
                Caption = 'Abrir Caja';
                ToolTip = 'Abre la caja con el monto inicial especificado';
                Image = OpenJournal;

                trigger OnAction()
                begin
                    // Código para abrir la caja se implementará aquí
                end;
            }

            action(CerrarCaja)
            {
                ApplicationArea = All;
                Caption = 'Cerrar Caja';
                ToolTip = 'Cierra la caja actual';
                Image = ClosePeriod;

                trigger OnAction()
                begin
                    // Código para cerrar la caja se implementará aquí
                end;
            }
        }
    }
}