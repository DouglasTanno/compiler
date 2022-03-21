%{ /* -*- C++ -*- */

#include "parser.hh"
#include "scanner.hh"
#include "driver.hh"

/*  Defines some macros to update locations */
#define STEP() do {driver.location_->step();} while (0)
#define COL(col) driver.location_->columns(col)
#define LINE(line) do {driver.location_->lines(line);} while (0)
#define YY_USER_ACTION COL(yyleng);

/* import the parser's token type into a local typedef */
typedef Simples::Parser::token token;
typedef Simples::Parser::token_type token_type;

/* By default yylex returns int, we use token_type. Unfortunately yyterminate
 * by default returns 0, which is not of token_type. */
#define yyterminate() return token::TOK_EOF

%}

/*** Flex Declarations and Options ***/

/* enable scanner to generate debug output. disable this for release
 * versions. */
%option debug
/* enable c++ scanner class generation */
%option c++
/* we don’t need yywrap */
%option noyywrap
/* you should not expect to be able to use the program interactively */
%option never-interactive
/* provide the global variable yylineno */
%option yylineno
/* do not fabricate input text to be scanned */
%option nounput
/* the manual says "somewhat more optimized" */
%option batch
/* change the name of the scanner class. results in "SimplesFlexLexer" */
%option prefix="Simples"

/*
%option stack
*/

/* Abbreviations.  */

blank   [ \t]+
eol     [\n\r]+

%%

 /* The following paragraph suffices to track locations accurately. Each time
 yylex is invoked, the begin position is moved onto the end position. */
%{
  STEP();
%}

/*Simbolos reservados*/

","             {return VIRG;}
":"             {return DOISP;}
";"             {return PVIRG;}
"("             {return EPAREN;}
")"             {return DPAREN;}
"["             {return ECOLCH;}
"]"             {return DCOLCH;}
"{"             {return ECHAVE;}
"}"             {return DCHAVE;}
"."             {return PONTO;}
"+"             {return MAIS;}
"-"             {return MENOS;}
"*"             {return ASTERISCO;}
"/"             {return BARRA;}
":="            {return ATRIB;}
"=="            {return IGUAL;}
"!="            {return NEG;}
"<"             {return MENOR;}
"<="            {return MENORIG;}
">"             {return MAIOR;}
">="            {return MAIORIG;}
"&"             {return E;}
"|"             {return OU;}
"="             {return EQFUNC;}

/*Palavras reservadas*/

"pare"          {return PARE;}
"continue"      {return CONTINUE;}
"para"          {return PARA;}
"fpara"         {return FPARA;}
"enquanto"      {return ENQUANTO;}
"fenquanto"     {return FENQUANTO;}
"faca"          {return FACA;}
"se"            {return SE;}
"fse"           {return FSE;}
"verdadeiro"    {return VERDADEIRO;}
"falso"         {return FALSO;}
"tipo"          {return TIPO;}
"de"            {return DE;}
"limite"        {return LIMITE;}
"global"        {return GLOBAL;}
"local"         {return LOCAL;}
"inteiro"       {return INTEIRO;}
"real"          {return REAL;}
"cadeia"        {return CADEIA;}
"valor"         {return VALOR;}
"ref"           {return REF;}
"retorne"       {return RETORNE;}
"nulo"          {return NULO;}
"inicio"        {return INICIO;}
"fim"           {return FIM;}
"funcao"        {return FUNCAO;}
"acao"          {return ACAO;}


 /*** BEGIN EXAMPLE - Change the example lexer rules below ***/

[0-9]+ {
    yylval->integerVal = atoi(yytext);
    return token::INTEIRO;
 }

[0-9]+"."[0-9]* {
	yylval->doubleVal = atof(yytext);
	return token::REAL;
}

[A-Za-z][A-Za-z0-9_,.-]* {
	yylval->stringVal = new std::string(yytext, yyleng);
	return token::IDENTIFICADOR;
}


\"   {init_string_buffer(); BEGIN cadeiaCond;}
<cadeiaCond>\"  {
	yylval.sval = String(string_buffer);
	BEGIN 0;
	return token::CADEIA;
	}
<cadeiaCond>\n  {
	EM_error(EM_tokPos,"unclose string: newline appear in string");
	yyterminate();
	}
<cadeiaCond><<EOF>> {
	EM_error(EM_tokPos,"unclose string"); yyterminate();
}
<cadeiaCond>\\[0-9]{3} {
	int tmp; sscanf(yytext+1, "%d", &tmp);
	if(tmp > 0xff) {
		EM_error(EM_tokPos,"ascii code out of range");
		yyterminate(); 
	}
    append_to_buffer(tmp);
}
<cadeiaCond>\\[0-9]+ {
	EM_error(EM_tokPos,"bad escape sequence");
	yyterminate();
}
<cadeiaCond>\\n {
	append_to_buffer('\n');
}
<cadeiaCond>\\t {
	append_to_buffer('\t');
}
<cadeiaCond>\\\\ {
	append_to_buffer('\\');
}
<cadeiaCond>\\\" {
	append_to_buffer('\"');
}
<cadeiaCond>\^[@A-Z\[\\\]\^_?] {
	append_to_buffer(yytext[1]-'a');
}
<cadeiaCond>\\[ \n\t\f]+\\ {
	int i; for(i = 0; yytext[i]; ++i) 
		if(yytext[i] == '\n') 
			EM_newline();
		continue;
}
<cadeiaCond>[^\\\n\"]* {
	char *tmp = yytext; 
	while(*tmp) append_to_buffer(*tmp++);
}


"/*" {
	comment_level+=1;
	BEGIN comentarioCond;
}
<comentarioCond>"*/" {
	comment_level-=1;
	if(comment_level==0)
		BEGIN 0;
		return token::COMENTARIO;
}
<comentarioCond><<EOF>> {
	EM_error(EM_tokPos,"unclosed comment"); 
	yyterminate();
}
<comentarioCond>.



{blank} { STEP(); }

{eol}  { LINE(yyleng); }

.             {
                std::cerr << *driver.location_ << " Unexpected token : "
                                              << *yytext << std::endl;
                driver.error_ = (driver.error_ == 127 ? 127
                                : driver.error_ + 1);
                STEP ();
              }

%%

/* CUSTOM C++ CODE */

namespace Simples {

  Scanner::Scanner() : SimplesFlexLexer() {}

  Scanner::~Scanner() {}

  void Scanner::set_debug(bool b) {
    yy_flex_debug = b;
  }
}

#ifdef yylex
# undef yylex
#endif

int SimplesFlexLexer::yylex()
{
  std::cerr << "call parsepitFlexLexer::yylex()!" << std::endl;
  return 0;
}