/* Theodhoraq Mihallari 333CC */

%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

//var = varaibila
//det - deterministic

bool global_var = true;    //var sa stie daca lucram cu variabila globala sau locala 
char name_buffer[50];    //stocham momentan numele automatului/grammatica

//struct global accesabil pentru variabile de ambele tip
typedef struct {
    char identifier[50];  // Nume
    int no_of_domains;    // No de domains
    char domains[20][50]; // numele lor
    bool is_global;       //este global sau local?
    int index; //daca sunt local,ce automat apartin 
    int index_for_grammers; //la fel dar pentru gramaticii
} GlobalVar; 

// Array pentru 100 global variables
GlobalVar globalVars[100];
int globalVarCount = 0; //no de variabile
bool i_am_grammer = false; //bool folosit pentru variabile de gramatici
//am folosit acelas tranzitile (%x IN_VARIABLE) pentru variabile de automat si gramatica
//din asta am acesta variabile,sa sti daca am venit din automat sau gramatica


// Structure pentru traziti
typedef struct {
    char from[20][3];    // from state
    char input[20][10];   // input symbol
    char to[20][3];      // to state
    int count;            // no de trazitii
} AutomatonRules;

//structura pentru automate
typedef struct {
    char name[50];       
    int num_rules;       
    char alphabet[37];   //letters + digits
    int alphabet_count;
    int num_states;
    char final_states[30][3];
    int num_final_states;
    char initial_state[3];
    AutomatonRules rules;
} Automaton;

bool clock = true; //folosit pentru citirea de trazitii (explicat mai jos)
Automaton automatons[50];  
int automatonCount = 0;    
bool flag = false;  //folosit pentru printarea de variabile in trazitii

//functie care primesc un automat si verific daca este det sau non det,explicat in readme
bool isDeterministic(Automaton *a) {
    for (int i = 0; i < a->rules.count; i++) {
        char from_i[3], to_i[3];
        char input_i[50];
        strcpy(input_i,a->rules.input[i]);
        strcpy(from_i, a->rules.from[i]);
        strcpy(to_i, a->rules.to[i]);

        for (int j = i + 1; j < a->rules.count; j++) {
            char from_j[3], to_j[3];
            char input_j[50];
            strcpy(input_j,a->rules.input[j]);
            strcpy(from_j, a->rules.from[j]);
            strcpy(to_j, a->rules.to[j]);

            // Daca 2 tranziti sunt din acelas stare
            if (strcmp(from_i, from_j) == 0) {
                // Check daca inputuri sunt variabile (daca da avem nevoie de domeniu)
                bool input_i_is_var = false, input_j_is_var = false;
                int var_i_index = -1, var_j_index = -1;

                // check daca input_i este o variable
                for (int k = 0; k < globalVarCount; k++) {
                    if (strcmp((char[]){globalVars[k].identifier[0], '\0'},input_i) == 0) {
                        
                        if (globalVars[k].is_global){
                            input_i_is_var = true;
                            var_i_index = k;
                            break;
                        }else {
                            if (automatonCount == globalVars[k].index) {
                                input_i_is_var = true;
                                var_i_index = k;
                                break;
                            }
                        }
                       
                    }
                }

                // check input_j
                for (int k = 0; k < globalVarCount; k++) {
                    if (strcmp((char[]){globalVars[k].identifier[0], '\0'},input_j) == 0) {

                        if (globalVars[k].is_global){
                            input_j_is_var = true;
                            var_j_index = k;
                            break;
                        }else {
                            if (automatonCount == globalVars[k].index) {
                                input_j_is_var = true;
                                var_j_index = k;
                                break;
                            }
                        }
                    }
                }

                // daca sunt variabile 
                if (input_i_is_var || input_j_is_var) {
                    // Expand la domains
                    char expanded_inputs_i[20][50], expanded_inputs_j[20][50];
                    int count_i = 0, count_j = 0;  

                    if (input_i_is_var) {
                        for (int k = 0; k < globalVars[var_i_index].no_of_domains; k++) {
                            strcpy(expanded_inputs_i[count_i++], globalVars[var_i_index].domains[k]);
                        }
                    } else {
                        strcpy(expanded_inputs_i[count_i++],input_i);
                    }

                    if (input_j_is_var) {
                        for (int k = 0; k < globalVars[var_j_index].no_of_domains; k++) {
                            strcpy(expanded_inputs_j[count_j++], globalVars[var_j_index].domains[k]);
                        }
                    } else {
                        strcpy(expanded_inputs_j[count_j++],input_j);
                    }

                    //verificam daca 2 inputuri sunt acelas -> non det
                    for (int x = 0; x < count_i; x++) {
                        for (int y = 0; y < count_j; y++) {
                            if (strcmp(expanded_inputs_i[x], expanded_inputs_j[y]) == 0) {
                                return false; 
                            }
                        }
                    }
                } else {
                    // daca intrarile nu sunt variabile comparam direct simboluri de intrare
                    if (input_i == input_j) {
                        return false; 
                    }
                }
            }
        }
    }
    return true; // Deterministic
}



