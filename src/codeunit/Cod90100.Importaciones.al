/// <summary>
/// Codeunit Importaciones (ID 90100).
/// Proporciona funcionalidad para la importación y exportación de datos mediante servicios web.
/// Gestiona operaciones relacionadas con productos, recursos, clientes, proveedores, facturas, cajas y TPVs.
/// </summary>
codeunit 75200 Importaciones
{
    TableNo = "TPV Cue";
    Permissions = TableData 18 = rimd,
    tabledata 23 = rimd,
    tabledata 27 = rimd,
    tabledata 36 = rimd,
    tabledata 37 = rimd,
    tabledata 38 = rimd,
    tabledata 39 = rimd,
    tabledata 75208 = rimd,
    tabledata 75207 = rimd,
    tabledata 75250 = rimd,
    tabledata 75200 = rimd,
    tabledata 76029 = rimd;
    /// <summary>
    /// Ping.
    /// Función de verificación de disponibilidad del servicio web.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure Ping(): Text
    begin
        exit('Pong');
    end;

    /// <summary>
    /// OnRun: Trigger principal que calcula el valor medio de transacción para ventas TPV del día actual.
    /// Filtra facturas de ventas registradas con TPV para el día de trabajo actual,
    /// calcula el valor promedio de transacción y actualiza el registro TPV Cue.
    /// </summary>
    trigger OnRun()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TotalAmount: Decimal;
        TotalTransactions: Integer;
        AverageTransactionValue: Decimal;
        TaskParameters: Dictionary of [Text, Text];
    begin
        // Calculate average transaction value
        SalesInvHeader.SetRange("Posting Date", WorkDate());
        SalesInvHeader.SetFilter("TPV", '<>%1', '');
        TotalTransactions := SalesInvHeader.Count;

        if TotalTransactions > 0 then begin
            if SalesInvHeader.FindSet() then
                repeat
                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.CalcSums(Amount);
                    TotalAmount += SalesInvLine.Amount;
                until SalesInvHeader.Next() = 0;

            AverageTransactionValue := TotalAmount / TotalTransactions;
        end else
            AverageTransactionValue := 0;

        // Al tener el TableNo = "TPV Cue", directamente actualizamos los valores aquí
        // Para evitar problemas de permisos, llamamos a nuestro método especial
        UpdateTPVCueRecord(Rec, AverageTransactionValue, CurrentDateTime);
    end;

    /// <summary>
    /// insertaProductos.
    /// Importa datos de productos desde un JSON estructurado.
    /// Permite crear nuevos productos, actualizar existentes o eliminarlos según la estructura JSON proporcionada.
    /// Si el número de producto es "TEMP" o vacío, crea un nuevo producto con numeración automática.
    /// Aplica plantillas de producto y gestiona unidades de medida asociadas.
    /// </summary>
    /// <param name="Data">Text</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaProductos(Data: Text): Text
    var
        JItemToken: JsonToken;
        JItemObj: JsonObject;
        JItems: JsonArray;
        JItem: JsonObject;
        ItemT: Record Item temporary;
        Item: Record Item;
        JToken: JsonToken;
        Texto: Text;
        RecRef2: RecordRef;
        ItemRecRef: RecordRef;
        ItemSetup: Record 313;
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        NoSeriesMgt: Codeunit "No. Series";
        ItemTempl: Record "Item Templ.";
        ItemFldRef: FieldRef;
        ProdRecRef: RecordRef;
        EmptyItemRecRef: RecordRef;
        EmptyItemTemplRecRef: RecordRef;
        ProdFldRef: FieldRef;
        EmptyProdFldRef: FieldRef;
        ItemTemplFldRef: FieldRef;
        EmptyItemFldRef: FieldRef;
        Unit: Record "Unit of Measure";
        ItemUnit: Record "Item Unit of Measure";
        i: Integer;
        Deleted: Boolean;
    begin

        JItemToken.ReadFrom(Data);
        JItemObj := JItemToken.AsObject();


        JItemObj.SelectToken('Items', JItemToken);
        JItems := JItemToken.AsArray();
        JItems.WriteTo(Data);


        foreach JToken in JItems do begin

            ItemT."No." := GetValueAsText(JToken, 'No_');
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            ItemT."No. 2" := GetValueAsText(JToken, 'No__2');
            ItemT."Description" := GetValueAsText(JToken, 'Description');
            ItemT."Search Description" := GetValueAsText(JToken, 'Search_Description');
            ItemT."Description 2" := GetValueAsText(JToken, 'Description_2');
            ItemT."Assembly BOM" := GetValueAsBoolean(JToken, 'Assembly_BOM');
            ItemT."Base Unit of Measure" := GetValueAsText(JToken, 'Base_Unit_of_Measure');
            ItemT."Unit List Price" := GetValueAsDecimal(JToken, 'Unit_List_Price');


            ItemT."Price Unit Conversion" := GetValueAsDecimal(JToken, 'Price_Unit_Conversion');
            Texto := GetValueAsText(JToken, 'Type');
            Case Texto Of
                'Inventory', 'Iventario':
                    ItemT."Type" := "Item Type"::Inventory;
                'Non-Inventory', 'No Iventario':
                    ItemT."Type" := "Item Type"::"Non-Inventory";
                'Service', 'Servicio':
                    ItemT."Type" := "Item Type"::Service;
            End;

            ItemT."Inventory Posting Group" := GetValueAsText(JToken, 'Inventory_Posting_Group');
            ItemT."Shelf No." := GetValueAsText(JToken, 'Shelf_No_');
            ItemT."Item Disc. Group" := GetValueAsText(JToken, 'Item_Disc__Group');
            ItemT."Allow Invoice Disc." := GetValueAsBoolean(JToken, 'Allow_Invoice_Disc_');
            ItemT."Statistics Group" := GetValueAsInteger(JToken, 'Statistics_Group');
            ItemT."Commission Group" := GetValueAsInteger(JToken, 'Commission_Group');
            ItemT."Unit Price" := GetValueAsDecimal(JToken, 'Unit_Price');
            Texto := GetValueAsText(JToken, 'Price_Profit_Calculation');
            Case Texto Of
                'No Relationship', 'Sin Relación':
                    ItemT."Price/Profit Calculation" := "Item Price Profit Calculation"::"No Relationship";
                'Price=Cost+Profit', 'Precio=Coste+Beneficio':
                    ItemT."Price/Profit Calculation" := "Item Price Profit Calculation"::"Price=Cost+Profit";
                'Profit=Price-Cost', 'Beneficio=Precio-Coste':
                    ItemT."Price/Profit Calculation" := "Item Price Profit Calculation"::"Profit=Price-Cost";
            End;
            ItemT."Profit %" := GetValueAsDecimal(JToken, 'Profit__');
            Texto := GetValueAsText(JToken, 'Costing_Method');
            Case Texto Of
                'Average', 'Medio':
                    ItemT."Costing Method" := "Costing Method"::Average;
                'FIFO':
                    ItemT."Costing Method" := "Costing Method"::FIFO;
                'LIFO':
                    ItemT."Costing Method" := "Costing Method"::LIFO;
                'Specific', 'Específico':
                    ItemT."Costing Method" := "Costing Method"::Specific;
                'Standard', 'Estandard':
                    ItemT."Costing Method" := "Costing Method"::Standard;
            End;
            ItemT."Unit Cost" := GetValueAsDecimal(JToken, 'Unit_Cost');
            ItemT."Standard Cost" := GetValueAsDecimal(JToken, 'Standard_Cost');
            ItemT."Last Direct Cost" := GetValueAsDecimal(JToken, 'Last_Direct_Cost');
            ItemT."Indirect Cost %" := GetValueAsDecimal(JToken, 'Indirect_Cost__');
            //ItemT."Cost is Adjusted":=GetValueAsText(JToken, 'Cost_is_Adjusted');
            //ItemT."Allow Online Adjustment":=GetValueAsText(JToken, 'Allow_Online_Adjustment');
            ItemT."Vendor No." := GetValueAsText(JToken, 'Vendor_No_');
            ItemT."Vendor Item No." := GetValueAsText(JToken, 'Vendor_Item_No_');
            //ItemT."Lead_Time_Calculation":=GetValueAsText(JToken, 'Lead_Time_Calculation');
            ItemT."Reorder Point" := GetValueAsDecimal(JToken, 'Reorder_Point');
            ItemT."Maximum Inventory" := GetValueAsDecimal(JToken, 'Maximum_Inventory');
            ItemT."Reorder Quantity" := GetValueAsDecimal(JToken, 'Reorder_Quantity');
            ItemT."Alternative Item No." := GetValueAsText(JToken, 'Alternative_Item No_');
            // ItemT."Unit_List_Price":=GetValueAsText(JToken, 'Unit_List_Price');
            // ItemT."Duty_Due_.":=GetValueAsText(JToken, 'Duty_Due__');
            // ItemT."Duty Code":=GetValueAsText(JToken, 'Duty_Code');
            ItemT."Gross Weight" := GetValueAsDecimal(JToken, 'Gross_Weight');
            ItemT."Net Weight" := GetValueAsDecimal(JToken, 'Net_Weight');
            ItemT."Units per Parcel" := GetValueAsDecimal(JToken, 'Units_per_Parcel');
            ItemT."Unit Volume" := GetValueAsDecimal(JToken, 'Unit_Volume');
            ItemT."Durability" := GetValueAsText(JToken, 'Durability');
            // ItemT."Freight_Type":=GetValueAsText(JToken, 'Freight_Type');
            // ItemT."Tariff No.":=GetValueAsText(JToken, 'Tariff_No_');
            // ItemT."Duty_Unit_Conversion":=GetValueAsText(JToken, 'Duty_Unit_Conversion');
            ItemT."Country/Region Purchased Code" := GetValueAsText(JToken, 'Country_Region_Purchased_Code');
            // ItemT."Budget_Quantity":=GetValueAsText(JToken, 'Budget_Quantity');
            // ItemT."Budgeted_Amount":=GetValueAsText(JToken, 'Budgeted_Amount');
            // ItemT."Budget_Profit":=GetValueAsText(JToken, 'Budget_Profit');
            ItemT."Blocked" := GetValueAsBoolean(JToken, 'Blocked');
            ItemT."Block Reason" := GetValueAsText(JToken, 'Block_Reason');
            // ItemT."Last_DateTime_Modified":=GetValueAsText(JToken, 'Last_DateTime_Modified');
            // ItemT."Last_Date_Modified":=GetValueAsText(JToken, 'Last_Date_Modified');
            // ItemT."Last_Time_Modified":=GetValueAsText(JToken, 'Last_Time_Modified');
            ItemT."Price Includes VAT" := GetValueAsBoolean(JToken, 'Price_Includes_VAT');
            ItemT."VAT Bus. Posting Gr. (Price)" := GetValueAsText(JToken, 'VAT_Bus__Posting_Gr__Price');
            ItemT."Gen. Prod. Posting Group" := GetValueAsText(JToken, 'Gen__Prod__Posting_Group');
            ItemT."Country/Region of Origin Code" := GetValueAsText(JToken, 'Country_Region_of_Origin_Code');
            //ItemT."Automatic Ext. Texts":=GetValueAsText(JToken, 'Automatic_Ext__Texts');
            //ItemT."No__Series":=GetValueAsText(JToken, 'No__Series');
            //ItemT."Tax_Group Code":=GetValueAsText(JToken, 'Tax_Group_Code');
            ItemT."VAT Prod. Posting Group" := GetValueAsText(JToken, 'VAT_Prod_Posting_Group');
            // ItemT."Reserve":=GetValueAsText(JToken, 'Reserve');
            ItemT."Global Dimension 1 Code" := GetValueAsText(JToken, 'Global_Dimension_1_Code');
            ItemT."Global Dimension 2 Code" := GetValueAsText(JToken, 'Global_Dimension_2_Code');
            // ItemT."Stockout_Warning":=GetValueAsText(JToken, 'Stockout_Warning');
            // ItemT."Prevent_Negative_Inventory":=GetValueAsText(JToken, 'Prevent_Negative_Inventory');
            // ItemT."Cost_of_Open_Production_Orders":=GetValueAsText(JToken, 'Cost_of_Open_Production_Orders');
            // ItemT."Application_Wksh__User_ID":=GetValueAsText(JToken, 'Application_Wksh__User_ID');
            // ItemT."Coupled_to_CRM":=GetValueAsText(JToken, 'Coupled_to_CRM');
            // ItemT."Assembly_Policy":=GetValueAsText(JToken, 'Assembly_Policy');
            // ItemT."GTIN":=GetValueAsText(JToken, 'GTIN');
            // ItemT."Default_Deferral_Template Code":=GetValueAsText(JToken, 'Default_Deferral_Template_Code');
            // ItemT."Low_Level Code":=GetValueAsText(JToken, 'Low_Level_Code');
            // ItemT."Lot_Size":=GetValueAsText(JToken, 'Lot_Size');
            // ItemT."Serial_Nos.":=GetValueAsText(JToken, 'Serial_Nos_');
            // ItemT."Last_Unit_Cost_Calc__Date":=GetValueAsText(JToken, 'Last_Unit_Cost_Calc__Date');
            // ItemT."Rolled_up_Material_Cost":=GetValueAsText(JToken, 'Rolled_up_Material_Cost');
            // ItemT."Rolled_up_Capacity_Cost":=GetValueAsText(JToken, 'Rolled_up_Capacity_Cost');
            // ItemT."Scrap_.":=GetValueAsText(JToken, 'Scrap__');
            // ItemT."Inventory_Value_Zero":=GetValueAsText(JToken, 'Inventory_Value_Zero');
            // ItemT."Discrete_Order_Quantity":=GetValueAsText(JToken, 'Discrete_Order_Quantity');
            // ItemT."Minimum_Order_Quantity":=GetValueAsText(JToken, 'Minimum_Order_Quantity');
            // ItemT."Maximum_Order_Quantity":=GetValueAsText(JToken, 'Maximum_Order_Quantity');
            ItemT."Safety Stock Quantity" := GetValueAsDecimal(JToken, 'Safety_Stock_Quantity');
            // ItemT."Order_Multiple":=GetValueAsText(JToken, 'Order_Multiple');
            // ItemT."Safety_Lead_Time":=GetValueAsText(JToken, 'Safety_Lead_Time');
            // ItemT."Flushing_Method":=GetValueAsText(JToken, 'Flushing_Method');
            // ItemT."Replenishment_System":=GetValueAsText(JToken, 'Replenishment_System');
            // ItemT."Rounding_Precision":=GetValueAsText(JToken, 'Rounding_Precision');
            ItemT."Sales Unit of Measure" := GetValueAsText(JToken, 'Sales_Unit_of_Measure');
            ItemT."Purch. Unit of Measure" := GetValueAsText(JToken, 'Purch__Unit_of_Measure');
            // ItemT."Time_Bucket":=GetValueAsText(JToken, 'Time_Bucket');
            // ItemT."Reordering_Policy":=GetValueAsText(JToken, 'Reordering_Policy');
            // ItemT."Include_Inventory":=GetValueAsText(JToken, 'Include_Inventory');
            // ItemT."Manufacturing_Policy":=GetValueAsText(JToken, 'Manufacturing_Policy');
            // ItemT."Rescheduling_Period":=GetValueAsText(JToken, 'Rescheduling_Period');
            // ItemT."Lot_Accumulation_Period":=GetValueAsText(JToken, 'Lot_Accumulation_Period');
            // ItemT."Dampener_Period":=GetValueAsText(JToken, 'Dampener_Period');
            // ItemT."Dampener_Quantity":=GetValueAsText(JToken, 'Dampener_Quantity');
            // ItemT."Overflow_Level":=GetValueAsText(JToken, 'Overflow_Level');
            ItemT."Manufacturer Code" := GetValueAsText(JToken, 'Manufacturer_Code');
            ItemT."Item Category Code" := GetValueAsText(JToken, 'Item_Category_Code');
            // ItemT."Created_From_Nonstock_Item":=GetValueAsText(JToken, 'Created_From_Nonstock_Item');
            ItemT."Purchasing Code" := GetValueAsText(JToken, 'Purchasing_Code');
            // ItemT."Service_Item Group":=GetValueAsText(JToken, 'Service_Item_Group');
            // ItemT."Item_Tracking Code":=GetValueAsText(JToken, 'Item_Tracking_Code');
            // ItemT."Lot_Nos.":=GetValueAsText(JToken, 'Lot_Nos_');
            // ItemT."Expiration_Calculation":=GetValueAsText(JToken, 'Expiration_Calculation');
            // ItemT."Warehouse_Class Code":=GetValueAsText(JToken, 'Warehouse_Class_Code');
            // ItemT."Special_Equipment Code":=GetValueAsText(JToken, 'Special_Equipment_Code');
            // ItemT."Put_away_Template Code":=GetValueAsText(JToken, 'Put_away_Template_Code');
            // ItemT."Put_away_Unit_of_Measure Code":=GetValueAsText(JToken, 'Put_away_Unit_of_Measure_Code');
            // ItemT."Phys_Invt_Counting_Period Code":=GetValueAsText(JToken, 'Phys_Invt_Counting_Period_Code');
            // ItemT."Last_Counting_Period_Update":=GetValueAsText(JToken, 'Last_Counting_Period_Update');
            // ItemT."Use_Cross_Docking":=GetValueAsText(JToken, 'Use_Cross_Docking');
            // ItemT."Next_Counting_Start_Date":=GetValueAsText(JToken, 'Next_Counting_Start_Date');
            // ItemT."Next_Counting_End_Date":=GetValueAsText(JToken, 'Next_Counting_End_Date');
            // ItemT."Unit_of_Measure_Id":=GetValueAsText(JToken, 'Unit_of_Measure_Id');
            // ItemT."Tax_Group_Id":=GetValueAsText(JToken, 'Tax_Group_Id');
            // ItemT."Sales_Blocked":=GetValueAsText(JToken, 'Sales_Blocked');
            // ItemT."Purchasing_Blocked":=GetValueAsText(JToken, 'Purchasing_Blocked');
            // ItemT."Item_Category_Id":=GetValueAsText(JToken, 'Item_Category_Id');
            // ItemT."Inventory_Posting_Group_Id":=GetValueAsText(JToken, 'Inventory_Posting_Group_Id');
            // ItemT."Gen__Prod__Posting_Group_Id":=GetValueAsText(JToken, 'Gen__Prod__Posting Group_Id');
            // ItemT."Over_Receipt Code":=GetValueAsText(JToken, 'Over_Receipt_Code');
            // ItemT."Cost_Regulation_.":=GetValueAsText(JToken, 'Cost_Regulation__');
            // ItemT."Routing No.":=GetValueAsText(JToken, 'Routing_No_');
            // ItemT."Production_BOM No.":=GetValueAsText(JToken, 'Production_BOM_No_');
            // ItemT."Single_Level_Material_Cost":=GetValueAsText(JToken, 'Single_Level_Material_Cost');
            // ItemT."Single_Level_Capacity_Cost":=GetValueAsText(JToken, 'Single_Level_Capacity_Cost');
            // ItemT."Single_Level_Subcontrd__Cost":=GetValueAsText(JToken, 'Single_Level_Subcontrd__Cost');
            // ItemT."Single_Level_Cap__Ovhd_Cost":=GetValueAsText(JToken, 'Single_Level_Cap__Ovhd_Cost');
            // ItemT."Single_Level_Mfg__Ovhd_Cost":=GetValueAsText(JToken, 'Single_Level_Mfg__Ovhd_Cost');
            // ItemT."Overhead_Rate":=GetValueAsText(JToken, 'Overhead_Rate');
            // ItemT."Rolled_up_Subcontracted_Cost":=GetValueAsText(JToken, 'Rolled_up_Subcontracted_Cost');
            // ItemT."Rolled_up_Mfg__Ovhd_Cost":=GetValueAsText(JToken, 'Rolled_up_Mfg__Ovhd_Cost');
            // ItemT."Rolled_up_Cap__Overhead_Cost":=GetValueAsText(JToken, 'Rolled_up_Cap__Overhead Cost');
            // ItemT."Order_Tracking_Policy":=GetValueAsText(JToken, 'Order_Tracking_Policy');
            // ItemT."Critical":=GetValueAsText(JToken, 'Critical');
            ItemT."Common Item No." := GetValueAsText(JToken, 'Common Item No_');

            If (ItemT."No." = 'TEMP') Or (ItemT."No." = '') Then begin

                ItemSetup.Get();
                ItemSetup.TestField("Item Nos.");
                iTem.Init;
                Item := ItemT;
                Item."No. Series" := ItemSetup."Item Nos.";
                Item."No." := NoSeriesMgt.GetNextNo(ItemSetup."Item Nos.", Today, true);
                Item.Insert();
                ItemSetup.TestField(ItemTemplate);
                ItemTempl.Get(ItemSetup.ItemTemplate);
                ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl);
                If ItemT."Base Unit of Measure" <> '' Then begin
                    If not Unit.Get(ItemT."Base Unit of Measure") Then begin
                        Unit."Code" := ItemT."Base Unit of Measure";
                        Unit."Description" := ItemT."Base Unit of Measure";
                        Unit.Insert();
                    end;
                    If Not ItemUnit.Get(Item."No.", ItemT."Base Unit of Measure") Then begin
                        ItemUnit."Item No." := Item."No.";
                        ItemUnit."Code" := ItemT."Base Unit of Measure";
                        ItemUnit."Qty. per Unit of Measure" := 1;
                        ItemUnit.Insert();
                    end;
                    Item.Validate("Base Unit of Measure", ItemT."Base Unit of Measure");
                end;
                If ItemT."Sales Unit of Measure" <> '' Then begin
                    If not Unit.Get(ItemT."Sales Unit of Measure") Then begin
                        Unit."Code" := ItemT."Sales Unit of Measure";
                        Unit."Description" := ItemT."Sales Unit of Measure";
                        Unit.Insert();
                    end;
                    If Not ItemUnit.Get(Item."No.", ItemT."Sales Unit of Measure") Then begin
                        ItemUnit."Item No." := Item."No.";
                        ItemUnit."Code" := ItemT."Sales Unit of Measure";
                        ItemUnit."Qty. per Unit of Measure" := 1;
                        ItemUnit.Insert();
                    end;
                    Item.Validate("Sales Unit of Measure", ItemT."Sales Unit of Measure");
                end;
                If ItemT."Purch. Unit of Measure" <> '' Then begin
                    If not Unit.Get(ItemT."Purch. Unit of Measure") Then begin
                        Unit."Code" := ItemT."Purch. Unit of Measure";
                        Unit."Description" := ItemT."Purch. Unit of Measure";
                        Unit.Insert();
                    end;
                    If Not ItemUnit.Get(Item."No.", ItemT."Purch. Unit of Measure") Then begin
                        ItemUnit."Item No." := Item."No.";
                        ItemUnit."Code" := ItemT."Purch. Unit of Measure";
                        ItemUnit."Qty. per Unit of Measure" := 1;
                        ItemUnit.Insert();
                    end;
                    Item.Validate("Purch. Unit of Measure", ItemT."Purch. Unit of Measure");
                end;

                Item.Modify();
                ItemT."No." := Item."No.";
            end else begin
                if not Deleted then begin
                    ItemRecRef.Gettable(ItemT);
                    EmptyItemRecRef.Open(Database::Item);
                    EmptyItemRecRef.Init();
                    If Item.Get(ItemT."No.") Then begin
                        ProdRecRef.GetTable(Item);
                        for i := 1 to ItemRecRef.FieldCount do begin
                            ItemFldRef := ItemRecRef.FieldIndex(i);
                            ProdFldRef := ProdRecRef.Field(ItemFldRef.Number);
                            EmptyItemFldRef := EmptyItemRecRef.Field(ItemFldRef.Number);
                            if (ItemFldRef.Value <> EmptyItemFldRef.Value)
                                then
                                ProdFldRef.Value := ItemFldRef.Value;
                        end;

                        ProdRecRef.Modify();
                        ItemT."No." := Item."No.";
                    end;
                end else begin
                    If Item.Get(ItemT."No.") Then Item.Delete();
                    ItemUnit.SetRange("Item No.", ItemT."No.");
                    ItemUnit.DeleteAll();
                end;
            end;
        end;
        exit(ItemT."No.");
    end;

    /// <summary>
    /// insertaClientes.
    /// Importa datos de clientes desde un formato JSON estructurado.
    /// Permite crear nuevos clientes, actualizar los existentes o eliminarlos según la estructura JSON.
    /// Si el número de cliente es "TEMP" o vacío, crea un nuevo cliente con numeración automática.
    /// Aplica plantillas de cliente y gestiona datos de dirección, contacto y configuración comercial.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaClientes(Data: Text): Text
    var
        JCustToken: JsonToken;
        JCustObj: JsonObject;
        JCustomers: JsonArray;
        JCust: JsonObject;
        CustT: Record Customer temporary;
        JToken: JsonToken;
        Texto: Text;
        Cust: Record Customer;
        RecRef2: RecordRef;
        CustomerRecRef: RecordRef;
        SalesSetup: Record "Sales & Receivables Setup";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        NoSeriesMgt: Codeunit "No. Series";
        CustomerTempl: Record "Customer Templ.";
        CustomerFldRef: FieldRef;
        CustRecRef: RecordRef;
        EmptyCustomerRecRef: RecordRef;
        EmptyCustomerTemplRecRef: RecordRef;
        CustFldRef: FieldRef;
        EmptyCustFldRef: FieldRef;
        CustomerTemplFldRef: FieldRef;
        EmptyCustomerFldRef: FieldRef;
        i: Integer;
        Deleted: Boolean;
    begin

        JCustToken.ReadFrom(Data);
        JCustObj := JCustToken.AsObject();


        JCustObj.SelectToken('Customers', JCustToken);
        JCustomers := JCustToken.AsArray();
        JCustomers.WriteTo(Data);


        foreach JToken in JCustomers do begin

            CustT."No." := GetValueAsText(JToken, 'No_');
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            CustT."Name" := GetValueAsText(JToken, 'Name');
            CustT."Search Name" := GetValueAsText(JToken, 'Search_Name');
            CustT."Name 2" := GetValueAsText(JToken, 'Name_2');
            CustT."Address" := GetValueAsText(JToken, 'Address');
            CustT."Address 2" := GetValueAsText(JToken, 'Address_2');
            CustT."City" := GetValueAsText(JToken, 'City');
            CustT."Contact" := GetValueAsText(JToken, 'Contact');
            CustT."Phone No." := GetValueAsText(JToken, 'Phone_No_');
            CustT."Telex No." := GetValueAsText(JToken, 'Telex_No_');
            CustT."Document Sending Profile" := GetValueAsText(JToken, 'Document_Sending_Profile');
            CustT."Ship-to Code" := GetValueAsText(JToken, 'Ship_to_Code');
            CustT."Our Account No." := GetValueAsText(JToken, 'Our_Account_No_');
            CustT."Territory Code" := GetValueAsText(JToken, 'Territory_Code');
            CustT."Global Dimension 1 Code" := GetValueAsText(JToken, 'Global_Dimension_1_Code');
            CustT."Global Dimension 2 Code" := GetValueAsText(JToken, 'Global_Dimension_2_Code');
            CustT."Chain Name" := GetValueAsText(JToken, 'Chain_Name');
            //CustT."Budgeted Amount":=GetValueAsText(JToken, 'Budgeted_Amount');
            CustT."Customer Posting Group" := GetValueAsText(JToken, 'Customer_Posting_Group');
            CustT."Currency Code" := GetValueAsText(JToken, 'Currency_Code');
            CustT."Customer Price Group" := GetValueAsText(JToken, 'Customer_Price_Group');
            CustT."Language Code" := GetValueAsText(JToken, 'Language_Code');
            CustT."Statistics Group" := GetValueAsInteger(JToken, 'Statistics_Group');
            CustT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Code');
            if CustT."Payment Method Code" = '' then
                CustT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Id');
            //Payment_Terms_Id y método de envío (Shipment_Method_Id
            CustT."Fin. Charge Terms Code" := GetValueAsText(JToken, 'Fin__Charge_Terms_Code');
            CustT."Salesperson Code" := GetValueAsText(JToken, 'Salesperson_Code');
            CustT."Shipment Method Code" := GetValueAsText(JToken, 'Shipment_Method_Code');
            If CustT."Shipping Agent Code" = '' Then
                CustT."Shipping Agent Code" := GetValueAsText(JToken, 'Shipping_Agent_Id');
            CustT."Shipping Agent Code" := GetValueAsText(JToken, 'Shipping_Agent_Code');
            CustT."Place of Export" := GetValueAsText(JToken, 'Place_of_Export');
            CustT."Invoice Disc. Code" := GetValueAsText(JToken, 'Invoice_Disc__Code');
            CustT."Customer Disc. Group" := GetValueAsText(JToken, 'Customer_Disc__Group');
            CustT."Country/Region Code" := GetValueAsText(JToken, 'Country_Region_Code');
            CustT."Collection Method" := GetValueAsText(JToken, 'Collection_Method');
            //CustT."Amount":=GetValueAsText(JToken, 'Amount');
            Texto := GetValueAsText(JToken, 'Blocked');
            Case Texto Of
                ' ':
                    CustT."Blocked" := "Customer Blocked"::" ";
                'All', 'Todos':
                    CustT."Blocked" := "Customer Blocked"::All;
                'Invoice', 'Factura':
                    CustT."Blocked" := "Customer Blocked"::Invoice;
                'Ship', 'Envio':
                    CustT."Blocked" := "Customer Blocked"::Ship;
            End;

            CustT."Invoice Copies" := GetValueAsInteger(JToken, 'Invoice_Copies');
            //CustT."Last Statement No.":=GetValueAsText(JToken, 'Last_Statement_No_');
            //CustT."Print_Statements":=GetValueAsText(JToken, 'Print_Statements');
            CustT."Bill-to Customer No." := GetValueAsText(JToken, 'Bill_to_Customer_No_');
            //CustT."Priority":=GetValueAsText(JToken, 'Priority');
            CustT."Payment Method Code" := GetValueAsText(JToken, 'Payment_Method_Code');
            // CustT."Last_Modified_Date_Time":=GetValueAsText(JToken, 'Last_Modified_Date_Time');
            // CustT."Last_Date_Modified":=GetValueAsText(JToken, 'Last_Date_Modified');
            // CustT."Application_Method":=GetValueAsText(JToken, 'Application_Method');
            CustT."Prices Including VAT" := GetValueAsBoolean(JToken, 'Prices_Including_VAT');
            CustT."POS Discount" := GetValueAsDecimal(JToken, 'POS_Discount');
            CustT.Address := GetValueAsText(JToken, 'Direcccion');
            CustT."Address 2" := GetValueAsText(JToken, 'Direccion_2');
            CustT."City" := GetValueAsText(JToken, 'Poblacion');
            CustT."Post Code" := GetValueAsText(JToken, 'Cod_Postal');
            CustT."Country/Region Code" := GetValueAsText(JToken, 'Pais');
            CustT."Phone No." := GetValueAsText(JToken, 'Telefono');
            CustT."Mobile Phone No." := GetValueAsText(JToken, 'Mobil');
            CustT."E-Mail" := GetValueAsText(JToken, 'E_Mail');
            CustT."Contact" := GetValueAsText(JToken, 'Contacto');
            CustT."VAT Registration No." := GetValueAsText(JToken, 'Numero_Identificacion_fiscal');
            CustT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            CustT."Fax No." := GetValueAsText(JToken, 'Fax_No_');
            CustT."Telex Answer Back" := GetValueAsText(JToken, 'Telex_Answer_Back');
            //CustT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            CustT."Combine Shipments" := GetValueAsBoolean(JToken, 'Combine_Shipments');
            CustT."Gen. Bus. Posting Group" := GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            CustT."GLN" := GetValueAsText(JToken, 'GLN');
            //CustT."Post Code" := GetValueAsText(JToken, 'Post_Code');
            CustT."County" := GetValueAsText(JToken, 'County');
            CustT."EORI Number" := GetValueAsText(JToken, 'EORI_Number');
            CustT."Use GLN in Electronic Document" := GetValueAsBoolean(JToken, 'Use_GLN_in_Electronic_Document');
            CustT."E-Mail" := GetValueAsText(JToken, 'E_Mail');
            //CustT."Home Page" := GetValueAsText(JToken, 'Home_Page');
            CustT."Reminder Terms Code" := GetValueAsText(JToken, 'Reminder_Terms_Code');
            //CustT."No. Series":=GetValueAsText(JToken, 'No__Series');
            //CustT."Tax Area Code":=GetValueAsText(JToken, 'Tax_Area_Code');
            //CustT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            CustT."VAT Bus. Posting Group" := GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            //CustT."Reserve":=GetValueAsText(JToken, 'Reserve');
            //CustT."Block_Payment_Tolerance":=GetValueAsText(JToken, 'Block_Payment_Tolerance');
            CustT."IC Partner Code" := GetValueAsText(JToken, 'IC_Partner_Code');
            CustT."Prepayment %" := GetValueAsDecimal(JToken, 'Prepayment__');
            Texto := GetValueAsText(JToken, 'Partner_Type');
            Case Texto Of
                ' ':
                    CustT."Partner Type" := "Partner Type"::" ";
                'Company', 'Empresa':
                    CustT."Partner Type" := "Partner Type"::Company;
                'Person', 'Persona':
                    CustT."Partner Type" := "Partner Type"::Person;
            End;

            //CustT."Intrastat_Partner_Type":=GetValueAsText(JToken, 'Intrastat_Partner_Type');
            //CustT."Image":=GetValueAsText(JToken, 'Image');
            //CustT."Privacy_Blocked":=GetValueAsText(JToken, 'Privacy_Blocked');
            //CustT."Disable_Search_by_Name":=GetValueAsText(JToken, 'Disable_Search_by_Name');
            CustT."Preferred Bank Account Code" := GetValueAsText(JToken, 'Preferred_Bank_Account_Code');
            //CustT."Coupled to CRM":=GetValueAsText(JToken, 'Coupled_to_CRM');
            CustT."Cash Flow Payment Terms Code" := GetValueAsText(JToken, 'Cash_Flow_Payment_Terms_Code');
            // CustT."Primary_Contact No.":=GetValueAsText(JToken, 'Primary_Contact_No_');
            // CustT."Contact_Type":=GetValueAsText(JToken, 'Contact_Type');
            CustT."Mobile Phone No." := GetValueAsText(JToken, 'Mobile_Phone_No_');
            CustT."Responsibility Center" := GetValueAsText(JToken, 'Responsibility_Center');
            // CustT."Shipping Advice":=GetValueAsText(JToken, 'Shipping_Advice');
            // CustT."Shipping Time":=GetValueAsText(JToken, 'Shipping_Time');
            CustT."Shipping Agent Service Code" := GetValueAsText(JToken, 'Shipping_Agent_Service_Code');
            CustT."Service Zone Code" := GetValueAsText(JToken, 'Service_Zone_Code');
            //CustT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            CustT."Allow Line Disc." := GetValueAsBoolean(JToken, 'Allow_Line_Disc_');
            CustT."Base Calendar Code" := GetValueAsText(JToken, 'Base_Calendar_Code');
            //CustT."Copy Sell-to Addr. to Qte From":=GetValueAsText(JToken, 'Copy_Sell_to_Addr__to_Qte_From');
            CustT."Validate EU Vat Reg. No." := GetValueAsBoolean(JToken, 'Validate_EU_Vat_Reg__No_');
            // CustT."Currency_Id":=GetValueAsText(JToken, 'Currency_Id');
            // CustT."Payment_Terms_Id":=GetValueAsText(JToken, 'Payment_Terms_Id');
            // CustT."Shipment_Method_Id":=GetValueAsText(JToken, 'Shipment_Method_Id');
            // CustT."Payment_Method_Id":=GetValueAsText(JToken, 'Payment_Method_Id');
            // CustT."Tax_Area_ID":=GetValueAsText(JToken, 'Tax_Area_ID');
            // CustT."Contact_ID":=GetValueAsText(JToken, 'Contact_ID');
            // CustT."Contact_Graph_Id":=GetValueAsText(JToken, 'Contact_Graph_Id');
            // CustT."Payment Days Code" := GetValueAsText(JToken, 'Payment_Days_Code');
            // CustT."Non-Paymt. Periods Code" := GetValueAsText(JToken, 'Non_Paymt__Periods_Code');
            // CustT."Not in AEAT" := GetValueAsBoolean(JToken, 'Not_in_AEAT');

            If (CustT."No." = 'TEMP') or (CustT."No." = '') Then begin

                SalesSetup.Get();
                SalesSetup.TestField("Customer Nos.");
                Cust := CustT;
                Cust."No. Series" := SalesSetup."Customer Nos.";
                Cust."No." := NoSeriesMgt.GetNextNo(SalesSetup."Customer Nos.", Today, true);
                Cust.Insert();
                CustT."No." := Cust."No.";
                SalesSetup.TestField(CustomerTemplate);
                CustomerTempl.Get(SalesSetup.CustomerTemplate);
                CustomerTemplMgt.ApplyCustomerTemplate(Cust, CustomerTempl);
            end else begin
                if not Deleted then begin
                    CustomerRecRef.Gettable(CustT);
                    EmptyCustomerRecRef.Open(Database::Customer);
                    EmptyCustomerRecRef.Init();
                    If Cust.Get(CustT."No.") Then begin
                        CustRecRef.GetTable(Cust);
                        for i := 1 to CustomerRecRef.FieldCount do begin
                            CustomerFldRef := CustomerRecRef.FieldIndex(i);
                            CustFldRef := CustRecRef.Field(CustomerFldRef.Number);
                            EmptyCustomerFldRef := EmptyCustomerRecRef.Field(CustomerFldRef.Number);
                            if (CustomerFldRef.Value <> EmptyCustomerFldRef.Value)
                                then
                                CustFldRef.Value := CustomerFldRef.Value;
                        end;

                        CustRecRef.Modify();
                    end;
                    CustomerRecRef.Close();
                    CustT."No." := Cust."No.";
                end else begin
                    If Cust.Get(CustT."No.") Then Cust.Delete();
                    CustT."No." := '';
                end;
            end;
        end;
        exit(CustT."No.");

    end;

    [ServiceEnabled]
    procedure insertaFacturasVenta(Data: Text): Text
    var
        JPedidoToken: JsonToken;
        JPedidoObj: JsonObject;
        JFacturas: JsonArray;
        JPedido: JsonObject;
        SalesHeaderT: Record "Sales Header" temporary;
        JToken: JsonToken;
        Texto: Text;
        Vend: Record Vendor;
        RecRef2: RecordRef;
        VendorRecRef: RecordRef;
        PurchSetup: Record 312;
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        NoSeriesMgt: Codeunit "No. Series";
        VendorTempl: Record "Vendor Templ.";
        VendorFldRef: FieldRef;
        VendRecRef: RecordRef;
        EmptyVendorRecRef: RecordRef;
        EmptyVendorTemplRecRef: RecordRef;
        VendFldRef: FieldRef;
        EmptyVendFldRef: FieldRef;
        VendorTemplFldRef: FieldRef;
        EmptyVendorFldRef: FieldRef;
        i: Integer;
        Pedido: Record "Sales Header";
        IdType: Text;
        InvoiceType: Text;
        IdSpecial: Text;
        Caja: Record "Configuracion TPV";
        TipoDetalle: Text;
    begin
        JPedidoToken.ReadFrom(Data);
        JPedidoObj := JPedidoToken.AsObject();


        JPedidoObj.SelectToken('Sales_Headers', JPedidoToken);
        JFacturas := JPedidoToken.AsArray();
        foreach JToken in JFacturas do begin
            Texto := GetValueAsText(JToken, 'Document_Type');
            Texto := GetValueAsText(JToken, 'Document_Type');
            case Texto Of
                'Invoice', 'Factura':
                    SalesHeaderT."Document Type" := SalesHeaderT."Document Type"::Invoice;
                'Credit Memo', 'Nota de Crédito', 'Abono', 'Credit Note':
                    SalesHeaderT."Document Type" := SalesHeaderT."Document Type"::"Credit Memo";
            end;
            SalesHeaderT."Sell-to Customer No." := GetValueAsText(JToken, 'Sell_to_Customer_No_');
            SalesHeaderT."No." := GetValueAsText(JToken, 'No_');
            SalesHeaderT.Colegio := GetValueAsText(JToken, 'Colegio');
            SalesHeaderT.TPV := GetValueAsText(JToken, 'Caja');
            if SalesHeaderT.TPV <> '' Then begin
                Caja.SetRange("Id TPV", SalesHeaderT.TPV);
                if Caja.FindFirst() then begin
                    SalesHeaderT.TPV := Caja."Tienda";
                    SalesHeaderT."Venta TPV" := true;
                end;
            end;

            If not Evaluate(SalesHeaderT.Turno, GetValueAsText(JToken, 'Turno')) Then SalesHeaderT.Turno := 1;
            SalesHeaderT."Bill-to Customer No." := GetValueAsText(JToken, 'Bill_to_Customer_No_');
            SalesHeaderT."Bill-to Name" := GetValueAsText(JToken, 'Bill_to_Name');
            SalesHeaderT."Bill-to Name 2" := GetValueAsText(JToken, 'Bill_to_Name_2');
            SalesHeaderT."Bill-to Address" := GetValueAsText(JToken, 'Bill_to_Address');
            SalesHeaderT."Bill-to Address 2" := GetValueAsText(JToken, 'Bill_to_Address_2');
            SalesHeaderT."Bill-to City" := GetValueAsText(JToken, 'Bill_to_City');
            SalesHeaderT."Bill-to Contact" := GetValueAsText(JToken, 'Bill_to_Contact');
            SalesHeaderT."Sell-to Customer No." := GetValueAsText(JToken, 'Sell_to_Customer_No_');
            SalesHeaderT."Sell-to Customer Name" := GetValueAsText(JToken, 'Sell_to_Customer_Name');
            SalesHeaderT."Sell-to Customer Name 2" := GetValueAsText(JToken, 'Sell_to_Customer_Name_2');
            SalesHeaderT."Sell-to Address" := GetValueAsText(JToken, 'Sell_to_Address');
            SalesHeaderT."Sell-to Address 2" := GetValueAsText(JToken, 'Sell_to_Address_2');
            SalesHeaderT."Sell-to City" := GetValueAsText(JToken, 'Sell_to_City');
            SalesHeaderT."Sell-to Contact" := GetValueAsText(JToken, 'Sell_to_Contact');
            SalesHeaderT."Your Reference" := GetValueAsText(JToken, 'Your_Reference');
            SalesHeaderT."Ship-to Code" := GetValueAsText(JToken, 'Ship_to_Code');
            SalesHeaderT."Ship-to Name" := GetValueAsText(JToken, 'Ship_to_Name');
            SalesHeaderT."Ship-to Name 2" := GetValueAsText(JToken, 'Ship_to_Name_2');
            SalesHeaderT."Ship-to Address" := GetValueAsText(JToken, 'Ship_to_Address');
            SalesHeaderT."Ship-to Address 2" := GetValueAsText(JToken, 'Ship_to_Address_2');
            SalesHeaderT."Ship-to City" := GetValueAsText(JToken, 'Ship_to_City');
            SalesHeaderT."Ship-to Contact" := GetValueAsText(JToken, 'Ship_to_Contact');
            SalesHeaderT."Cupon de descuento" := GetValueAsText(JToken, 'Cupon');
            TipoDetalle := GetValueAsText(JToken, 'Tipo_Detalle');
            Case TipoDetalle of
                'TPV':
                    SalesHeaderT."Tipo Detalle" := SalesHeaderT."Tipo Detalle"::TPV;
                'Cliente':
                    SalesHeaderT."Tipo Detalle" := SalesHeaderT."Tipo Detalle"::Cliente;
                'GrupoCliente':
                    SalesHeaderT."Tipo Detalle" := SalesHeaderT."Tipo Detalle"::GrupoCliente;
                'Colegio':
                    SalesHeaderT."Tipo Detalle" := SalesHeaderT."Tipo Detalle"::Colegio;
            end;
            SalesHeaderT."No. Detalle" := GetValueAsText(JToken, 'No_Detalle');
            If Evaluate(SalesHeaderT."Order Date", GetValueAsText(JToken, 'Order_Date')) Then;
            If Evaluate(SalesHeaderT."Posting Date", GetValueAsText(JToken, 'Posting_Date')) Then;
            If Evaluate(SalesHeaderT."Shipment Date", GetValueAsText(JToken, 'Shipment_Date')) Then;
            //Todas las fechas
            if Evaluate(SalesHeaderT."Due Date", GetValueAsText(JToken, 'Due_Date')) Then;
            if Evaluate(SalesHeaderT."Document Date", GetValueAsText(JToken, 'Document_Date')) Then;
            If Evaluate(SalesHeaderT."VAT Reporting Date", GetValueAsText(JToken, 'Posting_Date')) Then;

            // If Evaluate(SalesHeaderT."Quote Accepted Date",GetValueAsText(JToken,'Quote Accepted Date')) Then;
            // If Evaluate(SalesHeaderT."Requested Delivery Date",GetValueAsText(JToken,'Requested Delivery Date')) Then;
            // If Evaluate(SalesHeaderT."Promised Delivery Date",GetValueAsText(JToken,'Promised Delivery Date')) Then;

            SalesHeaderT."Posting Description" := GetValueAsText(JToken, 'Posting_Description');
            SalesHeaderT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Code');
            if SalesHeaderT."Payment Method Code" = '' then
                SalesHeaderT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Id');

            If Evaluate(SalesHeaderT."Due Date", GetValueAsText(JToken, 'Due_Date')) Then;
            SalesHeaderT."Payment Discount %" := GetValueAsDecimal(JToken, 'Payment_Discount__');
            //SalesHeaderT."Pmt. Discount Date":=GetValueAsText(JToken, 'Pmt__Discount_Date');
            SalesHeaderT."Shipment Method Code" := GetValueAsText(JToken, 'Shipment_Method_Code');
            SalesHeaderT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            SalesHeaderT."Shortcut Dimension 1 Code" := GetValueAsText(JToken, 'Shortcut_Dimension_1_Code');
            SalesHeaderT."Shortcut Dimension 2 Code" := GetValueAsText(JToken, 'Shortcut_Dimension_2_Code');
            SalesHeaderT."Customer Posting Group" := GetValueAsText(JToken, 'Customer_Posting_Group');
            SalesHeaderT."Currency Code" := GetValueAsText(JToken, 'Currency_Code');
            SalesHeaderT."Currency Factor" := GetValueAsDecimal(JToken, 'Currency_Factor');
            SalesHeaderT."Customer Price Group" := GetValueAsText(JToken, 'Customer_Price_Group');
            SalesHeaderT."Prices Including VAT" := GetValueAsBoolean(JToken, 'Prices_Including_VAT');
            SalesHeaderT."Invoice Disc. Code" := GetValueAsText(JToken, 'Invoice_Disc__Code');
            SalesHeaderT."Customer Disc. Group" := GetValueAsText(JToken, 'Customer_Disc__Group');
            SalesHeaderT."Language Code" := GetValueAsText(JToken, 'Language_Code');
            SalesHeaderT."Salesperson Code" := GetValueAsText(JToken, 'Salesperson_Code');
            SalesHeaderT."Order Class" := GetValueAsText(JToken, 'Order_Class');
            //SalesHeaderT."No. Printed":=GetValueAsText(JToken, 'No__Printed');
            SalesHeaderT."On Hold" := GetValueAsText(JToken, 'On_Hold');
            //SalesHeaderT."Applies-to Doc. Type":=GetValueAsText(JToken, 'Applies_to_Doc__Type');
            SalesHeaderT."Applies-to Doc. No." := GetValueAsText(JToken, 'Applies_to_Doc__No_');
            SalesHeaderT."Bal. Account No." := GetValueAsText(JToken, 'Bal__Account_No_');
            // SalesHeaderT."Ship":=GetValueAsText(JToken, 'Ship');
            // SalesHeaderT."Invoice":=GetValueAsText(JToken, 'Invoice');
            //SalesHeaderT."Print Posted Documents":=GetValueAsText(JToken, 'Print_Posted_Documents');
            SalesHeaderT."Shipping No." := GetValueAsText(JToken, 'Shipping_No_');
            SalesHeaderT."Posting No." := GetValueAsText(JToken, 'Posting_No_');
            SalesHeaderT."Last Shipping No." := GetValueAsText(JToken, 'Last_Shipping_No_');
            SalesHeaderT."Last Posting No." := GetValueAsText(JToken, 'Last_Posting_No_');
            SalesHeaderT."Prepayment No." := GetValueAsText(JToken, 'Prepayment_No_');
            SalesHeaderT."Last Prepayment No." := GetValueAsText(JToken, 'Last_Prepayment_No_');
            SalesHeaderT."Prepmt. Cr. Memo No." := GetValueAsText(JToken, 'Prepmt__Cr__Memo_No_');
            SalesHeaderT."Last Prepmt. Cr. Memo No." := GetValueAsText(JToken, 'Last_Prepmt__Cr__Memo_No_');
            SalesHeaderT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            // SalesHeaderT."Combine Shipments":=GetValueAsText(JToken, 'Combine_Shipments');
            SalesHeaderT."Reason Code" := GetValueAsText(JToken, 'Reason_Code');
            SalesHeaderT."Gen. Bus. Posting Group" := GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            SalesHeaderT."EU 3-Party Trade" := GetValueAsBoolean(JToken, 'EU_3_Party_Trade');
            SalesHeaderT."Transaction Type" := GetValueAsText(JToken, 'Transaction_Type');
            SalesHeaderT."Transport Method" := GetValueAsText(JToken, 'Transport_Method');
            SalesHeaderT."VAT Country/Region Code" := GetValueAsText(JToken, 'VAT_Country_Region_Code');
            SalesHeaderT."Sell-to Customer Name" := GetValueAsText(JToken, 'Sell_to_Customer_Name');
            SalesHeaderT."Sell-to Customer Name 2" := GetValueAsText(JToken, 'Sell_to_Customer_Name_2');
            SalesHeaderT."Sell-to Address" := GetValueAsText(JToken, 'Sell_to_Address');
            SalesHeaderT."Sell-to Address 2" := GetValueAsText(JToken, 'Sell_to_Address_2');
            SalesHeaderT."Sell-to City" := GetValueAsText(JToken, 'Sell_to_City');
            SalesHeaderT."Sell-to Contact" := GetValueAsText(JToken, 'Sell_to_Contact');
            SalesHeaderT."Bill-to Post Code" := GetValueAsText(JToken, 'Bill_to_Post_Code');
            SalesHeaderT."Bill-to County" := GetValueAsText(JToken, 'Bill_to_County');
            SalesHeaderT."Bill-to Country/Region Code" := GetValueAsText(JToken, 'Bill_to_Country_Region_Code');
            SalesHeaderT."Sell-to Post Code" := GetValueAsText(JToken, 'Sell_to_Post_Code');
            SalesHeaderT."Sell-to County" := GetValueAsText(JToken, 'Sell_to_County');
            SalesHeaderT."Sell-to Country/Region Code" := GetValueAsText(JToken, 'Sell_to_Country_Region_Code');
            SalesHeaderT."Ship-to Post Code" := GetValueAsText(JToken, 'Ship_to_Post_Code');
            SalesHeaderT."Ship-to County" := GetValueAsText(JToken, 'Ship_to_County');
            SalesHeaderT."Ship-to Country/Region Code" := GetValueAsText(JToken, 'Ship_to_Country_Region_Code');
            // SalesHeaderT."Bal. Account Type":=GetValueAsText(JToken, 'Bal__Account_Type');
            SalesHeaderT."Exit Point" := GetValueAsText(JToken, 'Exit_Point');
            //SalesHeaderT."Correction":=GetValueAsText(JToken, 'Correction');
            If Evaluate(SalesHeaderT."Document Date", GetValueAsText(JToken, 'Document_Date')) then;
            SalesHeaderT."External Document No." := GetValueAsText(JToken, 'External_Document_No_');
            SalesHeaderT."Area" := GetValueAsText(JToken, 'SalesHeaderArea');
            SalesHeaderT."Transaction Specification" := GetValueAsText(JToken, 'Transaction_Specification');
            SalesHeaderT."Payment Method Code" := GetValueAsText(JToken, 'Payment_Method_Code');
            SalesHeaderT."Shipping Agent Code" := GetValueAsText(JToken, 'Shipping_Agent_Code');
            //SalesHeaderT."Package Tracking No." := GetValueAsText(JToken, 'Package_Tracking_No_');
            SalesHeaderT."No. Series" := GetValueAsText(JToken, 'No__Series');
            SalesHeaderT."Posting No. Series" := GetValueAsText(JToken, 'Posting_No__Series');
            SalesHeaderT."Shipping No. Series" := GetValueAsText(JToken, 'Shipping_No__Series');
            SalesHeaderT."Tax Area Code" := GetValueAsText(JToken, 'Tax_Area_Code');
            // SalesHeaderT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            SalesHeaderT."VAT Bus. Posting Group" := GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            // SalesHeaderT."Reserve":=GetValueAsText(JToken, 'Reserve');
            SalesHeaderT."Applies-to ID" := GetValueAsText(JToken, 'Applies_to_ID');
            // SalesHeaderT."VAT Base Discount %":=GetValueAsText(JToken, 'VAT_Base_Discount__');
            // SalesHeaderT."Status":=GetValueAsText(JToken, 'Status');
            // SalesHeaderT."Invoice Discount Calculation":=GetValueAsText(JToken, 'Invoice_Discount_Calculation');
            // SalesHeaderT."Invoice Discount Value":=GetValueAsText(JToken, 'Invoice_Discount_Value');
            // SalesHeaderT."Send IC Document":=GetValueAsText(JToken, 'Send_IC_Document');
            // SalesHeaderT."IC Status":=GetValueAsText(JToken, 'IC_Status');
            SalesHeaderT."Sell-to IC Partner Code" := GetValueAsText(JToken, 'Sell_to_IC_Partner_Code');
            SalesHeaderT."Bill-to IC Partner Code" := GetValueAsText(JToken, 'Bill_to_IC_Partner_Code');
            // SalesHeaderT."IC Direction":=GetValueAsText(JToken, 'IC_Direction');
            SalesHeaderT."Prepayment %" := GetValueAsDecimal(JToken, 'Prepayment__');
            SalesHeaderT."Prepayment No. Series" := GetValueAsText(JToken, 'Prepayment_No__Series');
            // SalesHeaderT."Compress Prepayment":=GetValueAsText(JToken, 'Compress_Prepayment');
            // SalesHeaderT."Prepayment Due Date":=GetValueAsText(JToken, 'Prepayment_Due_Date');
            // SalesHeaderT."Prepmt. Cr. Memo No. Series":=GetValueAsText(JToken, 'Prepmt__Cr__Memo_No__Series');
            // SalesHeaderT."Prepmt. Posting Description":=GetValueAsText(JToken, 'Prepmt__Posting_Description');
            // SalesHeaderT."Prepmt. Pmt. Discount Date":=GetValueAsText(JToken, 'Prepmt__Pmt__Discount_Date');
            // SalesHeaderT."Prepmt. Payment Terms Code":=GetValueAsText(JToken, 'Prepmt__Payment_Terms_Code');
            // SalesHeaderT."Prepmt. Payment Discount %":=GetValueAsText(JToken, 'Prepmt__Payment_Discount__');
            SalesHeaderT."Quote No." := GetValueAsText(JToken, 'Quote_No_');
            // SalesHeaderT."Quote Valid Until Date":=GetValueAsText(JToken, 'Quote_Valid_Until_Date');
            // SalesHeaderT."Quote Sent to Customer":=GetValueAsText(JToken, 'Quote_Sent_to_Customer');
            // SalesHeaderT."Quote Accepted":=GetValueAsText(JToken, 'Quote_Accepted');
            // SalesHeaderT."Quote Accepted Date":=GetValueAsText(JToken, 'Quote_Accepted_Date');
            // SalesHeaderT."Job Queue Status":=GetValueAsText(JToken, 'Job_Queue_Status');
            // SalesHeaderT."Job Queue Entry ID":=GetValueAsText(JToken, 'Job_Queue_Entry_ID');
            SalesHeaderT."Company Bank Account Code" := GetValueAsText(JToken, 'Company_Bank_Account_Code');
            // SalesHeaderT."Incoming Document Entry No.":=GetValueAsText(JToken, 'Incoming_Document_Entry_No_');
            // SalesHeaderT."IsTest":=GetValueAsText(JToken, 'IsTest');
            SalesHeaderT."Sell-to Phone No." := GetValueAsText(JToken, 'Sell_to_Phone_No_');
            SalesHeaderT."Sell-to E-Mail" := GetValueAsText(JToken, 'Sell_to_E_Mail');
            SalesHeaderT."Journal Templ. Name" := GetValueAsText(JToken, 'Journal_Templ__Name');
            // SalesHeaderT."Work Description":=GetValueAsText(JToken, 'Work_Description');
            // SalesHeaderT."Dimension Set ID":=GetValueAsText(JToken, 'Dimension_Set_ID');
            // SalesHeaderT."Payment Service Set ID":=GetValueAsText(JToken, 'Payment_Service_Set_ID');
            // SalesHeaderT."Direct Debit Mandate ID":=GetValueAsText(JToken, 'Direct_Debit_Mandate_ID');
            // SalesHeaderT."Doc. No. Occurrence":=GetValueAsText(JToken, 'Doc__No__Occurrence');
            SalesHeaderT."Campaign No." := GetValueAsText(JToken, 'Campaign_No_');
            SalesHeaderT."Sell-to Contact No." := GetValueAsText(JToken, 'Sell_to_Contact_No_');
            SalesHeaderT."Bill-to Contact No." := GetValueAsText(JToken, 'Bill_to_Contact_No_');
            SalesHeaderT."Opportunity No." := GetValueAsText(JToken, 'Opportunity_No_');
            SalesHeaderT."Sell-to Customer Templ. Code" := GetValueAsText(JToken, 'Sell_to_Customer_Templ__Code');
            SalesHeaderT."Bill-to Customer Templ. Code" := GetValueAsText(JToken, 'Bill_to_Customer_Templ__Code');
            SalesHeaderT."Responsibility Center" := GetValueAsText(JToken, 'Responsibility_Center');
            // SalesHeaderT."Shipping Advice":=GetValueAsText(JToken, 'Shipping_Advice');
            // SalesHeaderT."Posting from Whse. Ref.":=GetValueAsText(JToken, 'Posting_from_Whse__Ref_');
            // SalesHeaderT."Requested Delivery Date":=GetValueAsText(JToken, 'Requested_Delivery_Date');
            // SalesHeaderT."Promised Delivery Date":=GetValueAsText(JToken, 'Promised_Delivery_Date');
            // SalesHeaderT."Shipping Time":=GetValueAsText(JToken, 'Shipping_Time');
            // SalesHeaderT."Outbound Whse. Handling Time":=GetValueAsText(JToken, 'Outbound_Whse__Handling_Time');
            // SalesHeaderT."Shipping Agent Service Code":=GetValueAsText(JToken, 'Shipping_Agent_Service_Code');
            // SalesHeaderT."Receive":=GetValueAsText(JToken, 'Receive');
            SalesHeaderT."Return Receipt No." := GetValueAsText(JToken, 'Return_Receipt_No_');
            SalesHeaderT."Return Receipt No. Series" := GetValueAsText(JToken, 'Return_Receipt_No__Series');
            SalesHeaderT."Last Return Receipt No." := GetValueAsText(JToken, 'Last_Return_Receipt_No_');
            // SalesHeaderT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            // SalesHeaderT."Allow Line Disc.":=GetValueAsText(JToken, 'Allow_Line_Disc_');
            // SalesHeaderT."Get Shipment Used":=GetValueAsText(JToken, 'Get_Shipment_Used');
            SalesHeaderT."Assigned User ID" := GetValueAsText(JToken, 'Assigned_User_ID');
            //SalesHeaderT."Corrected Invoice No." := GetValueAsText(JToken, 'Corrected_Invoice_No_');
            //SalesHeaderT."Due Date Modified":=GetValueAsText(JToken, 'Due_Date_Modified');
            // SalesHeaderT."Invoice Type":=GetValueAsText(JToken, 'Invoice_Type');
            // SalesHeaderT."Cr. Memo Type":=GetValueAsText(JToken, 'Cr__Memo_Type');
            IdSpecial := GetValueAsText(JToken, 'Special_Scheme_Code');

            SalesHeaderT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            SalesHeaderT."Importe total" := GetValueAsDecimal(JToken, 'importe_total');
            //Dto e imporrte Dto;
            SalesHeaderT."Invoice Discount Value" := GetValueAsDecimal(JToken, 'Dto');
            SalesHeaderT."Invoice Discount Amount" := GetValueAsDecimal(JToken, 'importeDto');
            If SalesHeaderT."No." <> '' Then Error('Falta implementar la mod. de un pedido');
            Pedido := SalesHeaderT;
            Pedido."No." := '';
            Pedido.Insert(true);
            Pedido.Validate("Sell-to Customer No.");
            If SalesHeaderT.Colegio <> '' then
                Pedido.Colegio := SalesHeaderT.Colegio;
            If SalesHeaderT.Tpv <> '' then
                Pedido.TPV := SalesHeaderT.TPv;
            if SalesHeaderT.Tienda <> '' then
                Pedido.Tienda := SalesHeaderT.Tienda;
            SalesHeaderT."Venta TPV" := true;
            If SalesHeaderT.Turno <> 0 then
                Pedido.Turno := SalesHeaderT.Turno;
            if SalesHeaderT."Bill-to Customer No." <> '' then
                Pedido."Bill-to Customer No." := SalesHeaderT."Bill-to Customer No.";
            if SalesHeaderT."Bill-to Name" <> '' then
                Pedido."Bill-to Name" := SalesHeaderT."Bill-to Name";
            if SalesHeaderT."Bill-to Name 2" <> '' then
                Pedido."Bill-to Name 2" := SalesHeaderT."Bill-to Name 2";
            if SalesHeaderT."Bill-to Address" <> '' then
                Pedido."Bill-to Address" := SalesHeaderT."Bill-to Address";
            if SalesHeaderT."Bill-to Address 2" <> '' then
                Pedido."Bill-to Address 2" := SalesHeaderT."Bill-to Address 2";
            if SalesHeaderT."Bill-to City" <> '' then
                Pedido."Bill-to City" := SalesHeaderT."Bill-to City";
            if SalesHeaderT."Bill-to Contact" <> '' then
                Pedido."Bill-to Contact" := SalesHeaderT."Bill-to Contact";
            if SalesHeaderT."Bill-to Post Code" <> '' then
                Pedido."Bill-to Post Code" := SalesHeaderT."Bill-to Post Code";
            if SalesHeaderT."Bill-to County" <> '' then
                Pedido."Bill-to County" := SalesHeaderT."Bill-to County";
            if SalesHeaderT."Bill-to Country/Region Code" <> '' then
                Pedido."Bill-to Country/Region Code" := SalesHeaderT."Bill-to Country/Region Code";
            If SalesHeaderT."Payment Method Code" <> '' then
                Pedido.Validate("Payment Method Code", SalesHeaderT."Payment Method Code");
            if SalesHeaderT."Posting Date" <> 0D Then
                Pedido.Validate("Posting Date", SalesHeaderT."Posting Date");
            If SalesHeadert."Order Date" <> 0D Then
                Pedido."Order Date" := SalesHeaderT."Order Date";
            if SalesHeaderT."Document Date" <> 0D Then
                Pedido."Document Date" := SalesHeaderT."Document Date";
            if salesHeaderT."Shipment Date" <> 0D Then
                Pedido."Shipment Date" := SalesHeaderT."Shipment Date";
            If SalesHeaderT."Requested Delivery Date" <> 0D Then
                Pedido."Requested Delivery Date" := SalesHeaderT."Requested Delivery Date";
            if SalesHeaderT."Sell-to Customer Name" <> '' then
                Pedido."Sell-to Customer Name" := SalesHeaderT."Sell-to Customer Name";
            if SalesHeaderT."Sell-to Customer Name 2" <> '' then
                Pedido."Sell-to Customer Name 2" := SalesHeaderT."Sell-to Customer Name 2";
            if SalesHeaderT."Sell-to Address" <> '' then
                Pedido.Validate("Sell-to Address", SalesHeaderT."Sell-to Address");
            if SalesHeaderT."Sell-to Address 2" <> '' then
                Pedido.Validate("Sell-to Address 2", SalesHeaderT."Sell-to Address 2");
            if SalesHeaderT."Sell-to City" <> '' then
                Pedido.Validate("Sell-to City", SalesHeaderT."Sell-to City");
            if SalesHeaderT."Sell-to Contact" <> '' then
                Pedido.Validate("Sell-to Contact", SalesHeaderT."Sell-to Contact");
            if SalesHeaderT."Sell-to Phone No." <> '' then
                Pedido.Validate("Sell-to Phone No.", SalesHeaderT."Sell-to Phone No.");
            if SalesHeaderT."Sell-to E-Mail" <> '' then
                Pedido.Validate("Sell-to E-Mail", SalesHeaderT."Sell-to E-Mail");
            if SalesHeaderT."Sell-to Post Code" <> '' then
                Pedido.Validate("Sell-to Post Code", SalesHeaderT."Sell-to Post Code");
            if SalesHeaderT."Sell-to County" <> '' then
                Pedido.Validate("Sell-to County", SalesHeaderT."Sell-to County");
            if SalesHeaderT."Sell-to Country/Region Code" <> '' then
                Pedido.Validate("Sell-to Country/Region Code", SalesHeaderT."Sell-to Country/Region Code");
            if SalesHeaderT."Bill-to County" <> '' then
                Pedido.Validate("Bill-to County", SalesHeaderT."Bill-to County");
            if SalesHeaderT."Bill-to Country/Region Code" <> '' then
                Pedido.Validate("Bill-to Country/Region Code", SalesHeaderT."Bill-to Country/Region Code");
            if SalesHeaderT."VAT Registration No." <> '' then
                Pedido."VAT Registration No." := SalesHeaderT."VAT Registration No.";
            //fechas
            if SalesHeaderT."Due Date" <> 0D Then
                Pedido."Due Date" := SalesHeaderT."Due Date";
            if SalesHeaderT."Quote Valid Until Date" <> 0D Then
                Pedido."Quote Valid Until Date" := SalesHeaderT."Quote Valid Until Date";
            if SalesHeaderT."Quote Accepted Date" <> 0D Then
                Pedido."Quote Accepted Date" := SalesHeaderT."Quote Accepted Date";
            if SalesHeaderT."Prepayment Due Date" <> 0D Then
                Pedido."Prepayment Due Date" := SalesHeaderT."Prepayment Due Date";
            if SalesHeaderT."Prepmt. Pmt. Discount Date" <> 0D Then
                Pedido."Prepmt. Pmt. Discount Date" := SalesHeaderT."Prepmt. Pmt. Discount Date";
            if SalesHeaderT."Requested Delivery Date" <> 0D Then
                Pedido."Requested Delivery Date" := SalesHeaderT."Requested Delivery Date";
            if SalesHeaderT."Promised Delivery Date" <> 0D Then
                Pedido."Promised Delivery Date" := SalesHeaderT."Promised Delivery Date";
            if SalesHeaderT."Posting Date" <> 0D Then
                Pedido."Posting Date" := SalesHeaderT."Posting Date";
            if SalesHeaderT."Document Date" <> 0D Then
                Pedido."Document Date" := SalesHeaderT."Document Date";
            if SalesHeaderT."Shipment Date" <> 0D Then
                Pedido."Shipment Date" := SalesHeaderT."Shipment Date";
            if SalesHeaderT."Payment Terms Code" <> '' then
                Pedido."Payment Terms Code" := SalesHeaderT."Payment Terms Code";
            if SalesHeaderT."Posting Description" <> '' then
                Pedido."Posting Description" := SalesHeaderT."Posting Description";
            Pedido."Importe total" := SalesHeaderT."Importe total";
            if SalesHeaderT.TPV <> '' then
                Pedido.TPV := SalesHeaderT.TPV;
            if SalesHeaderT."Invoice Discount Value" <> 0 Then
                Pedido."Invoice Discount Value" := SalesHeaderT."Invoice Discount Value";
            if SalesHeaderT."Invoice Discount Amount" <> 0 Then
                Pedido."Invoice Discount Amount" := SalesHeaderT."Invoice Discount Amount";
            if SalesHeaderT."Cupon de descuento" <> '' then
                Pedido."Cupon de descuento" := SalesHeaderT."Cupon de descuento";
            Pedido."Tipo Detalle" := SalesHeaderT."Tipo Detalle";
            if SalesHeaderT."No. Detalle" <> '' then
                Pedido."No. Detalle" := SalesHeaderT."No. Detalle";
            Pedido.Modify();
            SalesHeaderT."No." := Pedido."No.";

        end;
        Exit(SalesHeaderT."No.")
    end;
    /// <summary>
    /// insertaLineasFacturasVenta.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaLineasFacturasVenta(Data: Text): Text
    var
        JLPedidoToken: JsonToken;
        JLPedidoObj: JsonObject;
        JLFacturas: JsonArray;
        JLPedido: JsonObject;
        SalesLineT: Record "Sales Line" temporary;
        SalesHeader: Record "Sales Header";
        JToken: JsonToken;
        Texto: Text;
        RecRef2: RecordRef;
        VendorRecRef: RecordRef;
        PurchSetup: Record 312;
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        NoSeriesMgt: Codeunit "No. Series";
        VendorTempl: Record "Vendor Templ.";
        VendorFldRef: FieldRef;
        VendRecRef: RecordRef;
        EmptyVendorRecRef: RecordRef;
        EmptyVendorTemplRecRef: RecordRef;
        VendFldRef: FieldRef;
        EmptyVendFldRef: FieldRef;
        VendorTemplFldRef: FieldRef;
        EmptyVendorFldRef: FieldRef;
        i: Integer;
        FacturasL: Record "Sales Line";
        Linea: Integer;
        DocumentTotals: Codeunit "Document Totals";
        AmountWithDiscountAllowed: Decimal;
        InvoiceDiscountAmount: Decimal;
        Currency: Record Currency;
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";
        TotalSalesLine: Record "Sales Line";
        Amount: Decimal;
        ConfIva: Record "VAT Posting Setup";
        base: Decimal;
        rConf: Record "Config. Empresa";
    begin
        If not rConf.Get then begin
            rConf.Init();
            rConf.Insert();
        end;

        JLPedidoToken.ReadFrom(Data);
        JLPedidoObj := JLPedidoToken.AsObject();


        JLPedidoObj.SelectToken('Sales_Lines', JLPedidoToken);
        JLFacturas := JLPedidoToken.AsArray();
        foreach JToken in JLFacturas do begin
            Texto := GetValueAsText(JToken, 'Document_Type');
            case Texto Of
                'Invoice', 'Factura':
                    SalesLineT."Document Type" := SalesLineT."Document Type"::Invoice;
                'Credit Memo', 'Nota de Crédito', 'Abono', 'Credit Note':
                    SalesLineT."Document Type" := SalesLineT."Document Type"::"Credit Memo";
            end;
            If SalesHeader.Get(SalesLineT."Document Type", SalesLineT."Document No.") Then
                SalesLineT."Sell-to Customer No." := SalesHeader."Sell-to Customer No."
            else
                SalesLineT."Sell-to Customer No." := GetValueAsText(JToken, 'Sell_to_Customer_No_');
            SalesLineT."Document No." := GetValueAsText(JToken, 'Document_No_');
            //Linea += 10000;
            SalesLineT."Line No." := GetValueAsInteger(JToken, 'Line_No_');
            Texto := GetValueAsText(JToken, 'Type');
            Case Texto Of
                ' ':
                    SalesLineT."Type" := "Sales Line Type"::" ";
                'Charge (Item)', 'Cargo':
                    SalesLineT."Type" := "Sales Line Type"::"Charge (Item)";
                'Fixed Asset', 'Activo Fijo':
                    SalesLineT."Type" := "Sales Line Type"::"Fixed Asset";
                'G/L Account', 'Cuenta':
                    SalesLineT."Type" := "Sales Line Type"::"G/L Account";
                'Item', 'Producto', 'Artículo':
                    SalesLineT."Type" := "Sales Line Type"::Item;
                'Resource', 'Recurso':
                    SalesLineT."Type" := "Sales Line Type"::Resource;
            End;
            SalesLineT."No." := GetValueAsText(JToken, 'No_');
            SalesLineT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            SalesLineT."Posting Group" := GetValueAsText(JToken, 'Posting_Group');
            SalesLineT."Description" := GetValueAsText(JToken, 'Description');
            SalesLineT."Description 2" := GetValueAsText(JToken, 'Description_2');
            SalesLineT."Unit of Measure" := GetValueAsText(JToken, 'Unit_of_Measure');
            SalesLineT."Quantity" := GetValueAsDecimal(JToken, 'Quantity');
            SalesLineT."VAT Prod. Posting Group" := GetValueAsText(JToken, 'VAT_Prod__Posting_Group');
            //SalesLineT."Outstanding Quantity":=GetValueAsText(JToken, 'Outstanding_Quantity');
            // SalesLineT."Qty. to Invoice":=GetValueAsText(JToken, 'Qty__to_Invoice');
            // SalesLineT."Qty. to Ship":=GetValueAsText(JToken, 'Qty__to_Ship');
            SalesLineT."Unit Price" := GetValueAsDecimal(JToken, 'Unit_Price');
            // SalesLineT."Unit Cost (LCY)":=GetValueAsText(JToken, 'Unit_Cost_LCY');
            // SalesLineT."VAT %":=GetValueAsText(JToken, 'VAT__');
            SalesLineT."Line Discount %" := GetValueAsDecimal(JToken, 'Line_Discount_');
            SalesLineT."Line Discount Amount" := GetValueAsDecimal(JToken, 'Line_Discount_Amount');
            // SalesLineT."Amount":=GetValueAsText(JToken, 'Amount');
            // SalesLineT."Amount Including VAT":=GetValueAsText(JToken, 'Amount_Including_VAT');
            // SalesLineT."Allow Invoice Disc.":=GetValueAsText(JToken, 'Allow_Invoice_Disc_');
            // SalesLineT."Gross Weight":=GetValueAsText(JToken, 'Gross_Weight');
            // SalesLineT."Net Weight":=GetValueAsText(JToken, 'Net_Weight');
            // SalesLineT."Units per Parcel":=GetValueAsText(JToken, 'Units_per_Parcel');
            // SalesLineT."Unit Volume":=GetValueAsText(JToken, 'Unit_Volume');
            // SalesLineT."Appl.-to Item Entry":=GetValueAsText(JToken, 'Appl__to_Item_Entry');
            // SalesLineT."Shortcut Dimension 1 Code":=GetValueAsText(JToken, 'Shortcut_Dimension_1_Code');
            // SalesLineT."Shortcut Dimension 2 Code":=GetValueAsText(JToken, 'Shortcut_Dimension_2_Code');
            // SalesLineT."Customer Price Group":=GetValueAsText(JToken, 'Customer_Price_Group');
            // SalesLineT."Job No.":=GetValueAsText(JToken, 'Job_No_');
            // SalesLineT."Work Type Code":=GetValueAsText(JToken, 'Work_Type_Code');
            // SalesLineT."Recalculate Invoice Disc.":=GetValueAsText(JToken, 'Recalculate_Invoice_Disc_');
            // SalesLineT."Outstanding Amount":=GetValueAsText(JToken, 'Outstanding_Amount');
            // SalesLineT."Qty. Shipped Not Invoiced":=GetValueAsText(JToken, 'Qty__Shipped_Not_Invoiced');
            // SalesLineT."Shipped Not Invoiced":=GetValueAsText(JToken, 'Shipped_Not_Invoiced');
            // SalesLineT."Quantity Shipped":=GetValueAsText(JToken, 'Quantity_Shipped');
            // SalesLineT."Quantity Invoiced":=GetValueAsText(JToken, 'Quantity_Invoiced');
            // SalesLineT."Shipment No.":=GetValueAsText(JToken, 'Shipment_No_');
            // SalesLineT."Shipment Line No.":=GetValueAsText(JToken, 'Shipment_Line_No_');
            // SalesLineT."Profit %":=GetValueAsText(JToken, 'Profit__');
            // SalesLineT."Bill-to Customer No.":=GetValueAsText(JToken, 'Bill_to_Customer_No_');
            // SalesLineT."Inv. Discount Amount":=GetValueAsText(JToken, 'Inv__Discount_Amount');
            // SalesLineT."Purchase Order No.":=GetValueAsText(JToken, 'Purchase_Order_No_');
            // SalesLineT."Purch. Order Line No.":=GetValueAsText(JToken, 'Purch__Order_Line_No_');
            // SalesLineT."Drop Shipment":=GetValueAsText(JToken, 'Drop_Shipment');
            // SalesLineT."Gen. Bus. Posting Group":=GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            // SalesLineT."Gen. Prod. Posting Group":=GetValueAsText(JToken, 'Gen__Prod__Posting_Group');
            // SalesLineT."VAT Calculation Type":=GetValueAsText(JToken, 'VAT_Calculation_Type');
            // SalesLineT."Transaction Type":=GetValueAsText(JToken, 'Transaction_Type');
            // SalesLineT."Transport Method":=GetValueAsText(JToken, 'Transport_Method');
            // SalesLineT."Attached to Line No.":=GetValueAsText(JToken, 'Attached_to_Line_No_');
            // SalesLineT."Exit Point":=GetValueAsText(JToken, 'Exit_Point');
            // SalesLineT."Area":=GetValueAsText(JToken, 'SalesLineArea');
            // SalesLineT."Transaction Specification":=GetValueAsText(JToken, 'Transaction_Specification');
            // SalesLineT."Tax Category":=GetValueAsText(JToken, 'Tax_Category');
            // SalesLineT."Tax Area Code":=GetValueAsText(JToken, 'Tax_Area_Code');
            // SalesLineT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            // SalesLineT."Tax Group Code":=GetValueAsText(JToken, 'Tax_Group_Code');
            // SalesLineT."VAT Clause Code":=GetValueAsText(JToken, 'VAT_Clause_Code');
            // SalesLineT."VAT Bus. Posting Group":=GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            // SalesLineT."VAT Prod. Posting Group":=GetValueAsText(JToken, 'VAT_Prod__Posting_Group');
            // SalesLineT."Currency Code":=GetValueAsText(JToken, 'Currency_Code');
            // SalesLineT."Outstanding Amount (LCY)":=GetValueAsText(JToken, 'Outstanding_Amount_LCY');
            // SalesLineT."Shipped Not Invoiced (LCY)":=GetValueAsText(JToken, 'Shipped_Not_Invoiced_LCY');
            // SalesLineT."Shipped Not Inv. (LCY) No VAT":=GetValueAsText(JToken, 'Shipped_Not_Inv__LCY_No_VAT');
            // SalesLineT."Reserve":=GetValueAsText(JToken, 'Reserve');
            // SalesLineT."Blanket Order No.":=GetValueAsText(JToken, 'Blanket_Order_No_');
            // SalesLineT."Blanket Order Line No.":=GetValueAsText(JToken, 'Blanket_Order_Line_No_');
            // SalesLineT."VAT Base Amount":=GetValueAsText(JToken, 'VAT_Base_Amount');
            // SalesLineT."Unit Cost":=GetValueAsText(JToken, 'Unit_Cost');
            // SalesLineT."System-Created Entry":=GetValueAsText(JToken, 'System_Created_Entry');
            // SalesLineT."Line Amount":=GetValueAsText(JToken, 'Line_Amount');
            // SalesLineT."VAT Difference":=GetValueAsText(JToken, 'VAT_Difference');
            // SalesLineT."Inv. Disc. Amount to Invoice":=GetValueAsText(JToken, 'Inv__Disc__Amount_to_Invoice');
            // SalesLineT."VAT Identifier":=GetValueAsText(JToken, 'VAT_Identifier');
            // SalesLineT."IC Partner Ref. Type":=GetValueAsText(JToken, 'IC_Partner_Ref__Type');
            // SalesLineT."IC Partner Reference":=GetValueAsText(JToken, 'IC_Partner_Reference');
            // SalesLineT."Prepayment %":=GetValueAsText(JToken, 'Prepayment__');
            // SalesLineT."Prepmt. Line Amount":=GetValueAsText(JToken, 'Prepmt__Line_Amount');
            // SalesLineT."Prepmt. Amt. Inv.":=GetValueAsText(JToken, 'Prepmt__Amt__Inv_');
            // SalesLineT."Prepmt. Amt. Incl. VAT":=GetValueAsText(JToken, 'Prepmt__Amt__Incl__VAT');
            // SalesLineT."Prepayment Amount":=GetValueAsText(JToken, 'Prepayment_Amount');
            // SalesLineT."Prepmt. VAT Base Amt.":=GetValueAsText(JToken, 'Prepmt__VAT_Base_Amt_');
            // SalesLineT."Prepayment VAT %":=GetValueAsText(JToken, 'Prepayment_VAT__');
            // SalesLineT."Prepayment VAT Identifier":=GetValueAsText(JToken, 'Prepayment_VAT_Identifier');
            // SalesLineT."Prepayment Tax Area Code":=GetValueAsText(JToken, 'Prepayment_Tax_Area_Code');
            // SalesLineT."Prepayment Tax Liable":=GetValueAsText(JToken, 'Prepayment_Tax_Liable');
            // SalesLineT."Prepayment Tax Group Code":=GetValueAsText(JToken, 'Prepayment_Tax_Group_Code');
            // SalesLineT."Prepmt Amt to Deduct":=GetValueAsText(JToken, 'Prepmt_Amt_to_Deduct');
            // SalesLineT."Prepmt Amt Deducted":=GetValueAsText(JToken, 'Prepmt_Amt_Deducted');
            // SalesLineT."Prepayment Line":=GetValueAsText(JToken, 'Prepayment_Line');
            // SalesLineT."Prepmt. Amount Inv. Incl. VAT":=GetValueAsText(JToken, 'Prepmt__Amount_Inv__Incl__VAT');
            // SalesLineT."Prepmt. Amount Inv. (LCY)":=GetValueAsText(JToken, 'Prepmt__Amount_Inv__LCY');
            // SalesLineT."IC Partner Code":=GetValueAsText(JToken, 'IC_Partner_Code');
            // SalesLineT."Prepmt. VAT Amount Inv. (LCY)":=GetValueAsText(JToken, 'Prepmt__VAT_Amount_Inv__LCY');
            // SalesLineT."Prepayment VAT Difference":=GetValueAsText(JToken, 'Prepayment_VAT_Difference');
            // SalesLineT."Prepmt VAT Diff. to Deduct":=GetValueAsText(JToken, 'Prepmt_VAT_Diff__to_Deduct');
            // SalesLineT."Prepmt VAT Diff. Deducted":=GetValueAsText(JToken, 'Prepmt_VAT_Diff__Deducted');
            // SalesLineT."IC Item Reference No.":=GetValueAsText(JToken, 'IC_Item_Reference_No_');
            // SalesLineT."Pmt. Discount Amount":=GetValueAsText(JToken, 'Pmt__Discount_Amount');
            // SalesLineT."Prepmt. Pmt. Discount Amount":=GetValueAsText(JToken, 'Prepmt__Pmt__Discount_Amount');
            // SalesLineT."Line Discount Calculation":=GetValueAsText(JToken, 'Line_Discount_Calculation');
            // SalesLineT."Dimension Set ID":=GetValueAsText(JToken, 'Dimension_Set_ID');
            // SalesLineT."Qty. to Assemble to Order":=GetValueAsText(JToken, 'Qty__to_Assemble_to_Order');
            // SalesLineT."Qty. to Asm. to Order (Base)":=GetValueAsText(JToken, 'Qty__to_Asm__to_Order_Base');
            // SalesLineT."Job Task No.":=GetValueAsText(JToken, 'Job_Task_No_');
            // SalesLineT."Job Contract Entry No.":=GetValueAsText(JToken, 'Job_Contract_Entry_No_');
            // SalesLineT."Deferral Code":=GetValueAsText(JToken, 'Deferral_Code');
            // SalesLineT."Returns Deferral Start Date":=GetValueAsText(JToken, 'Returns_Deferral_Start_Date');
            // SalesLineT."Variant Code":=GetValueAsText(JToken, 'Variant_Code');
            // SalesLineT."Bin Code":=GetValueAsText(JToken, 'Bin_Code');
            // SalesLineT."Qty. per Unit of Measure":=GetValueAsText(JToken, 'Qty__per_Unit_of_Measure');
            // SalesLineT."Planned":=GetValueAsText(JToken, 'Planned');
            // SalesLineT."Qty. Rounding Precision":=GetValueAsText(JToken, 'Qty__Rounding_Precision');
            // SalesLineT."Qty. Rounding Precision (Base)":=GetValueAsText(JToken, 'Qty__Rounding_Precision_Base');
            // SalesLineT."Unit of Measure Code":=GetValueAsText(JToken, 'Unit_of_Measure_Code');
            // SalesLineT."Quantity (Base)":=GetValueAsText(JToken, 'Quantity_Base');
            // SalesLineT."Outstanding Qty. (Base)":=GetValueAsText(JToken, 'Outstanding_Qty__Base');
            // SalesLineT."Qty. to Invoice (Base)":=GetValueAsText(JToken, 'Qty__to_Invoice_Base');
            // SalesLineT."Qty. to Ship (Base)":=GetValueAsText(JToken, 'Qty__to_Ship_Base');
            // SalesLineT."Qty. Shipped Not Invd. (Base)":=GetValueAsText(JToken, 'Qty__Shipped_Not_Invd__Base');
            // SalesLineT."Qty. Shipped (Base)":=GetValueAsText(JToken, 'Qty__Shipped_Base');
            // SalesLineT."Qty. Invoiced (Base)":=GetValueAsText(JToken, 'Qty__Invoiced_Base');
            // SalesLineT."Depreciation Book Code":=GetValueAsText(JToken, 'Depreciation_Book_Code');
            // SalesLineT."Depr. until FA Posting Date":=GetValueAsText(JToken, 'Depr__until_FA_Posting_Date');
            // SalesLineT."Duplicate in Depreciation Book":=GetValueAsText(JToken, 'Duplicate_in_Depreciation_Book');
            // SalesLineT."Use Duplication List":=GetValueAsText(JToken, 'Use_Duplication_List');
            // SalesLineT."Responsibility Center":=GetValueAsText(JToken, 'Responsibility_Center');
            // SalesLineT."Out-of-Stock Substitution":=GetValueAsText(JToken, 'Out_of_Stock_Substitution');
            // SalesLineT."Originally Ordered No.":=GetValueAsText(JToken, 'Originally_Ordered_No_');
            // SalesLineT."Originally Ordered Var. Code":=GetValueAsText(JToken, 'Originally_Ordered_Var__Code');
            // SalesLineT."Item Category Code":=GetValueAsText(JToken, 'Item_Category_Code');
            // SalesLineT."Nonstock":=GetValueAsText(JToken, 'Nonstock');
            // SalesLineT."Purchasing Code":=GetValueAsText(JToken, 'Purchasing_Code');
            // SalesLineT."Product Group Code":=GetValueAsText(JToken, 'Product_Group_Code');
            // SalesLineT."Special Order":=GetValueAsText(JToken, 'Special_Order');
            // SalesLineT."Special Order Purchase No.":=GetValueAsText(JToken, 'Special_Order_Purchase_No_');
            // SalesLineT."Special Order Purch. Line No.":=GetValueAsText(JToken, 'Special_Order_Purch__Line_No_');
            // SalesLineT."Item Reference No.":=GetValueAsText(JToken, 'Item_Reference_No_');
            // SalesLineT."Item Reference Unit of Measure":=GetValueAsText(JToken, 'Item_Reference_Unit_of_Measure');
            // SalesLineT."Item Reference Type":=GetValueAsText(JToken, 'Item_Reference_Type');
            // SalesLineT."Item Reference Type No.":=GetValueAsText(JToken, 'Item_Reference_Type_No_');
            // SalesLineT."Completely Shipped":=GetValueAsText(JToken, 'Completely_Shipped');
            // SalesLineT."Requested Delivery Date":=GetValueAsText(JToken, 'Requested_Delivery_Date');
            // SalesLineT."Promised Delivery Date":=GetValueAsText(JToken, 'Promised_Delivery_Date');
            // SalesLineT."Shipping Time":=GetValueAsText(JToken, 'Shipping_Time');
            // SalesLineT."Outbound Whse. Handling Time":=GetValueAsText(JToken, 'Outbound_Whse__Handling_Time');
            // SalesLineT."Planned Delivery Date":=GetValueAsText(JToken, 'Planned_Delivery_Date');
            // SalesLineT."Planned Shipment Date":=GetValueAsText(JToken, 'Planned_Shipment_Date');
            // SalesLineT."Shipping Agent Code":=GetValueAsText(JToken, 'Shipping_Agent_Code');
            // SalesLineT."Shipping Agent Service Code":=GetValueAsText(JToken, 'Shipping_Agent_Service_Code');
            // SalesLineT."Allow Item Charge Assignment":=GetValueAsText(JToken, 'Allow_Item_Charge_Assignment');
            // SalesLineT."Return Qty. to Receive":=GetValueAsText(JToken, 'Return_Qty__to_Receive');
            // SalesLineT."Return Qty. to Receive (Base)":=GetValueAsText(JToken, 'Return_Qty__to_Receive_Base');
            // SalesLineT."Return Qty. Rcd. Not Invd.":=GetValueAsText(JToken, 'Return_Qty__Rcd__Not_Invd_');
            // SalesLineT."Ret. Qty. Rcd. Not Invd.(Base)":=GetValueAsText(JToken, 'Ret__Qty__Rcd__Not_Invd_Base');
            // SalesLineT."Return Rcd. Not Invd.":=GetValueAsText(JToken, 'Return_Rcd__Not_Invd_');
            // SalesLineT."Return Rcd. Not Invd. (LCY)":=GetValueAsText(JToken, 'Return_Rcd__Not_Invd__LCY');
            // SalesLineT."Return Qty. Received":=GetValueAsText(JToken, 'Return_Qty__Received');
            // SalesLineT."Return Qty. Received (Base)":=GetValueAsText(JToken, 'Return_Qty__Received_Base');
            // SalesLineT."Appl.-from Item Entry":=GetValueAsText(JToken, 'Appl__from_Item_Entry');
            // SalesLineT."BOM Item No.":=GetValueAsText(JToken, 'BOM_Item_No_');
            // SalesLineT."Return Receipt No.":=GetValueAsText(JToken, 'Return_Receipt_No_');
            // SalesLineT."Return Receipt Line No.":=GetValueAsText(JToken, 'Return_Receipt_Line_No_');
            // SalesLineT."Return Reason Code":=GetValueAsText(JToken, 'Return_Reason_Code');
            // SalesLineT."Copied From Posted Doc.":=GetValueAsText(JToken, 'Copied_From_Posted_Doc_');
            // SalesLineT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            // SalesLineT."Allow Line Disc.":=GetValueAsText(JToken, 'Allow_Line_Disc_');
            // SalesLineT."Customer Disc. Group":=GetValueAsText(JToken, 'Customer_Disc__Group');
            // SalesLineT."Subtype":=GetValueAsText(JToken, 'Subtype');
            // SalesLineT."Price description":=GetValueAsText(JToken, 'Price_description');
            // SalesLineT."EC %":=GetValueAsText(JToken, 'EC__');
            // SalesLineT."EC Difference":=GetValueAsText(JToken, 'EC_Difference');
            // SalesLineT."Prepayment EC %":=GetValueAsText(JToken, 'Prepayment_EC__');
            // Hacer aqui las validaciones
            FacturasL := SaleslineT;
            If FacturasL.Insert() Then begin

                FacturasL.Validate("No.", SalesLineT."No.");
                If SalesLineT."VAT Prod. Posting Group" <> ' ' then
                    FacturasL.Validate("VAT Prod. Posting Group", SalesLineT."VAT Prod. Posting Group");
                FacturasL.Description := SalesLineT.Description;
                FacturasL."Description 2" := SalesLineT."Description 2";
                FacturasL.Validate(Quantity, SalesLineT.Quantity);
                FacturasL.Validate("Unit Price", SalesLineT."Unit Price");
                FacturasL.Validate("Line Discount %", SalesLineT."Line Discount %");
                FacturasL.Modify();

            end
        end;
        SalesHeader.Get(SalesLineT."Document Type", SalesLineT."Document No.");
        if SalesHeader."Invoice Discount Value" <> 0 then begin
            if SalesHeader."Currency Code" <> '' then
                Currency.Get(SalesHeader."Currency Code");
            FacturasL.SetRange("Document No.", SalesHeader."No.");
            FacturasL.SetRange("Document Type", SalesHeader."Document Type");
            FacturasL.ModifyAll("Allow Invoice Disc.", true);
            If FacturasL.FindSet() then
                repeat
                    Amount += ((FacturasL.Quantity * FacturasL."Unit Price") * (1 - FacturasL."Line Discount %" / 100));
                until FacturasL.Next() = 0;
            Commit();
            InvoiceDiscountAmount := Round(Amount * SalesHeader."Invoice Discount Value" / 100, Currency."Amount Rounding Precision");
            SalesCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, SalesHeader);
            Commit();
            SalesHeader.Get(SalesLineT."Document Type", SalesLineT."Document No.");
            //SalesHeader."Invoice Discount Value":=0;
            //SalesHeader."Posting Description" := 'Calculado' + Format(InvoiceDiscountAmount);
            //SalesHeader.Modify();
        end;
        exit('Ok');
    end;

    procedure GetValueAsText(JToken: JsonToken; ParamString: Text): Text
    var
        JObject: JsonObject;
    begin
        If JToken.IsObject() = false Then exit('');
        JObject := JToken.AsObject();
        exit(SelectJsonToken(JObject, ParamString));
    end;
    /// <summary>
    /// SelectJsonToken.
    /// </summary>
    /// <param name="JObject">JsonObject.</param>
    /// <param name="Path">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SelectJsonToken(JObject: JsonObject; Path: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if NOT JToken.AsValue().IsNull() then
                exit(JToken.AsValue().AsText());
    end;

    /// <summary>
    /// SelectJsonTokenBoolena.
    /// </summary>
    /// <param name="JObject">JsonObject.</param>
    /// <param name="Path">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SelectJsonTokenBoolena(JObject: JsonObject; Path: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if NOT JToken.AsValue().IsNull() then
                if Strlen(JToken.AsValue().AsText()) > 0 then
                    exit(JToken.AsValue().AsBoolean());
    end;

    /// <summary>
    /// SelectJsonTokenDecimal.
    /// </summary>
    /// <param name="JObject">JsonObject.</param>
    /// <param name="Path">Text.</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure SelectJsonTokenDecimal(JObject: JsonObject; Path: Text): Decimal
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if Strlen(JToken.AsValue().AsText()) > 0 then
                exit(JToken.AsValue().AsDecimal());
    end;

    /// <summary>
    /// SelectJsonTokenInteger.
    /// </summary>
    /// <param name="JObject">JsonObject.</param>
    /// <param name="Path">Text.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure SelectJsonTokenInteger(JObject: JsonObject; Path: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if Strlen(JToken.AsValue().AsText()) > 0 then
                if JToken.AsValue().AsInteger() <> 0 then
                    exit(JToken.AsValue().AsInteger());
    end;

    procedure SelectJsonTokenDate(JObject: JsonObject; Path: Text): Date
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if Strlen(JToken.AsValue().AsText()) > 0 then
                exit(JToken.AsValue().AsDate());
    end;
    /// <summary>
    /// GetValueAsBoolean: Extrae un valor booleano de un token JSON.
    /// Busca en el objeto JSON un parámetro con el nombre especificado y convierte su valor a booleano.
    /// </summary>
    /// <param name="JToken">Token JSON del que extraer el valor.</param>
    /// <param name="ParamString">Nombre del parámetro a extraer.</param>
    /// <returns>Valor como booleano del parámetro, o falso si no existe, es nulo o no es convertible a booleano.</returns>
    local procedure GetValueAsBoolean(JToken: JsonToken; ParamString: Text): Boolean
    var
        JObject: JsonObject;
    begin
        If JToken.IsObject() = false Then exit(false);
        JObject := JToken.AsObject();
        exit(SelectJsonTokenBoolena(JObject, ParamString));
    end;

    /// <summary>
    /// GetValueAsBoolean: Extrae un valor booleano de un token JSON.
    /// Busca en el objeto JSON un parámetro con el nombre especificado y convierte su valor a booleano.
    /// </summary>
    /// <param name="JToken">Token JSON del que extraer el valor.</param>
    /// <param name="ParamString">Nombre del parámetro a extraer.</param>
    /// <returns>Valor como decimal del parámetro, o 0 si no existe, es nulo o no es convertible a decimal.</returns>
    local procedure GetValueAsDecimal(JToken: JsonToken; ParamString: Text): Decimal
    var
        JObject: JsonObject;
    begin
        If JToken.IsObject() = false Then exit(0);
        JObject := JToken.AsObject();
        exit(SelectJsonTokenDecimal(JObject, ParamString));
    end;
    /// <summary>
    /// GetValueAsInteger: Extrae un valor entero de un token JSON.
    /// Busca en el objeto JSON un parámetro con el nombre especificado y convierte su valor a entero.
    /// </summary>
    /// <param name="JToken">Token JSON del que extraer el valor.</param>
    /// <param name="ParamString">Nombre del parámetro a extraer.</param>
    /// <returns>Valor como entero del parámetro, o 0 si no existe, es nulo o no es convertible a entero.</returns>
    local procedure GetValueAsInteger(JToken: JsonToken; ParamString: Text): Integer
    var
        JObject: JsonObject;
    begin
        If JToken.IsObject() = false Then exit(0);
        JObject := JToken.AsObject();
        exit(SelectJsonTokenInteger(JObject, ParamString));
    end;

    /// <summary>
    /// insertaEmpleados. Usuarios del Tpv
    /// </summary>
    /// <param name="Data">Text</param>
    /// <returns>Return value of type Text.</returns>

    [ServiceEnabled]
    procedure insertaEmpleados(Data: Text): Text
    var
        JEmpToken: JsonToken;
        JEmpObj: JsonObject;
        JEmps: JsonArray;
        JEmp: JsonObject;
        EmpT: Record Employee temporary;
        Emp: Record Employee;
        JToken: JsonToken;
        Texto: Text;
        EmpRecRef: RecordRef;
        EmployeeRecRef: RecordRef;
        EmptyEmpRecRef: RecordRef;
        EmpFldRef: FieldRef;
        EmptyEmpFldRef: FieldRef;
        i: Integer;
        Deleted: Boolean;
        EmployeeFldRef: FieldRef;
        HumanResSetup: Record "Human Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        JEmpToken.ReadFrom(Data);
        JEmpObj := JEmpToken.AsObject();

        JEmpObj.SelectToken('Employees', JEmpToken);
        JEmps := JEmpToken.AsArray();
        JEmps.WriteTo(Data);

        foreach JToken in JEmps do begin
            EmpT."No." := GetValueAsText(JToken, 'No_');
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            EmpT."First Name" := GetValueAsText(JToken, 'First_Name');
            EmpT."First Name" := GetValueAsText(JToken, 'Name');
            EmpT."Middle Name" := GetValueAsText(JToken, 'Second_Family_Name');
            EmpT."Last Name" := GetValueAsText(JToken, 'First_Family_Name');
            EmpT."Middle Name" := GetValueAsText(JToken, 'Middle_Name');
            EmpT."Last Name" := GetValueAsText(JToken, 'Last_Name');
            EmpT."Job Title" := GetValueAsText(JToken, 'Job_Title');
            EmpT."Search Name" := GetValueAsText(JToken, 'Search_Name');
            EmpT."Address" := GetValueAsText(JToken, 'Address');
            EmpT."Address 2" := GetValueAsText(JToken, 'Address_2');
            EmpT."City" := GetValueAsText(JToken, 'City');
            EmpT."Post Code" := GetValueAsText(JToken, 'Post_Code');
            EmpT."Country/Region Code" := GetValueAsText(JToken, 'Country_Region_Code');
            EmpT."Phone No." := GetValueAsText(JToken, 'Phone_No_');
            EmpT."Mobile Phone No." := GetValueAsText(JToken, 'Mobile_Phone_No_');
            EmpT."E-Mail" := GetValueAsText(JToken, 'E_Mail');
            EmpT."Company E-Mail" := GetValueAsText(JToken, 'Company_E_Mail');
            EmpT."Birth Date" := GetValueAsDate(JToken, 'Birth_Date');
            EmpT."Social Security No." := GetValueAsText(JToken, 'Social_Security_No_');
            EmpT."Union Code" := GetValueAsText(JToken, 'Union_Code');
            EmpT."Union Membership No." := GetValueAsText(JToken, 'Union_Membership_No_');
            EmpT."Manager No." := GetValueAsText(JToken, 'Manager_No_');
            EmpT."Emplymt. Contract Code" := GetValueAsText(JToken, 'Emplymt__Contract_Code');
            EmpT."Statistics Group Code" := GetValueAsText(JToken, 'Statistics_Group_Code');
            EmpT."Resource No." := GetValueAsText(JToken, 'Resource_No_');
            EmpT."Extension" := GetValueAsText(JToken, 'Extension');
            EmpT."Pager" := GetValueAsText(JToken, 'Pager');
            EmpT."Fax No." := GetValueAsText(JToken, 'Fax_No_');
            EmpT."Company E-Mail" := GetValueAsText(JToken, 'Company_E_Mail');
            EmpT."Alt. Address Code" := GetValueAsText(JToken, 'Alt__Address_Code');
            EmpT."County" := GetValueAsText(JToken, 'County');
            EmpT."Usuario TPV" := true; //GetValueAsBoolean(JToken, 'Usuario_TPV');
            EmpT.Password := GetValueAsText(JToken, 'Password');
            If (EmpT."No." = 'TEMP') or (EmpT."No." = '') Then begin

                HumanResSetup.Get();
                HumanResSetup.TestField("Employee Nos.");
                Emp := EmpT;
                Emp."No. Series" := HumanResSetup."Employee Nos.";
                Emp."No." := NoSeriesMgt.GetNextNo(HumanResSetup."Employee Nos.", Today, true);
                Emp.Insert();
                EmpT."No." := Emp."No.";

            end else begin
                if not Deleted then begin
                    EmployeeRecRef.Gettable(EmpT);
                    EmptyEmpRecRef.Open(Database::Employee);
                    EmptyEmpRecRef.Init();
                    if Emp.Get(EmpT."No.") then begin
                        EmpRecRef.GetTable(Emp);
                        for i := 1 to EmployeeRecRef.FieldCount do begin
                            EmployeeFldRef := EmployeeRecRef.FieldIndex(i);
                            EmpFldRef := EmpRecRef.Field(EmployeeFldRef.Number);
                            EmptyEmpFldRef := EmptyEmpRecRef.Field(EmployeeFldRef.Number);
                            if (EmployeeFldRef.Value <> EmptyEmpFldRef.Value) then
                                EmpFldRef.Value := EmployeeFldRef.Value;
                        end;
                        EmpRecRef.Modify();
                    end;
                    EmpRecRef.Close();
                    EmpT."No." := Emp."No.";
                end else begin
                    if Emp.Get(EmpT."No.") then
                        Emp.Delete();
                    EmpT."No." := '';
                end;
            end;
        end;
        exit(EmpT."No.");
    end;
    /// <summary>
    /// GetValueAsDate: Extrae un valor fecha de un token JSON.
    /// Busca en el objeto JSON un parámetro con el nombre especificado y convierte su valor a fecha.
    /// </summary>
    /// <param name="JToken">Token JSON del que extraer el valor.</param>
    /// <param name="ParamString">Nombre del parámetro a extraer.</param>
    /// <returns>Valor como fecha del parámetro, o 0D si no existe, es nulo o no es convertible a fecha.</returns>
    local procedure GetValueAsDate(JToken: JsonToken; ParamString: Text): Date
    var
        JObject: JsonObject;
        jValue: Text;
    begin
        If JToken.IsObject() = false Then exit(0D);
        JObject := JToken.AsObject();
        exit(SelectJsonTokenDate(JObject, ParamString));

    end;

    /// <summary>
    /// insertaBomComponent.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insesrtaBomComponent(Data: Text): Text
    var
        JBomToken: JsonToken;
        JBomObj: JsonObject;
        JLineas: JsonArray;
        JToken: JsonToken;
        BOMComponentTemp: Record "BOM Component" temporary;
        BOMComponent: Record "BOM Component";
        Item: Record Item;
        Resource: Record Resource;
        LastLineNo: Integer;
        i: Integer;
        Texto: Text;
        ParentItemNo: Text;
    begin
        //
        //{"Paren Item No.":"25",
        //"lineas"
        //[
        //{"no":"46",
        //"line_No":10000,
        //"type":"Item",
        //"Unit of Measure Code":"Ud",
        //"quantity";1
        //.....
        //}
        //]
        //}

        JBomToken.ReadFrom(Data);
        JBomObj := JBomToken.AsObject();

        if not JBomObj.Contains('Paren Item No.') then
            Error('El JSON debe contener el campo Paren Item No.');

        ParentItemNo := GetValueAsText(JBomToken, 'Paren Item No.');

        if not JBomObj.Contains('lineas') then
            Error('El JSON debe contener un array de lineas');

        JBomObj.SelectToken('lineas', JBomToken);
        JLineas := JBomToken.AsArray();

        if not Item.Get(ParentItemNo) then
            Error('Parent item %1 does not exist', ParentItemNo);

        // Delete all existing BOM components for this parent
        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.DeleteAll();

        foreach JToken in JLineas do begin
            BOMComponentTemp.Init();
            BOMComponentTemp."Parent Item No." := ParentItemNo;

            if GetValueAsInteger(JToken, 'line_No') <> 0 then
                BOMComponentTemp."Line No." := GetValueAsInteger(JToken, 'line_No')
            else begin
                // Find the last line number for this parent
                BOMComponent.Reset();
                BOMComponent.SetRange("Parent Item No.", ParentItemNo);
                if BOMComponent.FindLast() then
                    LastLineNo := BOMComponent."Line No." + 10000
                else
                    LastLineNo := 10000;

                BOMComponentTemp."Line No." := LastLineNo;
            end;

            // Set the type
            Texto := GetValueAsText(JToken, 'type');
            case Texto of
                'Item', 'Producto', 'Artículo':
                    BOMComponentTemp.Type := BOMComponentTemp.Type::Item;
                'Resource', 'Recurso':
                    BOMComponentTemp.Type := BOMComponentTemp.Type::Resource;
            end;

            BOMComponentTemp."No." := GetValueAsText(JToken, 'no');
            BOMComponentTemp.Description := GetValueAsText(JToken, 'Description');
            BOMComponentTemp."Unit of Measure Code" := GetValueAsText(JToken, 'Unit of Measure Code');
            BOMComponentTemp."Quantity per" := GetValueAsDecimal(JToken, 'quantity');
            BOMComponentTemp.Position := GetValueAsText(JToken, 'Position');
            BOMComponentTemp."Position 2" := GetValueAsText(JToken, 'Position_2');
            BOMComponentTemp."Position 3" := GetValueAsText(JToken, 'Position_3');
            BOMComponentTemp."Machine No." := GetValueAsText(JToken, 'Machine_No');
            BOMComponentTemp."Variant Code" := GetValueAsText(JToken, 'Variant_Code');

            // Check if component exists based on type
            if BOMComponentTemp.Type = BOMComponentTemp.Type::Item then begin
                if not Item.Get(BOMComponentTemp."No.") then
                    Error('Component item %1 does not exist', BOMComponentTemp."No.");
            end else if BOMComponentTemp.Type = BOMComponentTemp.Type::Resource then begin
                if not Resource.Get(BOMComponentTemp."No.") then
                    Error('Resource %1 does not exist', BOMComponentTemp."No.");
            end;

            // Insert new component
            BOMComponent.Init();
            BOMComponent.TransferFields(BOMComponentTemp);
            BOMComponent.Insert();
        end;

        exit(ParentItemNo);
    end;

    [ServiceEnabled]
    procedure insertaTurnos(Data: Text): Text
    var
        JTurnoToken: JsonToken;
        JTurnoObj: JsonObject;
        JTurnos: JsonArray;
        JToken: JsonToken;
        RecTurno: Record Turno;
        RecTurnoOld: Record Turno;
        RecTurnoTmp: Record Turno temporary;
        RecRef: RecordRef;
        TurnoCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        TurnoRecRef: RecordRef;
        EmptyTurnoRecRef: RecordRef;
        TTurnoRecRef: RecordRef;
        i: Integer;
        TurnoFldRef: FieldRef;
        TTurnoFldRef: FieldRef;
        EmptyTurnoFldRef: FieldRef;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
        T: Text;
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JTurnoToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JTurnoObj := JTurnoToken.AsObject();

        // Obtener el array de turnos
        if not JTurnoObj.Get('Turnos', JTurnoToken) then
            exit('No se encontró el array "Turnos" en el JSON.');

        JTurnos := JTurnoToken.AsArray();

        // Contadores para el resultado
        TurnoCount := 0;
        ErrorCount := 0;

        // Procesar cada turno
        foreach JToken in JTurnos do begin
            Clear(RecTurno);

            // Buscar si ya existe un turno con ese código
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            Clear(RecTurnoTmp);
            T := GetValueAsText(JToken, 'No');
            if T = '' then
                RecTurnoTmp.No := 0;
            If T = 'TEMP' then
                RecTurnoTmp.No := 0;
            If Evaluate(RecTurnoTmp.No, T) then;
            //RecTurnoTmp.No := GetValueAsInteger(JToken, 'No');
            // Verificar que el turno no esté vacío


            RecTurnoTMP.HorarioInicio := GetValueAsTime(JToken, 'HorarioInicio');
            RecTurnoTMP.HorarioFin := GetValueAsTime(JToken, 'HorarioFin');
            RecTurnoTmp."Descripcion Turno" := GetValueAsText(JToken, 'DescripcionTurno');
            if RecTurnoTMP.Insert() then
                TurnoCount += 1
            else
                ErrorCount += 1;
            If (RecTurnoTMP."No" = 0) Then begin
                RecTurno := RecTurnoTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. Turno");
                If RecTurnoOld.FindLast() then
                    RecTurno."No" := RecTurnoOld."No" + 1
                else
                    RecTurno."No" := 1;
                RecTurno.Insert();
            end else begin
                // Actualizar turno existente
                if not Deleted then begin
                    TurnoRecRef.Gettable(RecTurnoTmp);
                    EmptyTurnoRecRef.Open(Database::Turno);
                    EmptyTurnoRecRef.Init();
                    If RecTurno.Get(RecTurnoTMP.No) Then begin
                        TTurnoRecRef.GetTable(RecTurno);
                        for i := 1 to TurnoRecRef.FieldCount do begin
                            TurnoFldRef := TurnoRecRef.FieldIndex(i);
                            TTurnoFldRef := TTurnoRecRef.Field(TurnoFldRef.Number);
                            EmptyTurnoFldRef := EmptyTurnoRecRef.Field(TurnoFldRef.Number);
                            if (TurnoFldRef.Value <> EmptyTurnoFldRef.Value)
                                then
                                TTurnoFldRef.Value := TurnoFldRef.Value;
                        end;

                        TTurnoRecRef.Modify();
                        RecTurnoTMP."No" := RecTurno."No";
                    end;
                end else begin
                    If RecTurno.Get(RecTurnoTmp."No") Then RecTurno.Delete();

                end;
                ErrorCount += 1;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Turnos procesados: %1, Errores: %2', TurnoCount, ErrorCount);
        exit(ResultadoText);
    end;

    local procedure GetValueAsTime(JToken: JsonToken; TokenName: Text): Time
    var
        JTokenValue: JsonToken;
        JObj: JsonObject;
        TimeValue: Time;
        TimeText: Text;
    begin
        JObj := JToken.AsObject();
        if JObj.Get(TokenName, JTokenValue) then begin
            TimeText := JTokenValue.AsValue().AsText();
            Evaluate(TimeValue, TimeText);
            exit(TimeValue);
        end;
        exit(0T);
    end;

    [ServiceEnabled]
    procedure insertaCajas(Data: Text): Text
    var
        JCajaToken: JsonToken;
        JCajaObj: JsonObject;
        JCajas: JsonArray;
        JToken: JsonToken;
        RecCaja: Record "Configuracion TPV";
        RecCajaTmp: Record "Configuracion TPV" temporary;
        RecRef: RecordRef;
        CajaCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        CajaRecRef: RecordRef;
        EmptyCajaRecRef: RecordRef;
        TCajaRecRef: RecordRef;
        i: Integer;
        CajaFldRef: FieldRef;
        TCajaFldRef: FieldRef;
        EmptyCajaFldRef: FieldRef;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JCajaToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JCajaObj := JCajaToken.AsObject();

        // Obtener el array de cajas
        if not JCajaObj.Get('Cajas', JCajaToken) then
            exit('No se encontró el array "Cajas" en el JSON.');

        JCajas := JCajaToken.AsArray();

        // Contadores para el resultado
        CajaCount := 0;
        ErrorCount := 0;

        // Procesar cada caja
        foreach JToken in JCajas do begin
            Clear(RecCaja);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            Clear(RecCajaTmp);
            RecCajaTmp."Id TPV" := GetValueAsText(JToken, 'No_');
            if RecCajaTMP."Id TPV" = '' then
                RecCajaTMP."Id TPV" := GetValueAsText(JToken, 'No'); // Compatibilidad con formato anterior
            RecCajaTMP.Descripcion := GetValueAsText(JToken, 'Nombre');
            RecCajaTMP."Tienda" := GetValueAsText(JToken, 'TPV');
            If RecCajaTMP."Tienda" = '' then exit('');
            if RecCajaTMP.Insert() then
                CajaCount += 1
            else
                ErrorCount += 1;


            // Verificar que la caja no esté vacía
            If (RecCajaTMP."Id TPV" = 'TEMP') Or (RecCajaTMP."Id TPV" = '') Then begin



                RecCaja := RecCajaTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. Caja");
                RecCaja."Id TPV" := NoSeriesMgt.GetNextNo(SalesSetup."Nums. Caja", Today, true);
                RecCaja.Insert();
            end else begin
                // Actualizar caja existente o eliminarla
                if not Deleted then begin
                    CajaRecRef.Gettable(RecCajaTmp);
                    EmptyCajaRecRef.Open(Database::"Configuracion TPV");
                    EmptyCajaRecRef.Init();
                    If RecCaja.Get(RecCajaTMP."Tienda", RecCajaTMP."Id TPV") Then begin
                        TCajaRecRef.GetTable(RecCaja);
                        for i := 1 to CajaRecRef.FieldCount do begin
                            CajaFldRef := CajaRecRef.FieldIndex(i);
                            TCajaFldRef := TCajaRecRef.Field(CajaFldRef.Number);
                            EmptyCajaFldRef := EmptyCajaRecRef.Field(CajaFldRef.Number);
                            if (CajaFldRef.Value <> EmptyCajaFldRef.Value)
                                then
                                TCajaFldRef.Value := CajaFldRef.Value;
                        end;

                        TCajaRecRef.Modify();
                        RecCajaTMP."Id TPV" := RecCaja."Id TPV";
                        CajaCount += 1;
                    end else
                        exit('');

                end else begin
                    If RecCaja.Get(RecCajaTmp."Tienda", RecCajaTmp."Id TPV") Then begin
                        RecCaja.Delete();
                        CajaCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Cajas procesadas: %1, Errores: %2', CajaCount, ErrorCount);
        exit(RecCaja."Id TPV");
    end;

    /// <summary>
    /// insertaAperturaCaja importa aperturas de caja desde JSON.
    /// </summary>
    /// <param name="Data">Texto con datos JSON</param>
    /// <returns>Texto con resultado de la importación</returns>
    [ServiceEnabled]
    procedure insertaAperturaCaja(Data: Text): Text
    var
        JAperturaToken: JsonToken;
        JAperturaObj: JsonObject;
        JAperturas: JsonArray;
        JToken: JsonToken;
        RecApertura: Record "Control de TPV";
        RecAperturaTmp: Record "Control de TPV" temporary;
        AperturaCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        EstadoTxt: Text;
        Num: Integer;
        Cajas: Record "Configuracion TPV";
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JAperturaToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JAperturaObj := JAperturaToken.AsObject();

        // Obtener el array de aperturas
        if not JAperturaObj.Get('Aperturas', JAperturaToken) then
            exit('No se encontró el array "Aperturas" en el JSON.');

        JAperturas := JAperturaToken.AsArray();

        // Contadores para el resultado
        AperturaCount := 0;
        ErrorCount := 0;

        // Procesar cada apertura
        foreach JToken in JAperturas do begin
            Clear(RecApertura);
            Clear(RecAperturaTmp);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');

            // Asignar valores desde JSON
            RecAperturaTmp."Usuario apertura" := GetValueAsText(JToken, 'Cajero');
            RecAperturaTmp.Fecha := GetValueAsDate(JToken, 'FechaDeApertura');
            RecAperturaTmp.ImporteDeApertura := GetValueAsDecimal(JToken, 'ImporteDeApertura');
            RecAperturaTmp."No. TPV" := GetValueAsText(JToken, 'Caja');
            RecAperturaTmp."No. Tienda" := GetValueAsText(JToken, 'Tienda');
            If RecAperturaTmp."No. TPV" <> '' then begin
                if RecAperturaTmp."No. Tienda" = '' then begin
                    Cajas.SetRange("Id TPV", RecAperturaTmp."No. TPV");
                    if Cajas.FindFirst() then
                        RecAperturaTmp."No. Tienda" := Cajas."Tienda";
                end;
            end;
            RecAperturaTmp.Turno := GetValueAsInteger(JToken, 'Turno');
            RecAperturaTmp."Hora apertura" := GetValueAsTime(JToken, 'HoraDeApertura');
            // Determinar el estado 
            EstadoTxt := GetValueAsText(JToken, 'Estado');
            if EstadoTxt = 'Cerrado' then
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::Cerrado
            else if EstadoTxt = 'Abierto' then
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::Abierto;
            // else if EstadoTxt = 'Turno Generado' then
            //     RecAperturaTmp.Estado := RecAperturaTmp.Estado::"Turno Generado"
            // else
            //     RecAperturaTmp.Estado := RecAperturaTmp.Estado::Abierto;

            // Verificar si existe un ID específico
            if GetValueAsText(JToken, 'No') = 'TEMP' then
                RecAperturaTmp."Id Replicacion" := '';


            if Deleted then begin
                // Buscar por ID si se especifica
                if RecAperturaTmp."Id Replicacion" <> '' then begin
                    RecApertura.SetRange("Id Replicacion", RecAperturaTmp."Id Replicacion");
                    if RecApertura.FindFirst() then begin
                        RecApertura.Delete();
                        AperturaCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else begin
                // Si se especifica un ID, intentar actualizar
                if RecAperturaTmp."No. TPV" <> '' then begin
                    if RecApertura.Get(RecAperturaTmp."No. Tienda", RecAperturaTmp."No. TPV", RecAperturaTmp.Fecha) then begin
                        RecApertura."Usuario apertura" := RecAperturaTmp."Usuario apertura";
                        RecApertura.Fecha := RecAperturaTmp.Fecha;
                        RecApertura."Hora apertura" := RecAperturaTmp."Hora apertura";
                        RecApertura.ImporteDeApertura := RecAperturaTmp.ImporteDeApertura;
                        RecApertura.Estado := RecAperturaTmp.Estado;
                        RecApertura."No. TPV" := RecAperturaTmp."No. TPV";
                        RecApertura."No. Tienda" := RecAperturaTmp."No. Tienda";
                        RecApertura.Turno := RecAperturaTmp.Turno;
                        RecApertura."Id Replicacion" := RecApertura."No. tienda" + ';' + RecApertura."No. TPV" + ';' + Format(RecApertura.Fecha);

                        if RecApertura.Modify() then
                            AperturaCount += 1
                        else
                            ErrorCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    // Insertar nueva apertura
                    RecApertura.Init();
                    RecApertura.TransferFields(RecAperturaTmp);
                    RecApertura."Id Replicacion" := RecApertura."No. tienda" + ';' + RecApertura."No. TPV" + ';' + Format(RecApertura.Fecha);
                    if NOT RecApertura.Insert() then
                        RecApertura.Modify();
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('%1', RecApertura."Id Replicacion");
        exit(ResultadoText);
    end;

    /// <summary>
    /// insertaCierreCaja importa cierres de caja desde JSON.
    /// </summary>
    /// <param name="Data">Texto con datos JSON</param>
    /// <returns>Texto con resultado de la importación</returns>
    [ServiceEnabled]
    procedure insertaCierreCaja(Data: Text): Text
    var
        JCierreToken: JsonToken;
        JCierreObj: JsonObject;
        JCierres: JsonArray;
        JToken: JsonToken;
        RecCierre: Record "Control de TPV";
        RecCierreTmp: Record "Control de TPV" temporary;
        CierreCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        EstadoTxt: Text;
        Num: Integer;
        AperturaDeCaja: Record "Control de TPV";
        Tienda: Text;
        TPV: Text;
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JCierreToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JCierreObj := JCierreToken.AsObject();

        // Obtener el array de cierres
        if not JCierreObj.Get('Cierres', JCierreToken) then
            exit('No se encontró el array "Cierres" en el JSON.');

        JCierres := JCierreToken.AsArray();

        // Contadores para el resultado
        CierreCount := 0;
        ErrorCount := 0;

        // Procesar cada cierre
        foreach JToken in JCierres do begin
            Clear(RecCierre);
            Clear(RecCierreTmp);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');

            // Asignar valores desde JSON
            RecCierreTmp."Usuario cierre" := GetValueAsText(JToken, 'Cajero');
            RecCierreTmp.ImporteDeApertura := GetValueAsDecimal(JToken, 'ImporteDeApertura');
            RecCierreTmp.Fecha := GetValueAsDate(JToken, 'FechaDeApertura');
            RecCierreTmp.ImporteDeCierreBS := GetValueAsDecimal(JToken, 'ImporteDeCierreBS');
            RecCierreTmp.ImporteDeCierreUS := GetValueAsDecimal(JToken, 'ImporteDeCierreUS');
            RecCierreTmp.ImporteDeCierreEUR := GetValueAsDecimal(JToken, 'ImporteDeCierreEUR');
            RecCierreTmp.ArqueoBS := GetValueAsDecimal(JToken, 'ArqueoBS');
            RecCierreTmp.ArqueoUS := GetValueAsDecimal(JToken, 'ArqueoUS');
            RecCierreTmp.ArqueoEUR := GetValueAsDecimal(JToken, 'ArqueoEUR');
            RecCierreTmp.FechaDeCierre := GetValueAsDateTime(JToken, 'FechaDeCierre');
            RecCierreTmp."Id Replicacion" := GetValueAsText(JToken, 'idApertura');
            If RecCierreTmp."Id Replicacion" <> '' then begin
                //Tienda;TPV
                AperturaDeCaja.SetRange("Id Replicacion", RecCierreTmp."Id Replicacion");
                if AperturaDeCaja.FindFirst() then begin
                    RecCierreTmp."No. Tienda" := AperturaDeCaja."No. Tienda";
                    RecCierreTmp."No. TPV" := AperturaDeCaja."No. TPV";
                    RecCierreTmp.Fecha := AperturaDeCaja.Fecha;
                end;
            end;
            // Determinar el estado
            EstadoTxt := GetValueAsText(JToken, 'Estado');
            if EstadoTxt = 'Cerrado' then
                RecCierreTmp.Estado := RecCierreTmp.Estado::Cerrado
            else
                RecCierreTmp.Estado := RecCierreTmp.Estado::Abierto;

            // Verificar si existe un ID específico
            // Verificar si existe un ID específico
            if GetValueAsText(JToken, 'No') = 'TEMP' then
                RecCierreTmp."Id Replicacion" := ''
            else if GetValueAsInteger(JToken, 'No') > 0 then
                RecCierreTmp."Id Replicacion" := GetValueAsText(JToken, 'No');


            if Deleted then begin
                // Buscar por ID si se especifica
                if RecCierreTmp."Id Replicacion" <> '' then begin
                    RecCierre.SetRange("Id Replicacion", RecCierreTmp."Id Replicacion");
                    if RecCierre.FindFirst() then begin
                        RecCierre.Delete();
                        CierreCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else begin
                // Si se especifica un ID, intentar actualizar
                if RecCierreTmp."Id Replicacion" <> '' then begin
                    if RecCierre.Get(RecCierreTmp."No. Tienda", RecCierreTmp."No. TPV", RecCierreTmp.Fecha) then begin
                        RecCierre."Usuario cierre" := RecCierreTmp."Usuario cierre";
                        RecCierre.ImporteDeApertura := RecCierreTmp.ImporteDeApertura;
                        RecCierre.Fecha := RecCierreTmp.Fecha;
                        RecCierre.ImporteDeCierreBS := RecCierreTmp.ImporteDeCierreBS;
                        RecCierre.ImporteDeCierreUS := RecCierreTmp.ImporteDeCierreUS;
                        RecCierre.ImporteDeCierreEUR := RecCierreTmp.ImporteDeCierreEUR;
                        RecCierre.ArqueoBS := RecCierreTmp.ArqueoBS;
                        RecCierre.ArqueoUS := RecCierreTmp.ArqueoUS;
                        RecCierre.ArqueoEUR := RecCierreTmp.ArqueoEUR;
                        RecCierre.FechaDeCierre := RecCierreTmp.FechaDeCierre;
                        RecCierre.Estado := RecCierreTmp.Estado;
                        RecCierre."Id Replicacion" := RecCierreTmp."Id Replicacion";

                        if RecCierre.Modify() then
                            CierreCount += 1
                        else
                            ErrorCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    // Insertar nuevo cierre
                    RecCierre.Reset();
                    RecCierre.Init();
                    RecCierre.TransferFields(RecCierreTmp);
                    RecCierre."Id Replicacion" := RecCierreTmp."Id Replicacion";
                    if RecCierre.Insert() then
                        CierreCount += 1
                    else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('%1', RecCierre."Id Replicacion");
        exit(ResultadoText);
    end;

    /// <summary>
    /// GetValueAsDateTime obtiene un valor DateTime de un token JSON.
    /// </summary>
    /// <param name="JToken">Token JSON del objeto principal</param>
    /// <param name="ParamString">Nombre del parámetro a obtener</param>
    /// <returns>Valor como DateTime</returns>
    local procedure GetValueAsDateTime(JToken: JsonToken; ParamString: Text): DateTime
    var
        JTokenValue: JsonToken;
        JObj: JsonObject;
        DateTimeValue: DateTime;
        DateTimeText: Text;
    begin
        JObj := JToken.AsObject();
        if JObj.Get(ParamString, JTokenValue) then begin
            DateTimeText := JTokenValue.AsValue().AsText();
            if Evaluate(DateTimeValue, DateTimeText) then
                exit(DateTimeValue);
        end;
        exit(0DT);
    end;

    /// <summary>
    /// insertaCierreDetalle importa detalles de cierre de caja desde JSON.
    /// </summary>
    /// <param name="Data">Texto con datos JSON</param>
    /// <returns>Texto con resultado de la importación</returns>
    [ServiceEnabled]
    procedure insertaCierreDetalle(Data: Text): Text
    var
        JDetalleToken: JsonToken;
        JDetalleObj: JsonObject;
        JDetalles: JsonArray;
        JToken: JsonToken;
        RecDetalle: Record CierreDeCajaDetalle;
        RecDetalleTmp: Record CierreDeCajaDetalle temporary;
        DetalleCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JDetalleToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JDetalleObj := JDetalleToken.AsObject();

        // Obtener el array de detalles
        if not JDetalleObj.Get('CierreDetalles', JDetalleToken) then
            exit('No se encontró el array "CierreDetalles" en el JSON.');

        JDetalles := JDetalleToken.AsArray();

        // Contadores para el resultado
        DetalleCount := 0;
        ErrorCount := 0;

        // Procesar cada detalle
        foreach JToken in JDetalles do begin
            Clear(RecDetalle);
            Clear(RecDetalleTmp);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');

            // Asignar valores desde JSON
            RecDetalleTmp.idCierre := GetValueAsText(JToken, 'idCierre');
            RecDetalleTmp.idApertura := GetValueAsText(JToken, 'idApertura');
            RecDetalleTmp.idFormaPago := GetValueAsText(JToken, 'idFormaPago');
            RecDetalleTmp.MontoPago := GetValueAsDecimal(JToken, 'MontoPago');

            // Verificar si existe un ID específico
            if GetValueAsInteger(JToken, 'item') > 0 then
                RecDetalleTmp.item := GetValueAsInteger(JToken, 'item');

            if Deleted then begin
                // Buscar por ID si se especifica
                if RecDetalleTmp.item > 0 then begin
                    if RecDetalle.Get(RecDetalleTmp.item) then begin
                        RecDetalle.Delete();
                        DetalleCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else begin
                // Si se especifica un ID, intentar actualizar
                if RecDetalleTmp.item > 0 then begin
                    if RecDetalle.Get(RecDetalleTmp.item) then begin
                        RecDetalle.idCierre := RecDetalleTmp.idCierre;
                        RecDetalle.idApertura := RecDetalleTmp.idApertura;
                        RecDetalle.idFormaPago := RecDetalleTmp.idFormaPago;
                        RecDetalle.MontoPago := RecDetalleTmp.MontoPago;

                        if RecDetalle.Modify() then
                            DetalleCount += 1
                        else
                            ErrorCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    // Insertar nuevo detalle
                    RecDetalle.Init();
                    RecDetalle.TransferFields(RecDetalleTmp);

                    if RecDetalle.Insert() then
                        DetalleCount += 1
                    else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Detalles procesados: %1, Errores: %2', DetalleCount, ErrorCount);
        exit(ResultadoText);
    end;

    /// <summary>
    /// insertaFormasDePago importa formas de pago desde JSON.
    /// </summary>
    /// <param name="Data">Texto con datos JSON</param>
    /// <returns>Texto con resultado de la importación</returns>
    [ServiceEnabled]
    procedure insertaFormasDePago(Data: Text): Text
    var
        JFormaPagoToken: JsonToken;
        JFormaPagoObj: JsonObject;
        JFormasPago: JsonArray;
        JToken: JsonToken;
        RecFormaPago: Record "Payment Method";
        RecFormaPagoTmp: Record "Payment Method" temporary;
        RecRef: RecordRef;
        FormaPagoCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        FormaPagoRecRef: RecordRef;
        EmptyFormaPagoRecRef: RecordRef;
        TFormaPagoRecRef: RecordRef;
        i: Integer;
        FormaPagoFldRef: FieldRef;
        TFormaPagoFldRef: FieldRef;
        EmptyFormaPagoFldRef: FieldRef;
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JFormaPagoToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JFormaPagoObj := JFormaPagoToken.AsObject();

        // Obtener el array de formas de pago
        if not JFormaPagoObj.Get('FormasDePago', JFormaPagoToken) then
            exit('No se encontró el array "FormasDePago" en el JSON.');

        JFormasPago := JFormaPagoToken.AsArray();

        // Contadores para el resultado
        FormaPagoCount := 0;
        ErrorCount := 0;

        // Procesar cada forma de pago
        foreach JToken in JFormasPago do begin
            Clear(RecFormaPago);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            Clear(RecFormaPagoTmp);
            RecFormaPagoTmp."Code" := GetValueAsText(JToken, 'Code');

            // Verificar que la forma de pago no esté vacía
            If (RecFormaPagoTmp."Code" <> '') Then begin
                // Actualizar forma de pago existente o eliminarla
                if not Deleted then begin
                    RecFormaPagoTMP.Description := GetValueAsText(JToken, 'Description');
                    RecFormaPagoTMP.Dto := GetValueAsDecimal(JToken, 'Dto');
                    FormaPagoRecRef.Gettable(RecFormaPagoTmp);
                    EmptyFormaPagoRecRef.Open(Database::"Payment Method");
                    EmptyFormaPagoRecRef.Init();

                    If RecFormaPago.Get(RecFormaPagoTmp."Code") Then begin
                        TFormaPagoRecRef.GetTable(RecFormaPago);
                        for i := 1 to FormaPagoRecRef.FieldCount do begin
                            FormaPagoFldRef := FormaPagoRecRef.FieldIndex(i);
                            TFormaPagoFldRef := TFormaPagoRecRef.Field(FormaPagoFldRef.Number);
                            EmptyFormaPagoFldRef := EmptyFormaPagoRecRef.Field(FormaPagoFldRef.Number);
                            if (FormaPagoFldRef.Value <> EmptyFormaPagoFldRef.Value)
                                then
                                TFormaPagoFldRef.Value := FormaPagoFldRef.Value;
                        end;

                        TFormaPagoRecRef.Modify();
                        FormaPagoCount += 1;
                    end else begin
                        // Si no existe, insertarla
                        RecFormaPago.Init();
                        RecFormaPago := RecFormaPagoTmp;
                        if RecFormaPago.Insert() then
                            FormaPagoCount += 1
                        else
                            ErrorCount += 1;
                    end;
                end else begin
                    // Eliminar si existe
                    If RecFormaPago.Get(RecFormaPagoTmp."Code") Then begin
                        RecFormaPago.Delete();
                        FormaPagoCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else
                ErrorCount += 1;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Formas de pago procesadas: %1, Errores: %2', FormaPagoCount, ErrorCount);
        exit(ResultadoText);
    end;

    /// <summary>
    /// insertaColegios.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaColegios(Data: Text): Text
    var
        JColegioToken: JsonToken;
        JColegioObj: JsonObject;
        JColegios: JsonArray;
        JColegio: JsonObject;
        ColegioT: Record Colegios temporary;
        JToken: JsonToken;
        Texto: Text;
        Colegio: Record Colegios;
        RecRef2: RecordRef;
        ColegioRecRef: RecordRef;
        ColegioFldRef: FieldRef;
        ColRecRef: RecordRef;
        EmptyColegioRecRef: RecordRef;
        ColFldRef: FieldRef;
        EmptyColFldRef: FieldRef;
        EmptyColegioFldRef: FieldRef;
        i: Integer;
        Deleted: Boolean;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        JColegioToken.ReadFrom(Data);
        JColegioObj := JColegioToken.AsObject();

        JColegioObj.SelectToken('Colegios', JColegioToken);
        JColegios := JColegioToken.AsArray();
        JColegios.WriteTo(Data);

        foreach JToken in JColegios do begin
            ColegioT."No" := GetValueAsText(JToken, 'No');
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            ColegioT."Nombre" := GetValueAsText(JToken, 'Nombre');
            ColegioT."Dirección" := GetValueAsText(JToken, 'Direccion');
            ColegioT."Dirección 2" := GetValueAsText(JToken, 'Direccion_2');
            ColegioT."Ciudad" := GetValueAsText(JToken, 'Ciudad');
            ColegioT."Código Postal" := GetValueAsText(JToken, 'Codigo_Postal');
            ColegioT."Provincia" := GetValueAsText(JToken, 'Provincia');
            ColegioT."País" := GetValueAsText(JToken, 'Pais');
            ColegioT."Teléfono" := GetValueAsText(JToken, 'Telefono');
            ColegioT."Móvil" := GetValueAsText(JToken, 'Movil');
            ColegioT."Email" := GetValueAsText(JToken, 'Email');
            ColegioT."Sitio Web" := GetValueAsText(JToken, 'Sitio_Web');
            ColegioT."NIF/CIF" := GetValueAsText(JToken, 'NIF_CIF');
            ColegioT."Contacto" := GetValueAsText(JToken, 'Contacto');
            ColegioT."Notas" := GetValueAsText(JToken, 'Notas');
            if Evaluate(ColegioT."Fecha Alta", GetValueAsText(JToken, 'Fecha_Alta')) Then;

            If (ColegioT."No" = '') or (ColegioT."No" = 'TEMP') Then begin
                // Generate a new code for the college
                SalesSetup.Get();
                Colegio.Reset();
                Colegio.Init();
                ColegioT."No" := NoSeriesMgt.GetNextNo(SalesSetup."Nums. Colegio", 0D, true);

                Colegio := ColegioT;
                Colegio.Insert();
                ColegioT."No" := Colegio."No";
            end else begin
                if not Deleted then begin
                    ColegioRecRef.Gettable(ColegioT);
                    EmptyColegioRecRef.Open(Database::Colegios);
                    EmptyColegioRecRef.Init();
                    If Colegio.Get(ColegioT."No") Then begin
                        ColRecRef.GetTable(Colegio);
                        for i := 1 to ColegioRecRef.FieldCount do begin
                            ColegioFldRef := ColegioRecRef.FieldIndex(i);
                            ColFldRef := ColRecRef.Field(ColegioFldRef.Number);
                            EmptyColegioFldRef := EmptyColegioRecRef.Field(ColegioFldRef.Number);
                            if (ColegioFldRef.Value <> EmptyColegioFldRef.Value)
                                then
                                ColFldRef.Value := ColegioFldRef.Value;
                        end;

                        ColRecRef.Modify();
                    end;
                    ColegioRecRef.Close();
                    ColegioT."No" := Colegio."No";
                end else begin
                    If Colegio.Get(ColegioT."No") Then Colegio.Delete();
                    ColegioT."No" := '';
                end;
            end;
        end;
        exit(ColegioT."No");
    end;

    [ServiceEnabled]
    procedure insertaPagosFacturasVenta(Data: Text): Text
    var
        JLPedidoToken: JsonToken;
        JLPedidoObj: JsonObject;
        JLFacturas: JsonArray;
        JLPedido: JsonObject;
        SalesLineT: Record "Detalle Pago Factura" temporary;
        SalesHeader: Record "Sales Header";
        JToken: JsonToken;
        Texto: Text;
        RecRef2: RecordRef;
        VendorRecRef: RecordRef;
        PurchSetup: Record 312;
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        VendorTempl: Record "Vendor Templ.";
        VendorFldRef: FieldRef;
        VendRecRef: RecordRef;
        EmptyVendorRecRef: RecordRef;
        EmptyVendorTemplRecRef: RecordRef;
        VendFldRef: FieldRef;
        EmptyVendFldRef: FieldRef;
        VendorTemplFldRef: FieldRef;
        EmptyVendorFldRef: FieldRef;
        i: Integer;
        FacturasL: Record "Detalle Pago Factura";
        Linea: Integer;
    begin
        JLPedidoToken.ReadFrom(Data);
        JLPedidoObj := JLPedidoToken.AsObject();


        JLPedidoObj.SelectToken('Sales_Payment_Lines', JLPedidoToken);
        JLFacturas := JLPedidoToken.AsArray();
        foreach JToken in JLFacturas do begin
            Texto := GetValueAsText(JToken, 'Document_Type');
            case Texto Of
                'Invoice', 'Factura':
                    SalesLineT."Document Type" := SalesLineT."Document Type"::Invoice;
                'Credit Memo', 'Nota de Crédito', 'Abono', 'Credit Note':
                    SalesLineT."Document Type" := SalesLineT."Document Type"::"Credit Memo";
            end;
            SalesLineT."Document No." := GetValueAsText(JToken, 'Document_No_');
            //Linea += 10000;
            SalesLineT."Line No." := GetValueAsInteger(JToken, 'Line_No');
            SalesLineT."Forma de Pago" := GetValueAsText(JToken, 'Payment_Method');
            SalesLineT."Importe" := GetValueAsDecimal(JToken, 'Amount');
            FacturasL := SaleslineT;
            If FacturasL.Insert() Then begin
                FacturasL.Validate(Importe);
                FacturasL.Modify();
            end
        end;
        exit('Ok');
    end;

    [ServiceEnabled]
    procedure insertaTPV(Data: Text): Text
    var
        JTPVToken: JsonToken;
        JTPVObj: JsonObject;
        JTPVs: JsonArray;
        JToken: JsonToken;
        RecTPV: Record Tiendas;
        RecTPVTmp: Record Tiendas temporary;
        TPVCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        TPVRecRef: RecordRef;
        EmptyTPVRecRef: RecordRef;
        TTPVRecRef: RecordRef;
        i: Integer;
        TPVFldRef: FieldRef;
        TTPVFldRef: FieldRef;
        EmptyTPVFldRef: FieldRef;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        // Verificar que hay datos para importar
        if Data = '' then
            exit('No se proporcionaron datos para importar.');

        // Intentar leer el JSON
        if not JTPVToken.ReadFrom(Data) then
            exit('Error al leer el formato JSON.');

        // Convertir a objeto JSON
        JTPVObj := JTPVToken.AsObject();

        // Obtener el array de TPV
        if not JTPVObj.Get('TPVs', JTPVToken) then
            exit('No se encontró el array "TPVs" en el JSON.');

        JTPVs := JTPVToken.AsArray();

        // Contadores para el resultado
        TPVCount := 0;
        ErrorCount := 0;

        // Procesar cada TPV
        foreach JToken in JTPVs do begin
            Clear(RecTPV);

            // Verificar si es una eliminación
            Deleted := GetValueAsBoolean(JToken, 'Deleted');
            Clear(RecTPVTmp);

            // Asignar valores usando la nueva estructura de nombres
            RecTPVTmp."Cod. Tienda" := GetValueAsText(JToken, 'No.');
            if RecTPVTmp."Cod. Tienda" = '' then
                RecTPVTmp."Cod. Tienda" := GetValueAsText(JToken, 'No'); // Compatibilidad con formato anterior

            RecTPVTmp.Descripcion := GetValueAsText(JToken, 'nombre');
            if RecTPVTmp.Descripcion = '' then
                RecTPVTmp.Descripcion := GetValueAsText(JToken, 'Nombre'); // Compatibilidad

            RecTPVTmp."Direccion" := GetValueAsText(JToken, 'direccion');
            RecTPVTmp."Direccion 2" := GetValueAsText(JToken, 'direccion2');
            RecTPVTmp."Ciudad" := GetValueAsText(JToken, 'ciudad');
            RecTPVTmp."Codigo Postal" := GetValueAsText(JToken, 'codigoPostal');
            //RecTPVTmp."Provincia" := GetValueAsText(JToken, 'provincia');
            RecTPVTmp."Cod. Pais" := GetValueAsText(JToken, 'pais');
            RecTPVTmp.Telefono := GetValueAsText(JToken, 'telefono');
            RecTPVTmp."Telefono 2" := GetValueAsText(JToken, 'movil');
            RecTPVTmp."e-mail" := GetValueAsText(JToken, 'email');
            RecTPVTmp."Pagina web" := GetValueAsText(JToken, 'sitioWeb');
            RecTPVTmp."No. Identificacion Fiscal" := GetValueAsText(JToken, 'nifCif');
            RecTPVTmp."Contacto" := GetValueAsText(JToken, 'contacto');
            RecTPVTmp."Notas" := GetValueAsText(JToken, 'notas');

            // Convertir fecha si existe
            if HasValue(JToken, 'fechaAlta') then
                Evaluate(RecTPVTmp."Fecha Alta", GetValueAsText(JToken, 'fechaAlta'));

            RecTPVTmp."Cod. Almacen" := GetValueAsText(JToken, 'locationCode');
            RecTPVTmp."No. Series" := GetValueAsText(JToken, 'noSeries');

            if RecTPVTMP.Insert() then
                TPVCount += 1
            else
                ErrorCount += 1;

            // Verificar que el TPV no esté vacío
            If (RecTPVTMP."Cod. Tienda" = 'TEMP') Or (RecTPVTMP."Cod. Tienda" = '') Then begin
                RecTPV := RecTPVTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. TPV");
                RecTPV."Cod. Tienda" := NoSeriesMgt.GetNextNo(SalesSetup."Nums. TPV", Today, true);
                RecTPV.Insert();
            end else begin
                // Actualizar TPV existente o eliminarlo
                if not Deleted then begin
                    TPVRecRef.Gettable(RecTPVTmp);
                    EmptyTPVRecRef.Open(Database::Tiendas);
                    EmptyTPVRecRef.Init();
                    If RecTPV.Get(RecTPVTMP."Cod. Tienda") Then begin
                        TTPVRecRef.GetTable(RecTPV);
                        for i := 1 to TPVRecRef.FieldCount do begin
                            TPVFldRef := TPVRecRef.FieldIndex(i);
                            TTPVFldRef := TTPVRecRef.Field(TPVFldRef.Number);
                            EmptyTPVFldRef := EmptyTPVRecRef.Field(TPVFldRef.Number);
                            if (TPVFldRef.Value <> EmptyTPVFldRef.Value)
                                then
                                TTPVFldRef.Value := TPVFldRef.Value;
                        end;

                        TTPVRecRef.Modify();
                        RecTPVTMP."Cod. Tienda" := RecTPV."Cod. Tienda";
                        TPVCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    If RecTPV.Get(RecTPVTmp."Cod. Tienda") Then begin
                        RecTPV.Delete();
                        TPVCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Tiendas procesadas: %1, Errores: %2', TPVCount, ErrorCount);
        exit(RecTPV."Cod. Tienda");
    end;

    local procedure HasValue(JToken: JsonToken; PropertyName: Text): Boolean
    var
        JObject: JsonObject;
        JPropertyToken: JsonToken;
    begin
        JObject := JToken.AsObject();
        exit(JObject.Get(PropertyName, JPropertyToken));
    end;
    #region roles






    procedure OnDrillDown(HeadlineType: Text)
    var
        TPVInvoicePage: Page "Sales List";
        SalesHeader: Record "Sales Header";
        PostedSalesInvoicesPage: Page "Posted Sales Invoices";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        case HeadlineType of
            'TodaySales':
                begin
                    SalesInvHeader.SetRange("Posting Date", WorkDate());
                    SalesInvHeader.SetFilter("TPV", '<>%1', '');
                    PostedSalesInvoicesPage.SetTableView(SalesInvHeader);
                    PostedSalesInvoicesPage.Run();
                end;
            'NoSales':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                    SalesHeader.SetRange("Posting Date", WorkDate());
                    SalesHeader.SetFilter("TPV", '<>%1', '');
                    TPVInvoicePage.SetTableView(SalesHeader);
                    TPVInvoicePage.RunModal();
                end;

        end;
    end;
    #endregion roles

    /// <summary>
    /// UpdateTPVCueRecord actualiza el registro TPV Cue de manera segura.
    /// Actualiza el valor promedio de transacción y la fecha/hora de actualización en el registro TPV Cue.
    /// Utiliza bloqueo de tabla para garantizar la integridad de los datos durante la actualización.
    /// </summary>
    /// <param name="TPVCue">Registro a actualizar</param>
    /// <param name="AverageTransactionValue">Valor medio de transacción</param>
    /// <param name="TPVSalesUpdatedOn">Fecha y hora de actualización</param>
    procedure UpdateTPVCueRecord(var TPVCue: Record "TPV Cue"; AverageTransactionValue: Decimal; TPVSalesUpdatedOn: DateTime)
    begin
        if not TPVCue.Get() then
            exit;

        TPVCue.LockTable();
        TPVCue."Average Transaction Value" := AverageTransactionValue;
        TPVCue."TPV Sales Updated On" := TPVSalesUpdatedOn;
        //if TPVCue.Modify() then;
        //Commit();
    end;

    /// <summary>
    /// GetCurrentSalesPrices.
    /// </summary>
    /// <returns>Return value of type Text - JSON con todos los precios de venta vigentes.</returns>
    [ServiceEnabled]
    procedure getcurrentsalesprices(): Text
    var
        SalesPrice: Record "Sales Price";
        JObject: JsonObject;
        JArray: JsonArray;
        JPrice: JsonObject;
        TodayDate: Date;
        JsonText: Text;
    begin
        TodayDate := WorkDate();

        // Filtrar precios de venta que estén vigentes hoy
        SalesPrice.SetFilter("Starting Date", '%1|..%2', 0D, TodayDate);
        SalesPrice.SetFilter("Ending Date", '%1|>=%2', 0D, TodayDate);

        if SalesPrice.FindSet() then begin
            repeat
                Clear(JPrice);

                // Información del precio
                JPrice.Add('Item_No', SalesPrice."Item No.");
                JPrice.Add('Sales_Type', Format(SalesPrice."Sales Type"));
                JPrice.Add('Sales_Code', SalesPrice."Sales Code");
                JPrice.Add('Starting_Date', Format(SalesPrice."Starting Date"));
                JPrice.Add('Ending_Date', Format(SalesPrice."Ending Date"));
                JPrice.Add('Currency_Code', SalesPrice."Currency Code");
                JPrice.Add('Unit_Price', SalesPrice."Unit Price");
                JPrice.Add('Minimum_Quantity', SalesPrice."Minimum Quantity");
                JPrice.Add('Unit_of_Measure_Code', SalesPrice."Unit of Measure Code");
                JPrice.Add('Variant_Code', SalesPrice."Variant Code");
                JPrice.Add('Allow_Line_Disc', SalesPrice."Allow Line Disc.");
                JPrice.Add('Allow_Invoice_Disc', SalesPrice."Allow Invoice Disc.");
                JPrice.Add('VAT_Bus_Posting_Gr_Price', SalesPrice."VAT Bus. Posting Gr. (Price)");

                JArray.Add(JPrice);
            until SalesPrice.Next() = 0;
        end;

        JObject.Add('SalesPrices', JArray);
        JObject.WriteTo(JsonText);

        exit(JsonText);
    end;

    /// <summary>
    /// GetActiveCoupons.
    /// </summary>
    /// <returns>Return value of type Text - JSON con todos los cupones activos con sus precios y descuentos.</returns>
    [ServiceEnabled]
    procedure getactivecoupons(): Text
    var
        Campaign: Record Campaign;
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        DetalleCupon: Record "Detalle Cupón";
        JObject: JsonObject;
        JArray: JsonArray;
        JCoupon: JsonObject;
        JPricesArray: JsonArray;
        JDiscountsArray: JsonArray;
        JDetailsArray: JsonArray;
        JPrice: JsonObject;
        JDiscount: JsonObject;
        JDetail: JsonObject;
        TodayDate: Date;
        JsonText: Text;
    begin
        TodayDate := WorkDate();

        // Filtrar campañas activas (cupones)
        // Una campaña se considera activa si:
        // 1. Está marcada como activa (IsActive = true) O
        // 2. Tiene fechas de inicio y fin válidas para hoy O
        // 3. No tiene importe total descontado (cupón no utilizado completamente)
        //Campaign.SetRange(Activated, true);
        Campaign.SetFilter("Starting Date", '%1|..%2', 0D, TodayDate);
        Campaign.SetFilter("Ending Date", '%1|>=%2', 0D, TodayDate);
        if Campaign.FindSet() then begin
            repeat
                Clear(JCoupon);
                Clear(JPricesArray);
                Clear(JDiscountsArray);
                Clear(JDetailsArray);

                // Información básica del cupón
                JCoupon.Add('No', Campaign."No.");
                JCoupon.Add('Description', Campaign.Description);
                JCoupon.Add('Starting_Date', Format(Campaign."Starting Date"));
                JCoupon.Add('Ending_Date', Format(Campaign."Ending Date"));
                // si importe total descontado es >= importe descuento, el cupón está utilizado
                if Campaign."Importe Total Descontado" >= Campaign."Importe Descuento" then
                    JCoupon.Add('Status', 'Utilizado')
                else
                    JCoupon.Add('Status', 'Pendiente');
                JCoupon.Add('Active', true);

                // Información de descuentos del cupón (campos personalizados)
                JCoupon.Add('Discount_Percentage', Campaign."% Descuento");
                JCoupon.Add('Discount_Amount', Campaign."Importe Descuento");
                JCoupon.Add('Total_Discounted_Amount', Campaign."Importe Total Descontado");

                // Obtener precios de venta asociados al cupón
                SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
                SalesPrice.SetRange("Sales Code", Campaign."No.");
                SalesPrice.SetFilter("Starting Date", '%1|..%2', 0D, TodayDate);
                SalesPrice.SetFilter("Ending Date", '%1|>=%2', 0D, TodayDate);

                if SalesPrice.FindSet() then begin
                    repeat
                        Clear(JPrice);
                        JPrice.Add('Item_No', SalesPrice."Item No.");
                        JPrice.Add('Unit_Price', SalesPrice."Unit Price");
                        JPrice.Add('Currency_Code', SalesPrice."Currency Code");
                        JPrice.Add('Starting_Date', Format(SalesPrice."Starting Date"));
                        JPrice.Add('Ending_Date', Format(SalesPrice."Ending Date"));
                        JPrice.Add('Minimum_Quantity', SalesPrice."Minimum Quantity");
                        JPrice.Add('Unit_of_Measure_Code', SalesPrice."Unit of Measure Code");
                        JPrice.Add('Variant_Code', SalesPrice."Variant Code");

                        JPricesArray.Add(JPrice);
                    until SalesPrice.Next() = 0;
                end;

                // Obtener descuentos de línea asociados al cupón
                SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Campaign);
                SalesLineDiscount.SetRange("Sales Code", Campaign."No.");
                SalesLineDiscount.SetFilter("Starting Date", '%1|..%2', 0D, TodayDate);
                SalesLineDiscount.SetFilter("Ending Date", '%1|>=%2', 0D, TodayDate);

                if SalesLineDiscount.FindSet() then begin
                    repeat
                        Clear(JDiscount);
                        JDiscount.Add('Type', Format(SalesLineDiscount.Type));
                        JDiscount.Add('Code', SalesLineDiscount.Code);
                        JDiscount.Add('Line_Discount_Percentage', SalesLineDiscount."Line Discount %");
                        JDiscount.Add('Currency_Code', SalesLineDiscount."Currency Code");
                        JDiscount.Add('Starting_Date', Format(SalesLineDiscount."Starting Date"));
                        JDiscount.Add('Ending_Date', Format(SalesLineDiscount."Ending Date"));
                        JDiscount.Add('Minimum_Quantity', SalesLineDiscount."Minimum Quantity");
                        JDiscount.Add('Unit_of_Measure_Code', SalesLineDiscount."Unit of Measure Code");
                        JDiscount.Add('Variant_Code', SalesLineDiscount."Variant Code");
                        JDiscountsArray.Add(JDiscount);
                    until SalesLineDiscount.Next() = 0;
                end;

                // Obtener detalles del cupón (TPV, Cliente, Grupo Cliente, Colegio)
                DetalleCupon.SetRange("Código Cupón", Campaign."No.");
                if DetalleCupon.FindSet() then begin
                    repeat
                        Clear(JDetail);
                        JDetail.Add('Detail_Type', Format(DetalleCupon."Tipo Detalle"));
                        JDetail.Add('No', DetalleCupon."No.");
                        JDetail.Add('Discount_Percentage', DetalleCupon."% Descuento");
                        JDetail.Add('Discount_Amount', DetalleCupon."Importe Descuento");
                        JDetail.Add('Total_Discounted_Amount', DetalleCupon."Importe Total Descontado");
                        if DetalleCupon."Importe Descuento" >= DetalleCupon."Importe Total Descontado" then
                            JDetail.Add('Status', 'Utilizado')
                        else
                            JDetail.Add('Status', 'Pendiente');
                        JDetailsArray.Add(JDetail);
                    until DetalleCupon.Next() = 0;
                end;

                // Agregar arrays al objeto cupón
                JCoupon.Add('Sales_Prices', JPricesArray);
                JCoupon.Add('Line_Discounts', JDiscountsArray);
                JCoupon.Add('Coupon_Details', JDetailsArray);

                JArray.Add(JCoupon);
            until Campaign.Next() = 0;
        end;

        JObject.Add('Active_Coupons', JArray);
        JObject.Add('Total_Count', JArray.Count);
        JObject.Add('Query_Date', Format(TodayDate));
        JObject.WriteTo(JsonText);

        exit(JsonText);
    end;

    /// <summary>
    /// GetProductStock.
    /// Devuelve el stock de productos por almacén en formato JSON.
    /// Si el producto está en blanco, devuelve todos los productos.
    /// Si el almacén está en blanco, devuelve todos los almacenes.
    /// </summary>
    /// <param name="ItemNo">Code[20] - Número del producto (opcional)</param>
    /// <param name="LocationCode">Code[10] - Código del almacén (opcional)</param>
    /// <returns>Return value of type Text - JSON con el stock de productos por almacén.</returns>
    [ServiceEnabled]
    procedure getproductostock(ItemNo: Code[20]; LocationCode: Code[10]): Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        Location: Record Location;
        JObject: JsonObject;
        JArray: JsonArray;
        JStock: JsonObject;
        JsonText: Text;
        CurrentItemNo: Code[20];
        CurrentLocationCode: Code[10];
        StockQuantity: Decimal;
        ProcessedCombinations: Dictionary of [Text, Boolean];
        CombinationKey: Text;
    begin
        // Validar si el producto existe (si se especifica)
        if ItemNo <> '' then begin
            if not Item.Get(ItemNo) then begin
                JObject.Add('Error', 'El producto ' + ItemNo + ' no existe');
                JObject.WriteTo(JsonText);
                exit(JsonText);
            end;
        end;

        // Validar si el almacén existe (si se especifica)
        if LocationCode <> '' then begin
            if not Location.Get(LocationCode) then begin
                JObject.Add('Error', 'El almacén ' + LocationCode + ' no existe');
                JObject.WriteTo(JsonText);
                exit(JsonText);
            end;
        end;

        // Configurar filtros en Item Ledger Entry
        ItemLedgerEntry.SetCurrentKey("Item No.", "Location Code");

        if ItemNo <> '' then
            ItemLedgerEntry.SetRange("Item No.", ItemNo);

        if LocationCode <> '' then
            ItemLedgerEntry.SetRange("Location Code", LocationCode);

        // Procesar entradas y calcular stock por producto y almacén
        if ItemLedgerEntry.FindSet() then begin
            repeat
                CurrentItemNo := ItemLedgerEntry."Item No.";
                CurrentLocationCode := ItemLedgerEntry."Location Code";
                CombinationKey := CurrentItemNo + '|' + CurrentLocationCode;

                // Verificar si ya procesamos esta combinación
                if not ProcessedCombinations.ContainsKey(CombinationKey) then begin
                    ProcessedCombinations.Add(CombinationKey, true);

                    // Calcular stock total para esta combinación producto-almacén
                    TempItemLedgerEntry.Copy(ItemLedgerEntry);
                    TempItemLedgerEntry.SetRange("Item No.", CurrentItemNo);
                    TempItemLedgerEntry.SetRange("Location Code", CurrentLocationCode);
                    TempItemLedgerEntry.CalcSums("Quantity");
                    StockQuantity := TempItemLedgerEntry."Quantity";


                    // Solo agregar si hay stock o si se solicita específicamente
                    if (StockQuantity <> 0) or (ItemNo <> '') or (LocationCode <> '') then begin
                        Clear(JStock);

                        // Información del producto
                        JStock.Add('Item_No', CurrentItemNo);
                        if Item.Get(CurrentItemNo) then begin
                            JStock.Add('Item_Description', Item.Description);
                            JStock.Add('Item_Description_2', Item."Description 2");
                            JStock.Add('Base_Unit_of_Measure', Item."Base Unit of Measure");
                            JStock.Add('Item_Category_Code', Item."Item Category Code");
                            JStock.Add('Type', Format(Item.Type));
                            JStock.Add('Blocked', Item.Blocked);


                        end else begin
                            JStock.Add('Item_Description', '');
                            JStock.Add('Item_Description_2', '');
                            JStock.Add('Base_Unit_of_Measure', '');
                            JStock.Add('Item_Category_Code', '');
                            JStock.Add('Type', '');
                            JStock.Add('Blocked', false);

                        end;

                        // Información del almacén
                        JStock.Add('Location_Code', CurrentLocationCode);
                        if Location.Get(CurrentLocationCode) then begin
                            JStock.Add('Location_Name', Location.Name);
                            JStock.Add('Location_Address', Location.Address);
                            JStock.Add('Location_City', Location.City);
                            JStock.Add('Location_Contact', Location.Contact);
                        end else begin
                            JStock.Add('Location_Name', '');
                            JStock.Add('Location_Address', '');
                            JStock.Add('Location_City', '');
                            JStock.Add('Location_Contact', '');
                        end;

                        // Información del stock
                        JStock.Add('Stock_Quantity', StockQuantity);
                        JStock.Add('Last_Update_Date', Format(WorkDate()));



                        JArray.Add(JStock);
                    end;
                end;

            until ItemLedgerEntry.Next() = 0;
        end;

        // Construir respuesta JSON
        JObject.Add('Product_Stock', JArray);
        JObject.Add('Total_Records', JArray.Count);
        JObject.Add('Query_Date', Format(WorkDate()));

        if ItemNo <> '' then
            JObject.Add('Filtered_Item', ItemNo)
        else
            JObject.Add('Filtered_Item', 'ALL');

        if LocationCode <> '' then
            JObject.Add('Filtered_Location', LocationCode)
        else
            JObject.Add('Filtered_Location', 'ALL');

        JObject.WriteTo(JsonText);
        exit(JsonText);
    end;

}





