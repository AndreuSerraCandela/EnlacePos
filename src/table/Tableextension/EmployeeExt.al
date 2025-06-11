tableextension 75210 EmployeeExt extends Employee
{
    fields
    {
        field(90110; "Usuario TPV"; Boolean)
        {
            Caption = 'Usuario TPV';
            DataClassification = CustomerContent;
        }
        field(90111; Password; Text[50])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(90112; Supervisor; Boolean)
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
        }
    }
}