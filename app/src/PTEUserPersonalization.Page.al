page 80600 "PTE User Personalization"
{
    Caption = 'Extended User Personalization';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = User;
    SourceTableView = where(State = filter(Enabled));
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("User Security ID"; Rec."User Security ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Download; DownloadLbl)
                {
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        ExportUserPerso: Codeunit "PTE Export User Perso";
                    begin
                        ExportUserPerso.Export(Rec."User Security ID");
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ImportUserPerso: Codeunit "PTE Import User Perso";
                begin
                    ImportUserPerso.Import();
                end;
            }
        }
    }

    var
        DownloadLbl: Label 'Download';
}