void printAutomaton(Automaton *a) {
    printf("\nNumele automatului: %s\n", a->name);
  if (isDeterministic(a)) {
        printf("Tipul automatului: Automat finit determinist (DFA)\n");
    } else {
        printf("Tipul automatului: Automat finit nedeterminist (NFA)\n");
    }    
    printf("Alfabetul de intrare: {");
    for(int i = 0; i < a->alphabet_count; i++) {
        printf("%c%s", a->alphabet[i], 
               i < a->alphabet_count - 1 ? ", " : "");
    }
    printf("}\n");
    
    printf("Numarul de stari: %d\n", a->num_states);
    printf("Starile finale: {");
    for(int i = 0; i < a->num_final_states; i++) {
        printf("%s%s", a->final_states[i],i < a->num_final_states - 1 ? ", " : "");
    }
        printf("}\n");
    printf("Starea initiala: %s\n", a->initial_state);
    
    int index = 0; //index pentru variabila (daca este)
    printf("Functia de tranzitie:\n");
    for(int i = 0; i < a->rules.count; i++) {

        for (int j = 0; j < 100; j++) {
//trecem prin vars și vedem daca oricare este egal cu inputul nostru
//latest var declarat și local are prioritate
        if (strcmp((char[]){globalVars[j].identifier[0], '\0'} ,a->rules.input[i]) == 0) {
//daca sunt global ,ok
            if (globalVars[j].is_global){
                flag = true;
                index = j;
            }else {
                //daca nu verificam ca sunt local pentur acest automat
                if(automatonCount == globalVars[j].index) {
                    flag = true;
                    index = j;
                }
            }
         
        }
    }

    if (!flag) {
        printf("m(%s, %s) = %s\n", 
               a->rules.from[i],
               a->rules.input[i],
               a->rules.to[i]);
    } else { 
     for (int k = 0;k < globalVars[index].no_of_domains; k++) {
               printf("m(%s, %s) = %s\n", 
               a->rules.from[i],
               globalVars[index].domains[k],
               a->rules.to[i]);
     }
     flag = false;
    }
   }

//local vars
 for (int i = 0; i < 100; i++) {

        if (globalVars[i].index == automatonCount) {

            printf("Variabila locala:\n");
            printf("  Identificator: %s\n", globalVars[i].identifier);
            
            printf("  Domeniu: {");
            for (int j = 0; j < globalVars[i].no_of_domains; j++) {
            printf("%s%s", globalVars[i].domains[j], (j == globalVars[i].no_of_domains - 1) ? "}" : " ,");
            //if ultimul in loop (pentru printarea)
            }
            printf("\n");
        }
    }

printf("\n");
}

typedef struct {
    char name[50];
    char alphabet[37];   //letters + digits
    int alphabet_count;
    int num_non_term;   //no de non terminali
    char start_symbol[5];
    int no_of_rules;
} Grammer;

Grammer grammers[50]; 
int grammersCount = 0;    
int type[100];  //vector care stocheaza toate tipuri pentru fiecare regula (valorea cel mai mice este tipul de gramatica)
int type_index = 0;  
int len_of_alpha; //pentru  type 0 or 1 ,alpha -> beta  (|alpha| <= |beta|)
int len_of_beta;

