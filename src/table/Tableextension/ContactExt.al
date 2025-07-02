tableextension 75218 ContactExt extends Contact
{
    fields
    {
        field(75213; "Source Counter"; Integer)
        {
            Caption = 'Source Counter';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
    }
}