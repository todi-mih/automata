Theodhoraq Mihallari 333CC 

Avem 3 structure important de date pentru : variabile,gramatice,automatele (+ o structura pentru tranzitii de automat)
Cu flex primim toate stringuri importante si stocham la structure de data (vedeti commentari in cod va rog)

Din inceput,din fisier de intrare,avem 4 posibilitati 
1) incep cu variable -> variable globala  (^"variable "...)
2) sunt commentele % 
3) commentari in mai mult de linie /**/
4) sunt o nume pentru gramatica sau automat (^[a-zA-Z][a-zA-Z0-9_]* ...)

1) Daca sunt variabila globala printez imediat ,daca nu stochez data si caruia ii apartin 
4) Stochez numele la un buffer si apoit depinde ce string vine,si verific daca am gasit 
gramatica sau automat

Apoi la ambele pentru fiecare field (alphabet,stari,simbol de star etc) stochez la structura 
de data respectiva.
Cazuri speciale:
a) grammatica :
dupa datele analizam regulamentele S -> regula1| regula2 ...
daca simbol de start este singur (S,S1..) sunt gramatica de tipul 2 sau 3 (gr,idc)
daca avem doua simboluri sunt de tipul 0 sau 1
In primul caz,vedem daca avem un regulament (string in ralitate) de forma ...aSb... (simboluri pot sa fii orice)
In alta verificam condita |alpha| <= |beta|
Stochez tipul (in realitate un integer 0,1,2,3) pentru fiecare regulament la o vector globala,
cel mai mica valoare in vectorul meu este tipul

b) automatele :
Din nou,stocham toate datele (alphabet,states etc) ,dupa,avem tranzitii
Tranzitii au forma from - input - to (ex q0 - a - q1,din q0 cu a merg la q1)
!! Acest foramt este important pentru algoritmul care determine daca este det sau non det
Dupa datele primul simbol trebuie sa fii from 
Apoi sunt tranzitii in forma input ,to ,input ,to .... stocham si terminam daca 
am primit ") ;" ,fac din nou cand am terminat automatul ") ;;"
In acest moment am toate datele , incrementez indexul de automat si printez informatile despre acest automat
Am nevoie de un algoritm sa gasesc tipul (det ,non det),am facut functia isDeterminisic
Sa intoarche true daca automatul este det ,si vice-versa.Avem ca input un pointer pentru automatul current.
In primul rand avem un loop for (i in 0 ... no de tranzitii) si apoi (j in  i+1... no de tranzitii)
si verificam daca from-ul de fiecare index sunt acelas.
Apoi verificam daca input-ul de fiecare index este o variabila sau nu.Daca nu  putem sa verificam
direct cu compararea de input-uri de index daca sunt acelas atunc automatul este non det
,cu mai mult cuvinte,pentru starea initiala daca merg cu acelas input la starile diferite automatul
este non det.Daca inputul este variabila cautam structura nostra de data pentru variabile,globala sau locala,
daca una dintre ele este variabila,gasim domenuiul respectiv,si daca din o stare merg la alte starii cu acelas
input (din domenuiul) atunc este non det.Daca aceste conditii nu sunt respectate atunc este det.
Mai mult detaii in cod.

