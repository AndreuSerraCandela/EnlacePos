pageextension 75225 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    actions
    {
        addafter("&Invoice")
        {
            action(UpdateEmail)
            {
                ApplicationArea = All;
                Caption = 'Actualizar Correo Electrónico';
                Image = Email;
                ToolTip = 'Actualiza el correo electrónico del cliente en la factura registrada';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    Importaciones: Codeunit Importaciones;
                begin
                    if Customer.Get(Rec."Sell-to Customer No.") then begin
                        if Customer."E-Mail" <> '' then begin
                            Importaciones.UpdateEmailInvoice(Customer, Rec);
                            Message('Correo electrónico actualizado correctamente.');
                        end else
                            Error('El cliente %1 no tiene un correo electrónico configurado.', Customer."No.");
                    end else
                        Error('No se pudo encontrar el cliente %1.', Rec."Sell-to Customer No.");
                end;
            }
        }
    }
}