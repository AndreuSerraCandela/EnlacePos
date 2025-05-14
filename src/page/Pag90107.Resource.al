Page 91107 Resource
{
    Caption = 'Resource';
    PageType = List;
    SourceTable = Resource;
    layout
    {
        area(Content)
        {
            repeater(Resource)
            {
                field(No_; Rec."No.") { ApplicationArea = All; }
                field(Type; Rec."Type") { ApplicationArea = All; }
                field(Name; Rec."Name") { ApplicationArea = All; }
                field(Search_Name; Rec."Search Name") { ApplicationArea = All; }
                field(Name_2; Rec."Name 2") { ApplicationArea = All; }
                field(Address; Rec."Address") { ApplicationArea = All; }
                field(Address_2; Rec."Address 2") { ApplicationArea = All; }
                field(City; Rec."City") { ApplicationArea = All; }
                field(Social_Security_No_; Rec."Social Security No.") { ApplicationArea = All; }
                field(Job_Title; Rec."Job Title") { ApplicationArea = All; }
                field(Education; Rec."Education") { ApplicationArea = All; }
                field(Contract_Class; Rec."Contract Class") { ApplicationArea = All; }
                field(Employment_Date; Rec."Employment Date") { ApplicationArea = All; }
                field(Resource_Group_No_; Rec."Resource Group No.") { ApplicationArea = All; }
                field(Global_Dimension_1_Code; Rec."Global Dimension 1 Code") { ApplicationArea = All; }
                field(Global_Dimension_2_Code; Rec."Global Dimension 2 Code") { ApplicationArea = All; }
                field(Base_Unit_of_Measure; Rec."Base Unit of Measure") { ApplicationArea = All; }
                field(Direct_Unit_Cost; Rec."Direct Unit Cost") { ApplicationArea = All; }
                field(Indirect_Cost__; Rec."Indirect Cost %") { ApplicationArea = All; }
                field(Unit_Cost; Rec."Unit Cost") { ApplicationArea = All; }
                field(Profit__; Rec."Profit %") { ApplicationArea = All; }
                field(Price_Profit_Calculation; Rec."Price/Profit Calculation") { ApplicationArea = All; }
                field(Unit_Price; Rec."Unit Price") { ApplicationArea = All; }
                field(Vendor_No_; Rec."Vendor No.") { ApplicationArea = All; }
                field(Last_Date_Modified; Rec."Last Date Modified") { ApplicationArea = All; }
                field(Gen__Prod__Posting_Group; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
                field(Post_Code; Rec."Post Code") { ApplicationArea = All; }
                field(County; Rec."County") { ApplicationArea = All; }
                field(Automatic_Ext__Texts; Rec."Automatic Ext. Texts") { ApplicationArea = All; }
                field(No__Series; Rec."No. Series") { ApplicationArea = All; }
                field(Tax_Group_Code; Rec."Tax Group Code") { ApplicationArea = All; }
                field(VAT_Prod__Posting_Group; Rec."VAT Prod. Posting Group") { ApplicationArea = All; }
                field(Country_Region_Code; Rec."Country/Region Code") { ApplicationArea = All; }
                field(IC_Partner_Purch__G_L_Acc__No_; Rec."IC Partner Purch. G/L Acc. No.") { ApplicationArea = All; }
                field(Image; Rec."Image") { ApplicationArea = All; }
                field(Privacy_Blocked; Rec."Privacy Blocked") { ApplicationArea = All; }
                //field(Coupled_to_CRM; Rec."Coupled to CRM") { ApplicationArea = All; }
                field(Use_Time_Sheet; Rec."Use Time Sheet") { ApplicationArea = All; }
                field(Time_Sheet_Owner_User_ID; Rec."Time Sheet Owner User ID") { ApplicationArea = All; }
                field(Time_Sheet_Approver_User_ID; Rec."Time Sheet Approver User ID") { ApplicationArea = All; }
                field(Default_Deferral_Template_Code; Rec."Default Deferral Template Code") { ApplicationArea = All; }
                field(Service_Zone_Filter; Rec."Service Zone Filter") { ApplicationArea = All; }
            }
        }
    }
}