void print_grammer_info(Grammer *g) {
    int lowest_type = 4;

    for (int i = 0; i < type_index; i++) {
        if (type[i] < lowest_type) {
            //cel mai mica
            lowest_type  = type[i];
        }
    }
    printf("\n");
    printf("Numele gramaticii: %s\n",g->name);
    printf("Tipul gramaticii: ");
     switch (lowest_type) {
        case 0:
            printf("GN (grammatica neregulata tip 0)\n");
            break;
        case 1:
            printf("GDC (tip 1)\n");
            break;
        case 2:
            printf("GIC (tip 2)\n");
            break;
        case 3:
            printf("GR (tip 3)\n");
            break;
        default:
            printf("ERROR\n");
            break;
    }
    printf("Numarul de reguli de productie: %d\n",g->no_of_rules);
    printf("Alfabetul gramaticii: {");
    for (int i = 0; i < g->alphabet_count; i++) {
        printf("%c%s", g->alphabet[i], (i == g->alphabet_count - 1) ? "}" : " ,");
    }
    printf("\n");

    //local vars
 for (int i = 0; i < 100; i++) {

        if (globalVars[i].index_for_grammers == grammersCount) {

            printf("Variabila locala:\n");
            printf("  Identificator: %s\n", globalVars[i].identifier);
            
            printf("  Domeniu: {");
            for (int j = 0; j < globalVars[i].no_of_domains; j++) {
            printf("%s%s", globalVars[i].domains[j], (j == globalVars[i].no_of_domains - 1) ? "}" : " ,");
            }
            printf("\n");
        }
    }

    //resetam pentru gramatica urmatora
    memset(type, 0, sizeof(type));
    type_index = 0;
}
%}

%option stack
%option noyywrap
%x IN_GRAMMER_OR_AUTOMAT 
%x IN_VARIABLE
%x IN_VARIABLE2
%x IN_AUTOMATON
%x IN_COUNT  
%x IN_ALPHA
%x IN_FINAL_STATE
%x IN_INITIAL_STATE
%s IN_TRANSITIONS
%x IN_GRAMMER
%x IN_ALPHA2
%x IN_NONTERM
%x IN_START_SYMBOL
%x IN_TYPE_2_3
%x IN_TYPE_0_1

%%


^[a-zA-Z][a-zA-Z0-9_]* {
    strcpy(name_buffer,yytext);  //stocham ce am primit
    BEGIN(IN_GRAMMER_OR_AUTOMAT);    //verificam ce este
}

<IN_GRAMMER_OR_AUTOMAT>{
"::= Grammar (" {    //daca urmatorul string este asta este grammatice
    strcpy(grammers[grammersCount].name,name_buffer);
    BEGIN(IN_GRAMMER);
}
"::= FiniteAutomaton (" {   //you get the idea :) 
    strcpy(automatons[automatonCount].name,name_buffer);
    BEGIN(IN_AUTOMATON);
}
. {

}
}


<IN_GRAMMER>{

    "alphabet"[ \t]*"::"[ \t]*"{ " {   //pentru fiecare field facem patter match is stocham 
        grammers[grammersCount].alphabet_count = 0;
        yy_push_state(IN_ALPHA2);
    }

    "nonterminals"[ \t]*"::"[ \t]*"{ " {
        yy_push_state(IN_NONTERM);
    }

    "start_symbol"[ \t]*"::"[ \t]* {
        yy_push_state(IN_START_SYMBOL);
    }
    
    [A-Z][0-9]* {  //match cu: O litera mare urmata optional de mai multe cifre 
       //S,S1,S2 .... S222.... aka pot sa fii type 2 or 3 (regulated or contex free)
        type[type_index] = 3;
        type_index++;
        yy_push_state(IN_TYPE_2_3);
    }
    
    [A-Z0-9&]+ {   //tip 0 sau 1
 
    for (int i = 0; i < yyleng; i++) {
        if (isalpha(yytext[i])) {
            len_of_alpha++;
        }
    }
        yy_push_state(IN_TYPE_0_1);
    }
  	") ;;" {  //am terminat gramatica 
    print_grammer_info(&grammers[grammersCount]);
    grammersCount++;    
	BEGIN(INITIAL);
	} 

    "" {

    }

    "variable " {  //daca este o var locala
    global_var = false;    
    i_am_grammer = true;
    BEGIN(IN_VARIABLE); 
    }
    [ \t\n;]+ ;  // Skip whitespace si semicolons

}

