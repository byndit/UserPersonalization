codeunit 80601 "PTE Import User Perso"
{
    var
        UseRegExValue: Label '(?:%1"|^")(""|[\w\W]*?)(?="%1|"$)|(?:%1(?!")|^(?!"))([^%1]*?)(?=$|%1)', Locked = true;

    procedure Import();
    var
        TempBlob: Codeunit "Temp Blob";
        ReadStream: InStream;
        LineNo: Integer;
        ReadLen: Integer;
        ReadText: Text;
        FromFile: Text;
    begin
        TempBlob.CreateInStream(ReadStream, TextEncoding::UTF8);
        UploadIntoStream('', '', '', FromFile, ReadStream);
        LineNo := 1;
        repeat
            ReadLen := ReadStream.ReadText(ReadText);
            if ReadLen > 0 then
                ParseLine(ReadText, LineNo);
        until ReadLen = 0;
    end;

    local procedure ParseLine(Line: Text; var LineNo: Integer)
    begin
        InsertRec(Line, LineNo);
        LineNo += 1;
    end;

    procedure InsertRec(NewValue: Text; LineNo: Integer)
    var
        TempGroups: Record Groups temporary;
        TempMatches: Record Matches temporary;
        RegEx: Codeunit Regex;
        UserIdGuid: Guid;
        RecRef: RecordRef;
        PageId: Integer;
        FldRef: FieldRef;
        MetaData: Text;
        ALPage: Text;
        EmitVersion: Integer;
        RegExValue: Text;
    begin
        RegExValue := StrSubstNo(UseRegExValue, '\|');
        RegEx.Match(NewValue, RegExValue, TempMatches);

        TempMatches.Get(0);
        RegEx.Groups(TempMatches, TempGroups);
        evaluate(UserIdGuid, TempGroups.ReadValue());
        TempGroups.Get(2);

        TempMatches.Get(1);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2);
        Evaluate(PageId, TempGroups.ReadValue());

        TempMatches.Get(2);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2);
        MetaData := TempGroups.ReadValue();

        TempMatches.Get(3);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2);
        ALPage := TempGroups.ReadValue();

        TempMatches.Get(4);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2);
        Evaluate(EmitVersion, TempGroups.ReadValue());

        RecRef.OPEN(Database::"User Page Metadata", false, CompanyName());
        FldRef := RecRef.Field(1);
        FldRef.Value := UserIdGuid;
        FldRef := RecRef.Field(2);
        FldRef.Value := PageId;
        FldRef := RecRef.Field(3);
        ImportBlob(FldRef, MetaData);
        FldRef := RecRef.Field(4);
        ImportBlob(FldRef, ALPage);
        FldRef := RecRef.Field(5);
        FldRef.Value := EmitVersion;
        if not RecRef.INSERT() then
            RecRef.MODIFY();
        RecRef.CLOSE();
    end;

    procedure ImportBlob(var FldRef: FieldRef; FldValue: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        outStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        outStr.WriteText(FldValue);
        TempBlob.ToFieldRef(FldRef);
    end;
}
