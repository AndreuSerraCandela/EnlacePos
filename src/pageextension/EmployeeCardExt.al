pageextension 75210 EmployeeCardExt extends "Employee Card"
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
page 75216 EmployeeList
{
    PageType = List;
    SourceTable = Employee;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    Caption = 'No.';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(FullName; Rec.FullName())
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Nombre Completo';
                    ToolTip = 'Specifies the full name of the employee.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Nombre';
                    ApplicationArea = BasicHR;
                    NotBlank = true;
                    ToolTip = 'Specifies the employee''s first name.';
                }
                field("Second Family Name"; Rec."Second Family Name")
                {
                    Caption = 'Segundo Apellido';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s middle name.';
                    Visible = false;
                }
                field("First Family Name"; Rec."First Family Name")
                {
                    Caption = 'Primer Apellido';
                    ApplicationArea = BasicHR;
                    NotBlank = true;
                    ToolTip = 'Specifies the employee''s last name.';
                }
                field(Initials; Rec.Initials)
                {
                    Caption = 'Iniciales';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee''s initials.';
                    Visible = false;
                }
                field("Job Title"; Rec."Job Title")
                {
                    Caption = 'Cargo';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s job title.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    Caption = 'Código Postal';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the postal code.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    Caption = 'País';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    Caption = 'Teléfono';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s telephone number.';
                }
                field(Extension; Rec.Extension)
                {
                    Caption = 'Extensión';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s telephone extension.';
                    Visible = false;
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
                field("Company_E_Mail"; Rec."Company E-Mail")
                {
                    Caption = 'Company E-Mail';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company e-mail address for the employee.';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    Caption = 'Teléfono Móvil';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s private telephone number.';
                    Visible = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Email Privado';
                    ToolTip = 'Specifies the employee''s private email address.';
                    Visible = false;
                }
                field("Statistics Group Code"; Rec."Statistics Group Code")
                {
                    Caption = 'Grupo Estadístico';
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a statistics group code to assign to the employee for statistical purposes.';
                    Visible = false;
                }
                field("Resource No."; Rec."Resource No.")
                {
                    Caption = 'Recurso';
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a resource number for the employee.';
                    Visible = false;
                }
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    Caption = 'Privacidad';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
                    Visible = false;
                }
                field("Search Name"; Rec."Search Name")
                {
                    Caption = 'Nombre de Búsqueda';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    Caption = 'Saldo';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the the employee''s balance.';
                }
                field(Comment; Rec.Comment)
                {
                    Caption = 'Comentario';
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies if a comment has been entered for this entry.';
                }
            }
        }
    }
}
pageextension 75211 EmployeeListExt extends "Employee List"
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
