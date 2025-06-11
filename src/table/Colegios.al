table 75208 Colegios
{
    Caption = 'Colegios';
    DataClassification = CustomerContent;
    LookupPageId = "Colegios";

    fields
    {
        field(1; "No"; Code[20])
        {
            Caption = 'No';
            DataClassification = CustomerContent;
        }
        field(2; "Nombre"; Text[100])
        {
            Caption = 'Nombre';
            DataClassification = CustomerContent;
        }
        field(3; "Dirección"; Text[100])
        {
            Caption = 'Dirección';
            DataClassification = CustomerContent;
        }
        field(4; "Dirección 2"; Text[50])
        {
            Caption = 'Dirección 2';
            DataClassification = CustomerContent;
        }
        field(5; "Ciudad"; Text[30])
        {
            Caption = 'Ciudad';
            DataClassification = CustomerContent;
        }
        field(6; "Código Postal"; Code[20])
        {
            Caption = 'Código Postal';
            DataClassification = CustomerContent;
        }
        field(7; "Provincia"; Text[30])
        {
            Caption = 'Provincia';
            DataClassification = CustomerContent;
        }
        field(8; "País"; Code[10])
        {
            Caption = 'País';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(9; "Teléfono"; Text[30])
        {
            Caption = 'Teléfono';
            DataClassification = CustomerContent;
        }
        field(10; "Móvil"; Text[30])
        {
            Caption = 'Móvil';
            DataClassification = CustomerContent;
        }
        field(11; "Email"; Text[80])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(12; "Sitio Web"; Text[80])
        {
            Caption = 'Sitio Web';
            DataClassification = CustomerContent;
        }
        field(13; "NIF/CIF"; Text[20])
        {
            Caption = 'NIF/CIF';
            DataClassification = CustomerContent;
        }
        field(14; "Contacto"; Text[50])
        {
            Caption = 'Contacto';
            DataClassification = CustomerContent;
        }
        field(15; "Notas"; Text[250])
        {
            Caption = 'Notas';
            DataClassification = CustomerContent;
        }
        field(16; "Fecha Alta"; Date)
        {
            Caption = 'Fecha Alta';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No")
        {
            Clustered = true;
        }
    }
}