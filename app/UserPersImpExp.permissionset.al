permissionset 80600 UserPersImpExp
{
    Assignable = true;
    Permissions = codeunit "PTE Export User Perso" = X,
        codeunit "PTE Import User Perso" = X,
        page "PTE User Personalization" = X;
}