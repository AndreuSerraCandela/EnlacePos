page 91152 "Dividir Pago"
{
    Caption = 'Dividir Pago';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(Pago1)
            {
                Caption = 'Primer Pago';

                field(FormaPago1; FormaPago1)
                {
                    Caption = 'Forma de Pago';
                    ApplicationArea = All;
                    TableRelation = "Payment Method";
                }

                field(Importe1; Importe1)
                {
                    Caption = 'Importe';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Importe2 := TotalAmount - Importe1;
                    end;
                }
            }

            group(Pago2)
            {
                Caption = 'Segundo Pago';

                field(FormaPago2; FormaPago2)
                {
                    Caption = 'Forma de Pago';
                    ApplicationArea = All;
                    TableRelation = "Payment Method";
                }

                field(Importe2; Importe2)
                {
                    Caption = 'Importe';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Importe1 := TotalAmount - Importe2;
                    end;
                }
            }
        }
    }

    var
        FormaPago1: Code[20];
        FormaPago2: Code[20];
        Importe1: Decimal;
        Importe2: Decimal;
        TotalAmount: Decimal;

    procedure SetTotalAmount(NewAmount: Decimal)
    begin
        TotalAmount := NewAmount;
    end;

    procedure GetValues(var NewFormaPago1: Code[20]; var NewFormaPago2: Code[20]; var NewImporte1: Decimal; var NewImporte2: Decimal)
    begin
        NewFormaPago1 := FormaPago1;
        NewFormaPago2 := FormaPago2;
        NewImporte1 := Importe1;
        NewImporte2 := Importe2;
    end;

    procedure SetValues(NewFormaPago1: Code[20]; NewFormaPago2: Code[20]; NewImporte1: Decimal; NewImporte2: Decimal)
    begin
        FormaPago1 := NewFormaPago1;
        FormaPago2 := NewFormaPago2;
        Importe1 := NewImporte1;
        Importe2 := NewImporte2;
        TotalAmount := NewImporte1 + NewImporte2;
    end;
}