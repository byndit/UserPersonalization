codeunit 80600 "PTE Export User Perso"
{

    procedure Export(NewUserId: Guid)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FldRef1: FieldRef;
        FldRef2: FieldRef;
        FldRef3: FieldRef;
        FldRef4: FieldRef;
        FldRef5: FieldRef;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        CrLf: Text[2];
        SaveFileDialogFilterMsg: Label 'TXT Files (*.txt)|*.txt';
        SaveFileDialogTitleMsg: Label 'Save TXT file';
        Instr: InStream;
        Filename: Text;
        MetaData: Text;
        ALPage: Text;
    begin
        Filename := 'UserPersonalization.txt';
        // Setup CR + LF
        CrLf[1] := 13; // Carriage Return
        CrLf[2] := 10; // Line Feed

        RecRef.OPEN(Database::"User Page Metadata", false, CompanyName());
        FldRef := RecRef.Field(1);
        FldRef.SetRange(NewUserId);
        // Filter on the current company, only "Note" type, and Notify = FALSE
        if RecRef.FindSet() then begin
            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            repeat
                FldRef1 := RecRef.Field(1);
                FldRef2 := RecRef.Field(2);
                FldRef3 := RecRef.Field(3);
                FldRef4 := RecRef.Field(4);
                FldRef5 := RecRef.Field(5);
                if FldRef3.Type = FldRef3.Type::Blob then
                    MetaData := ExportBlob(RecRef, FldRef3);
                if FldRef4.Type = FldRef4.Type::Blob then
                    ALPage := ExportBlob(RecRef, FldRef4);
                OutStr.WriteText(Format(FldRef1.Value) + '|' + Format(FldRef2.Value) + '|' + MetaData + '|' + ALPage + '|' + Format(FldRef5.Value) + CrLf);
            until RecRef.Next() = 0;

            TempBlob.CreateInStream(Instr);
            DownloadFromStream(Instr, SaveFileDialogTitleMsg, '', SaveFileDialogFilterMsg, Filename);
        end;
        RecRef.CLOSE();
    end;

    procedure ExportBlob(var RecRef: RecordRef; FldRef: FieldRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Instr: InStream;
        TempLine: Text[1024];
        FullText: Text;
    begin
        Clear(TempBlob);
        TempBlob.FromFieldRef(FldRef);
        if not TempBlob.HasValue() then
            exit('');
        TempBlob.CreateInStream(Instr, TextEncoding::UTF8);
        while not InStr.EOS do begin
            InStr.ReadText(TempLine, 1024);
            FullText += TempLine;
        end;
        exit(FullText);
    end;
}
