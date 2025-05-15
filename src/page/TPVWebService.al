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
    SourceTable = TPV;
    DelayedInsert = true;
    ODataKeyFields = "No";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."No")
                {
                    Caption = 'No';
                    ApplicationArea = All;
                }
                field(nombre; Rec."Nombre")
                {
                    Caption = 'nombre';
                    ApplicationArea = All;
                }
                field(direccion; Rec."Dirección")
                {
                    Caption = 'direccion';
                    ApplicationArea = All;
                }
                field(direccion2; Rec."Dirección 2")
                {
                    Caption = 'direccion2';
                    ApplicationArea = All;
                }
                field(ciudad; Rec."Ciudad")
                {
                    Caption = 'ciudad';
                    ApplicationArea = All;
                }
                field(codigoPostal; Rec."Código Postal")
                {
                    Caption = 'codigoPostal';
                    ApplicationArea = All;
                }
                field(provincia; Rec."Provincia")
                {
                    Caption = 'provincia';
                    ApplicationArea = All;
                }
                field(pais; Rec."País")
                {
                    Caption = 'pais';
                    ApplicationArea = All;
                }
                field(telefono; Rec."Teléfono")
                {
                    Caption = 'telefono';
                    ApplicationArea = All;
                }
                field(movil; Rec."Móvil")
                {
                    Caption = 'movil';
                    ApplicationArea = All;
                }
                field(email; Rec."Email")
                {
                    Caption = 'email';
                    ApplicationArea = All;
                }
                field(sitioWeb; Rec."Sitio Web")
                {
                    Caption = 'sitioWeb';
                    ApplicationArea = All;
                }
                field(nifCif; Rec."NIF/CIF")
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
                field(locationCode; Rec."Location Code")
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