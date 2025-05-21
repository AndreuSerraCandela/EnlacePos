page 91156 "TPV Activities"
{
    Caption = 'Actividades';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "TPV Cue";
    Permissions = tabledata "TPV Cue" = rimd;

    layout
    {
        area(content)
        {
            cuegroup("Daily TPV Transactions")
            {
                Caption = 'Transacciones de Hoy';
                field("TPV- Transactiones Pendientes"; Rec."Pending Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transacciones Pendientes';
                    ToolTip = 'Especifica el número de transacciones TPV pendientes.';
                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownPendingTransactions();
                    end;
                }
                field("TPV Open Credit Memos - Today"; Rec."Pending Creit Memo")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos TPV Pendientes';
                    ToolTip = 'Especifica el número de abonos TPV pendientes.';
                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownPendingCreditMemos();
                    end;
                }

                field("TPV Invoices - Today"; Rec."TPV Invoices - Today")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas TPV';
                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Especifica el número de facturas TPV creadas hoy.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownTodayInvoices();
                    end;
                }

                field("TPV Credit Memos - Today"; Rec."TPV Credit Memos - Today")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos TPV';
                    DrillDownPageID = "Posted Sales Credit Memos";
                    ToolTip = 'Especifica el número de abonos TPV creados hoy.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownTodayCreditMemos();
                    end;
                }

                // field("TPV Sales Amount - Today"; Rec."TPV Sales Amount - Today")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Importe Ventas';
                //     ToolTip = 'Especifica el importe total de ventas TPV de hoy.';
                //     AutoFormatType = 1;
                //     AutoFormatExpression = '<precision, 2:><standard format,0>€';
                // }

                // field("TPV Returns Amount - Today"; Rec."TPV Returns Amount - Today")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Importe Devoluciones';
                //     ToolTip = 'Especifica el importe total de devoluciones TPV de hoy.';
                //     AutoFormatType = 1;
                //     AutoFormatExpression = '<precision, 2:><standard format,0>€';
                // }

                field(AverageTransactionValue; AverageTransactionValue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Valor Medio Transacción';
                    ToolTip = 'Especifica el valor medio de las transacciones TPV de hoy.';
                    AutoFormatType = 1;
                    AutoFormatExpression = '<precision, 2:><standard format,0>€';
                    StyleExpr = AverageValueStyle;
                }


            }
            cuegroup("Cupones")
            {
                Caption = 'Cupones';
                field("Cupones Pendientes"; Rec."Pending Coupons")
                {
                    CaptionML = ENU = 'Pending Coupons',
                                ESP = 'Cupones Pendientes';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Campaign List";
                    ToolTip = 'Especifica el número de cupones pendientes.';
                }
                field("Cupones Utilizados"; Rec."Used Coupons")
                {
                    CaptionML = ENU = 'Used Coupons',
                                ESP = 'Cupones Utilizados';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Campaign List";
                    ToolTip = 'Especifica el número de cupones utilizados.';
                }
            }

            // cuegroup("Pending Transactions")
            // {
            //     Caption = 'Transacciones Pendientes';

            //     field("Pending Cash Transactions"; Rec."Pending Cash Transactions")
            //     {
            //         ApplicationArea = Basic, Suite;
            //         Caption = 'Transacciones en Efectivo Pendientes';
            //         DrillDownPageID = "Posted Sales Invoices";
            //         ToolTip = 'Especifica el número de transacciones TPV con pagos en efectivo pendientes.';
            //         StyleExpr = PendingCashStyle;

            //         trigger OnDrillDown()
            //         begin
            //             Rec.DrillDownPendingCashTransactions();
            //         end;
            //     }

            //     actions
            //     {
            //         action("Process Cash Receipt")
            //         {
            //             ApplicationArea = Basic, Suite;
            //             Caption = 'Procesar Cobro en Efectivo';
            //             RunObject = Page "Cash Receipt Journal";
            //             ToolTip = 'Procesar un cobro en efectivo para transacciones TPV pendientes.';
            //         }
            //     }
            // }

            cuegroup("Weekly Statistics")
            {
                Caption = 'Estadísticas Semanales';

                field("TPV Invoices - Last Week"; Rec."TPV Invoices - Last Week")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas TPV Esta Semana';
                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Especifica el número de facturas TPV creadas esta semana.';
                }

                field("TPV Credit Memos - Last Week"; Rec."TPV Credit Memos - Last Week")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos TPV Esta Semana';
                    DrillDownPageID = "Posted Sales Credit Memos";
                    ToolTip = 'Especifica el número de abonos TPV creados esta semana.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Configurar Indicadores';
                Image = Setup;
                ToolTip = 'Configurar los indicadores (mosaicos de estado) relacionados con el rol.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        TaskParameters.Add('View', Rec.GetView());
        if CalcTaskId <> 0 then
            if CurrPage.CancelBackgroundTask(CalcTaskId) then;
        CurrPage.EnqueueBackgroundTask(CalcTaskId, Codeunit::Importaciones, TaskParameters, 120000, PageBackgroundTaskErrorLevel::Warning);
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetRespCenterFilter();
        Rec.SetRange("Date Filter", WorkDate());
        Rec.SetFilter("Date Filter2", '>=%1', WorkDate());
        Rec.SetRange("User ID Filter", UserId());

        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        UIHelperTriggers: Codeunit "UI Helper Triggers";
    begin
        if TaskId <> CalcTaskId then
            exit;

        CalcTaskId := 0;

        // Forzamos la obtención del registro actualizado
        if Rec.Get() then;

        // Actualizamos los valores para mostrar en la página
        AverageTransactionValue := Rec."Average Transaction Value";
        UIHelperTriggers.GetCueStyle(Database::"TPV Cue", Rec.FieldNo("Average Transaction Value"), AverageTransactionValue, AverageValueStyle);

        CurrPage.Update(false);
    end;

    procedure EncodeResults(): Dictionary of [Text, Text]
    var
        Results: Dictionary of [Text, Text];
    begin
        Results.Add('AverageTransactionValue', Format(Rec."Average Transaction Value"));
        Results.Add('TPVSalesUpdatedOn', Format(Rec."TPV Sales Updated On"));
        exit(Results);
    end;


    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        CalcTaskId: Integer;
        AverageTransactionValue: Decimal;
        AverageValueStyle: Text;
        PendingCashStyle: Text;
}