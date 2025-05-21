pageextension 91117 "Campaign List Ext" extends "Campaign List"
{
    CaptionML = ENU = 'Coupons',
                ESP = 'Cupones';
    layout
    {
        modify("Salesperson Code")
        {
            Visible = false;
        }
        modify("Status Code")
        {
            Visible = false;
        }
    }
    actions
    {
        modify("C&ampaign")
        {
            Visible = false;
        }

        addfirst(navigation)
        {
            group("C&upón")
            {
                Caption = 'C&upón';
                Image = Campaign;
                action("A&sientos")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'A&sientos';
                    Image = Entries;
                    RunObject = Page "Campaign Entries";
                    RunPageLink = "Campaign No." = field("No.");
                    RunPageView = sorting("Campaign No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'Ver todos los asientos vinculados al cupón. En esta ventana, no puede crear manualmente nuevos asientos de cupón.';
                }
                action("Co&mentarios")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Co&mentarios';
                    Image = ViewComments;
                    RunObject = Page "Rlshp. Mgt. Comment Sheet";
                    RunPageLink = "Table Name" = const(Campaign),
                                  "No." = field("No."),
                                  "Sub No." = const(0);
                    ToolTip = 'Ver o agregar comentarios para el registro.';
                }
                action(Estadísticas)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Estadísticas';
                    Image = Statistics;
                    RunObject = Page "Campaign Statistics";
                    RunPageLink = "No." = field("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'Ver cifras clave relacionadas con su cupón.';
                }
                group(Dimensiones)
                {
                    Caption = 'Dimensiones';
                    Image = Dimensions;
                    action("Dimensiones-Individual")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensiones-Individual';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = const(5071),
                                      "No." = field("No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'Ver o editar el conjunto individual de dimensiones configuradas para el registro seleccionado.';
                    }
                    action("Dimensiones-&Múltiples")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensiones-&Múltiples';
                        Image = DimensionSets;
                        ToolTip = 'Ver o editar dimensiones para un grupo de registros. Puede asignar códigos de dimensión a transacciones para distribuir costos y analizar información histórica.';

                        trigger OnAction()
                        var
                            Campaign: Record Campaign;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Campaign);
                            DefaultDimMultiple.SetMultiRecord(Campaign, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
            }
        }
        modify("Campaign Details")
        {
            CaptionML = ENU = 'Coupon Details',
                        ESP = 'Detalles Cupón';
        }
        modify(Category_Category4)
        {
            Visible = false;
        }
        addafter(Category_Process)
        {
            group(Category_Campaign)
            {
                Caption = 'Cupones', Comment = 'Generated from the PromotedActionCategories property index 3.';

                group(Category_Dimensiones)
                {
                    Caption = 'Dimensiones';
                    ShowAs = SplitButton;

                    actionref("Dimensiones-&Múltiples_Promoted"; "Dimensiones-&Múltiples")
                    {
                    }
                    actionref("Dimensiones-Individual_Promoted"; "Dimensiones-Individual")
                    {
                    }
                }
                actionref(Estadísticas_Promoted; Estadísticas)
                {
                }
                actionref("Co&mentarios_Promoted"; "Co&mentarios")
                {
                }
            }
        }
    }
}