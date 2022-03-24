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
%token				NEG				"!="
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
%token				FACA			"faca"
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
%token				INICIO			"inicio"
%token				FIM				"fim"
%token				FUNCAO			"funcao"
%token				ACAO			"acao"
%token				COMENTARIO		"comentario"

%%

/* Programa */

programa:  
		declaracoes
        acao

declaracoes:
        lista_declaracao_de_tipo
        lista_declaracoes_de_globais
        lista_declaracoes_funcao

lista_declaracao_de_tipo:
		/*VAZIO*/
        | TIPO DOISP lista_declaracao_tipo

lista_declaracoes_de_globais:
		/*VAZIO*/
        | GLOBAL DOISP lista_declaracao_variavel

lista_declaracoes_de_funcoes:
		/*VAZIO*/
        | FUNCAO DOISP lista_declaracao_funcao

acao:
        ACAO DOISP lista_comandos


/* Tipos */

declaracao_tipo:
        IDENTIFICADOR EQFUNC descritor_tipo

descritor_tipo:
        IDENTIFICADOR
        | ECHAVE tipo_campos DCHAVE
        | ECOLCH tipo_campos DCOLCH DE IDENTIFICADOR

tipo_campos:
        tipo_campo
        | tipo_campos VIRG tipo_campo

tipo_campo: 
        IDENTIFICADOR DOISP IDENTIFICADOR

tipo_constantes:
        INTEIRO 
        | tipo_constantes VIRG INTEIRO

declaracao_variavel:
		IDENTIFICADOR DOISP IDENTIFICADOR ATRIB inicializacao

inicializacao:
		expr
		| ECHAVE criacao_de_registro DCHAVE
		
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
