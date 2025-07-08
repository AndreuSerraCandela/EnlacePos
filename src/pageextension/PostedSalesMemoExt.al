pageextension 75226 "Posted Sales Memo Ext" extends "Posted Sales Credit Memo"
{
    actions
    {
        addafter("&Cr. Memo")
        {
            action(UpdateEmail)
            {
                ApplicationArea = All;
                Caption = 'Actualizar Correo Electrónico';
                Image = Email;
                ToolTip = 'Actualiza el correo electrónico del cliente en el memo de crédito registrado';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    Importaciones: Codeunit Importaciones;
                begin
                    if Customer.Get(Rec."Sell-to Customer No.") then begin
                        if Customer."E-Mail" <> '' then begin
                            Importaciones.UpdateEmailCrMemo(Customer, Rec);
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