%{

/*** C++ Declarations ***/
#include "parser.hh"
#include "scanner.hh"

#define yylex driver.scanner_->yylex

%}

%code requires {
  #include <iostream>
  #include "driver.hh"
  #include "location.hh"
  #include "position.hh"
}

%code provides {
  namespace Simples  {
    // Forward declaration of the Driver class
    class Driver;

    inline void yyerror (const char* msg) {
      std::cerr << msg << std::endl;
    }
  }
}

/* Require bison 2.3 or later */
%require "2.4"
/* enable c++ generation */
%language "C++"
%locations
/* write out a header file containing the token defines */
%defines
/* add debug output code to generated parser. disable this for release
 * versions. */
%debug
/* namespace to enclose parser in */
%define api.namespace {Simples}
/* set the parser's class identifier */
%define api.parser.class {Parser}
/* set the parser */
%parse-param {Driver &driver}
/* set the lexer */
%lex-param {Driver &driver}
/* verbose error messages */
%define parse.error verbose
/* use newer C++ skeleton file */
%skeleton "lalr1.cc"
/* Entry point of grammar */
%start programa

%union
{
 /* YYLTYPE */
  int  			      integerVal;
  double 			    doubleVal;
  std::string*		stringVal;
}


/* Tokens */
/* Simbolos reservados */
%token				VIRG			"," 
%token				DOISP			":" 
%token				PVIRG			";" 
%token				EPAREN			"(" 
%token				DPAREN			")" 
%token				ECOLCH			"[" 
%token				DCOLCH			"]" 
%token				ECHAVE			"{" 
%token				DCHAVE			"}" 
%token				PONTO			"." 
%token				MAIS			"+" 
%token				MENOS			"-" 
%token				ASTERISCO		"*" 
%token				BARRA			"/" 
%token				ATRIB			":="
%token				IGUAL			"=="
%token				DIF				"!="
%token				MENOR			"<" 
%token				MENORIG			"<="
%token				MAIOR			">" 
%token				MAIORIG			">="
%token				E			    "&" 
%token				OU			    "|" 
%token				EQFUNC			"=" 

/* Palavras reservadas */
%token              TOK_EOF 0     	"end of file"
%token			    EOL				"end of line"
%token <integerVal> INTEIRO		    "inteiro"
%token <doubleVal> 	REAL		    "real"
%token <stringVal> 	IDENTIFICADOR   "identificador"
%token				PARE			"pare"
%token				CONTINUE		"continue"
%token				PARA			"para"
%token				FPARA			"fpara"
%token				ENQUANTO		"enquanto"
%token				FENQUANTO		"fenquanto"
%token				FACA			"faça"
%token				SE				"se"
%token				FSE				"fse"
%token				VERDADEIRO		"verdadeiro"
%token				FALSO			"falso"
%token				TIPO			"tipo"
%token				DE				"de"
%token				LIMITE			"limite"
%token				GLOBAL			"global"
%token				LOCAL			"local"
%token <stringVal>	CADEIA			"cadeia"
%token				VALOR			"valor"
%token				REF				"ref"
%token				RETORNE			"retorne"
%token				NULO			"nulo"
%token				INICIO			"início"
%token				FIM				"fim"
%token				FUNCAO			"função"
%token				ACAO			"ação"
%token				COMENTARIO		"comentário"

%%

/* Programa */

programa:  
		declaracoes
        | acao

declaracoes:
        lista_declaracao_de_tipo
        lista_declaracoes_de_globais
        lista_declaracoes_de_funcoes

lista_declaracao_de_tipo:
		/*VAZIO*/
        | TIPO DOISP lista_declaracao_tipo
        
lista_declaracao_tipo:
	declaracao_tipo
	| lista_declaracao_tipo declaracao_tipo

lista_declaracoes_de_globais:
		/*VAZIO*/
        | GLOBAL DOISP lista_declaracao_variavel
        
lista_declaracao_variavel:
	declaracao_variavel
	| lista_declaracao_variavel declaracao_variavel
	
lista_declaracoes_de_funcoes:
		/*VAZIO*/
        | FUNCAO DOISP lista_declaracao_funcao
        
lista_declaracao_funcao:
	declaracao_funcao
	| lista_declaracao_funcao declaracao_funcao
	
