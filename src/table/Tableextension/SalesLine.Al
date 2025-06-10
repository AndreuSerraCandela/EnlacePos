tableextension 91109 SalesHeaderExtension extends "Sales Header"
{
    fields
    {

        field(50101; "Importe total"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Colegio; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Colegios;
        }
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        // field(50104; Turno; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Turno';
        //     TableRelation = Turno.No;
        // }
        // field(50105; TPV; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'TPV';
        //     TableRelation = TPV."No";
        // }
        field(50106; "Cupon de descuento"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cupon de descuento';
            TableRelation = Campaign;
        }
        field(50107; "Tipo Detalle"; Enum "Tipo Detalle")
        {
            DataClassification = ToBeClassified;
            Caption = 'Tipo Detalle';
        }
        field(50108; "No. Detalle"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No. Detalle';
            TableRelation = if ("Tipo Detalle" = const(TPV)) TPV else
            if ("Tipo Detalle" = const(Cliente)) Customer else
            if ("Tipo Detalle" = const(GrupoCliente)) "Customer Price Group" else
            if ("Tipo Detalle" = const(Colegio)) "Colegios";
        }
    }
}
tableextension 91112 SalesInvoiceLineExtension extends "Sales Invoice header"
{
    fields
    {

        field(50101; "Importe total"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Colegio; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Colegios;
        }
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        // field(50104; Turno; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Turno';
        //     TableRelation = Turno.No;
        // }
        // field(76021; Turno; Integer)
        // {
        //     Caption = 'Turno';
        //     DataClassification = ToBeClassified;
        //     Description = 'DsPOS Standard';
        // }
        // field(76016; TPV; Code[20])
        // {
        //     Caption = 'POS';
        //     DataClassification = ToBeClassified;
        //     Description = 'DsPOS Standard';
        //     // TableRelation = "Configuracion TPV"."Id TPV" WHERE(Tienda = FIELD(Tienda));
        // }
        field(50106; "Cupon de descuento"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cupon de descuento';
            TableRelation = Campaign;
        }
        field(50107; "Tipo Detalle"; Enum "Tipo Detalle")
        {
            DataClassification = ToBeClassified;
            Caption = 'Tipo Detalle';
        }
        field(50108; "No. Detalle"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No. Detalle';
            TableRelation = if ("Tipo Detalle" = const(TPV)) TPV else
            if ("Tipo Detalle" = const(Cliente)) Customer else
            if ("Tipo Detalle" = const(GrupoCliente)) "Customer Price Group" else
            if ("Tipo Detalle" = const(Colegio)) "Colegios";
        }
    }
}
tableextension 91113 SalesCrHdExtension extends "Sales Cr.Memo Header"
{

    fields
    {

        field(50101; "Importe total"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Colegio; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Colegios;
        }
        field(50103; Caja; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Caja';
            TableRelation = Cajas.No;
        }
        // field(50104; Turno; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     Caption = 'Turno';
        //     TableRelation = Turno.No;
        // }
        // field(76021; Turno; Integer)
        // {
        //     Caption = 'Turno';
        //     DataClassification = ToBeClassified;
        //     Description = 'DsPOS Standard';
        // }
        // field(76016; TPV; Code[20])
        // {
        //     Caption = 'POS';
        //     DataClassification = ToBeClassified;
        //     Description = 'DsPOS Standard';
        //     // TableRelation = "Configuracion TPV"."Id TPV" WHERE(Tienda = FIELD(Tienda));
        // }
        field(50106; "Cupon de descuento"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cupon de descuento';
            TableRelation = Campaign;
        }
        field(50107; "Tipo Detalle"; Enum "Tipo Detalle")
        {
            DataClassification = ToBeClassified;
            Caption = 'Tipo Detalle';
        }
        field(50108; "No. Detalle"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No. Detalle';
            TableRelation = if ("Tipo Detalle" = const(TPV)) TPV else
            if ("Tipo Detalle" = const(Cliente)) Customer else
            if ("Tipo Detalle" = const(GrupoCliente)) "Customer Price Group" else
            if ("Tipo Detalle" = const(Colegio)) "Colegios";
        }
    }

}
