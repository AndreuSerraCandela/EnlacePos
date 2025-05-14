/// <summary>
/// Page Turno (ID 90115).
/// </summary>
page 91115 "Turno"
{
    Caption = 'Turno';
    PageType = List;
    SourceTable = Turno;
    UsageCategory = Lists;
    ApplicationArea = All;

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
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
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