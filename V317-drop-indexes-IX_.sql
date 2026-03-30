--Rychlý popis: Slouží ke smazání všech indexů začínajících na IX_ z databáze iCC.
--Důvodová zpráva:
--Ode dne 13. 1. 2020 obsahuje dacpac přejmenované indexy z IX_něco na AX_tabulka_něco. 
--Přirozeně se tak při update na 3.15 a vyšší verzi z 3.14 a nižší verze dacpacem narodí nové AX_ indexy.
--To může silně zpomalit vytváření, přepis i mazání záznamů.
--Možná konzultanti v minulosti pozměnili některé IX_ indexy, proto jde dacpac cestou jen přidání AX_ a neprovede zahození IX_.
--Zahození IX_ je možno dělat buď ručně po jednom, nebo následujícím skriptem odkomentováním EXEC SP_EXECUTESQL @qry

USE iCC
DECLARE @qry NVARCHAR(MAX);
SELECT @qry = (SELECT  'DROP INDEX [' + ix.name + '] ON ' + OBJECT_NAME(ix.ID) + '; '
       FROM  sysindexes ix
	   LEFT JOIN sysindexes ax ON ax.name= 'AX_'+OBJECT_NAME(ix.ID)+'_'+SUBSTRING(ix.name,4,50)
       WHERE   ix.Name IS NOT NULL AND SUBSTRING(ix.Name, 1, 3) = 'IX_'
	   AND ax.Name IS NOT NULL
       --AND OBJECT_NAME(ID) = 'Message' --lze omezit na jednu tabulku
       FOR XML PATH('')
);
SELECT @qry --náhled textu příkazu - vypadá jako jeden řádek, ale ten je hooodně dlouhý
--EXEC SP_EXECUTESQL @qry --provede smazání indexů IX_ - pravděpodobně nemáte odvahu to dělat v pracovní době KC? Napíše (1 row affected), ale to je eufemismus.