<IN_TYPE_0_1>{
"->" {
//ignoram asta
}


[a-zA-Z1-9&]+ {
//pentru fiecare regula verificam conditia |a| <= |b|
     for (int i = 0; i < yyleng; i++) {
        if (isalpha(yytext[i])) {
            len_of_beta++;
        }
    }

    if (len_of_alpha <= len_of_beta) {
        type[type_index] = 1;
        type_index++;
    } else {
      type[type_index] = 0;
       type_index++;
    }
    len_of_beta = 0;

}

";" {
    len_of_alpha = 0;  //resetam
    grammers[grammersCount].no_of_rules++;
    yy_pop_state();
}
"|" {
 grammers[grammersCount].no_of_rules++;
}
}

<IN_TYPE_2_3>{
"->" {

}

[a-zA-Z1-9&]*[a-zA-Z][&][A-Z0-9]+[&][a-zA-z][a-zA-Z1-9&]* { //daca este de forma ...aSb de exemplu
type[type_index] = 2;
type_index++;
}


[a-zA-Z1-9&]*[a-z]*[&]*[A-Z1-9]*[&]*[a-z]*[a-zA-Z1-9&]* {
//tip 3
}

";" {
    grammers[grammersCount].no_of_rules++;
    yy_pop_state();
}
"|" {
 grammers[grammersCount].no_of_rules++;
}
}

<IN_START_SYMBOL>{

    [A-Z][a-zA-Z0-9]* { //stocham ce am primit,la fel pentru alta stari
        strcpy(grammers[grammersCount].start_symbol,yytext);
    }

   ";" { //am terminat
    yy_pop_state();
   }

}

<IN_NONTERM>{
    
    [A-Z][a-zA-Z0-9]* {
        grammers[grammersCount].num_non_term++;
    }
    "," {
    }
    "}" {
    yy_pop_state();
    }

     . {
	
	 }
}

<IN_ALPHA2>{
    [a-zA-Z0-9] { 

        grammers[grammersCount].alphabet[grammers[grammersCount].alphabet_count] = yytext[0]; 
        grammers[grammersCount].alphabet_count++; 
    }
    "," { 
    }
    "} ;" { 
        yy_pop_state();
    }
    . {

    }
}

^"variable " { 
    //variabila globala
    BEGIN(IN_VARIABLE); 
}

"%" {
//commentari pe linie
}

"/*"([^*]|\*[^/])*"*/" {
//comentari cu mai mult de randuri
}


<IN_VARIABLE>{
    [a-z][a-zA-Z0-9_]* { 
        if (global_var) {   //daca global var pritam direct si stocham
            globalVars[globalVarCount].is_global = true;
        printf("Variabila globala:\n");
        strcpy(globalVars[globalVarCount].identifier, yytext);
        printf("  Identificator: %s\n", yytext);
        
        globalVars[globalVarCount].no_of_domains = 0; 
        
        BEGIN(IN_VARIABLE2);   //alte date
    }else if (!global_var) {
        globalVars[globalVarCount].is_global = false;
        if(i_am_grammer){  //daca am venit din o gramatica
            globalVars[globalVarCount].index_for_grammers = grammersCount;
        }else {
        globalVars[globalVarCount].index = automatonCount;

        }
        strcpy(globalVars[globalVarCount].identifier, yytext);
        
        globalVars[globalVarCount].no_of_domains = 0; 
        BEGIN(IN_VARIABLE2); 
    }
        
    }
}

