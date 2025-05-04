/// <summary>
/// Codeunit Funciones conciliacion cuenta (ID 7001110).
/// </summary>
codeunit 90110 "Funciones conciliacion cuenta"
{
    Permissions = TableData 17 = m;
    trigger OnRun()
    BEGIN
        //Conciliacion_Automatica;
        RehacerMovsCont;
        //PonerFechaConciliacion;
    END;

    VAR
        Text100: Label 'Conciliación Normal\ \';
        Text102: Label 'Conciliación FPR\ \';
        Text104: Label 'Debe marcar algun %1 para conciliar.';
        Text105: Label 'La suma de los importes a conciliar debe ser 0.';
        Text106: Label 'Conciliación automática.';
        Text107: Label 'No hay movimientos para desliquidar.';
        Text108: Label '" - desconciliacion"';
        Text109: Label '¿Seguro que desea desconciliar los movimientos seleccionados?';
        Text110: Label 'Debe especificar una cuenta para conciliar.';
        Text111: Label '"  Cuenta      #1######## @2@@@@@@@@@\"';
        Text112: Label '"  Movs. conc. #3########"';
        Text113: Label '¿Confirma que desea regenerar los datos de la conciliación contable?';
        Text114: Label '¿Confirma que desea grabar la fecha conciliación en los movimientos contables?';
        Text115: Label 'Procesando @1@@@@@@@@@';
        Finestra: Dialog;
        Text116: Label 'El %1 %2 %3 ha sido liquidado por otro usuario.';
        MinMov: Integer;
        MaxMov: Integer;

    PROCEDURE ImporteConciliado(par_Mov: Integer): Decimal;
    VAR
        rMovCon: Record "Mov. Conciliacion cuenta";
        Importe: Decimal;
    BEGIN

        Importe := 0;

        rMovCon.RESET;
        rMovCon.SETRANGE("Nº Mov.", par_Mov);
        IF rMovCon.FIND('-') THEN BEGIN
            rMovCon.CALCSUMS("Importe conciliado");
            Importe := rMovCon."Importe conciliado";
        END;

        EXIT(Importe);
    END;

    PROCEDURE Conciliado(par_Mov: Integer; par_ImporteDL: Decimal): Boolean;
    BEGIN

        EXIT(ImporteConciliado(par_Mov) = par_ImporteDL);
    END;

    PROCEDURE Conciliacion_Automatica(par_Cuenta: Code[20]);
    VAR
        rGrConPro: Record 93;
    BEGIN
        IF par_Cuenta = '' THEN
            ERROR(Text110);

        // rGrConPro.SETRANGE(FPR, par_Cuenta);
        // IF rGrConPro.FIND('-') THEN
        //     Conciliacion_Albaranes(par_Cuenta)
        // ELSE
        Conciliacion_Cuenta(par_Cuenta);
    END;

    PROCEDURE Conciliacion_Cuenta(par_Cuenta: Text[20]);
    VAR
        rMov: Record 17;
        rMov2: Record 17;
        rMovTMP: Record 17 TEMPORARY;
        ImporteConciliadoCon: Decimal;
        nCon: Integer;
        i: Integer;
        nRegs: Integer;
        esConciliado: Boolean;
    BEGIN
        IF par_Cuenta = '' THEN
            ERROR(Text110);

        rMov.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //rMov.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        rMov.SETCURRENTKEY("G/L Account No.", "Posting Date");

        rMov.SETRANGE("G/L Account No.", par_Cuenta);
        rMov.SETRANGE(Pendiente, TRUE);

        rMov2.RESET;
        rMov2.SETCURRENTKEY("G/L Account No.", "Document No.", "Bill No.", "External Document No.");
        rMov2.SETRANGE("G/L Account No.", par_Cuenta);
        rMov2.SETRANGE(Pendiente, TRUE);

        IF rMov.FIND('-') THEN BEGIN
            Finestra.OPEN(Text100 +
                          Text111 +
                          Text112);
            Finestra.UPDATE(1, par_Cuenta);
            i := 0;
            nRegs := rMov.COUNT;
            REPEAT
                esConciliado := FALSE;
                i := i + 1;
                Finestra.UPDATE(2, ROUND((i / nRegs) * 10000, 1));
                ImporteConciliadoCon := rMov.Amount - rMov."Importe pendiente";

                // PLB 27/06/2007
                // INC-23651
                //
                //IF rMov.Amount <> ImporteConciliadoCon THEN BEGIN
                IF (rMov.Amount <> ImporteConciliadoCon) AND (rMov."External Document No." <> '') THEN BEGIN

                    rMov2.SETRANGE("Posting Date");
                    rMov2.SETRANGE("External Document No.", rMov."External Document No.");
                    rMov2.SETFILTER("Entry No.", '<>%1', rMov."Entry No.");
                    IF rMov2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            IF (rMov2."Importe pendiente" + rMov."Importe pendiente") = 0 THEN BEGIN
                                rMovTMP := rMov;
                                rMovTMP."Importe a conciliar" := rMov."Importe pendiente";
                                rMovTMP.INSERT;

                                rMovTMP := rMov2;
                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                rMovTMP.INSERT;

                                i := i + 1;
                                esConciliado := TRUE;
                            END
                        UNTIL esConciliado OR (rMov2.NEXT = 0);

                        // -- 2o intento conciliacion -------------------------------------------
                        IF NOT esConciliado THEN BEGIN
                            ImporteConciliadoCon := 0;
                            rMov2.SETRANGE("Entry No.");
                            IF rMov2.FIND('-') THEN BEGIN
                                REPEAT
                                    ImporteConciliadoCon += rMov2."Importe pendiente";
                                UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                IF ImporteConciliadoCon = 0 THEN BEGIN
                                    rMov2.FIND('-');
                                    REPEAT
                                        IF rMov2."Importe pendiente" <> 0 THEN BEGIN
                                            ImporteConciliadoCon += rMov2."Importe pendiente";

                                            rMovTMP := rMov2;
                                            rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                            rMovTMP.INSERT;

                                            IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                i := i + 1;
                                            esConciliado := ImporteConciliadoCon = 0;
                                        END;
                                    UNTIL esConciliado OR (rMov2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            IF NOT esConciliado THEN BEGIN
                                ImporteConciliadoCon := 0;
                                rMov2.SETRANGE("Posting Date", rMov."Posting Date", 99991231D);
                                rMov2.SETFILTER("Entry No.", '%1..', rMov."Entry No.");
                                IF rMov2.FIND('-') THEN BEGIN
                                    REPEAT
                                        ImporteConciliadoCon += rMov2."Importe pendiente";
                                    UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                    IF ImporteConciliadoCon = 0 THEN BEGIN
                                        rMov2.FIND('-');
                                        REPEAT
                                            ImporteConciliadoCon += rMov2."Importe pendiente";
                                            IF (rMov2."Importe pendiente") <> 0 THEN BEGIN
                                                rMovTMP := rMov2;
                                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                                rMovTMP.INSERT;

                                                IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                    i := i + 1;
                                                esConciliado := ImporteConciliadoCon = 0;
                                            END;
                                        UNTIL esConciliado OR (rMov2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                IF esConciliado THEN BEGIN
                    nCon += rMovTMP.COUNT;
                    Finestra.UPDATE(3, nCon);
                    Conciliar(rMovTMP, Text106);
                END;
            UNTIL rMov.NEXT = 0;
            Finestra.CLOSE;
        END;
    END;

    PROCEDURE Conciliar(VAR par_mov: Record 17 TEMPORARY; par_Descripcion: Text[50]): Integer;
    VAR
        rMov: Record 17;
        rMovCon: Record "Mov. Conciliacion cuenta";
        rCon: Record "Conciliacion cuenta";
        cDiaGenRegLin: Codeunit 12;
        wMin: Integer;
        wMax: Integer;
    BEGIN
        // WITH par_mov DO BEGIN
        par_mov.SETCURRENTKEY("G/L Account No.", "Posting Date");
        IF NOT par_mov.FIND('-') THEN
            ERROR(Text104, par_mov.TABLECAPTION);
        par_mov.CALCSUMS("Importe a conciliar");
        IF par_mov."Importe a conciliar" <> 0 THEN BEGIN
            par_mov.DELETEALL;
            COMMIT;
            EXIT;
        END;
        BuscarMaxMinNmovE(wMin, wMax);

        rCon.RESET;
        rCon.SETRANGE("Nº", wMin, wMax);
        IF rCon.FIND('+') THEN
            rCon."Nº" := rCon."Nº" + 1
        ELSE
            rCon."Nº" := wMin + 1;
        // If Strpos(UserId, '\') <> 0 Then
        //     rCon."Usuario" := Copystr(USERID, 11)
        // else
        rCon.Usuario := USERID;
        rCon.Fecha := TODAY;
        rCon.Hora := TIME;
        rCon.Comentario := par_Descripcion;
        rCon.INSERT(TRUE);

        IF par_mov.FIND('-') THEN
            REPEAT
                rMov.GET(par_mov."Entry No.");
                IF rMov."Importe pendiente" <> par_mov."Importe pendiente" THEN
                    ERROR(Text116, rMov.TABLECAPTION, rMov.FIELDCAPTION("Entry No."), rMov."Entry No.");

                rMovCon.INIT;
                rMovCon."Nº Mov." := par_mov."Entry No.";
                rMovCon."Nº Conciliacion" := rCon."Nº";
                rMovCon."Importe conciliado" := par_mov."Importe a conciliar";
                rMovCon."Nº cuenta" := par_mov."G/L Account No.";
                rMovCon."Fecha conciliacion" := rCon.Fecha;
                rMovCon.INSERT(TRUE);

                rMov."Importe pendiente" := par_mov."Importe pendiente" - par_mov."Importe a conciliar";
                rMov."Importe a conciliar" := 0;
                rMov."Usuario conciliacion" := '';
                IF rMov."Importe pendiente" = 0 THEN
                    rMov.Pendiente := FALSE;
                //rMov.Replicado := FALSE;
                rMov.MODIFY;
            UNTIL par_mov.NEXT = 0;

        par_mov.DELETEALL;

        COMMIT;
        // END;

        EXIT(rCon."Nº");
    END;

    PROCEDURE Conciliar_Manual(VAR par_mov: Record 17 TEMPORARY);
    VAR
        rMov: Record 17;
        rMovTMP: Record 17 TEMPORARY;
        rCon: Record "Conciliacion cuenta";
        nCon: Integer;
        rMov2: Record 17;
        esConciliado: Boolean;
        importec: Decimal;
    BEGIN
        // Conciliar_Registros
        //
        rMov.COPY(par_mov);
        rMov.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion");
        rMov.SETRANGE("G/L Account No.", par_mov."G/L Account No.");
        rMov.SETRANGE("Usuario conciliacion", USERID);
        rMov.SETFILTER(rMov.Marca, '<>%1', '');
        IF rMov.FINDFIRST THEN BEGIN

            rMov2.COPY(par_mov);
            rMov2.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion");
            rMov2.SETRANGE("G/L Account No.", par_mov."G/L Account No.");
            rMov2.SETRANGE("Usuario conciliacion", USERID);
            rMov2.SETFILTER(rMov2.Marca, '%1', '');
            IF rMov2.FIND('-') THEN BEGIN
                REPEAT
                    importec := importec - rMov2."Importe pendiente";

                    rMovTMP := rMov2;
                    rMovTMP."Importe a conciliar" := +rMov2."Importe pendiente";
                    rMovTMP.INSERT;
                    IF importec = -rMov."Importe pendiente" THEN
                        esConciliado := TRUE;
                UNTIL esConciliado OR (rMov2.NEXT = 0);
            END;
            rMovTMP := rMov;
            rMovTMP."Importe a conciliar" := +importec;
            rMovTMP.INSERT;

        END;
        rMov.ModifyAll(Pendiente, false);
        nCon := Conciliar(rMovTMP, '');

        rCon.GET(nCon);
        rCon.SETRECFILTER;
        PAGE.RUN(PAGE::"Ficha Conciliaciones cuenta", rCon);
    END;

    PROCEDURE Desconciliar_Registros(VAR par_mov: Record 17);
    VAR
        rCon: Record "Conciliacion cuenta";
        rMovCon: Record "Mov. Conciliacion cuenta";
        rMovCon2: Record "Mov. Conciliacion cuenta";
        fFichaCon: page "Movs. Conciliacion cuenta";
        rMov: Record 17;
    BEGIN

        rMovCon.RESET;
        rMovCon.SETRANGE("Nº Mov.", par_mov."Entry No.");
        IF NOT rMovCon.FIND('-') THEN
            ERROR(Text107);

        CLEAR(fFichaCon);
        fFichaCon.SETTABLEVIEW := rMovCon;
        fFichaCon.LOOKUPMODE := TRUE;
        fFichaCon.CAPTION := fFichaCon.CAPTION + Text108;
        IF fFichaCon.RUNMODAL = ACTION::LookupOK THEN BEGIN
            fFichaCon.DevolverSeleccionados(rMovCon);
            IF NOT CONFIRM(Text109) THEN
                EXIT;
            IF rMovCon.FIND('-') THEN
                REPEAT
                    rMovCon2.RESET;
                    rMovCon2.SETRANGE("Nº Conciliacion", rMovCon."Nº Conciliacion");
                    IF rMovCon2.FIND('-') THEN
                        REPEAT
                            rMov.GET(rMovCon2."Nº Mov.");
                            rMov."Importe pendiente" := rMov."Importe pendiente" + rMovCon2."Importe conciliado";
                            rMov.Pendiente := TRUE;
                            //rMov.Replicado := FALSE;
                            rMov.MODIFY;
                        UNTIL rMovCon2.NEXT = 0;
                    IF rCon.GET(rMovCon."Nº Conciliacion") THEN
                        rCon.DELETE(TRUE);
                UNTIL rMovCon.NEXT = 0;
        END;
    END;

    PROCEDURE Conciliacion_Cuenta_FPR(par_Cuenta: Code[20]);
    VAR
        rMov: Record 17;
        rMov2: Record 17;
        rMovTMP: Record 17 TEMPORARY;
        rHisAlbCom: Record 120;
        rHisFacCom: Record 122;
        rHisAboCom: Record 124;
        ImporteConciliadoCon: Decimal;
        nCon: Integer;
        i: Integer;
        nRegs: Integer;
        wFactura: Code[20];
        rHisAlbComtmp: Record 120 TEMPORARY;
    BEGIN

        IF par_Cuenta = '' THEN
            ERROR(Text110);

        nCon := 0;
        rMov.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //rMov.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        rMov.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion", Pendiente, "Document Type");

        rMov.SETRANGE("G/L Account No.", par_Cuenta);
        rMov.SETRANGE(Pendiente, TRUE);
        rMov.SETRANGE("Document Type", rMov."Document Type"::" ");

        rMov2.RESET;
        rMov2.SETCURRENTKEY("G/L Account No.", "Document No.", "Bill No.", "External Document No.");
        rMov2.SETRANGE("G/L Account No.", par_Cuenta);
        rMov2.SETRANGE(Pendiente, TRUE);

        IF rMov.FIND('-') THEN BEGIN
            Finestra.OPEN(Text102 +
                          Text111 +
                          Text112);
            Finestra.UPDATE(1, par_Cuenta);
            i := 0;
            nRegs := rMov.COUNT;
            REPEAT
                i := i + 1;
                Finestra.UPDATE(2, ROUND((i / nRegs) * 10000, 1));

                IF rHisAlbCom.GET(rMov."Document No.") then // {AND (rHisAlbCom."Nº Factura" <> '')} THEN
                    wFactura := Factura(rHisAlbCom."No.")
                ELSE
                    wFactura := '';
                IF wFactura <> '' THEN BEGIN
                    IF rHisFacCom.GET(wFactura) THEN BEGIN
                        rMov2.SETRANGE("Document Type", rMov2."Document Type"::Invoice);
                        rMov2.SETRANGE("Document No.", wFactura);
                    END
                    ELSE
                        IF rHisAboCom.GET(wFactura) THEN BEGIN
                            rMov2.SETRANGE("Document Type", rMov2."Document Type"::"Credit Memo");
                            rMov2.SETRANGE("Document No.", wFactura);
                        END
                        ELSE BEGIN
                            rMov2.SETRANGE("Document Type");
                            rMov2.SETRANGE("Document No.", wFactura);
                        END;

                    // -- 1er intento conciliacion -------------------------------------------
                    // se cazan los movimientos de las facturas con el albarán
                    //
                    IF rMov2.FIND('-') THEN BEGIN
                        REPEAT
                            IF NOT rMovTMP.GET(rMov."Entry No.") THEN BEGIN
                                rMovTMP := rMov;
                                rMovTMP."Importe a conciliar" := 0;
                                rMovTMP.INSERT;
                            END;
                            rMovTMP."Importe a conciliar" -= rMov2."Importe pendiente";
                            rMovTMP.MODIFY;

                            rMovTMP := rMov2;
                            rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                            rMovTMP.INSERT;

                            IF rMov2."Document Type" = rMov2."Document Type"::" " THEN
                                i := i + 1;
                        UNTIL rMov2.NEXT = 0;

                        // -- 2o intento conciliacion -------------------------------------------
                        // se cazan todos los albaranes relacionados con las facturas del primer albarán
                        //
                        Albaranes(wFactura, par_Cuenta, rHisAlbComtmp);
                        rHisAlbComtmp.SETFILTER("No.", '<>%1', rHisAlbCom."No.");
                        IF rHisAlbComtmp.FIND('-') THEN
                            REPEAT
                                IF rHisAlbComtmp."No." <> rMovTMP."Document No." THEN BEGIN
                                    //rMov2.SETRANGE("Document Type", rMov2."Document Type"::Receipt);
                                    rMov2.SETRANGE("Document No.", rHisAlbCom."No.");
                                    IF rMov2.FIND('-') THEN BEGIN
                                        ImporteConciliadoCon := -rMov2."Importe pendiente";

                                        IF NOT rMovTMP.GET(rMov."Entry No.") THEN BEGIN
                                            rMovTMP := rMov;
                                            rMovTMP."Importe a conciliar" := 0;
                                            rMovTMP.INSERT;
                                        END;
                                        rMovTMP."Importe a conciliar" -= rMov2."Importe pendiente";
                                        rMovTMP.MODIFY;

                                        rMovTMP := rMov2;
                                        rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                        rMovTMP.INSERT;

                                        i := i + 1;
                                    END;
                                END;
                            UNTIL rHisAlbComtmp.NEXT = 0;

                        // -- Testeo conciliacion -------------------------------------------
                        // Se verifica que los importes a conciliar tengan sentido. En caso contrario
                        // se intentan recalcular los importes a liquidar
                        //
                        rMovTMP.GET(rMov."Entry No.");
                        rMovTMP.CALCFIELDS("Importe conciliado");
                        IF (ABS(rMovTMP."Importe a conciliar" + rMovTMP."Importe conciliado") > ABS(rMovTMP.Amount)) OR
                           ((rMovTMP.Amount > 0) AND (rMovTMP."Importe a conciliar" < 0)) OR
                           ((rMovTMP.Amount < 0) AND (rMovTMP."Importe a conciliar" > 0)) THEN BEGIN
                            ImporteConciliadoCon := rMovTMP."Importe a conciliar";

                            rMovTMP."Importe a conciliar" := rMovTMP.Amount - rMovTMP."Importe conciliado";
                            rMovTMP.MODIFY;
                            ImporteConciliadoCon := rMovTMP."Importe a conciliar" - ImporteConciliadoCon;

                            rMovTMP.SETFILTER("Entry No.", '<>%1', rMov."Entry No.");
                            IF rMovTMP.FIND('+') THEN
                                REPEAT
                                    IF ((rMovTMP.Amount > 0) AND (ImporteConciliadoCon > 0)) OR
                                       ((rMovTMP.Amount < 0) AND (ImporteConciliadoCon < 0)) THEN BEGIN

                                        // solo volvemos el contador atras si el movimiento quedaba totalmente liquidado
                                        //
                                        IF (rMovTMP."Document Type" = rMovTMP."Document Type"::" ") AND
                                           (rMovTMP."Importe pendiente" = rMovTMP."Importe a conciliar") THEN
                                            i := i - 1;

                                        IF ABS(ImporteConciliadoCon) > ABS(rMovTMP."Importe a conciliar") THEN BEGIN
                                            ImporteConciliadoCon := ImporteConciliadoCon - rMovTMP."Importe a conciliar";
                                            rMovTMP.DELETE;
                                        END
                                        ELSE BEGIN
                                            rMovTMP."Importe a conciliar" := rMovTMP."Importe a conciliar" - ImporteConciliadoCon;
                                            rMovTMP.MODIFY;
                                            ImporteConciliadoCon := 0;
                                        END;
                                    END;
                                UNTIL (rMovTMP.NEXT(-1) = 0) OR (ImporteConciliadoCon = 0);
                            rMovTMP.SETRANGE("Entry No.");

                            // Si aun asi la suma de los importes a conciliar no es 0, modificamos el importe a conciliar
                            // del movimiento de referencia
                            //
                            IF ImporteConciliadoCon <> 0 THEN BEGIN
                                rMovTMP.GET(rMov."Entry No.");
                                rMovTMP."Importe a conciliar" := rMovTMP."Importe a conciliar" - ImporteConciliadoCon;
                                IF rMovTMP."Importe a conciliar" = 0 THEN
                                    rMovTMP.DELETEALL
                                ELSE
                                    rMovTMP.MODIFY;
                            END;
                        END;

                        // Solo conciliaremos si hay algo que conciliar
                        //
                        IF rMovTMP.FIND('-') THEN BEGIN
                            nCon += rMovTMP.COUNT;
                            Conciliar(rMovTMP, Text106);
                            Finestra.UPDATE(3, nCon);
                        END;
                    END;
                END;
            UNTIL rMov.NEXT = 0;
            Finestra.CLOSE;
        END;
    END;

    PROCEDURE RehacerMovsCont();
    VAR
        rMov: Record 17;
        i: Integer;
        nRegs: Integer;
        ImpCon: Decimal;
    BEGIN

        IF NOT CONFIRM(Text113) THEN
            EXIT;

        rMov.RESET;
        IF rMov.FIND('-') THEN BEGIN
            Finestra.OPEN(Text115);
            i := 0;
            nRegs := rMov.COUNT;
            REPEAT
                i := i + 1;
                Finestra.UPDATE(1, ROUND((i / nRegs) * 10000, 1));
                ImpCon := ImporteConciliado(rMov."Entry No.");
                IF rMov."Importe pendiente" <> ROUND(rMov.Amount - ImpCon) THEN BEGIN
                    rMov."Importe pendiente" := ROUND(rMov.Amount - ImpCon);
                    rMov.Pendiente := rMov."Importe pendiente" <> 0;
                    //      rMov.Replicado := FALSE;
                    rMov.MODIFY;
                END;
            UNTIL rMov.NEXT = 0;
            Finestra.CLOSE;
        END;
    END;

    PROCEDURE PonerFechaConciliacion();
    VAR
        rMovCon: Record "Mov. Conciliacion cuenta";
        rMovCon2: Record "Mov. Conciliacion cuenta";
        rCon: Record "Conciliacion cuenta";
        i: Integer;
        nRegs: Integer;
    BEGIN

        IF NOT CONFIRM(Text114) THEN
            EXIT;

        rMovCon.RESET;
        rMovCon.SETCURRENTKEY("Fecha conciliacion");
        rMovCon.SETRANGE("Fecha conciliacion", 0D);
        IF rMovCon.FIND('-') THEN BEGIN
            Finestra.OPEN(Text115);
            i := 0;
            nRegs := rMovCon.COUNT;
            REPEAT
                i := i + 1;
                Finestra.UPDATE(1, ROUND((i / nRegs) * 10000, 1));
                rCon.GET(rMovCon."Nº Conciliacion");
                rMovCon2 := rMovCon;
                rMovCon2."Fecha conciliacion" := rCon.Fecha;
                rMovCon2.MODIFY;
            UNTIL rMovCon.NEXT = 0;
        END;
        Finestra.CLOSE;
    END;

    PROCEDURE Conciliacion_Albaranes(par_Cuenta: Text[20]);
    VAR
        rMov: Record 17;
        rMov2: Record 17;
        rMovTMP: Record 17 TEMPORARY;
        ImporteConciliadoCon: Decimal;
        nCon: Integer;
        i: Integer;
        nRegs: Integer;
        esConciliado: Boolean;
    BEGIN
        //Tax Area Code
        IF par_Cuenta = '' THEN
            ERROR(Text110);

        rMov.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //rMov.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        rMov.SETCURRENTKEY("G/L Account No.", "Posting Date");
        rMov.SETRANGE("G/L Account No.", par_Cuenta);
        rMov.SETRANGE(Pendiente, TRUE);

        rMov2.RESET;
        rMov2.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
        rMov2.SETRANGE("G/L Account No.", par_Cuenta);
        rMov2.SETRANGE(Pendiente, TRUE);
        //rMov2.SETRANGE(rMov2."Document Type", rMov2."Document Type"::Receipt);
        rMov2.SETRANGE(rMov2."Tax Area Code", '');
        rMov2.SETFILTER(rMov2."Document No.", '<>%1', '');
        IF rMov2.FINDFIRST THEN
            REPEAT
                rMov2."Tax Area Code" := rMov2."Document No.";
                rMov2.MODIFY;
            UNTIL NOT rMov2.FINDFIRST;
        rMov2.SETRANGE(rMov2."Document Type");
        rMov2.SETRANGE(rMov2."Tax Area Code");
        rMov2.SETRANGE(rMov2."Document No.");

        IF rMov.FIND('-') THEN BEGIN
            Finestra.OPEN(Text100 +
                          Text111 +
                          Text112);
            Finestra.UPDATE(1, par_Cuenta);
            i := 0;
            nRegs := rMov.COUNT;
            REPEAT
                esConciliado := FALSE;
                i := i + 1;
                Finestra.UPDATE(2, ROUND((i / nRegs) * 10000, 1));
                ImporteConciliadoCon := rMov.Amount - rMov."Importe pendiente";

                IF (rMov.Amount <> ImporteConciliadoCon) AND (rMov."Tax Area Code" <> '') THEN BEGIN

                    rMov2.SETRANGE("Posting Date");
                    rMov2.SETRANGE("Tax Area Code", rMov."Tax Area Code");
                    rMov2.SETFILTER("Entry No.", '<>%1', rMov."Entry No.");
                    IF rMov2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            IF (rMov2."Importe pendiente" + rMov."Importe pendiente") = 0 THEN BEGIN
                                rMovTMP := rMov;
                                rMovTMP."Importe a conciliar" := rMov."Importe pendiente";
                                rMovTMP.INSERT;

                                rMovTMP := rMov2;
                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                rMovTMP.INSERT;

                                i := i + 1;
                                esConciliado := TRUE;
                            END
                        UNTIL esConciliado OR (rMov2.NEXT = 0);
                        //Conciliando por el mayor
                        IF NOT esConciliado THEN BEGIN
                            REPEAT
                                IF ABS(rMov2."Importe pendiente") < ABS(rMov."Importe pendiente") THEN BEGIN
                                    rMovTMP := rMov;
                                    rMovTMP."Importe a conciliar" := -rMov2."Importe pendiente";
                                    rMovTMP.INSERT;

                                    rMovTMP := rMov2;
                                    rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                    rMovTMP.INSERT;

                                    i := i + 1;
                                    esConciliado := TRUE;
                                END
                            UNTIL esConciliado OR (rMov2.NEXT = 0);
                        END;
                        // -- 2o intento conciliacion -------------------------------------------
                        IF NOT esConciliado THEN BEGIN
                            ImporteConciliadoCon := 0;
                            rMov2.SETRANGE("Entry No.");
                            IF rMov2.FIND('-') THEN BEGIN
                                REPEAT
                                    ImporteConciliadoCon += rMov2."Importe pendiente";
                                UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                IF ImporteConciliadoCon = 0 THEN BEGIN
                                    rMov2.FIND('-');
                                    REPEAT
                                        IF rMov2."Importe pendiente" <> 0 THEN BEGIN
                                            ImporteConciliadoCon += rMov2."Importe pendiente";

                                            rMovTMP := rMov2;
                                            rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                            rMovTMP.INSERT;

                                            IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                i := i + 1;
                                            esConciliado := ImporteConciliadoCon = 0;
                                        END;
                                    UNTIL esConciliado OR (rMov2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            IF NOT esConciliado THEN BEGIN
                                ImporteConciliadoCon := 0;
                                rMov2.SETRANGE("Posting Date", rMov."Posting Date", 99991231D);
                                rMov2.SETFILTER("Entry No.", '%1..', rMov."Entry No.");
                                IF rMov2.FIND('-') THEN BEGIN
                                    REPEAT
                                        ImporteConciliadoCon += rMov2."Importe pendiente";
                                    UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                    IF ImporteConciliadoCon = 0 THEN BEGIN
                                        rMov2.FIND('-');
                                        REPEAT
                                            ImporteConciliadoCon += rMov2."Importe pendiente";
                                            IF (rMov2."Importe pendiente") <> 0 THEN BEGIN
                                                rMovTMP := rMov2;
                                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                                rMovTMP.INSERT;

                                                IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                    i := i + 1;
                                                esConciliado := ImporteConciliadoCon = 0;
                                            END;
                                        UNTIL esConciliado OR (rMov2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                IF esConciliado THEN BEGIN
                    nCon += rMovTMP.COUNT;
                    Finestra.UPDATE(3, nCon);
                    Conciliar(rMovTMP, Text106);
                    COMMIT;
                END;
            UNTIL rMov.NEXT = 0;
            Finestra.CLOSE;
        END;
    END;

    PROCEDURE BuscarMaxMinNmovE(VAR par_Min: Integer; VAR par_Max: Integer);
    VAR
        glSetup: Record 98;
    BEGIN
        // BuscarMaxMinNmovE
        //
        // Numerador movimientos

        glSetup.GET;
        BuscarMaxMinNmov;

        par_Min := MinMov;
        par_Max := MaxMov;
    END;

    PROCEDURE Factura(Albaran: Code[20]): Code[20];
    VAR
        r123: Record 123;
        r125: Record 125;
    BEGIN
        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + Albaran + '*');
        IF r123.FINDFIRST THEN EXIT(r123."Document No.");
        r125.SETCURRENTKEY(r125."Buy-from Vendor No.", r125.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r125.SETFILTER(r125.Description, '%1', '*' + Albaran + '*');
        IF r125.FINDFIRST THEN EXIT(r125."Document No.");

        //   {REPEAT
        //        r122.SETRANGE(r122."No.", r123."Document No.");
        //        IF r122.FINDFIRST THEN r122.MARK := TRUE;
        //     UNTIL r123.NEXT = 0;
        //     r122.SETRANGE(r122."No.");
        //     r122.MARKEDONLY := TRUE;
        //     PAGE.RUNMODAL(0, r122); }
    END;

    PROCEDURE Albaranes(tFactura: Code[20]; tcuenta: Text[30]; VAR rAlb: Record 120 TEMPORARY): Code[20];
    VAR
        r17: Record 17;
        r120: Record 120;
    BEGIN
        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.", r17."Posting Date", r17."Tax Area Code");
        r17.SETRANGE("Document No.", tFactura);
        r17.SETRANGE(r17."G/L Account No.", tcuenta);
        IF r17.FINDFIRST THEN
            REPEAT
                IF r17."Tax Area Code" <> '' THEN BEGIN
                    IF r120.GET(r17."Tax Area Code") THEN BEGIN
                        rAlb := r120;
                        IF rAlb.INSERT THEN;
                    END;
                END;
            UNTIL r17.NEXT = 0;
    END;

    LOCAL PROCEDURE BuscarMaxMinNmov();
    VAR
        GLSetup: Record 98;
    BEGIN
        // BuscarMaxMinNmov
        //
        // Numerador movimientos

        MinMov := 0;
        MaxMov := 2147483647;
    END;

    PROCEDURE Conciliacion_Proveedor(par_Cuenta: Code[20]; par_Proveedor: Code[20]);
    VAR
        rMov: Record 17;
        rMov2: Record 17;
        rMovTMP: Record 17 TEMPORARY;
        ImporteConciliadoCon: Decimal;
        nCon: Integer;
        i: Integer;
        nRegs: Integer;
        esConciliado: Boolean;
    BEGIN
        //Tax Area Code
        IF par_Cuenta = '' THEN
            ERROR(Text110);

        rMov.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //rMov.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        rMov.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.", "Gen. Posting Type", "Document Type");
        rMov.SETRANGE("G/L Account No.", par_Cuenta);
        rMov.SETRANGE("Source No.", par_Proveedor);
        rMov.SETRANGE("Source Type", rMov."Source Type"::Vendor);
        rMov.SETRANGE(Pendiente, TRUE);

        rMov2.RESET;
        rMov2.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.", "Gen. Posting Type", "Document Type");
        rMov2.SETRANGE("G/L Account No.", par_Cuenta);
        rMov2.SETRANGE(Pendiente, TRUE);
        rMov2.SETRANGE("Source No.", par_Proveedor);
        rMov2.SETRANGE("Source Type", rMov2."Source Type"::Vendor);

        IF rMov.FIND('-') THEN BEGIN
            Finestra.OPEN(Text100 +
                          Text111 +
                          Text112);
            Finestra.UPDATE(1, par_Cuenta);
            i := 0;
            nRegs := rMov.COUNT;
            REPEAT
                esConciliado := FALSE;
                i := i + 1;
                Finestra.UPDATE(2, ROUND((i / nRegs) * 10000, 1));
                ImporteConciliadoCon := rMov.Amount - rMov."Importe pendiente";

                IF (rMov.Amount <> ImporteConciliadoCon) then begin //{AND (rMov."Tax Area Code" <> '')} THEN BEGIN

                    rMov2.SETRANGE("Posting Date");
                    //rMov2.SETRANGE("Tax Area Code", rMov."Tax Area Code");
                    rMov2.SETFILTER("Entry No.", '<>%1', rMov."Entry No.");
                    IF rMov2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            IF (rMov2."Importe pendiente" + rMov."Importe pendiente") = 0 THEN BEGIN
                                rMovTMP := rMov;
                                rMovTMP."Importe a conciliar" := rMov."Importe pendiente";
                                rMovTMP.INSERT;

                                rMovTMP := rMov2;
                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                rMovTMP.INSERT;

                                i := i + 1;
                                esConciliado := TRUE;
                            END
                        UNTIL esConciliado OR (rMov2.NEXT = 0);

                        // -- 2o intento conciliacion -------------------------------------------
                        IF NOT esConciliado THEN BEGIN
                            ImporteConciliadoCon := 0;
                            rMov2.SETRANGE("Entry No.");
                            IF rMov2.FIND('-') THEN BEGIN
                                REPEAT
                                    ImporteConciliadoCon += rMov2."Importe pendiente";
                                UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                IF ImporteConciliadoCon = 0 THEN BEGIN
                                    rMov2.FIND('-');
                                    REPEAT
                                        IF rMov2."Importe pendiente" <> 0 THEN BEGIN
                                            ImporteConciliadoCon += rMov2."Importe pendiente";

                                            rMovTMP := rMov2;
                                            rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                            rMovTMP.INSERT;

                                            IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                i := i + 1;
                                            esConciliado := ImporteConciliadoCon = 0;
                                        END;
                                    UNTIL esConciliado OR (rMov2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            IF NOT esConciliado THEN BEGIN
                                ImporteConciliadoCon := 0;
                                rMov2.SETRANGE("Posting Date", rMov."Posting Date", 99991231D);
                                rMov2.SETFILTER("Entry No.", '%1..', rMov."Entry No.");
                                IF rMov2.FIND('-') THEN BEGIN
                                    REPEAT
                                        ImporteConciliadoCon += rMov2."Importe pendiente";
                                    UNTIL (ImporteConciliadoCon = 0) OR (rMov2.NEXT = 0);

                                    IF ImporteConciliadoCon = 0 THEN BEGIN
                                        rMov2.FIND('-');
                                        REPEAT
                                            ImporteConciliadoCon += rMov2."Importe pendiente";
                                            IF (rMov2."Importe pendiente") <> 0 THEN BEGIN
                                                rMovTMP := rMov2;
                                                rMovTMP."Importe a conciliar" := rMov2."Importe pendiente";
                                                rMovTMP.INSERT;

                                                IF rMov2."Entry No." <> rMov."Entry No." THEN
                                                    i := i + 1;
                                                esConciliado := ImporteConciliadoCon = 0;
                                            END;
                                        UNTIL esConciliado OR (rMov2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                IF esConciliado THEN BEGIN
                    nCon += rMovTMP.COUNT;
                    Finestra.UPDATE(3, nCon);
                    Conciliar(rMovTMP, Text106);
                END;
            UNTIL rMov.NEXT = 0;
            Finestra.CLOSE;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitGLEntry', '', false, false)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal)
    var
    begin
        GLEntry."Importe pendiente" := GLEntry.Amount;
        GLEntry.Pendiente := GLEntry."Importe pendiente" <> 0;
    end;

    // BEGIN
    // {
    //   // COC2.00 - Conciliación de FPR

    //   // PLB 06/03/2002
    //   COC2.01
    //   Guardar la fecha de conciliación en los movimientos para poder hacer ver que estaba pendiente a una fecha determinada

    //   // PLB 17/07/2002
    //   Conciliación automática para la empresa activa

    //   // PLB 15/02/2006
    //   INC-18469
    //   Problemas de rendimiento y bloqueos provocados por la conciliación contable

    //   Se han realizado los siguientes cambios:

    //   - Se ha reprogramado las rutinas de conciliacion contable
    //   - Sigue liquidando los movimientos con las mismas condiciones pero se emplean variables temporales
    //     para ir guardando las conciliaciones
    //   - Tambien se ha a¤adido un COMMIT despues de una conciliación (en la del FPR ya estaba)
    //   - Al inicio de las conciliaciones ya no se realiza ningún MODIFYALL
    //   - No se utiliza el campo "Usuario conciliacion" (este se usará sólo en las conciliaciones manuales)
    //   - Se ha eliminado una parte de codigo que no repercutía en los procesos (el bucle de empresas)
    //   - La función "Conciliacion_Automatica" se ha dividido en dos: "Conciliacion_Automatica" y "Conciliacion_Cuenta"
    //   - La función "Conciliacion_Automatica_FPR" se ha renombrado a "Conciliacion_Cuenta_FPR"
    //   - Se ha eliminado la parte pensada para la marca "Conciliacion automatica" en la cuenta. Este campo
    //     deberá eliminarse en un futuro

    //   // PLB 27/06/2007
    //   INC-23651
    //   Mejoras de rendimiento
    // }
    // END.

}