Page 75204 PurchaseLine
{
    Caption = 'PurchaseLine';
    SourceTable = "Purchase Line";
    layout
    {
        area(Content)
        {
            repeater(PurchaseLine)
            {
                field(Document_Type; Rec."Document Type") { ApplicationArea = All; }
                field(Buy_from_Vendor_No_; Rec."Buy-from Vendor No.") { ApplicationArea = All; }
                field(Document_No_; Rec."Document No.") { ApplicationArea = All; }
                field(Line_No_; Rec."Line No.") { ApplicationArea = All; }
                field(Type; Rec."Type") { ApplicationArea = All; }
                field(No_; Rec."No.") { ApplicationArea = All; }
                field(Location_Code; Rec."Location Code") { ApplicationArea = All; }
                field(Posting_Group; Rec."Posting Group") { ApplicationArea = All; }
                field(Expected_Receipt_Date; Rec."Expected Receipt Date") { ApplicationArea = All; }
                field(Description; Rec."Description") { ApplicationArea = All; }
                field(Description_2; Rec."Description 2") { ApplicationArea = All; }
                field(Unit_of_Measure; Rec."Unit of Measure") { ApplicationArea = All; }
                field(Quantity; Rec."Quantity") { ApplicationArea = All; }
                field(Outstanding_Quantity; Rec."Outstanding Quantity") { ApplicationArea = All; }
                field(Qty__to_Invoice; Rec."Qty. to Invoice") { ApplicationArea = All; }
                field(Qty__to_Receive; Rec."Qty. to Receive") { ApplicationArea = All; }
                field(Direct_Unit_Cost; Rec."Direct Unit Cost") { ApplicationArea = All; }
                field(VAT__; Rec."VAT %") { ApplicationArea = All; }
                field(Line_Discount__; Rec."Line Discount %") { ApplicationArea = All; }
                field(Line_Discount_Amount; Rec."Line Discount Amount") { ApplicationArea = All; }
                field(Amount; Rec."Amount") { ApplicationArea = All; }
                field(Amount_Including_VAT; Rec."Amount Including VAT") { ApplicationArea = All; }
                field(Allow_Invoice_Disc_; Rec."Allow Invoice Disc.") { ApplicationArea = All; }
                field(Gross_Weight; Rec."Gross Weight") { ApplicationArea = All; }
                field(Net_Weight; Rec."Net Weight") { ApplicationArea = All; }
                field(Units_per_Parcel; Rec."Units per Parcel") { ApplicationArea = All; }
                field(Unit_Volume; Rec."Unit Volume") { ApplicationArea = All; }
                field(Appl__to_Item_Entry; Rec."Appl.-to Item Entry") { ApplicationArea = All; }
                field(Shortcut_Dimension_1_Code; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field(Shortcut_Dimension_2_Code; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field(Job_No_; Rec."Job No.") { ApplicationArea = All; }
                field(Indirect_Cost__; Rec."Indirect Cost %") { ApplicationArea = All; }
                field(Recalculate_Invoice_Disc_; Rec."Recalculate Invoice Disc.") { ApplicationArea = All; }
                field(Outstanding_Amount; Rec."Outstanding Amount") { ApplicationArea = All; }
                field(Qty__Rcd__Not_Invoiced; Rec."Qty. Rcd. Not Invoiced") { ApplicationArea = All; }
                field(Amt__Rcd__Not_Invoiced; Rec."Amt. Rcd. Not Invoiced") { ApplicationArea = All; }
                field(Quantity_Received; Rec."Quantity Received") { ApplicationArea = All; }
                field(Quantity_Invoiced; Rec."Quantity Invoiced") { ApplicationArea = All; }
                field(Receipt_No_; Rec."Receipt No.") { ApplicationArea = All; }
                field(Receipt_Line_No_; Rec."Receipt Line No.") { ApplicationArea = All; }
                field(Order_No_; Rec."Order No.") { ApplicationArea = All; }
                field(Order_Line_No_; Rec."Order Line No.") { ApplicationArea = All; }
                field(Profit__; Rec."Profit %") { ApplicationArea = All; }
                field(Pay_to_Vendor_No_; Rec."Pay-to Vendor No.") { ApplicationArea = All; }
                field(Inv__Discount_Amount; Rec."Inv. Discount Amount") { ApplicationArea = All; }
                field(Vendor_Item_No_; Rec."Vendor Item No.") { ApplicationArea = All; }
                field(Sales_Order_No_; Rec."Sales Order No.") { ApplicationArea = All; }
                field(Sales_Order_Line_No_; Rec."Sales Order Line No.") { ApplicationArea = All; }
                field(Drop_Shipment; Rec."Drop Shipment") { ApplicationArea = All; }
                field(Gen__Bus__Posting_Group; Rec."Gen. Bus. Posting Group") { ApplicationArea = All; }
                field(Gen__Prod__Posting_Group; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
                field(VAT_Calculation_Type; Rec."VAT Calculation Type") { ApplicationArea = All; }
                field(Transaction_Type; Rec."Transaction Type") { ApplicationArea = All; }
                field(Transport_Method; Rec."Transport Method") { ApplicationArea = All; }
                field(Attached_to_Line_No_; Rec."Attached to Line No.") { ApplicationArea = All; }
                field(Entry_Point; Rec."Entry Point") { ApplicationArea = All; }
                field(PurchaseLineArea; Rec."Area") { ApplicationArea = All; }
                field(Transaction_Specification; Rec."Transaction Specification") { ApplicationArea = All; }
                field(Tax_Area_Code; Rec."Tax Area Code") { ApplicationArea = All; }
                field(Tax_Liable; Rec."Tax Liable") { ApplicationArea = All; }
                field(Tax_Group_Code; Rec."Tax Group Code") { ApplicationArea = All; }
                field(Use_Tax; Rec."Use Tax") { ApplicationArea = All; }
                field(VAT_Bus__Posting_Group; Rec."VAT Bus. Posting Group") { ApplicationArea = All; }
                field(VAT_Prod__Posting_Group; Rec."VAT Prod. Posting Group") { ApplicationArea = All; }
                field(Currency_Code; Rec."Currency Code") { ApplicationArea = All; }
                field(Blanket_Order_No_; Rec."Blanket Order No.") { ApplicationArea = All; }
                field(Blanket_Order_Line_No_; Rec."Blanket Order Line No.") { ApplicationArea = All; }
                field(VAT_Base_Amount; Rec."VAT Base Amount") { ApplicationArea = All; }
                field(Unit_Cost; Rec."Unit Cost") { ApplicationArea = All; }
                field(System_Created_Entry; Rec."System-Created Entry") { ApplicationArea = All; }
                field(Line_Amount; Rec."Line Amount") { ApplicationArea = All; }
                field(VAT_Difference; Rec."VAT Difference") { ApplicationArea = All; }
                field(Inv__Disc__Amount_to_Invoice; Rec."Inv. Disc. Amount to Invoice") { ApplicationArea = All; }
                field(VAT_Identifier; Rec."VAT Identifier") { ApplicationArea = All; }
                field(IC_Partner_Ref__Type; Rec."IC Partner Ref. Type") { ApplicationArea = All; }
                field(IC_Partner_Reference; Rec."IC Partner Reference") { ApplicationArea = All; }
                field(Prepayment__; Rec."Prepayment %") { ApplicationArea = All; }
                field(Prepmt__Line_Amount; Rec."Prepmt. Line Amount") { ApplicationArea = All; }
                field(Prepmt__Amt__Inv_; Rec."Prepmt. Amt. Inv.") { ApplicationArea = All; }
                field(Prepmt__Amt__Incl__VAT; Rec."Prepmt. Amt. Incl. VAT") { ApplicationArea = All; }
                field(Prepayment_Amount; Rec."Prepayment Amount") { ApplicationArea = All; }
                field(Prepmt__VAT_Base_Amt_; Rec."Prepmt. VAT Base Amt.") { ApplicationArea = All; }
                field(Prepayment_VAT__; Rec."Prepayment VAT %") { ApplicationArea = All; }
                field(Prepmt__VAT_Calc__Type; Rec."Prepmt. VAT Calc. Type") { ApplicationArea = All; }
                field(Prepayment_VAT_Identifier; Rec."Prepayment VAT Identifier") { ApplicationArea = All; }
                field(Prepayment_Tax_Area_Code; Rec."Prepayment Tax Area Code") { ApplicationArea = All; }
                field(Prepayment_Tax_Liable; Rec."Prepayment Tax Liable") { ApplicationArea = All; }
                field(Prepayment_Tax_Group_Code; Rec."Prepayment Tax Group Code") { ApplicationArea = All; }
                field(Prepmt_Amt_to_Deduct; Rec."Prepmt Amt to Deduct") { ApplicationArea = All; }
                field(Prepmt_Amt_Deducted; Rec."Prepmt Amt Deducted") { ApplicationArea = All; }
                field(Prepayment_Line; Rec."Prepayment Line") { ApplicationArea = All; }
                field(Prepmt__Amount_Inv__Incl__VAT; Rec."Prepmt. Amount Inv. Incl. VAT") { ApplicationArea = All; }
                field(IC_Partner_Code; Rec."IC Partner Code") { ApplicationArea = All; }
                field(Prepayment_VAT_Difference; Rec."Prepayment VAT Difference") { ApplicationArea = All; }
                field(Prepmt_VAT_Diff__to_Deduct; Rec."Prepmt VAT Diff. to Deduct") { ApplicationArea = All; }
                field(Prepmt_VAT_Diff__Deducted; Rec."Prepmt VAT Diff. Deducted") { ApplicationArea = All; }
                field(IC_Item_Reference_No_; Rec."IC Item Reference No.") { ApplicationArea = All; }
                field(Pmt__Discount_Amount; Rec."Pmt. Discount Amount") { ApplicationArea = All; }
                field(Prepmt__Pmt__Discount_Amount; Rec."Prepmt. Pmt. Discount Amount") { ApplicationArea = All; }
                field(Dimension_Set_ID; Rec."Dimension Set ID") { ApplicationArea = All; }
                field(Job_Task_No_; Rec."Job Task No.") { ApplicationArea = All; }
                field(Job_Line_Type; Rec."Job Line Type") { ApplicationArea = All; }
                field(Job_Unit_Price; Rec."Job Unit Price") { ApplicationArea = All; }
                field(Job_Total_Price; Rec."Job Total Price") { ApplicationArea = All; }
                field(Job_Line_Amount; Rec."Job Line Amount") { ApplicationArea = All; }
                field(Job_Line_Discount_Amount; Rec."Job Line Discount Amount") { ApplicationArea = All; }
                field(Job_Line_Discount__; Rec."Job Line Discount %") { ApplicationArea = All; }
                field(Job_Currency_Factor; Rec."Job Currency Factor") { ApplicationArea = All; }
                field(Job_Currency_Code; Rec."Job Currency Code") { ApplicationArea = All; }
                field(Job_Planning_Line_No_; Rec."Job Planning Line No.") { ApplicationArea = All; }
                field(Job_Remaining_Qty_; Rec."Job Remaining Qty.") { ApplicationArea = All; }
                field(Deferral_Code; Rec."Deferral Code") { ApplicationArea = All; }
                field(Returns_Deferral_Start_Date; Rec."Returns Deferral Start Date") { ApplicationArea = All; }
                field(Prod__Order_No_; Rec."Prod. Order No.") { ApplicationArea = All; }
                field(Variant_Code; Rec."Variant Code") { ApplicationArea = All; }
                field(Bin_Code; Rec."Bin Code") { ApplicationArea = All; }
                field(Qty__per_Unit_of_Measure; Rec."Qty. per Unit of Measure") { ApplicationArea = All; }
                field(Qty__Rounding_Precision; Rec."Qty. Rounding Precision") { ApplicationArea = All; }
                field(Unit_of_Measure_Code; Rec."Unit of Measure Code") { ApplicationArea = All; }
                field(FA_Posting_Date; Rec."FA Posting Date") { ApplicationArea = All; }
                field(FA_Posting_Type; Rec."FA Posting Type") { ApplicationArea = All; }
                field(Depreciation_Book_Code; Rec."Depreciation Book Code") { ApplicationArea = All; }
                field(Salvage_Value; Rec."Salvage Value") { ApplicationArea = All; }
                field(Depr__until_FA_Posting_Date; Rec."Depr. until FA Posting Date") { ApplicationArea = All; }
                field(Depr__Acquisition_Cost; Rec."Depr. Acquisition Cost") { ApplicationArea = All; }
                field(Maintenance_Code; Rec."Maintenance Code") { ApplicationArea = All; }
                field(Insurance_No_; Rec."Insurance No.") { ApplicationArea = All; }
                field(Budgeted_FA_No_; Rec."Budgeted FA No.") { ApplicationArea = All; }
                field(Duplicate_in_Depreciation_Book; Rec."Duplicate in Depreciation Book") { ApplicationArea = All; }
                field(Use_Duplication_List; Rec."Use Duplication List") { ApplicationArea = All; }
                field(Responsibility_Center; Rec."Responsibility Center") { ApplicationArea = All; }
                field(Item_Category_Code; Rec."Item Category Code") { ApplicationArea = All; }
                field(Nonstock; Rec."Nonstock") { ApplicationArea = All; }
                field(Purchasing_Code; Rec."Purchasing Code") { ApplicationArea = All; }
                field(Special_Order; Rec."Special Order") { ApplicationArea = All; }
                field(Special_Order_Sales_No_; Rec."Special Order Sales No.") { ApplicationArea = All; }
                field(Special_Order_Sales_Line_No_; Rec."Special Order Sales Line No.") { ApplicationArea = All; }
                field(Item_Reference_No_; Rec."Item Reference No.") { ApplicationArea = All; }
                field(Item_Reference_Unit_of_Measure; Rec."Item Reference Unit of Measure") { ApplicationArea = All; }
                field(Item_Reference_Type; Rec."Item Reference Type") { ApplicationArea = All; }
                field(Item_Reference_Type_No_; Rec."Item Reference Type No.") { ApplicationArea = All; }
                field(Completely_Received; Rec."Completely Received") { ApplicationArea = All; }
                field(Requested_Receipt_Date; Rec."Requested Receipt Date") { ApplicationArea = All; }
                field(Promised_Receipt_Date; Rec."Promised Receipt Date") { ApplicationArea = All; }
                field(Lead_Time_Calculation; Rec."Lead Time Calculation") { ApplicationArea = All; }
                field(Inbound_Whse__Handling_Time; Rec."Inbound Whse. Handling Time") { ApplicationArea = All; }
                field(Planned_Receipt_Date; Rec."Planned Receipt Date") { ApplicationArea = All; }
                field(Order_Date; Rec."Order Date") { ApplicationArea = All; }
                field(Allow_Item_Charge_Assignment; Rec."Allow Item Charge Assignment") { ApplicationArea = All; }
                field(Return_Qty__to_Ship; Rec."Return Qty. to Ship") { ApplicationArea = All; }
                field(Return_Qty__Shipped_Not_Invd_; Rec."Return Qty. Shipped Not Invd.") { ApplicationArea = All; }
                field(Return_Shpd__Not_Invd_; Rec."Return Shpd. Not Invd.") { ApplicationArea = All; }
                field(Return_Qty__Shipped; Rec."Return Qty. Shipped") { ApplicationArea = All; }
                field(Return_Shipment_No_; Rec."Return Shipment No.") { ApplicationArea = All; }
                field(Return_Shipment_Line_No_; Rec."Return Shipment Line No.") { ApplicationArea = All; }
                field(Return_Reason_Code; Rec."Return Reason Code") { ApplicationArea = All; }
                field(Subtype; Rec."Subtype") { ApplicationArea = All; }
                field(Copied_From_Posted_Doc_; Rec."Copied From Posted Doc.") { ApplicationArea = All; }
                field(Price_Calculation_Method; Rec."Price Calculation Method") { ApplicationArea = All; }
                field(Over_Receipt_Quantity; Rec."Over-Receipt Quantity") { ApplicationArea = All; }
                field(Over_Receipt_Code; Rec."Over-Receipt Code") { ApplicationArea = All; }
                field(Over_Receipt_Approval_Status; Rec."Over-Receipt Approval Status") { ApplicationArea = All; }
                field(Routing_No_; Rec."Routing No.") { ApplicationArea = All; }
                field(Operation_No_; Rec."Operation No.") { ApplicationArea = All; }
                field(Work_Center_No_; Rec."Work Center No.") { ApplicationArea = All; }
                field(Finished; Rec."Finished") { ApplicationArea = All; }
                field(Prod__Order_Line_No_; Rec."Prod. Order Line No.") { ApplicationArea = All; }
                field(Overhead_Rate; Rec."Overhead Rate") { ApplicationArea = All; }
                field(MPS_Order; Rec."MPS Order") { ApplicationArea = All; }
                field(Planning_Flexibility; Rec."Planning Flexibility") { ApplicationArea = All; }
                field(Safety_Lead_Time; Rec."Safety Lead Time") { ApplicationArea = All; }
                field(Routing_Reference_No_; Rec."Routing Reference No.") { ApplicationArea = All; }

            }
        }
    }

}
