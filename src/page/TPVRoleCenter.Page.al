page 91155 "TPV Role Center"
{
    Caption = 'Operador TPV';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Control104; "Headline RC TPV")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control1901851508; "TPV Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part("User Tasks Activities"; "User Tasks Activities")
            {
                ApplicationArea = Suite;
            }
            part("Job Queue Tasks Activities"; "Job Queue Tasks Activities")
            {
                ApplicationArea = Suite;
            }
            part("Emails"; "Email Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part(Control14; "Team Member Activities")
            {
                ApplicationArea = Suite;
            }
            part(Control1907692008; "My Customers")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control1; "Trailing Sales Orders Chart")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control4; "My Job Queue")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1905989608; "My Items")
            {
                ApplicationArea = Basic, Suite;
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control21; "Report Inbox Part")
            {
                ApplicationArea = Suite;
            }
            systempart(Control1901377608; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(embedding)
        {
            ToolTip = 'Gestionar procesos TPV, ver KPIs y acceder a sus artículos y clientes favoritos.';
            action(TPVInvoices)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Facturas TPV';
                Image = "Order";
                RunObject = Page "Posted Sales Invoices";
                RunPageView = where(TPV = filter(<> ''));
                ToolTip = 'Ver facturas creadas a través del sistema TPV.';
            }
            action(TPVCreditMemos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Abonos TPV';
                Image = "CreditMemo";
                RunObject = Page "Posted Sales Credit Memos";
                RunPageView = where(TPV = filter(<> ''));
                ToolTip = 'Ver abonos creados a través del sistema TPV.';
            }
            action(TPV)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TPV';
                Image = Warehouse;
                RunObject = Page "TPV List";
                ToolTip = 'Ver o editar información detallada de las facturas TPV.';
            }
            action(Cajas)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cajas';
                Image = CashFlow;
                RunObject = Page Cajas;
                ToolTip = 'Ver o editar información detallada de las cajas.';
            }
            action(Turnos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Turnos';
                Image = CalculateCost;
                RunObject = Page Turno;
                ToolTip = 'Ver o editar información detallada de los turnos.';
            }
            action(Items)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Artículos';
                Image = Item;
                RunObject = Page "Item List";
                ToolTip = 'Ver o editar información detallada de los productos con los que comercia.';
            }

            action(Customers)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Clientes';
                Image = Customer;
                RunObject = Page "Customer List";
                ToolTip = 'Ver o editar información detallada de los clientes con los que comercia.';
            }
            action(Colegios)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Colegios';
                Image = ContactReference;
                RunObject = Page Colegios;
                ToolTip = 'Ver o editar información detallada de los colegios con los que comercia.';
            }
            action("Cash Receipt Journals")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Diarios de Cobro';
                Image = Journals;
                RunObject = Page "General Journal Batches";
                RunPageView = where("Template Type" = const("Cash Receipts"),
                                    Recurring = const(false));
                ToolTip = 'Registrar pagos en efectivo para transacciones TPV.';
            }
        }
        area(sections)
        {
            group(TPVTransactions)
            {
                Caption = 'TPV';
                Image = Bank;
                ToolTip = 'Gestionar transacciones y procesos TPV.';
                action("Lista TPV")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'TPV';
                    Image = Warehouse;
                    RunObject = Page "TPV List";
                }
                action("Lista Cajas")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cajas';
                    Image = CashFlow;
                    RunObject = Page Cajas;
                }
                action("Lista Turnos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Turnos';
                    Image = CalculateCost;
                    RunObject = Page Turno;
                }

                action("TPV Invoice List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas TPV';
                    Image = Document;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageView = where("TPV" = filter(<> ''));
                    ToolTip = 'Ver la lista de facturas TPV registradas.';
                }

                action("TPV Credit Memo List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos TPV';
                    Image = CreditMemo;
                    RunObject = Page "Posted Sales Credit Memos";
                    RunPageView = where("TPV" = filter(<> ''));
                    ToolTip = 'Ver la lista de abonos TPV registrados.';
                }

                action("Cash Transaction Register")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Registro de Caja';
                    Image = CashFlow;
                    RunObject = Page "Cash Receipt Journal";
                    ToolTip = 'Ver y gestionar la caja registradora para transacciones TPV.';
                }
                action(Usuarios)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Usuarios';
                    Image = User;
                    RunObject = Page "Employee List";
                }
            }
            group("Posted Documents")
            {
                Caption = 'Documentos Registrados';
                Image = FiledPosted;
                ToolTip = 'Ver el historial de registros de ventas, transacciones TPV e inventario.';

                action("Posted Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas de Venta Registradas';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Abrir la lista de facturas de venta registradas.';
                }

                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos de Venta Registrados';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Abrir la lista de abonos de venta registrados.';
                }
            }
        }
        // area(creation)
        // {
        //     action("New TPV Invoice")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Nueva Factura TPV';
        //         Image = NewSalesInvoice;
        //         RunObject = Page "Sales Invoice";
        //         RunPageMode = Create;
        //         ToolTip = 'Crear una nueva factura TPV.';
        //     }

        //     action("New TPV Credit Memo")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Nuevo Abono TPV';
        //         Image = CreditMemo;
        //         RunObject = Page "Sales Cr.Memo";
        //         RunPageMode = Create;
        //         ToolTip = 'Crear un nuevo abono TPV.';
        //     }
        // }
        area(processing)
        {
            group(Reports)
            {
                Caption = 'Informes';

                action("TPV Daily Sales Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Informe de Ventas Diarias';
                    Image = "Report";
                    //RunObject = Report "TPV Daily Sales";
                    ToolTip = 'Ver un resumen de las ventas TPV de un día específico.';
                }

                action("TPV Monthly Sales Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Informe de Ventas Mensuales';
                    Image = "Report";
                    //RunObject = Report "TPV Monthly Sales";
                    ToolTip = 'Ver un resumen de las ventas TPV de un mes específico.';
                }
            }
            group(History)
            {
                Caption = 'Historial';
                action("Navi&gate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Buscar movimientos...';
                    Image = Navigate;
                    RunObject = Page Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Encontrar movimientos y documentos que existen para el número de documento y la fecha de registro en el documento seleccionado.';
                }
            }
        }
    }
}