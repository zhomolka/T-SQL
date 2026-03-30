
public mcResult as long
private DEN as long
private MESIC as long
private ROK as long
private SVATEK as string
private DATUM as string
rem private BREZEN as long
private POBREZEN as long
private PABREZEN as long
rem private DUBEN as long
private PADUBEN as long
private PODUBEN as long
private VELIKONOCE as string
private m as long
private n as long
private a as long
private b as long
private c as long
private d as long
private e as long
private f as long

sub main
                SVATEK = "#1.1.# #1.5.# #8.5.# #5.7.# #6.7.# #28.9.# #28.10.# #17.11.# #24.12.# #25.12.# #26.12.#"
                ROK = DatePart("yyyy", Date)
                MESIC = DatePart("m", Date)
                DEN = DatePart("d", Date)
'               ROK = 2005
'               MESIC = 5
'               DEN = 8

rem       DATUM = "#" & Cstr(Date) & "#"
                DATUM = "#" & DEN & "." & MESIC & "." & "#"

' Zjistuje je-li obdobi Velikonoc tj. 22.3. az 26.4. vcetne a vypocita Velikonocni pondělí a patek  pro dany rok

                if (MESIC = 3 and DEN > 21) or (MESIC = 4 and DEN <= 26) then
                               VELIKONOCE = "Je Velikonocni obdobi"
                               print VELIKONOCE$
                               m = 24
                               n = 5
                               a = ROK mod 19
        b = ROK mod 4
        c = ROK mod 7
        d = (19 * a + m) mod 30
        e = (n + 2 * b + 4 * c + 6 * d) mod 7
        POBREZEN = (22 + d + e)  + 1
                    PABREZEN = (22 + d + e)  - 2
        DUBEN = (d + e - 9) + 1
            if POBREZEN <= 31 then
                 VELIKONOCE = "#" & PABREZEN             & "." & 3 & "." & "#" & "#" & POBREZEN               & "." & 3 & "." & "#"
            end if
            if PODUBEN >= 27 then
                PODUBEN = PODUBEN - 7
                            VELIKONOCE = "#" & PADUBEN   & "." & 4 & "." & "#" & "#" & PADUBEN & "." & 4 & "." & "#"
            elseif DUBEN > 0 then
                VELIKONOCE = "#" & PADUBEN               & "." & 4 & "." & "#" & "#" & PADUBEN & "." & 4 & "." & "#"
            end if
' Zjisti je-li dnesni datum pondeli Velikonocni
        f = Instr(VELIKONOCE,DATUM)
                else
                               VELIKONOCE = "Neni Velikonocni obdobi"
' Hleda je-li dnesni datum svatek
       ' f = Instr(SVATEK,DATUM)
                end if
    if f = 0 then
        f = Instr(SVATEK,DATUM)
    end if

print a; b; c; d; e
rem print BREZEN
print PABREZEN
print POBREZEN
rem print DUBEN
print PADUBEN
print PODUBEN
print VELIKONOCE$
print "ROK je ", ROK
print "MESIC je ", MESIC
print "DEN je ", DEN
print "Datum je  ", DATUM$

                if f <> 0  then
                               mcResult = 1
        print "Je svatek"
                elseif f = 0  then 
                               mcResult = 0
        print "Neni svatek"
                end if
end sub

