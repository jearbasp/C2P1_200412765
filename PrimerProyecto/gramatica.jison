/**
 * Gramatica de lectura de entrada Primer Proyecto Compi2
 */

/* Definición Léxica */
%lex

%options case-insensitive

%%

"function"          return 'TOK_FUNCION';
"void"              return 'TOK_VOID';
"String"            return 'TOK_STRING';
"Number"            return 'TOK_NUMBER';
"Boolean"           return 'TOK_BOOLEAN';
"types"             return 'TOK_TYPES';
"let"               return 'TOK_LET';
"const"             return 'TOK_CONST';
"true"              return 'TOK_TRUE';
"false"             return 'TOK_FALSE';
"and"               return 'TOK_AND';
"or"                return 'TOK_OR';
"not"               return 'TOK_NOT';
"console.log"       return 'TOK_CONSOLA';
"graficar_ts"       return 'TOK_GRAFICAR';
"return"            return 'TOK_RETURN';
"continue"          return 'TOK_CONTINUE';
"break"             return 'TOK_BREAK';
"if"                return 'TOK_SI';
"else"              return 'TOK_SINO';
"switch"            return 'TOK_ENCASO';
"case"              return 'TOK_CASO';
"default"           return 'TOK_DEFECTO';
"for"               return 'TOK_FOR';
"in"                return 'TOK_IN';
"of"                return 'TOK_OF';
"while"             return 'TOK_MIENTRAS';
"do"                return 'TOK_HACER';
"var"               return 'TOK_VAR';
"push"              return 'TOK_PUSH';
"pop"               return 'TOK_POP';
"length"            return 'TOK_SIZE';

";"                 return 'TOK_PTCOMA';
"("                 return 'TOK_PARIZQ';
")"                 return 'TOK_PARDER';
"["                 return 'TOK_CORIZQ';
"]"                 return 'TOK_CORDER';
"{"                 return 'TOK_LLAIZQ';
"}"                 return 'TOK_LLADER';
":"                 return 'TOK_DOSPUNTOS';
","                 return 'TOK_COMA';
"'"                 return 'TOK_COMILLA';
"!"                 return 'TOK_ADMIRACION';
"?"                 return 'TOK_INTERROGACION';
"."                 return 'TOK_PUNTO';

"%"                 return 'MODIFICADOR';
"="                 return 'TOK_IGUAL';
"+"                 return 'MAS';
"-"                 return 'MENOS';
"*"                 return 'POR';
"/"                 return 'DIVIDIDO';
">"                 return 'MAYORQUE';
"<"                 return 'MENORQUE';

/* Espacios en blanco */
[ \r\t]+            {}
\n                  {}

[0-9]+("."[0-9]+)?\b    return 'TOK_DECIMAL';
//[0-9]+\b                return 'TOK_ENTERO';
([a-zA-Z])[a-zA-Z0-9_]* return 'TOK_ID';
([a-zA-Z])[a-zA-Z0-9_" "]* return 'TOK_TEXTO';

<<EOF>>                 return 'EOF';

.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex

/* Asociación de operadores y precedencia */

%left 'MAS' 'MENOS'
%left 'POR' 'DIVIDIDO'
%left UMENOS

%start inicio

%% /* Definición de la gramática */

inicio: 
    codigo EOF { console.log('Codigo sin Funciones anidadas: ' + $1); }
;

codigo:
    cod codigo { $$ = $1 + $2; }
    |cod { $$ = $1; }
    |error { console.error('Este es un error sintáctico: ' + yytext + ', en la linea: ' + @$.first_line + ', en la columna: ' + @$.first_column); }
;

cod:
    funcion { $$ = $1; }
    |declaracion { $$ = $1 + '\n'; }
    |asignacion { $$ = $1 + '\n'; }
    |llamadaFunc TOK_PTCOMA { $$ = $1 + ';\n'; }
    |sentenciasControl { $$ = $1; }
    |sentenciasCiclo { $$ = $1; }
    |retornaFunc { $$ = $1; }
    //| { $$ = ''; }
;

funcion:
    TOK_FUNCION TOK_ID TOK_PARIZQ parametros TOK_PARDER TOK_DOSPUNTOS typeVar TOK_LLAIZQ codigo TOK_LLADER { $$ = 'function ' + $2 + '(' + $4 + '):' + $7 + '{\n' + $9 + '\n}\n'; }
