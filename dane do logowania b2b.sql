select

knt_akronim as [akronim]
,KnS_Nazwa as [osoba]
,KnS_HasloOsoby as [haslo]
,KnS_EMail as [E-Mail]
,Knt_EMail as [Karty E-mail]

from cdn.kntkarty
join cdn.kntosoby on Knt_GIDNumer=KnS_KntNumer

where KnS_KntTyp=32 and Knt_Akronim='0001'