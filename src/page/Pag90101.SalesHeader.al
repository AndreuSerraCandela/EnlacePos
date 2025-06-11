Page 75201 SalesHeader
{
    Caption = 'SalesHeader';
    SourceTable = "Sales Header";
    layout
    {
        area(Content)
        {
            repeater(SalesHeader)
            {
                field(Document_Type; Rec."Document Type") { ApplicationArea = All; }
                field(Sell_to_Customer_No_; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field(No_; Rec."No.") { ApplicationArea = All; }
                field(Bill_to_Customer_No_; Rec."Bill-to Customer No.") { ApplicationArea = All; }
                field(Bill_to_Name; Rec."Bill-to Name") { ApplicationArea = All; }
                field(Bill_to_Name_2; Rec."Bill-to Name 2") { ApplicationArea = All; }
                field(Bill_to_Address; Rec."Bill-to Address") { ApplicationArea = All; }
                field(Bill_to_Address_2; Rec."Bill-to Address 2") { ApplicationArea = All; }
                field(Bill_to_City; Rec."Bill-to City") { ApplicationArea = All; }
                field(Bill_to_Contact; Rec."Bill-to Contact") { ApplicationArea = All; }
                field(Your_Reference; Rec."Your Reference") { ApplicationArea = All; }
                field(Ship_to_Code; Rec."Ship-to Code") { ApplicationArea = All; }
                field(Ship_to_Name; Rec."Ship-to Name") { ApplicationArea = All; }
                field(Ship_to_Name_2; Rec."Ship-to Name 2") { ApplicationArea = All; }
                field(Ship_to_Address; Rec."Ship-to Address") { ApplicationArea = All; }
                field(Ship_to_Address_2; Rec."Ship-to Address 2") { ApplicationArea = All; }
                field(Ship_to_City; Rec."Ship-to City") { ApplicationArea = All; }
                field(Ship_to_Contact; Rec."Ship-to Contact") { ApplicationArea = All; }
                field(Order_Date; Rec."Order Date") { ApplicationArea = All; }
                field(Posting_Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Shipment_Date; Rec."Shipment Date") { ApplicationArea = All; }
                field(Posting_Description; Rec."Posting Description") { ApplicationArea = All; }
                field(Payment_Terms_Code; Rec."Payment Terms Code") { ApplicationArea = All; }
                field(Due_Date; Rec."Due Date") { ApplicationArea = All; }
                field(Payment_Discount__; Rec."Payment Discount %") { ApplicationArea = All; }
                field(Pmt__Discount_Date; Rec."Pmt. Discount Date") { ApplicationArea = All; }
                field(Shipment_Method_Code; Rec."Shipment Method Code") { ApplicationArea = All; }
                field(Location_Code; Rec."Location Code") { ApplicationArea = All; }
                field(Shortcut_Dimension_1_Code; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field(Shortcut_Dimension_2_Code; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field(Customer_Posting_Group; Rec."Customer Posting Group") { ApplicationArea = All; }
                field(Currency_Code; Rec."Currency Code") { ApplicationArea = All; }
                field(Currency_Factor; Rec."Currency Factor") { ApplicationArea = All; }
                field(Customer_Price_Group; Rec."Customer Price Group") { ApplicationArea = All; }
                field(Prices_Including_VAT; Rec."Prices Including VAT") { ApplicationArea = All; }
                field(Invoice_Disc__Code; Rec."Invoice Disc. Code") { ApplicationArea = All; }
                field(Customer_Disc__Group; Rec."Customer Disc. Group") { ApplicationArea = All; }
                field(Language_Code; Rec."Language Code") { ApplicationArea = All; }
                field(Salesperson_Code; Rec."Salesperson Code") { ApplicationArea = All; }
                field(Order_Class; Rec."Order Class") { ApplicationArea = All; }
                field(No__Printed; Rec."No. Printed") { ApplicationArea = All; }
                field(On_Hold; Rec."On Hold") { ApplicationArea = All; }
                field(Applies_to_Doc__Type; Rec."Applies-to Doc. Type") { ApplicationArea = All; }
                field(Applies_to_Doc__No_; Rec."Applies-to Doc. No.") { ApplicationArea = All; }
                field(Bal__Account_No_; Rec."Bal. Account No.") { ApplicationArea = All; }
                field(Ship; Rec."Ship") { ApplicationArea = All; }
                field(Invoice; Rec."Invoice") { ApplicationArea = All; }
                field(Print_Posted_Documents; Rec."Print Posted Documents") { ApplicationArea = All; }
                field(Shipping_No_; Rec."Shipping No.") { ApplicationArea = All; }
                field(Posting_No_; Rec."Posting No.") { ApplicationArea = All; }
                field(Last_Shipping_No_; Rec."Last Shipping No.") { ApplicationArea = All; }
                field(Last_Posting_No_; Rec."Last Posting No.") { ApplicationArea = All; }
                field(Prepayment_No_; Rec."Prepayment No.") { ApplicationArea = All; }
                field(Last_Prepayment_No_; Rec."Last Prepayment No.") { ApplicationArea = All; }
                field(Prepmt__Cr__Memo_No_; Rec."Prepmt. Cr. Memo No.") { ApplicationArea = All; }
                field(Last_Prepmt__Cr__Memo_No_; Rec."Last Prepmt. Cr. Memo No.") { ApplicationArea = All; }
                field(VAT_Registration_No_; Rec."VAT Registration No.") { ApplicationArea = All; }
                field(Combine_Shipments; Rec."Combine Shipments") { ApplicationArea = All; }
                field(Reason_Code; Rec."Reason Code") { ApplicationArea = All; }
                field(Gen__Bus__Posting_Group; Rec."Gen. Bus. Posting Group") { ApplicationArea = All; }
                field(EU_3_Party_Trade; Rec."EU 3-Party Trade") { ApplicationArea = All; }
                field(Transaction_Type; Rec."Transaction Type") { ApplicationArea = All; }
                field(Transport_Method; Rec."Transport Method") { ApplicationArea = All; }
                field(VAT_Country_Region_Code; Rec."VAT Country/Region Code") { ApplicationArea = All; }
                field(Sell_to_Customer_Name; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field(Sell_to_Customer_Name_2; Rec."Sell-to Customer Name 2") { ApplicationArea = All; }
                field(Sell_to_Address; Rec."Sell-to Address") { ApplicationArea = All; }
                field(Sell_to_Address_2; Rec."Sell-to Address 2") { ApplicationArea = All; }
                field(Sell_to_City; Rec."Sell-to City") { ApplicationArea = All; }
                field(Sell_to_Contact; Rec."Sell-to Contact") { ApplicationArea = All; }
                field(Bill_to_Post_Code; Rec."Bill-to Post Code") { ApplicationArea = All; }
                field(Bill_to_County; Rec."Bill-to County") { ApplicationArea = All; }
                field(Bill_to_Country_Region_Code; Rec."Bill-to Country/Region Code") { ApplicationArea = All; }
                field(Sell_to_Post_Code; Rec."Sell-to Post Code") { ApplicationArea = All; }
                field(Sell_to_County; Rec."Sell-to County") { ApplicationArea = All; }
                field(Sell_to_Country_Region_Code; Rec."Sell-to Country/Region Code") { ApplicationArea = All; }
                field(Ship_to_Post_Code; Rec."Ship-to Post Code") { ApplicationArea = All; }
                field(Ship_to_County; Rec."Ship-to County") { ApplicationArea = All; }
                field(Ship_to_Country_Region_Code; Rec."Ship-to Country/Region Code") { ApplicationArea = All; }
                field(Bal__Account_Type; Rec."Bal. Account Type") { ApplicationArea = All; }
                field(Exit_Point; Rec."Exit Point") { ApplicationArea = All; }
                field(Correction; Rec."Correction") { ApplicationArea = All; }
                field(Document_Date; Rec."Document Date") { ApplicationArea = All; }
                field(External_Document_No_; Rec."External Document No.") { ApplicationArea = All; }
                field(SalesHeaderArea; Rec."Area") { ApplicationArea = All; }
                field(Transaction_Specification; Rec."Transaction Specification") { ApplicationArea = All; }
                field(Payment_Method_Code; Rec."Payment Method Code") { ApplicationArea = All; }
                field(Shipping_Agent_Code; Rec."Shipping Agent Code") { ApplicationArea = All; }
                //field(Package_Tracking_No_; Rec."Package Tracking No.") { ApplicationArea = All; }
                field(No__Series; Rec."No. Series") { ApplicationArea = All; }
                field(Posting_No__Series; Rec."Posting No. Series") { ApplicationArea = All; }
                field(Shipping_No__Series; Rec."Shipping No. Series") { ApplicationArea = All; }
                field(Tax_Area_Code; Rec."Tax Area Code") { ApplicationArea = All; }
                field(Tax_Liable; Rec."Tax Liable") { ApplicationArea = All; }
                field(VAT_Bus__Posting_Group; Rec."VAT Bus. Posting Group") { ApplicationArea = All; }
                field(Reserve; Rec."Reserve") { ApplicationArea = All; }
                field(Applies_to_ID; Rec."Applies-to ID") { ApplicationArea = All; }
                field(VAT_Base_Discount__; Rec."VAT Base Discount %") { ApplicationArea = All; }
                field(Status; Rec."Status") { ApplicationArea = All; }
                field(Invoice_Discount_Calculation; Rec."Invoice Discount Calculation") { ApplicationArea = All; }
                field(Invoice_Discount_Value; Rec."Invoice Discount Value") { ApplicationArea = All; }
                field(Send_IC_Document; Rec."Send IC Document") { ApplicationArea = All; }
                field(IC_Status; Rec."IC Status") { ApplicationArea = All; }
                field(Sell_to_IC_Partner_Code; Rec."Sell-to IC Partner Code") { ApplicationArea = All; }
                field(Bill_to_IC_Partner_Code; Rec."Bill-to IC Partner Code") { ApplicationArea = All; }
                field(IC_Direction; Rec."IC Direction") { ApplicationArea = All; }
                field(Prepayment__; Rec."Prepayment %") { ApplicationArea = All; }
                field(Prepayment_No__Series; Rec."Prepayment No. Series") { ApplicationArea = All; }
                field(Compress_Prepayment; Rec."Compress Prepayment") { ApplicationArea = All; }
                field(Prepayment_Due_Date; Rec."Prepayment Due Date") { ApplicationArea = All; }
                field(Prepmt__Cr__Memo_No__Series; Rec."Prepmt. Cr. Memo No. Series") { ApplicationArea = All; }
                field(Prepmt__Posting_Description; Rec."Prepmt. Posting Description") { ApplicationArea = All; }
                field(Prepmt__Pmt__Discount_Date; Rec."Prepmt. Pmt. Discount Date") { ApplicationArea = All; }
                field(Prepmt__Payment_Terms_Code; Rec."Prepmt. Payment Terms Code") { ApplicationArea = All; }
                field(Prepmt__Payment_Discount__; Rec."Prepmt. Payment Discount %") { ApplicationArea = All; }
                field(Quote_No_; Rec."Quote No.") { ApplicationArea = All; }
                field(Quote_Valid_Until_Date; Rec."Quote Valid Until Date") { ApplicationArea = All; }
                field(Quote_Sent_to_Customer; Rec."Quote Sent to Customer") { ApplicationArea = All; }
                field(Quote_Accepted; Rec."Quote Accepted") { ApplicationArea = All; }
                field(Quote_Accepted_Date; Rec."Quote Accepted Date") { ApplicationArea = All; }
                field(Job_Queue_Status; Rec."Job Queue Status") { ApplicationArea = All; }
                field(Job_Queue_Entry_ID; Rec."Job Queue Entry ID") { ApplicationArea = All; }
                field(Company_Bank_Account_Code; Rec."Company Bank Account Code") { ApplicationArea = All; }
                field(Incoming_Document_Entry_No_; Rec."Incoming Document Entry No.") { ApplicationArea = All; }
                field(IsTest; Rec."IsTest") { ApplicationArea = All; }
                field(Sell_to_Phone_No_; Rec."Sell-to Phone No.") { ApplicationArea = All; }
                field(Sell_to_E_Mail; Rec."Sell-to E-Mail") { ApplicationArea = All; }
                field(Journal_Templ__Name; Rec."Journal Templ. Name") { ApplicationArea = All; }
                field(Work_Description; Rec."Work Description") { ApplicationArea = All; }
                field(Dimension_Set_ID; Rec."Dimension Set ID") { ApplicationArea = All; }
                field(Payment_Service_Set_ID; Rec."Payment Service Set ID") { ApplicationArea = All; }
                field(Direct_Debit_Mandate_ID; Rec."Direct Debit Mandate ID") { ApplicationArea = All; }
                field(Doc__No__Occurrence; Rec."Doc. No. Occurrence") { ApplicationArea = All; }
                field(Campaign_No_; Rec."Campaign No.") { ApplicationArea = All; }
                field(Sell_to_Contact_No_; Rec."Sell-to Contact No.") { ApplicationArea = All; }
                field(Bill_to_Contact_No_; Rec."Bill-to Contact No.") { ApplicationArea = All; }
                field(Opportunity_No_; Rec."Opportunity No.") { ApplicationArea = All; }
                field(Sell_to_Customer_Templ__Code; Rec."Sell-to Customer Templ. Code") { ApplicationArea = All; }
                field(Bill_to_Customer_Templ__Code; Rec."Bill-to Customer Templ. Code") { ApplicationArea = All; }
                field(Responsibility_Center; Rec."Responsibility Center") { ApplicationArea = All; }
                field(Shipping_Advice; Rec."Shipping Advice") { ApplicationArea = All; }
                field(Posting_from_Whse__Ref_; Rec."Posting from Whse. Ref.") { ApplicationArea = All; }
                field(Requested_Delivery_Date; Rec."Requested Delivery Date") { ApplicationArea = All; }
                field(Promised_Delivery_Date; Rec."Promised Delivery Date") { ApplicationArea = All; }
                field(Shipping_Time; Rec."Shipping Time") { ApplicationArea = All; }
                field(Outbound_Whse__Handling_Time; Rec."Outbound Whse. Handling Time") { ApplicationArea = All; }
                field(Shipping_Agent_Service_Code; Rec."Shipping Agent Service Code") { ApplicationArea = All; }
                field(Receive; Rec."Receive") { ApplicationArea = All; }
                field(Return_Receipt_No_; Rec."Return Receipt No.") { ApplicationArea = All; }
                field(Return_Receipt_No__Series; Rec."Return Receipt No. Series") { ApplicationArea = All; }
                field(Last_Return_Receipt_No_; Rec."Last Return Receipt No.") { ApplicationArea = All; }
                field(Price_Calculation_Method; Rec."Price Calculation Method") { ApplicationArea = All; }
                field(Allow_Line_Disc_; Rec."Allow Line Disc.") { ApplicationArea = All; }
                field(Get_Shipment_Used; Rec."Get Shipment Used") { ApplicationArea = All; }
                field(Assigned_User_ID; Rec."Assigned User ID") { ApplicationArea = All; }
                field(Corrected_Invoice_No_; Rec."Corrected Invoice No.") { ApplicationArea = All; }
                field(Due_Date_Modified; Rec."Due Date Modified") { ApplicationArea = All; }
                field(Invoice_Type; Rec."Invoice Type") { ApplicationArea = All; }
                field(Cr__Memo_Type; Rec."Cr. Memo Type") { ApplicationArea = All; }
                field(Special_Scheme_Code; Rec."Special Scheme Code") { ApplicationArea = All; }
                field(Operation_Description; Rec."Operation Description") { ApplicationArea = All; }
                field(Correction_Type; Rec."Correction Type") { ApplicationArea = All; }
                field(Operation_Description_2; Rec."Operation Description 2") { ApplicationArea = All; }
                field(Succeeded_Company_Name; Rec."Succeeded Company Name") { ApplicationArea = All; }
                field(Succeeded_VAT_Registration_No_; Rec."Succeeded VAT Registration No.") { ApplicationArea = All; }
                field(ID_Type; Rec."ID Type") { ApplicationArea = All; }
                field(Do_Not_Send_To_SII; Rec."Do Not Send To SII") { ApplicationArea = All; }
                field(Issued_By_Third_Party; Rec."Issued By Third Party") { ApplicationArea = All; }
                field(SII_First_Summary_Doc__No_; Rec."SII First Summary Doc. No.") { ApplicationArea = All; }
                field(SII_Last_Summary_Doc__No_; Rec."SII Last Summary Doc. No.") { ApplicationArea = All; }
                field(Applies_to_Bill_No_; Rec."Applies-to Bill No.") { ApplicationArea = All; }
                field(Cust__Bank_Acc__Code; Rec."Cust. Bank Acc. Code") { ApplicationArea = All; }


            }


        }

    }


}