;

parametros:
    parametro TOK_COMA parametros { $$ = $1 + ',' + $3; }
    |parametro { $$ = $1; }
;

parametro:
    TOK_ID TOK_DOSPUNTOS tipoVar { $$ = $1 + ':' + $3; }
    | { $$ = ''; }
;

parametrosEnv:
    terminalBool TOK_COMA parametrosEnv { $$ = $1 + ',' + $3; }
    |terminalBool { $$ = $1; }
    | { $$ = $1; }
;



typeVar:
    TOK_VOID { $$ = 'void'; }
    |tipoVar { $$ = $1; }
;

tipoVar:
    TOK_STRING { $$ = $1; }
    |TOK_NUMBER { $$ = $1; }
    |TOK_BOOLEAN { $$ = $1; }
    |TOK_TYPES { $$ = $1; }
    |error { console.error('Este es un error sintáctico: ' + yytext + ', en la linea: ' + @$.first_line + ', en la columna: ' + @$.first_column); $$ = 'Types'; }
;

declaracion:
    tipoDec asignacion { $$ = $1 + ' ' + $2; }
;

asignacion:
    TOK_ID igualdad TOK_PTCOMA { $$ = $1 + $2 + ';'; }
;

igualdad:
    TOK_IGUAL expresion { $$ = '=' + $2; }
    | { $$ = ''; }
;

addRest:
    TOK_ID MAS MAS { $$ = $1 + '++'; }
    |TOK_ID MENOS MENOS { $$ = $1 + '--'; }
;

tipoDec:
    TOK_LET { $$ = 'let'; }
    |TOK_CONST { $$ = 'const'; }
    |TOK_VAR { $$ = 'var'; }
;

expresion:
    //operacionArit { $$ = $1; }
    expBooleana { $$ = $1; }
;

operacionArit:
    //MENOS expresion %prec UMENOS  { $$ = $2 *-1; }
	operacionArit MAS operacionArit       { $$ = $1 + '+' + $3; }
	|operacionArit MENOS operacionArit     { $$ = $1 + '-' + $3; }
	|operacionArit POR operacionArit       { $$ = $1 + '*' + $3; }
	|operacionArit DIVIDIDO operacionArit  { $$ = $1 + '/' + $3; }
    |operacionArit POR POR operacionArit  { $$ = $1 + '^' + $4; }
    //|operacionArit MODIFICADOR operacionArit  { $$ = $1 + '%' + $3; }
    |terminal TOK_ADMIRACION { $$ = $1 + '!'; } 
	|terminal { $$ = $1; }
    //|terminal MAS MAS { $$ = $1 + '++'; }
    //|terminal MENOS MENOS { $$ = $1 + '--'; }
	|TOK_PARIZQ expBooleana TOK_PARDER       { $$ = '(' + $2 + ')'; }
;

terminal:
    TOK_DECIMAL { $$ = $1; }
    |TOK_ID { $$ = $1; }
    |TOK_COMILLA TOK_ID TOK_COMILLA { $$ = $1 + $2 + $3; }
    |llamadaFunc { $$ = $1; }
    |terniario {  $$ = $1;  }
;

terniario:
    TOK_ID TOK_INTERROGACION expresion TOK_DOSPUNTOS terminal { $$ = $1 + '?' + $3 + ':' + $5; }
;

expBooleana:
	expBooleana1 TOK_AND expBooleana1 { $$ = $1 + ' AND ' + $3; }
	|expBooleana1 TOK_OR expBooleana1 { $$ = $1 + ' OR ' + $3; }
	|TOK_NOT expBooleana1 { $$ = 'NOT ' + $2 ; }
	|expBooleana1 { $$ = $1; }
	//|TOK_PARIZQ expBooleana TOK_PARDER { $$ = '(' + $2 + ')'; }
;

expBooleana1:
	terminalBool MAYORQUE terminalBool { $$ = $1 + '>' + $3; }
	|terminalBool MENORQUE terminalBool { $$ = $1 + '<' + $3; }
	|terminalBool TOK_IGUAL terminalBool { $$ = $1 + '=' + $3; }
    |terminalBool MENORQUE MAYORQUE terminalBool { $$ = $1 + '<>' + $4; }
	|terminalBool MENORQUE TOK_IGUAL terminalBool { $$ = $1 + '<=' + $4; }
	|terminalBool MAYORQUE TOK_IGUAL terminalBool { $$ = $1 + '>=' + $4; }
	|terminalBool { $$ = $1; }
