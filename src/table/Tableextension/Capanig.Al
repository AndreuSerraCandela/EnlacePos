tableextension 75215 Capanig extends Campaign
{
    CaptionML = ENU = 'Coupon',
                ESP = 'Ficha Cupón';
    fields
    {
        field(50101; "% Descuento"; Decimal)
        {
            Caption = '% Descuento';
            DataClassification = ToBeClassified;
        }
        field(50102; "Importe Descuento"; Decimal)
        {
            Caption = 'Importe Descuento';
            DataClassification = ToBeClassified;
        }
        field(50103; "Importe Total Descontado"; Decimal)
        {
            Caption = 'Importe Total';
            DataClassification = ToBeClassified;
        }
        field(50104; "Cupon"; Boolean)
        {
            Caption = 'Cupon';
            DataClassification = ToBeClassified;
        }



    }
}
//Crear una Tabla de Detalle de Cupon Que Tenga un "Tipo Detalle" que Puede ser TPV, Cliente O Grupo de Cliente con los mismos campos que la tabla "Sales Invoice Line"
table 75216 "Detalle Cupón"
{
    Caption = 'Detalle Cupón';
    fields
    {
        field(1; "Código Cupón"; Code[20])
        {
            Caption = 'Código Cupón';
            DataClassification = ToBeClassified;
            TableRelation = Campaign;
        }
        field(2; "Tipo Detalle"; Enum "Tipo Detalle")
        {
            Caption = 'Tipo Detalle';
            DataClassification = ToBeClassified;
        }
        field(3; "No."; Code[20])
        {
            TableRelation = if ("Tipo Detalle" = const(TPV)) Tiendas else
            if ("Tipo Detalle" = const(Cliente)) Customer else
            if ("Tipo Detalle" = const(GrupoCliente)) "Customer Price Group" else
            if ("Tipo Detalle" = const(Colegio)) Contact;
        }

        field(50101; "% Descuento"; Decimal)
        {
            Caption = '% Descuento';
            DataClassification = ToBeClassified;
        }
        field(50102; "Importe Descuento"; Decimal)
        {
            Caption = 'Importe Descuento';
            DataClassification = ToBeClassified;
        }
        field(50103; "Importe Total Descontado"; Decimal)
        {
            Caption = 'Importe Total';
            DataClassification = ToBeClassified;
        }




    }
    keys
    {
        key(Key1; "Código Cupón", "Tipo Detalle", "No.")
        {
            Clustered = true;
        }
    }
}
