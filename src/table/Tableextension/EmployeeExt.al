tableextension 75210 EmployeeExt extends "Cajeros"
{
    fields
    {
        modify(Tipo)
        {
            trigger OnAfterValidate()
            begin
                if Tipo = Tipo::Supervisor then
                    "Supervisor" := true
                else
                    "Supervisor" := false;
            end;
        }
        field(90110; "Usuario TPV"; Boolean)
        {
            Caption = 'Usuario TPV';
            DataClassification = CustomerContent;
        }

        field(90112; Supervisor; Boolean)
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
        }
        field(90113; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(90114; "Middle Name"; Text[100])
        {
            Caption = 'Segundo Apellido';
            DataClassification = CustomerContent;
        }
        field(90115; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(90116; "Initials"; Text[10])
        {
            Caption = 'Initials';
            DataClassification = CustomerContent;
        }
        field(90117; "Job Title"; Text[100])
        {
            Caption = 'Job Title';
            DataClassification = CustomerContent;
        }
        field(90118; "Post Code"; Text[100])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(90119; "Country/Region Code"; Text[100])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(90120; "Phone No."; Text[100])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(90121; "Mobile Phone No."; Text[100])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
        }
        field(90122; "E-Mail"; Text[100])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
        field(90123; "Company E-Mail"; Text[100])
        {
            Caption = 'Company E-Mail';
            DataClassification = CustomerContent;
        }
        field(90124; "Statistics Group Code"; Text[100])
        {
            Caption = 'Statistics Group Code';
            DataClassification = CustomerContent;
        }
        field(90125; "Resource No."; Text[100])
        {
            Caption = 'Resource No.';
            DataClassification = CustomerContent;
        }
        field(90126; "Privacy Blocked"; Boolean)
        {
            Caption = 'Privacy Blocked';
            DataClassification = CustomerContent;
        }
        field(90127; "Balance (LCY)"; Decimal)
        {
            Caption = 'Balance (LCY)';
            DataClassification = CustomerContent;
        }
        field(90128; "Comment"; Text[100])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(90129; "Search Name"; Text[100])
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(90130; "Extension"; Text[100])
        {
            Caption = 'Extension';
            DataClassification = CustomerContent;
        }
        field(90131; "Address"; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(90132; "Address 2"; Text[100])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(90133; "City"; Text[100])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(90134; "State"; Text[100])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(90140; "Birth Date"; Date)
        {
            Caption = 'Birth Date';
            DataClassification = CustomerContent;
        }
        field(90142; "No. Series"; Text[100])
        {
            Caption = 'No. Series';
        }
    }
    trigger OnInsert()
    var
        Cajero: Record "Cajeros";
        NoSeries: Codeunit "No. Series";
        EmployeeSetup: Record "Human Resources Setup";

    begin
        if "Id" = '' then begin
            EmployeeSetup.Get();
            EmployeeSetup.TestField("Employee Nos.");
            "No. Series" := EmployeeSetup."Employee Nos.";
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Id" := NoSeries.GetNextNo("No. Series");
            Cajero.ReadIsolation(IsolationLevel::ReadUncommitted);
            Cajero.SetLoadFields("Id");
            while Cajero.Get("Id") do
                "Id" := NoSeries.GetNextNo("No. Series");
        end;

    end;
}