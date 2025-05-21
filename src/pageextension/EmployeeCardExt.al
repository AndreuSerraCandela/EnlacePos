pageextension 91110 EmployeeCardExt extends "Employee Card"
{
    layout
    {
        addafter(General)
        {
            group(TPV)
            {

                Caption = 'TPV';
                field("Supervisor"; Rec."Supervisor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this employee is a supervisor.';
                }
                field("Usuario TPV"; Rec."Usuario TPV")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this employee is a TPV user.';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the password for TPV access.';
                }

            }
        }
    }
}
pageextension 91111 EmployeeListExt extends "Employee List"
{
    layout
    {
        addafter(Extension)
        {
            field("Usuario TPV"; Rec."Usuario TPV")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this employee is a TPV user.';
            }
            field(Password; Rec.Password)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the password for TPV access.';
            }
            field("Company_E_Mail"; Rec."Company E-Mail")
            {
                Caption = 'Company E-Mail';
                ApplicationArea = All;
                ToolTip = 'Specifies the company e-mail address for the employee.';
            }
        }
    }
}
