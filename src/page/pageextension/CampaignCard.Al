pageextension 91118 "Campaign Card Ext" extends "Campaign Card"
{
    CaptionML = ENU = 'Campaign',
                ESP = 'Campaña';
    layout
    {
        modify("Status Code")
        {
            Visible = false;
        }
        modify(Activated)
        {
            Visible = false;
        }
        modify("Salesperson Code")
        {
            Visible = false;
        }
        addafter(General)
        {
            group(Descuento)
            {
                Caption = 'Descuento';
                field("% Descuento"; Rec."% Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el porcentaje de descuento del cupón';
                }
                field("Importe Descuento"; Rec."Importe Descuento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe de descuento del cupón';
                }
                field("Importe Total Descontado"; Rec."Importe Total Descontado")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el importe total descontado del cupón';
                    Editable = false;
                }

            }


            part(DetalleCupon; "Detalle Cupón Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Código Cupón" = field("No.");
                UpdatePropagation = Both;
                Caption = 'Detalle Cupón';
            }
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
            group("C&ampaña")
            {
                Caption = 'C&ampaña';
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
                    ToolTip = 'Ver todos los asientos vinculados a la campaña. En esta ventana, no puede crear manualmente nuevos asientos de campaña.';
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
                    ToolTip = 'Ver cifras clave relacionadas con su campaña.';
                }
                action(Dimensiones)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensiones';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(5071),
                                  "No." = field("No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'Ver o editar dimensiones, como área, proyecto o departamento, que puede asignar a documentos de ventas y compras para distribuir costos y analizar el historial de transacciones.';
                }
                action("T&areas")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'T&areas';
                    Image = TaskList;
                    RunObject = Page "Task List";
                    RunPageLink = "Campaign No." = field("No."),
                                  "System To-do Type" = filter(Organizer);
                    RunPageView = sorting("Campaign No.");
                    ToolTip = 'Ver tareas para la campaña.';
                }
                action("S&egmentos")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'S&egmentos';
                    Image = Segment;
                    RunObject = Page "Segment List";
                    RunPageLink = "Campaign No." = field("No.");
                    RunPageView = sorting("Campaign No.");
                    ToolTip = 'Ver una lista de todos los segmentos abiertos. Los segmentos abiertos son aquellos para los que aún no se ha registrado la interacción.';
                }
                action("Opo&rtunidades")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Opo&rtunidades';
                    Image = OpportunitiesList;
                    RunObject = Page "Opportunity List";
                    RunPageLink = "Campaign No." = field("No.");
                    RunPageView = sorting("Campaign No.");
                    ToolTip = 'Ver oportunidades para la campaña.';
                }
#if not CLEAN25
                action("&Precios de Venta")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = '&Precios de Venta';
                    Image = SalesPrices;
                    Visible = not ExtendedPriceEnabledNew;
                    ToolTip = 'Definir cómo configurar acuerdos de precios de venta. Estos precios de venta pueden ser para clientes individuales, para un grupo de clientes, para todos los clientes o para una campaña.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';

                    trigger OnAction()
                    var
                        SalesPrice: Record "Sales Price";
                    begin
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
                        SalesPrice.SetRange("Sales Code", Rec."No.");
                        Page.Run(Page::"Sales Prices", SalesPrice);
                    end;
                }
                action("&Descuentos de Línea de Venta")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = '&Descuentos de Línea de Venta';
                    Image = SalesLineDisc;
                    Visible = not ExtendedPriceEnabledNew;
                    ToolTip = 'Ver los descuentos de línea de venta disponibles. Estos acuerdos de descuento pueden ser para clientes individuales, para un grupo de clientes, para todos los clientes o para una campaña.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';

                    trigger OnAction()
                    var
                        SalesLineDiscount: Record "Sales Line Discount";
                    begin
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Campaign);
                        SalesLineDiscount.SetRange("Sales Code", Rec."No.");
                        Page.Run(Page::"Sales Line Discounts", SalesLineDiscount);
                    end;
                }
#endif
                action(ListasPrecios)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Listas de Precios de Venta';
                    Image = Price;
                    Visible = ExtendedPriceEnabledNew;
                    ToolTip = 'Ver o configurar listas de precios de venta para productos que vende al cliente. Un precio de producto se otorga automáticamente en las líneas de factura cuando se cumplen los criterios especificados, como cliente, cantidad o fecha de finalización.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, Enum::"Price Type"::Sale, Enum::"Price Amount Type"::Any);
                    end;
                }
                action(LineasPrecios)
                {
                    AccessByPermission = TableData "Sales Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Precios de Venta';
                    Image = Price;
                    Visible = ExtendedPriceEnabledNew;
                    ToolTip = 'Ver o configurar líneas de precios de venta para productos que vende al cliente. Un precio de producto se otorga automáticamente en las líneas de factura cuando se cumplen los criterios especificados, como cliente, cantidad o fecha de finalización.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Price);
                    end;
                }
                action(LineasDescuento)
                {
                    AccessByPermission = TableData "Sales Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Descuentos de Venta';
                    Image = LineDiscount;
                    Visible = ExtendedPriceEnabledNew;
                    ToolTip = 'Ver o configurar diferentes descuentos para productos que vende al cliente. Un descuento de línea de producto se otorga automáticamente en las líneas de factura cuando se cumplen los criterios especificados, como cliente, cantidad o fecha de finalización.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Discount);
                    end;
                }
#if not CLEAN25
                action(ListasPreciosDescuentos)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Listas de Precios (Descuentos)';
                    Image = LineDiscount;
                    Visible = false;
                    ToolTip = 'Ver o configurar diferentes descuentos para productos que vende al cliente. Un descuento de línea de producto se otorga automáticamente en las líneas de factura cuando se cumplen los criterios especificados, como cliente, cantidad o fecha de finalización.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action PriceLists shows all sales price lists with prices and discounts';
                    ObsoleteTag = '18.0';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Discount);
                    end;
                }
#endif
            }

        }
        modify("Campaign Details")
        {
            Visible = false;
        }
        addafter(PriceLines_Promoted)
        {
#if not CLEAN25
            actionref("Precios_Venta_Promoted"; "&Precios de Venta")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '17.0';
            }
#endif

            actionref(LineasPrecios_Promoted; LineasPrecios)
            {
            }
            actionref(LineasDescuento_Promoted; LineasDescuento)
            {
            }
#if not CLEAN25
            actionref("Descuentos_Linea_Venta_Promoted"; "&Descuentos de Línea de Venta")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '17.0';
            }
#endif
            actionref(ListasPreciosDescuentos_Promoted; ListasPreciosDescuentos)
            {
            }
        }
        addbefore(Category_Category5)
        {
            group(Category_CategoryCupon)
            {
                Caption = 'Cupon', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(Dimensinones_Promoted; Dimensiones)
                {
                }
                actionref(Estadisticas_Promoted; Estadísticas)
                {
                }
                actionref("Co&mentarios_Promoted"; "Co&mentarios")
                {
                }
                actionref("S&egmentos_Promoted"; "S&egmentos")
                {
                }
                actionref("Opo&rtunidades_Promoted"; "Opo&rtunidades")
                {
                }
            }

        }
    }
    trigger OnOpenPage()
    begin
        ExtendedPriceEnabledNew := PriceCalculationMgtNew.IsExtendedPriceCalculationEnabled();
    end;

    var
        ExtendedPriceEnabledNew: Boolean;
        PriceCalculationMgtNew: Codeunit "Price Calculation Mgt.";
}