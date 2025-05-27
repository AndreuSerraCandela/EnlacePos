/// <summary>
/// Codeunit Importaciones (ID 90100).
/// Proporciona funcionalidad para la importación y exportación de datos mediante servicios web.
/// Gestiona operaciones relacionadas con productos, recursos, clientes, proveedores, facturas, cajas y TPVs.
/// </summary>
codeunit 91100 Importaciones
{
    TableNo = "TPV Cue";
    Permissions = TableData 18 = rimd,
    tabledata 23 = rimd,
    tabledata 27 = rimd,
    tabledata 36 = rimd,
    tabledata 37 = rimd,
    tabledata 38 = rimd,
    tabledata 39 = rimd,
    tabledata 91108 = rimd,
    tabledata 91107 = rimd,
    tabledata 91150 = rimd,
    tabledata 91100 = rimd,
    tabledata 91120 = rimd;
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
    /// insertaRecrusos.
    /// Importa datos de recursos desde un formato JSON estructurado.
    /// Permite crear nuevos recursos o actualizar los existentes según la estructura JSON.
    /// Si el número de recurso es "TEMP" o vacío, crea un nuevo recurso con numeración automática.
    /// Gestiona todos los atributos y propiedades del recurso.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaRecrusos(Data: Text): Text
    var
        JResToken: JsonToken;
        JResObj: JsonObject;
        JResources: JsonArray;
        JRes: JsonObject;
        ResourceT: Record Resource temporary;
        JToken: JsonToken;
        Texto: Text;
        Res: Record Resource;
        RecRef2: RecordRef;
        ResourceRecRef: RecordRef;
        PurchSetup: Record "Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
        ResourceTempl: Record Resource;
        ResourceFldRef: FieldRef;
        ResRecRef: RecordRef;
        EmptyResourceRecRef: RecordRef;
        EmptyResourceTemplRecRef: RecordRef;
        ResFldRef: FieldRef;
        EmptyResFldRef: FieldRef;
        ResourceTemplFldRef: FieldRef;
        EmptyResourceFldRef: FieldRef;
        i: Integer;
    begin
        JResToken.ReadFrom(Data);
        JResObj := JResToken.AsObject();


        JResObj.SelectToken('Resources', JResToken);
        JResources := JResToken.AsArray();
        foreach JToken in JResources do begin

            ResourceT."No." := GetValueAsText(JToken, 'No_');
            Texto := GetValueAsText(JToken, 'Type');
            Case Texto Of
                'Machine', 'Maquina':
                    ResourceT."Type" := "Resource Type"::Machine;
                'Person', 'Persona':
                    ResourceT."Type" := "Resource Type"::Person;
            End;

            ResourceT."Name" := GetValueAsText(JToken, 'Name');
            ResourceT."Search Name" := GetValueAsText(JToken, 'Search_Name');
            ResourceT."Name 2" := GetValueAsText(JToken, 'Name_2');
            ResourceT."Address" := GetValueAsText(JToken, 'Address');
            ResourceT."Address 2" := GetValueAsText(JToken, 'Address_2');
            ResourceT."City" := GetValueAsText(JToken, 'City');
            ResourceT."Social Security No." := GetValueAsText(JToken, 'Social_Security No_');
            ResourceT."Job Title" := GetValueAsText(JToken, 'Job_Title');
            ResourceT."Education" := GetValueAsText(JToken, 'Education');
            ResourceT."Contract Class" := GetValueAsText(JToken, 'Contract_Class');
            if evaluate(ResourceT."Employment Date", GetValueAsText(JToken, 'Employment_Date')) Then;
            ResourceT."Resource Group No." := GetValueAsText(JToken, 'Resource_Group_No_');
            ResourceT."Global Dimension 1 Code" := GetValueAsText(JToken, 'Global_Dimension_1_Code');
            ResourceT."Global Dimension 2 Code" := GetValueAsText(JToken, 'Global_Dimension_2_Code');
            ResourceT."Base Unit of Measure" := GetValueAsText(JToken, 'Base_Unit_of_Measure');
            ResourceT."Direct Unit Cost" := GetValueAsDecimal(JToken, 'Direct_Unit Cost');
            ResourceT."Indirect Cost %" := GetValueAsdecimal(JToken, 'Indirect_Cost__');
            ResourceT."Unit Cost" := GetValueAsDecimal(JToken, 'Unit_Cost');
            ResourceT."Profit %" := GetValueAsDecimal(JToken, 'Profit__');
            Texto := GetValueAsText(JToken, 'Price_Profit_Calculation');
            Case Texto Of
                'No Relationship', 'Sin Relación':
                    ResourceT."Price/Profit Calculation" := ResourceT."Price/Profit Calculation"::"No Relationship";
                'Price=Cost+Profit', 'Precio=Coste+Beneficio':
                    ResourceT."Price/Profit Calculation" := ResourceT."Price/Profit Calculation"::"Price=Cost+Profit";
                'Profit=Price-Cost', 'Beneficio=Precio-Coste':
                    ResourceT."Price/Profit Calculation" := ResourceT."Price/Profit Calculation"::"Profit=Price-Cost";
            End;
            ResourceT."Unit Price" := GetValueAsDecimal(JToken, 'Unit_Price');
            ResourceT."Vendor No." := GetValueAsText(JToken, 'Vendor_No_');
            //ResourceT."Last Date Modified" := GetValueAsText(JToken, 'Last Date Modified');
            ResourceT."Gen. Prod. Posting Group" := GetValueAsText(JToken, 'Gen__Prod__Posting_Group');
            ResourceT."Post Code" := GetValueAsText(JToken, 'Post_Code');
            ResourceT."County" := GetValueAsText(JToken, 'County');
            ResourceT."Automatic Ext. Texts" := GetValueAsBoolean(JToken, 'Automatic_Ext__Texts');
            ResourceT."No. Series" := GetValueAsText(JToken, 'No__Series');
            //ResourceT."Tax Group Code" := GetValueAsText(JToken, 'Tax Group_Code');
            ResourceT."VAT Prod. Posting Group" := GetValueAsText(JToken, 'VAT_Prod__Posting_Group');
            ResourceT."Country/Region Code" := GetValueAsText(JToken, 'Country_Region_Code');
            ResourceT."IC Partner Purch. G/L Acc. No." := GetValueAsText(JToken, 'IC_Partner_Purch__G_L_Acc__No_');
            // ResourceT."Image" := GetValueAsText(JToken, 'Image');
            ResourceT."Privacy Blocked" := GetValueAsBoolean(JToken, 'Privacy_Blocked');
            //ResourceT."Coupled_to_CRM" := GetValueAsText(JToken, 'Coupled to CRM');
            //ResourceT."Use Time Sheet" := GetValueAsText(JToken, 'Use Time Sheet');
            ResourceT."Time Sheet Owner User ID" := GetValueAsText(JToken, 'Time_Sheet_Owner_User_ID');
            ResourceT."Time Sheet Approver User ID" := GetValueAsText(JToken, 'Time_Sheet_Approver_User_ID');
            ResourceT."Default Deferral Template Code" := GetValueAsText(JToken, 'Default_Deferral_Template_Code');
            //ResourceT."Service Zone Filter" := GetValueAsText(JToken, 'Service Zone Filter');

            If (ResourceT."No." = 'TEMP') or (ResourceT."No." = '') Then begin

                PurchSetup.Get();
                Res := ResourceT;
                Res."No. Series" := PurchSetup."Resource Nos.";
                Res."No." := NoSeriesMgt.GetNextNo(PurchSetup."Resource Nos.", Today, true);
                Res.Insert();
                ResourceTempl.FindFirst();
                ResourceRecRef.Gettable(ResourceTempl);

                EmptyResourceRecRef.Open(Database::Resource);
                EmptyResourceRecRef.Init();
                If Res.Get(ResourceT."No.") Then begin
                    ResRecRef.GetTable(Res);
                    for i := 1 to ResourceRecRef.FieldCount do begin
                        ResourceFldRef := ResourceRecRef.FieldIndex(i);
                        ResFldRef := ResRecRef.Field(ResourceFldRef.Number);
                        EmptyResourceFldRef := EmptyResourceRecRef.Field(ResourceFldRef.Number);
                        if (ResourceFldRef.Value <> EmptyResourceFldRef.Value) and (ResFldRef.Value = EmptyResourceFldRef.Value)
                            then
                            ResFldRef.Value := ResourceFldRef.Value;
                    end;
                    ResRecRef.Modify();
                end;
                ResourceT."No." := Res."No.";
            end else begin
                ResourceRecRef.Gettable(ResourceT);
                EmptyResourceRecRef.Open(Database::Resource);
                EmptyResourceRecRef.Init();
                If Res.Get(ResourceT."No.") Then begin
                    ResRecRef.GetTable(Res);
                    for i := 1 to ResourceRecRef.FieldCount do begin
                        ResourceFldRef := ResourceRecRef.FieldIndex(i);
                        ResFldRef := ResRecRef.Field(ResourceFldRef.Number);
                        EmptyResourceFldRef := EmptyResourceRecRef.Field(ResourceFldRef.Number);
                        if (ResourceFldRef.Value <> EmptyResourceFldRef.Value)
                            then
                            ResFldRef.Value := ResourceFldRef.Value;
                    end;

                    ResRecRef.Modify();
                end;

                ResourceT."No." := Res."No.";
            end;
            exit(ResourceT."No.");
        end;
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
            CustT."Payment Days Code" := GetValueAsText(JToken, 'Payment_Days_Code');
            CustT."Non-Paymt. Periods Code" := GetValueAsText(JToken, 'Non_Paymt__Periods_Code');
            CustT."Not in AEAT" := GetValueAsBoolean(JToken, 'Not_in_AEAT');

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
    /// <summary>
    /// insertaProveedores.
    /// Importa datos de proveedores desde un formato JSON estructurado.
    /// Permite crear nuevos proveedores o actualizar los existentes según la estructura JSON.
    /// Si el número de proveedor es "TEMP" o vacío, crea un nuevo proveedor con numeración automática.
    /// Aplica plantillas de proveedor y gestiona datos de dirección, contacto y configuración comercial.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaProveedores(Data: Text): Text
    var
        JVendorToken: JsonToken;
        JVendorObj: JsonObject;
        JVendors: JsonArray;
        JVendor: JsonObject;
        VendorT: Record Vendor temporary;
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
    begin
        JVendorToken.ReadFrom(Data);
        JVendorObj := JVendorToken.AsObject();


        JVendorObj.SelectToken('Vendors', JVendorToken);
        JVendors := JVendorToken.AsArray();
        foreach JToken in JVendors do begin


            VendorT."No." := GetValueAsText(JToken, 'No_');
            VendorT."Name" := GetValueAsText(JToken, 'Name');
            VendorT."Search Name" := GetValueAsText(JToken, 'Search_Name');
            VendorT."Name 2" := GetValueAsText(JToken, 'Name_2');
            VendorT."Address" := GetValueAsText(JToken, 'Address');
            VendorT."Address 2" := GetValueAsText(JToken, 'Address_2');
            VendorT."City" := GetValueAsText(JToken, 'City');
            VendorT."Contact" := GetValueAsText(JToken, 'Contact');
            VendorT."Phone No." := GetValueAsText(JToken, 'Phone_No_');
            VendorT."Telex No." := GetValueAsText(JToken, 'Telex_No_');
            VendorT."Our Account No." := GetValueAsText(JToken, 'Our_Account_No_');
            VendorT."Territory Code" := GetValueAsText(JToken, 'Territory_Code');
            VendorT."Global Dimension 1 Code" := GetValueAsText(JToken, 'Global_Dimension_1_Code');
            VendorT."Global Dimension 2 Code" := GetValueAsText(JToken, 'Global_Dimension_2_Code');
            VendorT."Budgeted Amount" := GetValueAsDecimal(JToken, 'Budgeted_Amount');
            VendorT."Vendor Posting Group" := GetValueAsText(JToken, 'Vendor_Posting_Group');
            VendorT."Currency Code" := GetValueAsText(JToken, 'Currency_Code');
            VendorT."Language Code" := GetValueAsText(JToken, 'Language_Code');
            VendorT."Statistics Group" := GetValueAsInteger(JToken, 'Statistics_Group');
            VendorT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Code');
            VendorT."Fin. Charge Terms Code" := GetValueAsText(JToken, 'Fin__Charge_Terms_Code');
            VendorT."Purchaser Code" := GetValueAsText(JToken, 'Purchaser_Code');
            VendorT."Shipment Method Code" := GetValueAsText(JToken, 'Shipment_Method_Code');
            VendorT."Shipping Agent Code" := GetValueAsText(JToken, 'Shipping_Agent_Code');
            VendorT."Invoice Disc. Code" := GetValueAsText(JToken, 'Invoice_Disc__Code');
            VendorT."Country/Region Code" := GetValueAsText(JToken, 'Country_Region_Code');
            Texto := GetValueAsText(JToken, 'Blocked');
            Case Texto Of
                ' ':
                    VendorT."Blocked" := "Vendor Blocked"::" ";
                'All', 'Todos':
                    VendorT."Blocked" := "Vendor Blocked"::All;
                'Payment', 'Pago':
                    VendorT."Blocked" := "Vendor Blocked"::Payment;
            End;
            VendorT."Pay-to Vendor No." := GetValueAsText(JToken, 'Pay_to_Vendor_No_');
            VendorT."Priority" := GetValueAsInteger(JToken, 'Priority');
            VendorT."Payment Method Code" := GetValueAsText(JToken, 'Payment_Method_Code');
            // VendorT."Last Modified Date Time":=GetValueAsText(JToken, 'Last_Modified_Date_Time');
            // VendorT."Last Date Modified":=GetValueAsText(JToken, 'Last_Dat_ Modified');
            // VendorT."Application Method":=GetValueAsText(JToken, 'Application_Method');
            VendorT."Prices Including VAT" := GetValueAsBoolean(JToken, 'Prices_Including_VAT');
            VendorT."Fax No." := GetValueAsText(JToken, 'Fax_No_');
            VendorT."Telex Answer Back" := GetValueAsText(JToken, 'Telex_Answer_Back');
            VendorT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            VendorT."Gen. Bus. Posting Group" := GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            // VendorT."Picture;Vendor."Picture"){}
            VendorT."GLN" := GetValueAsText(JToken, 'GLN');
            VendorT."Post Code" := GetValueAsText(JToken, 'Post_Code');
            VendorT."County" := GetValueAsText(JToken, 'County');
            VendorT."EORI Number" := GetValueAsText(JToken, 'EORI_Number');
            VendorT."E-Mail" := GetValueAsText(JToken, 'E_Mail');
            //VendorT."Home Page" := GetValueAsText(JToken, 'Home_Page');
            //VendorT."No. Series":=GetValueAsText(JToken, 'No__Series');
            //VendorT."Tax Area Code":=GetValueAsText(JToken, 'Tax_Area_Code');
            //VendorT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            VendorT."VAT Bus. Posting Group" := GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            //VendorT."Block_Payment_Tolerance":=GetValueAsText(JToken, 'Block_Payment_Tolerance');
            VendorT."IC Partner Code" := GetValueAsText(JToken, 'IC_Partner_Code');
            VendorT."Prepayment %" := GetValueAsInteger(JToken, 'Prepayment__');
            Texto := GetValueAsText(JToken, 'Partner_Type');
            Case Texto Of
                ' ':
                    VendorT."Partner Type" := "Partner Type"::" ";
                'Company', 'Empresa':
                    VendorT."Partner Type" := "Partner Type"::Company;
                'Person', 'Persona':
                    VendorT."Partner Type" := "Partner Type"::Person;
            End;
            //VendorT."Intrastat Partner Type":=GetValueAsText(JToken, 'Intrastat_Partner_Type');
            //VendorT."Image":=GetValueAsText(JToken, 'Image');
            VendorT."Privacy Blocked" := GetValueAsBoolean(JToken, 'Privacy_Blocked');
            //VendorT."Disable_Search_by_Name":=GetValueAsText(JToken, 'Disable_Search_by_Name');
            VendorT."Creditor No." := GetValueAsText(JToken, 'Creditor_No_');
            VendorT."Preferred Bank Account Code" := GetValueAsText(JToken, 'Preferred_Bank_Account_Code');
            //VendorT."Coupled to CRM":=GetValueAsText(JToken, 'Coupled_to_CRM');
            VendorT."Cash Flow Payment Terms Code" := GetValueAsText(JToken, 'Cash_Flow_Payment_Terms_Code');
            VendorT."Primary Contact No." := GetValueAsText(JToken, 'Primary_Contact_No_');
            VendorT."Mobile Phone No." := GetValueAsText(JToken, 'Mobile_Phone_No_');
            VendorT."Responsibility Center" := GetValueAsText(JToken, 'Responsibility_Center');
            VendorT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            // VendorT."Lead Time Calculation":=GetValueAsText(JToken, 'Lead_Time_Calculation');
            // VendorT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            VendorT."Base Calendar Code" := GetValueAsText(JToken, 'Base_Calendar_Code');
            VendorT."Document Sending Profile" := GetValueAsText(JToken, 'Document_Sending_Profile');
            VendorT."Validate EU Vat Reg. No." := GetValueAsBoolean(JToken, 'Validate_EU_Vat_Reg__No_');
            // VendorT."Currency_Id":=GetValueAsText(JToken, 'Currency_Id');
            // VendorT."Payment_Terms_Id":=GetValueAsText(JToken, 'Payment_Terms_Id');
            // VendorT."Payment_Method_Id":=GetValueAsText(JToken, 'Payment_Method_Id');
            VendorT."Over-Receipt Code" := GetValueAsText(JToken, 'Over-Receipt_Code');
            VendorT."Payment Days Code" := GetValueAsText(JToken, 'Payment_Days_Code');
            VendorT."Non-Paymt. Periods Code" := GetValueAsText(JToken, 'Non_Paymt__Periods_Code');
            // VendorT."Self_Employed;Vendor."Self Employed"){}

            If (VendorT."No." = 'TEMP') or (VendorT."No." = '') Then begin

                PurchSetup.Get();
                PurchSetup.TestField("Vendor Nos.");
                Vend := VendorT;
                Vend."No. Series" := PurchSetup."Vendor Nos.";
                Vend."No." := NoSeriesMgt.GetNextNo(PurchSetup."Vendor Nos.", Today, true);
                Vend.Insert();
                PurchSetup.TestField(VendorTemplate);
                VendorTempl.Get(PurchSetup.VendorTemplate);
                VendorTemplMgt.ApplyVendorTemplate(Vend, VendorTempl);
                VendorT."No." := Vend."No.";
            end else begin
                VendorRecRef.Gettable(VendorT);
                EmptyVendorRecRef.Open(Database::Vendor);
                EmptyVendorRecRef.Init();
                If Vend.Get(VendorT."No.") Then begin
                    VendRecRef.GetTable(Vend);
                    for i := 1 to VendorRecRef.FieldCount do begin
                        VendorFldRef := VendorRecRef.FieldIndex(i);
                        VendFldRef := VendRecRef.Field(VendorFldRef.Number);
                        EmptyVendorFldRef := EmptyVendorRecRef.Field(VendorFldRef.Number);
                        if (VendorFldRef.Value <> EmptyVendorFldRef.Value)
                            then
                            VendFldRef.Value := VendorFldRef.Value;
                    end;

                    VendRecRef.Modify();
                end;

                VendorT."No." := Vend."No.";
            end;
        end;
        exit(VendorT."No.");
    end;
    /// <summary>
    /// insertaFacturasVenta.
    /// Importa facturas de venta desde un formato JSON estructurado.
    /// Procesa la creación de nuevas facturas de venta a partir de los datos proporcionados.
    /// Gestiona información como cliente, dirección, condiciones de pago, datos fiscales, esquemas especiales, etc.
    /// Si la factura ya existe, se lanzará un error pues no está implementada la modificación.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
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
        Caja: Record Cajas;
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
            SalesHeaderT.Caja := GetValueAsText(JToken, 'Caja');
            if SalesHeaderT.Caja <> '' Then begin
                Caja.Get(SalesHeaderT.Caja);
                SalesHeaderT.TPV := Caja.Tpv;
            end;
            SalesHeaderT.Turno := GetValueAsText(JToken, 'Turno');
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
            SalesHeaderT."Corrected Invoice No." := GetValueAsText(JToken, 'Corrected_Invoice_No_');
            //SalesHeaderT."Due Date Modified":=GetValueAsText(JToken, 'Due_Date_Modified');
            // SalesHeaderT."Invoice Type":=GetValueAsText(JToken, 'Invoice_Type');
            // SalesHeaderT."Cr. Memo Type":=GetValueAsText(JToken, 'Cr__Memo_Type');
            IdSpecial := GetValueAsText(JToken, 'Special_Scheme_Code');
            Case IdSpecial Of
                '00':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"01 General";
                '01':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"02 Export";
                '03':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"03 Special System";
                '04':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"04 Gold";
                '05':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"05 Travel Agencies";
                '06':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"06 Groups of Entities";
                '07':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"07 Special Cash";
                '08':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"08  IPSI / IGIC";
                '09':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"09 Travel Agency Services";
                '10':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"10 Third Party";
                '11':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"11 Business Withholding";
                '12':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"12 Business not Withholding";
                '13':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"13 Business Withholding and not Withholding";
                '14':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"14 Invoice Work Certification";
                '15':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"15 Invoice of Consecutive Nature";
                '16':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"16 First Half 2017";
                '17':
                    SalesHeaderT."Special Scheme Code" := SalesHeaderT."Special Scheme Code"::"17 Operations Under The One-Stop-Shop Regime";
            End;

            SalesHeaderT."Operation Description" := GetValueAsText(JToken, 'Operation_Description');
            // SalesHeaderT."Correction Type":=GetValueAsText(JToken, 'Correction_Type');
            SalesHeaderT."Operation Description 2" := GetValueAsText(JToken, 'Operation_Description_2');
            SalesHeaderT."Succeeded Company Name" := GetValueAsText(JToken, 'Succeeded_Company_Name');
            SalesHeaderT."Succeeded VAT Registration No." := GetValueAsText(JToken, 'Succeeded_VAT_Registration_No_');
            // SalesHeaderT."ID Type":=GetValueAsText(JToken, 'ID_Type');
            // SalesHeaderT."Do Not Send To SII":=GetValueAsText(JToken, 'Do_Not_Send_To_SII');
            // SalesHeaderT."Issued By Third Party":=GetValueAsText(JToken, 'Issued_By_Third_Party');
            // SalesHeaderT."SII First Summary Doc. No.":=GetValueAsText(JToken, 'SII_First_Summary_Doc__No_');
            // SalesHeaderT."SII Last Summary Doc. No.":=GetValueAsText(JToken, 'SII_Last_Summary_Doc__No_');
            SalesHeaderT."Applies-to Bill No." := GetValueAsText(JToken, 'Applies_to_Bill_No_');
            SalesHeaderT."Cust. Bank Acc. Code" := GetValueAsText(JToken, 'Cust__Bank_Acc__Code');
            SalesHeaderT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            SalesHeaderT."Importe total" := GetValueAsDecimal(JToken, 'importe_total');
            IdType := GetValueAsText(JToken, 'ID_Type');
            Case IdType Of
                '02':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"02-VAT Registration No.";
                '03':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"03-Passport";
                '04':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"04-ID Document";
                '05':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"05-Certificate Of Residence";
                '06':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"06-Other Probative Document";
                '07':
                    SalesHeaderT."ID Type" := SalesHeaderT."ID Type"::"07-Not On The Census";
            End;
            InvoiceType := GetValueAsText(JToken, 'Invoice_Type');
            Case InvoiceType Of
                'F1':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"F1 Invoice";
                'F2':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"F2 Simplified Invoice";
                'F3':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"F3 Invoice issued to replace simplified invoices";
                'F4':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"F4 Invoice summary entry";
                'R1':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"R1 Corrected Invoice";
                'R2':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"R2 Corrected Invoice (Art. 80.3)";
                'R3':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"R3 Corrected Invoice (Art. 80.4)";
                'R4':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"R4 Corrected Invoice (Other)";
                'R5':
                    SalesHeaderT."Invoice Type" := SalesHeaderT."Invoice Type"::"R5 Corrected Invoice in Simplified Invoices";
            End;
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
            If SalesHeaderT.Caja <> '' then
                Pedido.Caja := SalesHeaderT.Caja;
            If SalesHeaderT.Turno <> '' then
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
            if SalesHeaderT."VAT Registration No." <> '' then
                Pedido."Succeeded Vat Registration No." := SalesHeaderT."VAT Registration No.";
            If SalesHeaderT."ID Type".AsInteger() <> 0 Then
                Pedido."ID Type" := SalesHeaderT."ID Type";
            if SalesHeaderT."Invoice Type".AsInteger() <> 0 Then
                Pedido."Invoice Type" := SalesHeaderT."Invoice Type";
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
            if SalesHeaderT."Special Scheme Code".AsInteger() <> 0 Then
                Pedido."Special Scheme Code" := SalesHeaderT."Special Scheme Code";
            if SalesHeaderT.TPV <> '' then
                Pedido.TPV := SalesHeaderT.TPV;
            if SalesHeaderT."Invoice Discount Value" <> 0 Then
                Pedido."Invoice Discount Value" := SalesHeaderT."Invoice Discount Value";
            if SalesHeaderT."Invoice Discount Amount" <> 0 Then
                Pedido."Invoice Discount Amount" := SalesHeaderT."Invoice Discount Amount";
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
    begin
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
    /// <summary>
    /// insertaFacturasCompra.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaFacturasCompra(Data: Text): Text
    var
        JPedidoToken: JsonToken;
        JPedidoObj: JsonObject;
        JFacturas: JsonArray;
        JPedido: JsonObject;
        PurchaseHeaderT: Record "Purchase Header" temporary;
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
        Pedido: Record "Purchase Header";
    begin
        JPedidoToken.ReadFrom(Data);
        JPedidoObj := JPedidoToken.AsObject();


        JPedidoObj.SelectToken('Purchase_Headers', JPedidoToken);
        JFacturas := JPedidoToken.AsArray();
        foreach JToken in JFacturas do begin
            PurchaseHeaderT."Document Type" := PurchaseHeaderT."Document Type"::Invoice;//GetValueAsText(JToken, 'Document_Type');
            PurchaseHeaderT."Buy-from Vendor No." := GetValueAsText(JToken, 'Buy_from_Vendor_No_');
            PurchaseHeaderT."No." := GetValueAsText(JToken, 'No_');
            PurchaseHeaderT."Pay-to Vendor No." := GetValueAsText(JToken, 'Pay_to_Vendor_No_');
            PurchaseHeaderT."Pay-to Name" := GetValueAsText(JToken, 'Pay_to_Name');
            PurchaseHeaderT."Pay-to Name 2" := GetValueAsText(JToken, 'Pay_to_Name_2');
            PurchaseHeaderT."Pay-to Address" := GetValueAsText(JToken, 'Pay_to_Address');
            PurchaseHeaderT."Pay-to Address 2" := GetValueAsText(JToken, 'Pay_to_Address_2');
            PurchaseHeaderT."Pay-to City" := GetValueAsText(JToken, 'Pay_to_City');
            PurchaseHeaderT."Pay-to Contact" := GetValueAsText(JToken, 'Pay_to_Contact');
            PurchaseHeaderT."Your Reference" := GetValueAsText(JToken, 'Your_Reference');
            PurchaseHeaderT."Ship-to Code" := GetValueAsText(JToken, 'Ship_to_Code');
            PurchaseHeaderT."Ship-to Name" := GetValueAsText(JToken, 'Ship_to_Name');
            PurchaseHeaderT."Ship-to Name 2" := GetValueAsText(JToken, 'Ship_to_Name_2');
            PurchaseHeaderT."Ship-to Address" := GetValueAsText(JToken, 'Ship_to_Address');
            PurchaseHeaderT."Ship-to Address 2" := GetValueAsText(JToken, 'Ship_to_Address_2');
            PurchaseHeaderT."Ship-to City" := GetValueAsText(JToken, 'Ship_to_City');
            PurchaseHeaderT."Ship-to Contact" := GetValueAsText(JToken, 'Ship_to_Contact');
            If Evaluate(PurchaseHeaderT."Order Date", GetValueAsText(JToken, 'Order_Date')) Then;
            If Evaluate(PurchaseHeaderT."Posting Date", GetValueAsText(JToken, 'Posting_Date')) Then;
            If Evaluate(PurchaseHeaderT."Expected Receipt Date", GetValueAsText(JToken, 'Expected_Receipt_Date')) Then;
            PurchaseHeaderT."Posting Description" := GetValueAsText(JToken, 'Posting_Description');
            PurchaseHeaderT."Payment Terms Code" := GetValueAsText(JToken, 'Payment_Terms_Code');
            If Evaluate(PurchaseHeaderT."Due Date", GetValueAsText(JToken, 'Due_Date')) Then;
            // PurchaseHeaderT."Payment Discount %":=GetValueAsText(JToken, 'Payment_Discount__');
            // PurchaseHeaderT."Pmt. Discount Date":=GetValueAsText(JToken, 'Pmt__Discount_Date');
            PurchaseHeaderT."Shipment Method Code" := GetValueAsText(JToken, 'Shipment_Method_Code');
            PurchaseHeaderT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            PurchaseHeaderT."Shortcut Dimension 1 Code" := GetValueAsText(JToken, 'Shortcut_Dimension_1_Code');
            PurchaseHeaderT."Shortcut Dimension 2 Code" := GetValueAsText(JToken, 'Shortcut_Dimension_2_Code');
            PurchaseHeaderT."Vendor Posting Group" := GetValueAsText(JToken, 'Vendor_Posting_Group');
            PurchaseHeaderT."Currency Code" := GetValueAsText(JToken, 'Currency_Code');
            PurchaseHeaderT."Currency Factor" := GetValueAsdecimal(JToken, 'Currency_Factor');
            // PurchaseHeaderT."Prices Including VAT":=GetValueAsText(JToken, 'Prices_Including_VAT');
            // PurchaseHeaderT."Invoice Disc. Code":=GetValueAsText(JToken, 'Invoice_Disc__Code');
            // PurchaseHeaderT."Language Code":=GetValueAsText(JToken, 'Language_Code');
            // PurchaseHeaderT."Purchaser Code":=GetValueAsText(JToken, 'Purchaser_Code');
            // PurchaseHeaderT."Order Class":=GetValueAsText(JToken, 'Order_Class');
            // PurchaseHeaderT."Comment":=GetValueAsText(JToken, 'Comment');
            // PurchaseHeaderT."No. Printed":=GetValueAsText(JToken, 'No__Printed');
            PurchaseHeaderT."On Hold" := GetValueAsText(JToken, 'On_Hold');
            // PurchaseHeaderT."Applies-to Doc. Type":=GetValueAsText(JToken, 'Applies_to_Doc__Type');
            PurchaseHeaderT."Applies-to Doc. No." := GetValueAsText(JToken, 'Applies_to_Doc__No_');
            // PurchaseHeaderT."Bal. Account No.":=GetValueAsText(JToken, 'Bal__Account_No_');
            // PurchaseHeaderT."Recalculate Invoice Disc.":=GetValueAsText(JToken, 'Recalculate_Invoice_Disc_');
            // PurchaseHeaderT."Receive":=GetValueAsText(JToken, 'Receive');
            // PurchaseHeaderT."Invoice":=GetValueAsText(JToken, 'Invoice');
            // PurchaseHeaderT."Print Posted Documents":=GetValueAsText(JToken, 'Print_Posted_Documents');
            // PurchaseHeaderT."Amount":=GetValueAsText(JToken, 'Amount');
            // PurchaseHeaderT."Amount Including VAT":=GetValueAsText(JToken, 'Amount_Including_VAT');
            // PurchaseHeaderT."Receiving No.":=GetValueAsText(JToken, 'Receiving_No_');
            // PurchaseHeaderT."Posting No.":=GetValueAsText(JToken, 'Posting_No_');
            // PurchaseHeaderT."Last Receiving No.":=GetValueAsText(JToken, 'Last_Receiving_No_');
            // PurchaseHeaderT."Last Posting No.":=GetValueAsText(JToken, 'Last_Posting_No_');
            PurchaseHeaderT."Vendor Order No." := GetValueAsText(JToken, 'Vendor_Order_No_');
            PurchaseHeaderT."Vendor Shipment No." := GetValueAsText(JToken, 'Vendor_Shipment_No_');
            PurchaseHeaderT."Vendor Invoice No." := GetValueAsText(JToken, 'Vendor_Invoice_No_');
            PurchaseHeaderT."Vendor Cr. Memo No." := GetValueAsText(JToken, 'Vendor_Cr__Memo_No_');
            PurchaseHeaderT."VAT Registration No." := GetValueAsText(JToken, 'VAT_Registration_No_');
            // PurchaseHeaderT."Sell-to Customer No.":=GetValueAsText(JToken, 'Sell_to_Customer_No_');
            // PurchaseHeaderT."Reason Code":=GetValueAsText(JToken, 'Reason_Code');
            // PurchaseHeaderT."Gen. Bus. Posting Group":=GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            // PurchaseHeaderT."Transaction Type":=GetValueAsText(JToken, 'Transaction_Type');
            // PurchaseHeaderT."Transport Method":=GetValueAsText(JToken, 'Transport_Method');
            // PurchaseHeaderT."VAT Country/Region Code":=GetValueAsText(JToken, 'VAT_Country_Region_Code');
            // PurchaseHeaderT."Buy-from Vendor Name":=GetValueAsText(JToken, 'Buy_from_Vendor_Name');
            // PurchaseHeaderT."Buy-from Vendor Name 2":=GetValueAsText(JToken, 'Buy_from_Vendor_Name_2');
            // PurchaseHeaderT."Buy-from Address":=GetValueAsText(JToken, 'Buy_from_Address');
            // PurchaseHeaderT."Buy-from Address 2":=GetValueAsText(JToken, 'Buy_from_Address_2');
            // PurchaseHeaderT."Buy-from City":=GetValueAsText(JToken, 'Buy_from_City');
            // PurchaseHeaderT."Buy-to Post Code":=GetValueAsText(JToken, 'Pay_to_Post_Code');
            // PurchaseHeaderT."Pay-to County":=GetValueAsText(JToken, 'Pay_to_County');
            // PurchaseHeaderT."Pay-to Country/Region Code":=GetValueAsText(JToken, 'Pay_to_Country_Region_Code');
            // PurchaseHeaderT."Buy-from Post Code":=GetValueAsText(JToken, 'Buy_from_Post_Code');
            // PurchaseHeaderT."Buy-from County":=GetValueAsText(JToken, 'Buy_from_County');
            // PurchaseHeaderT."Buy-from Country/Region Code":=GetValueAsText(JToken, 'Buy_from_Country_Region_Code');
            // PurchaseHeaderT."Ship-to Post Code":=GetValueAsText(JToken, 'Ship_to_Post_Code');
            // PurchaseHeaderT."Ship-to County":=GetValueAsText(JToken, 'Ship_to_County');
            // PurchaseHeaderT."Ship-to Country/Region Code":=GetValueAsText(JToken, 'Ship_to_Country_Region_Code');
            // PurchaseHeaderT."Bal. Account Type":=GetValueAsText(JToken, 'Bal__Account_Type');
            // PurchaseHeaderT."Order Address Code":=GetValueAsText(JToken, 'Order_Address_Code');
            // PurchaseHeaderT."Entry Point":=GetValueAsText(JToken, 'Entry_Point');
            // PurchaseHeaderT."Correction":=GetValueAsText(JToken, 'Correction');
            // PurchaseHeaderT."Document Date":=GetValueAsText(JToken, 'Document_Date');
            // PurchaseHeaderT."Area":=GetValueAsText(JToken, 'PurchaseHeaderArea');
            // PurchaseHeaderT."Transaction Specification":=GetValueAsText(JToken, 'Transaction_Specification');
            // PurchaseHeaderT."Payment Method Code":=GetValueAsText(JToken, 'Payment_Method_Code');
            // PurchaseHeaderT."No. Series":=GetValueAsText(JToken, 'No__Series');
            // PurchaseHeaderT."Posting No. Series":=GetValueAsText(JToken, 'Posting_No__Series');
            // PurchaseHeaderT."Receiving No. Series":=GetValueAsText(JToken, 'Receiving_No__Series');
            // PurchaseHeaderT."Tax Area Code":=GetValueAsText(JToken, 'Tax_Area_Code');
            // PurchaseHeaderT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            // PurchaseHeaderT."VAT Bus. Posting Group":=GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            // PurchaseHeaderT."Applies-to ID":=GetValueAsText(JToken, 'Applies_to_ID');
            // PurchaseHeaderT."VAT Base Discount %":=GetValueAsText(JToken, 'VAT_Base_Discount__');
            // PurchaseHeaderT."Status":=GetValueAsText(JToken, 'Status');
            // PurchaseHeaderT."Invoice Discount Calculation":=GetValueAsText(JToken, 'Invoice_Discount_Calculation');
            // PurchaseHeaderT."Invoice Discount Value":=GetValueAsText(JToken, 'Invoice_Discount_Value');
            // PurchaseHeaderT."Send IC Document":=GetValueAsText(JToken, 'Send_IC_Document');
            // PurchaseHeaderT."IC Status":=GetValueAsText(JToken, 'IC_Status');
            // PurchaseHeaderT."Buy-from IC Partner Code":=GetValueAsText(JToken, 'Buy_from_IC_Partner_Code');
            // PurchaseHeaderT."Pay-to IC Partner Code":=GetValueAsText(JToken, 'Pay_to_IC_Partner_Code');
            // PurchaseHeaderT."IC Direction":=GetValueAsText(JToken, 'IC_Direction');
            // PurchaseHeaderT."Prepayment No.":=GetValueAsText(JToken, 'Prepayment_No_');
            // PurchaseHeaderT."Last Prepayment No.":=GetValueAsText(JToken, 'Last_Prepayment_No_');
            // PurchaseHeaderT."Prepmt. Cr. Memo No.":=GetValueAsText(JToken, 'Prepmt__Cr__Memo_No_');
            // PurchaseHeaderT."Last Prepmt. Cr. Memo No.":=GetValueAsText(JToken, 'Last_Prepmt__Cr__Memo_No_');
            // PurchaseHeaderT."Prepayment %":=GetValueAsText(JToken, 'Prepayment__');
            // PurchaseHeaderT."Prepayment No. Series":=GetValueAsText(JToken, 'Prepayment_No__Series');
            // PurchaseHeaderT."Compress Prepayment":=GetValueAsText(JToken, 'Compress_Prepayment');
            // PurchaseHeaderT."Prepayment Due Date":=GetValueAsText(JToken, 'Prepayment_Due_Date');
            // PurchaseHeaderT."Prepmt. Cr. Memo No. Series":=GetValueAsText(JToken, 'Prepmt__Cr__Memo_No__Series');
            // PurchaseHeaderT."Prepmt. Posting Description":=GetValueAsText(JToken, 'Prepmt__Posting_Description');
            // PurchaseHeaderT."Prepmt. Pmt. Discount Date":=GetValueAsText(JToken, 'Prepmt__Pmt__Discount_Date');
            // PurchaseHeaderT."Prepmt. Payment Terms Code":=GetValueAsText(JToken, 'Prepmt__Payment_Terms_Code');
            // PurchaseHeaderT."Prepmt. Payment Discount %":=GetValueAsText(JToken, 'Prepmt__Payment_Discount__');
            // PurchaseHeaderT."Quote No.":=GetValueAsText(JToken, 'Quote_No_');
            // PurchaseHeaderT."Job Queue Status":=GetValueAsText(JToken, 'Job_Queue_Status');
            // PurchaseHeaderT."Job Queue Entry ID":=GetValueAsText(JToken, 'Job_Queue_Entry_ID');
            // PurchaseHeaderT."Incoming Document Entry No.":=GetValueAsText(JToken, 'Incoming_Document_Entry_No_');
            // PurchaseHeaderT."Creditor No.":=GetValueAsText(JToken, 'Creditor_No_');
            // PurchaseHeaderT."Payment Reference":=GetValueAsText(JToken, 'Payment_Reference');
            // PurchaseHeaderT."Journal Templ. Name":=GetValueAsText(JToken, 'Journal_Templ__Name');
            // PurchaseHeaderT."Dimension Set ID":=GetValueAsText(JToken, 'Dimension_Set_ID');
            // PurchaseHeaderT."Invoice Discount Amount":=GetValueAsText(JToken, 'Invoice_Discount_Amount');
            // PurchaseHeaderT."No. of Archived Versions":=GetValueAsText(JToken, 'No__of_Archived_Versions');
            // PurchaseHeaderT."Doc. No. Occurrence":=GetValueAsText(JToken, 'Doc__No__Occurrence');
            // PurchaseHeaderT."Campaign No.":=GetValueAsText(JToken, 'Campaign_No_');
            // PurchaseHeaderT."Buy-from Contact No.":=GetValueAsText(JToken, 'Buy_from_Contact_No_');
            // PurchaseHeaderT."Pay-to Contact No.":=GetValueAsText(JToken, 'Pay_to_Contact_No_');
            // PurchaseHeaderT."Responsibility Center":=GetValueAsText(JToken, 'Responsibility_Center');
            // PurchaseHeaderT."Partially Invoiced":=GetValueAsText(JToken, 'Partially_Invoiced');
            // PurchaseHeaderT."Completely Received":=GetValueAsText(JToken, 'Completely_Received');
            // PurchaseHeaderT."Posting from Whse. Ref.":=GetValueAsText(JToken, 'Posting_from_Whse__Ref_');
            // PurchaseHeaderT."Location Filter":=GetValueAsText(JToken, 'Location_Filter');
            // PurchaseHeaderT."Requested Receipt Date":=GetValueAsText(JToken, 'Requested_Receipt_Date');
            // PurchaseHeaderT."Promised Receipt Date":=GetValueAsText(JToken, 'Promised_Receipt_Date');
            // PurchaseHeaderT."Lead Time Calculation":=GetValueAsText(JToken, 'Lead_Time_Calculation');
            // PurchaseHeaderT."Inbound Whse. Handling Time":=GetValueAsText(JToken, 'Inbound_Whse__Handling_Time');
            // PurchaseHeaderT."Date Filter":=GetValueAsText(JToken, 'Date_Filter');
            // PurchaseHeaderT."Vendor Authorization No.":=GetValueAsText(JToken, 'Vendor_Authorization_No_');
            // PurchaseHeaderT."Return Shipment No.":=GetValueAsText(JToken, 'Return_Shipment_No_');
            // PurchaseHeaderT."Return Shipment No. Series":=GetValueAsText(JToken, 'Return_Shipment_No__Series');
            // PurchaseHeaderT."Ship":=GetValueAsText(JToken, 'Ship');
            // PurchaseHeaderT."Last Return Shipment No.":=GetValueAsText(JToken, 'Last_Return_Shipment_No_');
            // PurchaseHeaderT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            //PurchaseHeaderT."Id":=eAsText(JToken, '                //fieldattribute(Id');
            // PurchaseHeaderT."Assigned User ID":=GetValueAsText(JToken, 'Assigned_User_ID');
            // PurchaseHeaderT."Pending Approvals":=GetValueAsText(JToken, 'Pending_Approvals');
            // PurchaseHeaderT."Generate Autoinvoices":=GetValueAsText(JToken, 'Generate_Autoinvoices');
            // PurchaseHeaderT."Generate Autocredit Memo":=GetValueAsText(JToken, 'Generate_Autocredit_Memo');
            // PurchaseHeaderT."Corrected Invoice No.":=GetValueAsText(JToken, 'Corrected_Invoice_No_');
            // PurchaseHeaderT."Due Date Modified":=GetValueAsText(JToken, 'Due_Date_Modified');
            // PurchaseHeaderT."Invoice Type":=GetValueAsText(JToken, 'Invoice_Type');
            // PurchaseHeaderT."Cr. Memo Type":=GetValueAsText(JToken, 'Cr__Memo_Type');
            // PurchaseHeaderT."Special Scheme Code":=GetValueAsText(JToken, 'Special_Scheme_Code');
            // PurchaseHeaderT."Operation Description":=GetValueAsText(JToken, 'Operation_Description');
            // PurchaseHeaderT."Correction Type":=GetValueAsText(JToken, 'Correction_Type');
            // PurchaseHeaderT."Operation Description 2":=GetValueAsText(JToken, 'Operation_Description_2');
            // PurchaseHeaderT."Succeeded Company Name":=GetValueAsText(JToken, 'Succeeded_Company_Name');
            // PurchaseHeaderT."Succeeded VAT Registration No.":=GetValueAsText(JToken, 'Succeeded_VAT_Registration_No_');
            // PurchaseHeaderT."ID Type":=GetValueAsText(JToken, 'ID_Type');
            // PurchaseHeaderT."Do Not Send To SII":=GetValueAsText(JToken, 'Do_Not_Send_To_SII');
            // PurchaseHeaderT."Applies-to Bill No.":=GetValueAsText(JToken, 'Applies_to_Bill_No_');
            PurchaseHeaderT."Vendor Bank Acc. Code" := GetValueAsText(JToken, 'Vendor_Bank_Acc__Code');
            If PurchaseHeaderT."No." <> '' Then Error('Falta implementar la mod. de un pedido');
            Pedido := PurchaseHeaderT;
            Pedido."No." := '';
            Pedido.Insert(true);
            Pedido.Validate("Buy-from Vendor No.");
            Pedido.Modify();
            PurchaseHeaderT."No." := Pedido."No.";

        end;
        Exit(PurchaseHeaderT."No.")

    end;
    /// <summary>
    /// insertaLineasFacturasCompra.
    /// </summary>
    /// <param name="Data">Text.</param>
    /// <returns>Return value of type Text.</returns>
    [ServiceEnabled]
    procedure insertaLineasFacturasCompra(Data: Text): Text
    var
        JLPedidoToken: JsonToken;
        JLPedidoObj: JsonObject;
        JLFacturas: JsonArray;
        JLPedido: JsonObject;
        PurchaseLineT: Record "Purchase Line" temporary;
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
        FacturasL: Record "Purchase Line";
    begin
        JLPedidoToken.ReadFrom(Data);
        JLPedidoObj := JLPedidoToken.AsObject();


        JLPedidoObj.SelectToken('Purchase_Lines', JLPedidoToken);
        JLFacturas := JLPedidoToken.AsArray();
        foreach JToken in JLFacturas do begin
            PurchaseLineT."Document Type" := PurchaseLineT."Document Type"::Invoice;//GetValueAsText(JToken, 'Document_Type');
            PurchaseLineT."Buy-from Vendor No." := GetValueAsText(JToken, 'Buy_from_Vendor_No_');
            PurchaseLineT."Document No." := GetValueAsText(JToken, 'Document_No_');
            PurchaseLineT."Line No." := GetValueAsInteger(JToken, 'Line_No_');
            Texto := GetValueAsText(JToken, 'Type');
            Case Texto Of
                ' ':
                    PurchaseLineT."Type" := "Purchase Line Type"::" ";
                'Charge (Item)', 'Cargo':
                    PurchaseLineT."Type" := "Purchase Line Type"::"Charge (Item)";
                'Fixed Asset', 'Activo Fijo':
                    PurchaseLineT."Type" := "pURCHASE Line Type"::"Fixed Asset";
                'G/L Account', 'Cuenta':
                    PurchaseLineT."Type" := "Purchase Line Type"::"G/L Account";
                'Item', 'Producto', 'Artículo':
                    PurchaseLineT."Type" := "Purchase Line Type"::Item;
                'Resource', 'Recurso':
                    PurchaseLineT."Type" := "Purchase Line Type"::Resource;
            End;
            PurchaseLineT."No." := GetValueAsText(JToken, 'No_');
            PurchaseLineT."Location Code" := GetValueAsText(JToken, 'Location_Code');
            PurchaseLineT."Posting Group" := GetValueAsText(JToken, 'Posting_Group');
            //PurchaseLineT."Expected Receipt Date":=GetValueAsText(JToken, 'Expected_Receipt_Date');
            PurchaseLineT."Description" := GetValueAsText(JToken, 'Description');
            PurchaseLineT."Description 2" := GetValueAsText(JToken, 'Description_2');
            PurchaseLineT."Unit of Measure" := GetValueAsText(JToken, 'Unit_of_Measure');
            PurchaseLineT."Quantity" := GetValueAsDecimal(JToken, 'Quantity');
            //PurchaseLineT."Outstanding Quantity":=GetValueAsText(JToken, 'Outstanding_Quantity');
            PurchaseLineT."Qty. to Invoice" := GetValueAsDecimal(JToken, 'Qty__to_Invoice');
            PurchaseLineT."Qty. to Receive" := GetValueAsDecimal(JToken, 'Qty__to_Receive');
            PurchaseLineT."Direct Unit Cost" := GetValueAsDecimal(JToken, 'Direct_Unit_Cost');
            PurchaseLineT."VAT %" := GetValueAsDecimal(JToken, 'VAT__');
            PurchaseLineT."Line Discount %" := GetValueAsDecimal(JToken, 'Line_Discount__');
            PurchaseLineT."Line Discount Amount" := GetValueAsDecimal(JToken, 'Line_Discount_Amount');
            // PurchaseLineT."Amount":=GetValueAsText(JToken, 'Amount');
            // PurchaseLineT."Amount Including VAT":=GetValueAsText(JToken, 'Amount_Including_VAT');
            // PurchaseLineT."Allow Invoice Disc.":=GetValueAsText(JToken, 'Allow_Invoice_Disc_');
            // PurchaseLineT."Gross Weight":=GetValueAsText(JToken, 'Gross_Weight');
            // PurchaseLineT."Net Weight":=GetValueAsText(JToken, 'Net_Weight');
            // PurchaseLineT."Units per Parcel":=GetValueAsText(JToken, 'Units_per_Parcel');
            // PurchaseLineT."Unit Volume":=GetValueAsText(JToken, 'Unit_Volume');
            // PurchaseLineT."Appl.-to Item Entry":=GetValueAsText(JToken, 'Appl__to_Item_Entry');
            // PurchaseLineT."Shortcut Dimension 1 Code":=GetValueAsText(JToken, 'Shortcut_Dimension_1_Code');
            // PurchaseLineT."Shortcut Dimension 2 Code":=GetValueAsText(JToken, 'Shortcut_Dimension_2_Code');
            // PurchaseLineT."Job No.":=GetValueAsText(JToken, 'Job_No_');
            // PurchaseLineT."Indirect Cost %":=GetValueAsText(JToken, 'Indirect_Cost__');
            // PurchaseLineT."Recalculate Invoice Disc.":=GetValueAsText(JToken, 'Recalculate_Invoice_Disc_');
            // PurchaseLineT."Outstanding Amount":=GetValueAsText(JToken, 'Outstanding_Amount');
            // PurchaseLineT."Qty. Rcd. Not Invoiced":=GetValueAsText(JToken, 'Qty__Rcd__Not_Invoiced');
            // PurchaseLineT."Amt. Rcd. Not Invoiced":=GetValueAsText(JToken, 'Amt__Rcd__Not_Invoiced');
            // PurchaseLineT."Quantity Received":=GetValueAsText(JToken, 'Quantity_Received');
            // PurchaseLineT."Quantity Invoiced":=GetValueAsText(JToken, 'Quantity_Invoiced');
            // PurchaseLineT."Receipt No.":=GetValueAsText(JToken, 'Receipt_No_');
            // PurchaseLineT."Receipt Line No.":=GetValueAsText(JToken, 'Receipt_Line_No_');
            // PurchaseLineT."Order No.":=GetValueAsText(JToken, 'Order_No_');
            // PurchaseLineT."Order Line No.":=GetValueAsText(JToken, 'Order_Line_No_');
            // PurchaseLineT."Profit %":=GetValueAsText(JToken, 'Profit__');
            // PurchaseLineT."Pay-to Vendor No.":=GetValueAsText(JToken, 'Pay_to_Vendor_No_');
            // PurchaseLineT."Inv. Discount Amount":=GetValueAsText(JToken, 'Inv__Discount_Amount');
            // PurchaseLineT."Vendor Item No.":=GetValueAsText(JToken, 'Vendor_Item_No_');
            // PurchaseLineT."Sales Order No.":=GetValueAsText(JToken, 'Sales_Order_No_');
            // PurchaseLineT."Sales Order Line No.":=GetValueAsText(JToken, 'Sales_Order_Line_No_');
            // PurchaseLineT."Drop Shipment":=GetValueAsText(JToken, 'Drop_Shipment');
            // PurchaseLineT."Gen. Bus. Posting Group":=GetValueAsText(JToken, 'Gen__Bus__Posting_Group');
            // PurchaseLineT."Gen. Prod. Posting Group":=GetValueAsText(JToken, 'Gen__Prod__Posting_Group');
            // PurchaseLineT."VAT Calculation Type":=GetValueAsText(JToken, 'VAT_Calculation_Type');
            // PurchaseLineT."Transaction Type":=GetValueAsText(JToken, 'Transaction_Type');
            // PurchaseLineT."Transport Method":=GetValueAsText(JToken, 'Transport_Method');
            // PurchaseLineT."Attached to Line No.":=GetValueAsText(JToken, 'Attached_to_Line_No_');
            // PurchaseLineT."Entry Point":=GetValueAsText(JToken, 'Entry_Point');
            // PurchaseLineT."Area":=GetValueAsText(JToken, 'PurchaseLineArea');
            // PurchaseLineT."Transaction Specification":=GetValueAsText(JToken, 'Transaction_Specification');
            // PurchaseLineT."Tax Area Code":=GetValueAsText(JToken, 'Tax_Area_Code');
            // PurchaseLineT."Tax Liable":=GetValueAsText(JToken, 'Tax_Liable');
            // PurchaseLineT."Tax Group Code":=GetValueAsText(JToken, 'Tax_Group_Code');
            // PurchaseLineT."Use Tax":=GetValueAsText(JToken, 'Use_Tax');
            // PurchaseLineT."VAT Bus. Posting Group":=GetValueAsText(JToken, 'VAT_Bus__Posting_Group');
            // PurchaseLineT."VAT Prod. Posting Group":=GetValueAsText(JToken, 'VAT_Prod__Posting_Group');
            // PurchaseLineT."Currency Code":=GetValueAsText(JToken, 'Currency_Code');
            // PurchaseLineT."Blanket Order No.":=GetValueAsText(JToken, 'Blanket_Order_No_');
            // PurchaseLineT."Blanket Order Line No.":=GetValueAsText(JToken, 'Blanket_Order_Line_No_');
            // PurchaseLineT."VAT Base Amount":=GetValueAsText(JToken, 'VAT_Base_Amount');
            // PurchaseLineT."Unit Cost":=GetValueAsText(JToken, 'Unit_Cost');
            // PurchaseLineT."System-Created Entry":=GetValueAsText(JToken, 'System_Created_Entry');
            // PurchaseLineT."Line Amount":=GetValueAsText(JToken, 'Line_Amount');
            // PurchaseLineT."VAT Difference":=GetValueAsText(JToken, 'VAT_Difference');
            // PurchaseLineT."Inv. Disc. Amount to Invoice":=GetValueAsText(JToken, 'Inv__Disc__Amount_to_Invoice');
            // PurchaseLineT."VAT Identifier":=GetValueAsText(JToken, 'VAT_Identifier');
            // PurchaseLineT."IC Partner Ref. Type":=GetValueAsText(JToken, 'IC_Partner_Ref__Type');
            // PurchaseLineT."IC Partner Reference":=GetValueAsText(JToken, 'IC_Partner_Reference');
            // PurchaseLineT."Prepayment %":=GetValueAsText(JToken, 'Prepayment__');
            // PurchaseLineT."Prepmt. Line Amount":=GetValueAsText(JToken, 'Prepmt__Line_Amount');
            // PurchaseLineT."Prepmt. Amt. Inv.":=GetValueAsText(JToken, 'Prepmt__Amt__Inv_');
            // PurchaseLineT."Prepmt. Amt. Incl. VAT":=GetValueAsText(JToken, 'Prepmt__Amt__Incl__VAT');
            // PurchaseLineT."Prepayment Amount":=GetValueAsText(JToken, 'Prepayment_Amount');
            // PurchaseLineT."Prepmt. VAT Base Amt.":=GetValueAsText(JToken, 'Prepmt__VAT_Base_Amt_');
            // PurchaseLineT."Prepayment VAT %":=GetValueAsText(JToken, 'Prepayment_VAT__');
            // PurchaseLineT."Prepmt. VAT Calc. Type":=GetValueAsText(JToken, 'Prepmt__VAT_Calc__Type');
            // PurchaseLineT."Prepayment VAT Identifier":=GetValueAsText(JToken, 'Prepayment_VAT_Identifier');
            // PurchaseLineT."Prepayment Tax Area Code":=GetValueAsText(JToken, 'Prepayment_Tax_Area_Code');
            // PurchaseLineT."Prepayment Tax Liable":=GetValueAsText(JToken, 'Prepayment_Tax_Liable');
            // PurchaseLineT."Prepayment Tax Group Code":=GetValueAsText(JToken, 'Prepayment_Tax_Group_Code');
            // PurchaseLineT."Prepmt Amt to Deduct":=GetValueAsText(JToken, 'Prepmt_Amt_to_Deduct');
            // PurchaseLineT."Prepmt Amt Deducted":=GetValueAsText(JToken, 'Prepmt_Amt_Deducted');
            // PurchaseLineT."Prepayment Line":=GetValueAsText(JToken, 'Prepayment_Line');
            // PurchaseLineT."Prepmt. Amount Inv. Incl. VAT":=GetValueAsText(JToken, 'Prepmt__Amount_Inv__Incl__VAT');
            // PurchaseLineT."IC Partner Code":=GetValueAsText(JToken, 'IC_Partner_Code');
            // PurchaseLineT."Prepayment VAT Difference":=GetValueAsText(JToken, 'Prepayment_VAT_Difference');
            // PurchaseLineT."Prepmt VAT Diff. to Deduct":=GetValueAsText(JToken, 'Prepmt_VAT_Diff__to_Deduct');
            // PurchaseLineT."Prepmt VAT Diff. Deducted":=GetValueAsText(JToken, 'Prepmt_VAT_Diff__Deducted');
            // PurchaseLineT."IC Item Reference No.":=GetValueAsText(JToken, 'IC_Item_Reference_No_');
            // PurchaseLineT."Pmt. Discount Amount":=GetValueAsText(JToken, 'Pmt__Discount_Amount');
            // PurchaseLineT."Prepmt. Pmt. Discount Amount":=GetValueAsText(JToken, 'Prepmt__Pmt__Discount_Amount');
            // PurchaseLineT."Dimension Set ID":=GetValueAsText(JToken, 'Dimension_Set_ID');
            // PurchaseLineT."Job Task No.":=GetValueAsText(JToken, 'Job_Task_No_');
            // PurchaseLineT."Job Line Type":=GetValueAsText(JToken, 'Job_Line_Type');
            // PurchaseLineT."Job Unit Price":=GetValueAsText(JToken, 'Job_Unit_Price');
            // PurchaseLineT."Job Total Price":=GetValueAsText(JToken, 'Job_Total_Price');
            // PurchaseLineT."Job Line Amount":=GetValueAsText(JToken, 'Job_Line_Amount');
            // PurchaseLineT."Job Line Discount Amount":=GetValueAsText(JToken, 'Job_Line_Discount_Amount');
            // PurchaseLineT."Job Line Discount %":=GetValueAsText(JToken, 'Job_Line_Discount__');
            // PurchaseLineT."Job Currency Factor":=GetValueAsText(JToken, 'Job_Currency_Factor');
            // PurchaseLineT."Job Currency Code":=GetValueAsText(JToken, 'Job_Currency_Code');
            // PurchaseLineT."Job Planning Line No.":=GetValueAsText(JToken, 'Job_Planning_Line_No_');
            // PurchaseLineT."Job Remaining Qty.":=GetValueAsText(JToken, 'Job_Remaining_Qty_');
            // PurchaseLineT."Deferral Code":=GetValueAsText(JToken, 'Deferral_Code');
            // PurchaseLineT."Returns Deferral Start Date":=GetValueAsText(JToken, 'Returns_Deferral_Start_Date');
            // PurchaseLineT."Prod. Order No.":=GetValueAsText(JToken, 'Prod__Order_No_');
            // PurchaseLineT."Variant Code":=GetValueAsText(JToken, 'Variant_Code');
            // PurchaseLineT."Bin Code":=GetValueAsText(JToken, 'Bin_Code');
            // PurchaseLineT."Qty. per Unit of Measure":=GetValueAsText(JToken, 'Qty__per_Unit_of_Measure');
            // PurchaseLineT."Qty. Rounding Precision":=GetValueAsText(JToken, 'Qty__Rounding_Precision');
            // PurchaseLineT."Unit of Measure Code":=GetValueAsText(JToken, 'Unit_of_Measure_Code');
            // PurchaseLineT."FA Posting Date":=GetValueAsText(JToken, 'FA_Posting_Date');
            // PurchaseLineT."FA Posting Type":=GetValueAsText(JToken, 'FA_Posting_Type');
            // PurchaseLineT."Depreciation Book Code":=GetValueAsText(JToken, 'Depreciation_Book_Code');
            // PurchaseLineT."Salvage Value":=GetValueAsText(JToken, 'Salvage_Value');
            // PurchaseLineT."Depr. until FA Posting Date":=GetValueAsText(JToken, 'Depr__until_FA_Posting_Date');
            // PurchaseLineT."Depr. Acquisition Cost":=GetValueAsText(JToken, 'Depr__Acquisition_Cost');
            // PurchaseLineT."Maintenance Code":=GetValueAsText(JToken, 'Maintenance_Code');
            // PurchaseLineT."Insurance No.":=GetValueAsText(JToken, 'Insurance_No_');
            // PurchaseLineT."Budgeted FA No.":=GetValueAsText(JToken, 'Budgeted_FA_No_');
            // PurchaseLineT."Duplicate in Depreciation Book":=GetValueAsText(JToken, 'Duplicate_in_Depreciation_Book');
            // PurchaseLineT."Use Duplication List":=GetValueAsText(JToken, 'Use_Duplication_List');
            // PurchaseLineT."Responsibility Center":=GetValueAsText(JToken, 'Responsibility_Center');
            // PurchaseLineT."Item Category Code":=GetValueAsText(JToken, 'Item_Category_Code');
            // PurchaseLineT."Nonstock":=GetValueAsText(JToken, 'Nonstock');
            // PurchaseLineT."Purchasing Code":=GetValueAsText(JToken, 'Purchasing_Code');
            // PurchaseLineT."Special Order":=GetValueAsText(JToken, 'Special_Order');
            // PurchaseLineT."Special Order Sales No.":=GetValueAsText(JToken, 'Special_Order_Sales_No_');
            // PurchaseLineT."Special Order Sales Line No.":=GetValueAsText(JToken, 'Special_Order_Sales_Line_No_');
            // PurchaseLineT."Item Reference No.":=GetValueAsText(JToken, 'Item_Reference_No_');
            // PurchaseLineT."Item Reference Unit of Measure":=GetValueAsText(JToken, 'Item_Reference_Unit_of_Measure');
            // PurchaseLineT."Item Reference Type":=GetValueAsText(JToken, 'Item_Reference_Type');
            // PurchaseLineT."Item Reference Type No.":=GetValueAsText(JToken, 'Item_Reference_Type_No_');
            // PurchaseLineT."Completely Received":=GetValueAsText(JToken, 'Completely_Received');
            // PurchaseLineT."Requested Receipt Date":=GetValueAsText(JToken, 'Requested_Receipt_Date');
            // PurchaseLineT."Promised Receipt Date":=GetValueAsText(JToken, 'Promised_Receipt_Date');
            // PurchaseLineT."Lead Time Calculation":=GetValueAsText(JToken, 'Lead_Time_Calculation');
            // PurchaseLineT."Inbound Whse. Handling Time":=GetValueAsText(JToken, 'Inbound_Whse__Handling_Time');
            // PurchaseLineT."Planned Receipt Date":=GetValueAsText(JToken, 'Planned_Receipt_Date');
            // PurchaseLineT."Order Date":=GetValueAsText(JToken, 'Order_Date');
            // PurchaseLineT."Allow Item Charge Assignment":=GetValueAsText(JToken, 'Allow_Item_Charge_Assignment');
            // PurchaseLineT."Return Qty. to Ship":=GetValueAsText(JToken, 'Return_Qty__to_Ship');
            // PurchaseLineT."Return Qty. Shipped Not Invd.":=GetValueAsText(JToken, 'Return_Qty__Shipped_Not_Invd_');
            // PurchaseLineT."Return Shpd. Not Invd.":=GetValueAsText(JToken, 'Return_Shpd__Not_Invd_');
            // PurchaseLineT."Return Qty. Shipped":=GetValueAsText(JToken, 'Return_Qty__Shipped');
            // PurchaseLineT."Return Shipment No.":=GetValueAsText(JToken, 'Return_Shipment_No_');
            // PurchaseLineT."Return Shipment Line No.":=GetValueAsText(JToken, 'Return_Shipment_Line_No_');
            // PurchaseLineT."Return Reason Code":=GetValueAsText(JToken, 'Return_Reason_Code');
            // PurchaseLineT."Subtype":=GetValueAsText(JToken, 'Subtype');
            // PurchaseLineT."Copied From Posted Doc.":=GetValueAsText(JToken, 'Copied_From_Posted_Doc_');
            // PurchaseLineT."Price Calculation Method":=GetValueAsText(JToken, 'Price_Calculation_Method');
            // PurchaseLineT."Over-Receipt Quantity":=GetValueAsText(JToken, 'Over_Receipt_Quantity');
            // PurchaseLineT."Over-Receipt Code":=GetValueAsText(JToken, 'Over_Receipt_Code');
            // PurchaseLineT."Over-Receipt Approval Status":=GetValueAsText(JToken, 'Over_Receipt_Approval_Status');
            // PurchaseLineT."EC %":=GetValueAsText(JToken, 'EC__');
            // PurchaseLineT."EC Difference":=GetValueAsText(JToken, 'EC_Difference');
            // PurchaseLineT."Prepayment EC %":=GetValueAsText(JToken, 'Prepayment_EC__');
            // PurchaseLineT."Routing No.":=GetValueAsText(JToken, 'Routing_No_');
            // PurchaseLineT."Operation No.":=GetValueAsText(JToken, 'Operation_No_');
            // PurchaseLineT."Work Center No.":=GetValueAsText(JToken, 'Work_Center_No_');
            // PurchaseLineT."Finished":=GetValueAsText(JToken, 'Finished');
            // PurchaseLineT."Prod. Order Line No.":=GetValueAsText(JToken, 'Prod__Order_Line_No_');
            // PurchaseLineT."Overhead Rate":=GetValueAsText(JToken, 'Overhead_Rate');
            // PurchaseLineT."MPS Order":=GetValueAsText(JToken, 'MPS_Order');
            // PurchaseLineT."Planning Flexibility":=GetValueAsText(JToken, 'Planning_Flexibility');
            // PurchaseLineT."Safety Lead Time":=GetValueAsText(JToken, 'Safety_Lead_Time');
            // PurchaseLineT."Routing Reference No.":=GetValueAsText(JToken, 'Routing_Reference_No_');

            FacturasL := PurchaseLineT;
            If FacturasL.Insert() Then begin
                FacturasL.Validate("No.", PurchaseLineT."No.");
                FacturasL.Description := PurchaseLineT.Description;
                FacturasL."Description 2" := PurchaseLineT."Description 2";
                FacturasL.Validate(Quantity, PurchaseLineT.Quantity);
                FacturasL.Validate("Direct Unit Cost", PurchaseLineT."Direct Unit Cost");
                FacturasL.Validate("Line Discount %", PurchaseLineT."Line Discount %");
                FacturasL.Modify();
            end;
        end;
        exit('Ok');
    end;

    /// <summary>
    /// GetValueAsText.
    /// </summary>
    /// <param name="JToken">JsonToken.</param>
    /// <param name="ParamString">Text.</param>
    /// <returns>Return value of type Text.</returns>
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
    /// insertaEmpleados.
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
            EmpT.Name := GetValueAsText(JToken, 'Name');
            EmpT."Second Family Name" := GetValueAsText(JToken, 'Second_Family_Name');
            EmpT."First Family Name" := GetValueAsText(JToken, 'First_Family_Name');
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
            RecTurnoTmp.No := GetValueAsText(JToken, 'No');
            // Verificar que el turno no esté vacío


            RecTurnoTMP.HorarioInicio := GetValueAsTime(JToken, 'HorarioInicio');
            RecTurnoTMP.HorarioFin := GetValueAsTime(JToken, 'HorarioFin');
            RecTurnoTmp."Descripcion Turno" := GetValueAsText(JToken, 'DescripcionTurno');
            if RecTurnoTMP.Insert() then
                TurnoCount += 1
            else
                ErrorCount += 1;
            If (RecTurnoTMP."No" = 'TEMP') Or (RecTurnoTMP."No" = '') Then begin
                RecTurno := RecTurnoTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. Turno");
                RecTurno."No" := NoSeriesMgt.GetNextNo(SalesSetup."Nums. Turno", Today, true);
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
        RecCaja: Record Cajas;
        RecCajaTmp: Record Cajas temporary;
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
            RecCajaTmp.No := GetValueAsText(JToken, 'No_');
            if RecCajaTMP.No = '' then
                RecCajaTMP.No := GetValueAsText(JToken, 'No'); // Compatibilidad con formato anterior
            RecCajaTMP.Nombre := GetValueAsText(JToken, 'Nombre');
            RecCajaTMP.TPV := GetValueAsText(JToken, 'TPV');
            if RecCajaTMP.Insert() then
                CajaCount += 1
            else
                ErrorCount += 1;


            // Verificar que la caja no esté vacía
            If (RecCajaTMP.No = 'TEMP') Or (RecCajaTMP.No = '') Then begin



                RecCaja := RecCajaTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. Caja");
                RecCaja.No := NoSeriesMgt.GetNextNo(SalesSetup."Nums. Caja", Today, true);
                RecCaja.Insert();
            end else begin
                // Actualizar caja existente o eliminarla
                if not Deleted then begin
                    CajaRecRef.Gettable(RecCajaTmp);
                    EmptyCajaRecRef.Open(Database::Cajas);
                    EmptyCajaRecRef.Init();
                    If RecCaja.Get(RecCajaTMP.No) Then begin
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
                        RecCajaTMP.No := RecCaja.No;
                        CajaCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    If RecCaja.Get(RecCajaTmp.No) Then begin
                        RecCaja.Delete();
                        CajaCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. Cajas procesadas: %1, Errores: %2', CajaCount, ErrorCount);
        exit(RecCaja.No);
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
        RecApertura: Record AperturaDeCaja;
        RecAperturaTmp: Record AperturaDeCaja temporary;
        AperturaCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        EstadoTxt: Text;
        Num: Integer;
        Cajas: Record Cajas;
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
            RecAperturaTmp.Cajero := GetValueAsText(JToken, 'Cajero');
            RecAperturaTmp.FechaDeApertura := GetValueAsDate(JToken, 'FechaDeApertura');
            RecAperturaTmp.ImporteDeApertura := GetValueAsDecimal(JToken, 'ImporteDeApertura');
            RecAperturaTmp.Caja := GetValueAsText(JToken, 'Caja');
            If RecAperturaTmp.Caja <> '' then begin
                if Cajas.Get(RecAperturaTmp.Caja) then
                    RecAperturaTmp.TPV := Cajas.TPV;
            end;
            RecAperturaTmp.Turno := GetValueAsText(JToken, 'Turno');
            RecAperturaTmp.HoraDeApertura := GetValueAsTime(JToken, 'HoraDeApertura');
            // Determinar el estado 
            EstadoTxt := GetValueAsText(JToken, 'Estado');
            if EstadoTxt = 'Cerrado' then
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::Cerrado
            else if EstadoTxt = 'Abierto' then
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::Abierto
            else if EstadoTxt = 'Turno Generado' then
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::"Turno Generado"
            else
                RecAperturaTmp.Estado := RecAperturaTmp.Estado::Abierto;

            // Verificar si existe un ID específico
            if GetValueAsText(JToken, 'No') = 'TEMP' then
                RecAperturaTmp.No := 0
            else if GetValueAsInteger(JToken, 'No') > 0 then
                RecAperturaTmp.No := GetValueAsInteger(JToken, 'No');

            if Deleted then begin
                // Buscar por ID si se especifica
                if RecAperturaTmp.No > 0 then begin
                    if RecApertura.Get(RecAperturaTmp.No) then begin
                        RecApertura.Delete();
                        AperturaCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else begin
                // Si se especifica un ID, intentar actualizar
                if RecAperturaTmp.No > 0 then begin
                    if RecApertura.Get(RecAperturaTmp.No) then begin
                        RecApertura.Cajero := RecAperturaTmp.Cajero;
                        RecApertura.FechaDeApertura := RecAperturaTmp.FechaDeApertura;
                        RecApertura.HoraDeApertura := RecAperturaTmp.HoraDeApertura;
                        RecApertura.ImporteDeApertura := RecAperturaTmp.ImporteDeApertura;
                        RecApertura.Estado := RecAperturaTmp.Estado;
                        RecApertura.Caja := RecAperturaTmp.Caja;
                        RecApertura.Turno := RecAperturaTmp.Turno;

                        if RecApertura.Modify() then
                            AperturaCount += 1
                        else
                            ErrorCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    // Insertar nueva apertura
                    RecApertura.Reset();
                    If RecApertura.FindLast() then
                        Num := RecApertura.No + 1
                    else
                        Num := 1;
                    RecApertura.Init();
                    RecApertura.TransferFields(RecAperturaTmp);
                    RecApertura.No := Num;
                    if RecApertura.Insert() then
                        AperturaCount += 1
                    else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('%1', RecApertura.No);
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
        RecCierre: Record CierreDeCaja;
        RecCierreTmp: Record CierreDeCaja temporary;
        CierreCount: Integer;
        ErrorCount: Integer;
        ResultadoText: Text;
        Deleted: Boolean;
        EstadoTxt: Text;
        Num: Integer;
        AperturaDeCaja: Record AperturaDeCaja;
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
            RecCierreTmp.Cajero := GetValueAsText(JToken, 'Cajero');
            RecCierreTmp.ImporteDeApertura := GetValueAsDecimal(JToken, 'ImporteDeApertura');
            RecCierreTmp.FechaDeApertura := GetValueAsDate(JToken, 'FechaDeApertura');
            RecCierreTmp.ImporteDeCierreBS := GetValueAsDecimal(JToken, 'ImporteDeCierreBS');
            RecCierreTmp.ImporteDeCierreUS := GetValueAsDecimal(JToken, 'ImporteDeCierreUS');
            RecCierreTmp.ImporteDeCierreEUR := GetValueAsDecimal(JToken, 'ImporteDeCierreEUR');
            RecCierreTmp.ArqueoBS := GetValueAsDecimal(JToken, 'ArqueoBS');
            RecCierreTmp.ArqueoUS := GetValueAsDecimal(JToken, 'ArqueoUS');
            RecCierreTmp.ArqueoEUR := GetValueAsDecimal(JToken, 'ArqueoEUR');
            RecCierreTmp.FechaDeCierre := GetValueAsDateTime(JToken, 'FechaDeCierre');
            RecCierreTmp.idApertura := GetValueAsInteger(JToken, 'idApertura');
            If RecCierreTmp.idApertura <> 0 then begin
                if AperturaDeCaja.Get(RecCierreTmp.idApertura) then
                    RecCierreTmp.TPV := AperturaDeCaja.TPV;
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
                RecCierreTmp.No := 0
            else if GetValueAsInteger(JToken, 'No') > 0 then
                RecCierreTmp.No := GetValueAsInteger(JToken, 'No');


            if Deleted then begin
                // Buscar por ID si se especifica
                if RecCierreTmp.No > 0 then begin
                    if RecCierre.Get(RecCierreTmp.No) then begin
                        RecCierre.Delete();
                        CierreCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end else begin
                // Si se especifica un ID, intentar actualizar
                if RecCierreTmp.No > 0 then begin
                    if RecCierre.Get(RecCierreTmp.No) then begin
                        RecCierre.Cajero := RecCierreTmp.Cajero;
                        RecCierre.ImporteDeApertura := RecCierreTmp.ImporteDeApertura;
                        RecCierre.FechaDeApertura := RecCierreTmp.FechaDeApertura;
                        RecCierre.ImporteDeCierreBS := RecCierreTmp.ImporteDeCierreBS;
                        RecCierre.ImporteDeCierreUS := RecCierreTmp.ImporteDeCierreUS;
                        RecCierre.ImporteDeCierreEUR := RecCierreTmp.ImporteDeCierreEUR;
                        RecCierre.ArqueoBS := RecCierreTmp.ArqueoBS;
                        RecCierre.ArqueoUS := RecCierreTmp.ArqueoUS;
                        RecCierre.ArqueoEUR := RecCierreTmp.ArqueoEUR;
                        RecCierre.FechaDeCierre := RecCierreTmp.FechaDeCierre;
                        RecCierre.Estado := RecCierreTmp.Estado;
                        RecCierre.idApertura := RecCierreTmp.idApertura;

                        if RecCierre.Modify() then
                            CierreCount += 1
                        else
                            ErrorCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    // Insertar nuevo cierre
                    RecCierre.Reset();
                    If RecCierre.FindLast() then
                        Num := RecCierre.No + 1
                    else
                        Num := 1;
                    RecCierre.Init();
                    RecCierre.TransferFields(RecCierreTmp);
                    RecCierre.No := Num;
                    if RecCierre.Insert() then
                        CierreCount += 1
                    else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('%1', RecCierre.No);
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
            RecDetalleTmp.idCierre := GetValueAsInteger(JToken, 'idCierre');
            RecDetalleTmp.idApertura := GetValueAsInteger(JToken, 'idApertura');
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
        RecTPV: Record TPV;
        RecTPVTmp: Record TPV temporary;
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
            RecTPVTmp."No" := GetValueAsText(JToken, 'No'); // Compatibilidad con formato anterior

            RecTPVTmp."Nombre" := GetValueAsText(JToken, 'nombre');
            if RecTPVTmp."Nombre" = '' then
                RecTPVTmp."Nombre" := GetValueAsText(JToken, 'Nombre'); // Compatibilidad

            RecTPVTmp."Dirección" := GetValueAsText(JToken, 'direccion');
            RecTPVTmp."Dirección 2" := GetValueAsText(JToken, 'direccion2');
            RecTPVTmp."Ciudad" := GetValueAsText(JToken, 'ciudad');
            RecTPVTmp."Código Postal" := GetValueAsText(JToken, 'codigoPostal');
            RecTPVTmp."Provincia" := GetValueAsText(JToken, 'provincia');
            RecTPVTmp."País" := GetValueAsText(JToken, 'pais');
            RecTPVTmp."Teléfono" := GetValueAsText(JToken, 'telefono');
            RecTPVTmp."Móvil" := GetValueAsText(JToken, 'movil');
            RecTPVTmp."Email" := GetValueAsText(JToken, 'email');
            RecTPVTmp."Sitio Web" := GetValueAsText(JToken, 'sitioWeb');
            RecTPVTmp."NIF/CIF" := GetValueAsText(JToken, 'nifCif');
            RecTPVTmp."Contacto" := GetValueAsText(JToken, 'contacto');
            RecTPVTmp."Notas" := GetValueAsText(JToken, 'notas');

            // Convertir fecha si existe
            if HasValue(JToken, 'fechaAlta') then
                Evaluate(RecTPVTmp."Fecha Alta", GetValueAsText(JToken, 'fechaAlta'));

            RecTPVTmp."Location Code" := GetValueAsText(JToken, 'locationCode');
            RecTPVTmp."No. Series" := GetValueAsText(JToken, 'noSeries');

            if RecTPVTMP.Insert() then
                TPVCount += 1
            else
                ErrorCount += 1;

            // Verificar que el TPV no esté vacío
            If (RecTPVTMP."No" = 'TEMP') Or (RecTPVTMP."No" = '') Then begin
                RecTPV := RecTPVTmp;
                SalesSetup.Get();
                SalesSetup.TestField("Nums. TPV");
                RecTPV."No" := NoSeriesMgt.GetNextNo(SalesSetup."Nums. TPV", Today, true);
                RecTPV.Insert();
            end else begin
                // Actualizar TPV existente o eliminarlo
                if not Deleted then begin
                    TPVRecRef.Gettable(RecTPVTmp);
                    EmptyTPVRecRef.Open(Database::TPV);
                    EmptyTPVRecRef.Init();
                    If RecTPV.Get(RecTPVTMP."No") Then begin
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
                        RecTPVTMP."No" := RecTPV."No";
                        TPVCount += 1;
                    end else
                        ErrorCount += 1;
                end else begin
                    If RecTPV.Get(RecTPVTmp."No") Then begin
                        RecTPV.Delete();
                        TPVCount += 1;
                    end else
                        ErrorCount += 1;
                end;
            end;
        end;

        // Preparar mensaje de resultado
        ResultadoText := StrSubstNo('Importación completada. TPVs procesados: %1, Errores: %2', TPVCount, ErrorCount);
        exit(RecTPV."No");
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
        Campaign.SetRange(Activated, true);
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
                JCoupon.Add('Active', Campaign.Activated);

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

}