acao:
        ACAO DOISP lista_comandos

lista_comandos:
	comando
	| lista_comandos PVIRG comando
	
comando:
	local_de_armazenamento ATRIB expr
	| chamada_de_funcao
	| SE expr VERDADEIRO lista_comandos FSE
	| SE expr VERDADEIRO lista_comandos FALSO lista_comandos FSE
	| PARA IDENTIFICADOR DE expr LIMITE expr FACA lista_comandos FPARA
	| ENQUANTO expr FACA lista_comandos FENQUANTO
	| PARE
	| CONTINUE
	| RETORNE expr


declaracao_tipo:
        IDENTIFICADOR EQFUNC descritor_tipo

descritor_tipo:
        IDENTIFICADOR
        | ECHAVE tipo_campos DCHAVE
        | ECOLCH tipo_constantes DCOLCH DE IDENTIFICADOR

tipo_campos:
        tipo_campo
        | tipo_campos VIRG tipo_campo

tipo_campo: 
        IDENTIFICADOR DOISP IDENTIFICADOR

tipo_constantes:
        INTEIRO 
        | tipo_constantes VIRG INTEIRO

declaracao_variavel:
		IDENTIFICADOR DOISP IDENTIFICADOR ATRIB expr

		
declaracao_funcao:
		IDENTIFICADOR EPAREN args DPAREN EQFUNC corpo
		| IDENTIFICADOR EPAREN args DPAREN DOISP IDENTIFICADOR EQFUNC corpo
		
args:
		modificador IDENTIFICADOR DOISP IDENTIFICADOR

modificador:
		VALOR | REF
		
corpo:
		declaracoes_de_locais
		ACAO DOISP lista_comandos
		
declaracoes_de_locais:
		/*VAZIO*/
		| LOCAL DOISP lista_declaracao_variavel
		
lista_args_chamada:
	/*VAZIO*/
	| fator
	| lista_args_chamada VIRG fator

expr: ECHAVE criacao_de_registro DCHAVE
     | ECOLCH criacao_de_vetor DCOLCH
     | expressao_logica
	
expressao_logica:
	expressao_logica E expressao_relacional
	| expressao_logica OU expressao_relacional
	| expressao_relacional
	
expressao_relacional:
	expressao_relacional IGUAL expressao_aritmetica
	| expressao_relacional DIF expressao_aritmetica
	| expressao_relacional MENOR expressao_aritmetica	
	| expressao_relacional MENORIG expressao_aritmetica
	| expressao_relacional MAIOR expressao_aritmetica
	| expressao_relacional MAIORIG expressao_aritmetica
	| expressao_aritmetica
	
expressao_aritmetica:
	expressao_aritmetica MAIS termo
	| expressao_aritmetica MENOS termo
	| termo
	
criacao_de_registro:
	atribuicao_de_registro
	| criacao_de_registro VIRG atribuicao_de_registro
	
criacao_de_vetor:
	atribuicao_de_vetor
	| criacao_de_vetor VIRG atribuicao_de_vetor
	
atribuicao_de_vetor:
	/*VAZIO*/
	| expr
	
local_de_armazenamento:
	IDENTIFICADOR
	| local_de_armazenamento PONTO IDENTIFICADOR
	| local_de_armazenamento ECOLCH lista_args_chamada DCOLCH

atribuicao_de_registro:
	IDENTIFICADOR EQFUNC expr
	
literal:
	INTEIRO
	| REAL
	//| CADEIA

termo: 
	termo ASTERISCO fator
	| termo BARRA fator
	| fator

fator:
	EPAREN expr DPAREN 
	| literal
	| local_de_armazenamento
	| chamada_de_funcao
	| NULO

chamada_de_funcao:
	IDENTIFICADOR EPAREN lista_args_chamada DPAREN


/*
constant : INTEGER { std::cout << "Inteiro: " << $1 << std::endl; }
         | REAL  { std::cout << "Real: " << $1 << std::endl; }

variable : IDENTIFIER {  std::cout << "Identificador: " << *$1 << std::endl; }
*/

%%

namespace Simples {
   void Parser::error(const location&, const std::string& m) {
        std::cerr << *driver.location_ << ": " << m << std::endl;
        driver.error_ = (driver.error_ == 127 ? 127 : driver.error_ + 1);
   }
}