;

terminalBool:
    TOK_TRUE { $$ = $1; }
    |TOK_FALSE { $$ = $1; }
    |operacionArit { $$ = $1; }
;

llamadaFunc:
    TOK_ID TOK_PARIZQ parametrosEnv TOK_PARDER { $$ = $1 + '(' + $3 + ')'; }
    |TOK_ID TOK_PUNTO opA TOK_PARIZQ parametrosEnv TOK_PARDER { $$ = $1 + '.' + $3 + '(' + $5 + ')'; }
    |TOK_CONSOLA TOK_PARIZQ parametrosEnv TOK_PARDER { $$ = $1 + '(' + $3 + ')'; }
    |TOK_GRAFICAR TOK_PARIZQ TOK_PARDER { $$ = $1 + '()'; }
;

opA:
    TOK_PUSH { $$ = $1; }
    |TOK_POP { $$ = $1; }
    |TOK_SIZE { $$ = $1; }
;

sentenciasControl:
    sentenciaSi { $$ = $1; }
    |sentenciaSwitch { $$ = $1; }
;

sentenciaSi:
    TOK_SI TOK_PARIZQ expBooleana TOK_PARDER TOK_LLAIZQ codigo TOK_LLADER sentenciaSino { $$ = 'if(' + $3 + '){\n' + $6 + '\n}\n' + $8; }
;

sentenciaSino:
    TOK_SINO TOK_LLAIZQ codigo TOK_LLADER { $$ = 'else{\n' + $3 + '\n}\n'; }
    | { $$ = $1; }
;

sentenciaSwitch:
    TOK_ENCASO TOK_PARIZQ terminal TOK_PARDER TOK_LLAIZQ casos TOK_LLADER { $$ = 'switch(' + $3 + '){\n' + $6 + '\n}\n'; }
;

casos:
    caso casos { $$ = $1 + $2; }
    |caso { $$ = $1; }
;

caso:
    TOK_CASO terminal TOK_DOSPUNTOS codigo transferencias { $$ = 'case' + $2 + ':' + $4 + $5 + '\n'; }
    |TOK_DEFECTO TOK_DOSPUNTOS codigo transferencias { $$ = 'default:' + $3 + $4 + '\n'; }
;

transferencias:
    TOK_BREAK TOK_PTCOMA { $$ = 'break;'; }
    |TOK_CONTINUE TOK_PTCOMA { $$ = 'continue;'; }
    | { $$ = ''; }
;

retornaFunc:
    TOK_RETURN expBooleana TOK_PTCOMA { $$ = 'return ' + $2 + ';\n'; }
    |TOK_RETURN TOK_PTCOMA { $$ = 'return;\n'; } 
;

sentenciasCiclo:
    sentenciaMientras { $$ = $1; }
    |sentenciaHacerMientras { $$ = $1; }
    |sentenciaPara { $$ = $1; }
;

sentenciaMientras:
    TOK_MIENTRAS TOK_PARIZQ expBooleana TOK_PARDER TOK_LLAIZQ codigo TOK_LLADER { $$ = 'while(' + $3 + '){\n' + $6 + '\n}\n'; }
;

sentenciaHacerMientras:
    TOK_HACER TOK_LLAIZQ codigo TOK_LLADER TOK_MIENTRAS TOK_PARIZQ expBooleana TOK_PARDER TOK_PTCOMA { $$ = 'do{\n' + $3 + '\n}while(' + $7 + ');\n'; }
;

sentenciaPara:
    TOK_FOR TOK_PARIZQ condicionPara TOK_PARDER TOK_LLAIZQ codigo TOK_LLADER { $$ = 'for(' + $3 + '){\n' + $6 + '}\n'; }
;

condicionPara:
    declaracion expBooleana1 TOK_PTCOMA addRest { $$ = $1 + $2 + ';' + $4; }
    |tipoDec TOK_ID igualdad InOf TOK_ID { $$ = $1 + ' ' + $2 + ' ' + $3 + ' ' + $4 + ' ' + $5; } 
;

InOf:
    TOK_IN { $$ = $1; }
    |TOK_OF { $$ = $1; }
;