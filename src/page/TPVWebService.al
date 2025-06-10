/// <summary>
/// Page TPV Web Service (ID 91172).
/// </summary>
page 91172 "TPV Web Service"
{
    Caption = 'TPV Web Service';
    PageType = API;
    APIPublisher = 'enlacePos';
    APIGroup = 'tpv';
    APIVersion = 'v1.0';
    EntityName = 'tpv';
    EntitySetName = 'tpvs';
    SourceTable = Tiendas;
    DelayedInsert = true;
    ODataKeyFields = "Cod. Tienda";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."Cod. Tienda")
                {
                    Caption = 'No';
                    ApplicationArea = All;
                }
                field(nombre; Rec.Descripcion)
                {
                    Caption = 'nombre';
                    ApplicationArea = All;
                }
                field(direccion; Rec."Direccion")
                {
                    Caption = 'direccion';
                    ApplicationArea = All;
                }
                field(direccion2; Rec."Direccion 2")
                {
                    Caption = 'direccion2';
                    ApplicationArea = All;
                }
                field(ciudad; Rec."Ciudad")
                {
                    Caption = 'ciudad';
                    ApplicationArea = All;
                }
                field(codigoPostal; Rec."Codigo Postal")
                {
                    Caption = 'codigoPostal';
                    ApplicationArea = All;
                }
                field(provincia; '')
                {
                    Caption = 'provincia';
                    ApplicationArea = All;
                }
                field(pais; Rec."Cod. Pais")
                {
                    Caption = 'pais';
                    ApplicationArea = All;
                }
                field(telefono; Rec.Telefono)
                {
                    Caption = 'telefono';
                    ApplicationArea = All;
                }
                field(movil; Rec."Telefono 2")
                {
                    Caption = 'movil';
                    ApplicationArea = All;
                }
                field(email; Rec."e-mail")
                {
                    Caption = 'email';
                    ApplicationArea = All;
                }
                field(sitioWeb; Rec."Pagina web")
                {
                    Caption = 'sitioWeb';
                    ApplicationArea = All;
                }
                field(nifCif; Rec."No. Identificacion Fiscal")
                {
                    Caption = 'nifCif';
                    ApplicationArea = All;
                }
                field(contacto; Rec."Contacto")
                {
                    Caption = 'contacto';
                    ApplicationArea = All;
                }
                field(notas; Rec."Notas")
                {
                    Caption = 'notas';
                    ApplicationArea = All;
                }
                field(fechaAlta; Rec."Fecha Alta")
                {
                    Caption = 'fechaAlta';
                    ApplicationArea = All;
                }
                field(locationCode; Rec."Cod. Almacen")
                {
                    Caption = 'locationCode';
                    ApplicationArea = All;
                }
                field(noSeries; Rec."No. Series")
                {
                    Caption = 'noSeries';
                    ApplicationArea = All;
                }
            }
        }
    }
}