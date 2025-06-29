/// <summary>
/// Page Turno (ID 90115).
/// </summary>
page 75215 "Turno"
{
    Caption = 'Turno';
    PageType = List;
    SourceTable = Turno;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTableView = where("No" = filter(<> 0));
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el ID del turno';
                    Editable = false;

                }
                field(Turno; Rec."Descripcion Turno")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código/nombre del turno';
                }
                field(HorarioInicio; Rec.HorarioInicio)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la hora de inicio del turno';
                }
                field(HorarioFin; Rec.HorarioFin)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica la hora de fin del turno';
                }
            }
        }
    }
}