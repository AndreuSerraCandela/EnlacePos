tableextension 75218 ContactExt extends Contact
{
    fields
    {
        field(75213; "Source Counter"; Integer)
        {
            ObsoleteState = Pending;
            Caption = 'Source Counter';
            DataClassification = CustomerContent;
        }
        field(75214; "Source Counter2"; Integer)
        {
            Caption = 'Source Counter2';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PS; "Source Counter")
        {

        }
        key(PS2; "Source Counter2")
        {

        }
    }
}