<IN_VARIABLE2>{
    "::="[ \t]*"{" { 
         if(global_var) {
            printf("  Domeniu: {"); 
        }
    }
    [a-zA-Z0-9_]+ { 
       //domeniu
        strcpy(globalVars[globalVarCount].domains[globalVars[globalVarCount].no_of_domains], yytext);
        globalVars[globalVarCount].no_of_domains++;
         if(global_var) {
            printf("%s", yytext); 
        }
    }
    "," { 
        if(global_var) {
            printf(", ");
        }
    
        }
    "}" { 
        if(global_var) {
            printf("}\n");
        }
        globalVarCount++; 
        if(!global_var){
            global_var = true;
            if (!i_am_grammer){
                //daca am venit din automat merg inapoi
                BEGIN(IN_AUTOMATON); 

            }else {
                i_am_grammer = false;
                BEGIN(IN_GRAMMER);
            }
  
        }else

        BEGIN(INITIAL); 
    }
     . {}
}

<IN_AUTOMATON>{
    "alphabet"[ \t]*"::"[ \t]*"{" { 
            yy_push_state(IN_ALPHA);
    }
    "states"[ \t]*"::"[ \t]*"{" {
        yy_push_state(IN_COUNT);
    }
    "final_states"[ \t]*"::"[ \t]*"{" { 
        yy_push_state(IN_FINAL_STATE);
    }
    "initial_state"[ \t]*"::" {
        yy_push_state(IN_INITIAL_STATE);
    }

    "variable " { 
    global_var = false;
    BEGIN(IN_VARIABLE); 
    }

  	") ;;" {
    printAutomaton(&automatons[automatonCount]);

    automatonCount++;
	BEGIN(INITIAL);
	} 
    [a-zA-Z0-9]+    { 
        //traziti sunt de froma : from input to -> q0 a q1 ,din q0 cu a merg la q1 (de exemplu)
        //asta este pentru stochare de from
        strcpy(automatons[automatonCount].rules.from[automatons[automatonCount].rules.count], yytext);
        BEGIN(IN_TRANSITIONS);
    }
    
    [ \t\n;]+ ; 
}

<IN_TRANSITIONS>{
"-> (" {

 }
    [a-zA-Z0-9]+ {
 //acum am stochat from,stochez inputuri si la ce stare merg cu asta
 //prima este inputul din asta stochez inputul primul (clock = true)
 //al doua este "to" (la ce stare merg cu asta,clock = false) 
 //aceste sunt in foram input,to,input,to.... din asta am folosit un clock schema
 //am invatat la apm (verilog) :)
        if(clock){
        
        strcpy(automatons[automatonCount].rules.input[automatons[automatonCount].rules.count] ,yytext);

        }else {
        strcpy(automatons[automatonCount].rules.to[automatons[automatonCount].rules.count],yytext);
        automatons[automatonCount].rules.count++;
        strcpy(automatons[automatonCount].rules.from[automatons[automatonCount].rules.count], automatons[automatonCount].rules.from[automatons[automatonCount].rules.count - 1]);

        }
        //resetam
        clock = !clock;

    }

    ") ;" {
      BEGIN(IN_AUTOMATON);
    }
}
<IN_INITIAL_STATE>{
    [a-zA-Z0-9]+ {
        strcpy(automatons[automatonCount].initial_state ,yytext); 
    }
    ";" { 
        yy_pop_state();
    }

    [ \t\n]+ ;  
}

<IN_FINAL_STATE>{
 [a-zA-Z0-9]+ { 
        strcpy(automatons[automatonCount].final_states[automatons[automatonCount].num_final_states] ,yytext); 
        automatons[automatonCount].num_final_states++; 
    }
    "," { 
    }
    "};" { 
        yy_pop_state();
    }
}

<IN_COUNT>{

    [a-zA-Z0-9]+ {
        //facem count pentru no de stari
        automatons[automatonCount].num_states++;
    }
    "," {
    }
    "}" {
        yy_pop_state(); 
    }

     . {
	
	 }
}

<IN_ALPHA>{
    [a-zA-Z0-9] { 
   
        automatons[automatonCount].alphabet[automatons[automatonCount].alphabet_count] = yytext[0]; 
        automatons[automatonCount].alphabet_count++; 
    }
    "," { 
    }
    "};" { 
        yy_pop_state();
    }
}

[ \t\n;]    ;
.           ;

%%

int main(int argc, char *argv[]) {
    if(argc != 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 1;
    }
    memset(globalVars, -1, sizeof(globalVars));

    yyin = fopen(argv[1], "r");
    yylex();
    return 0;
}