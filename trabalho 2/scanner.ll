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

variable : IDENTIFIER {  std::cout << "Identificador: " << *$1 << std::endl; }

%%

namespace Simples {
   void Parser::error(const location&, const std::string& m) {
        std::cerr << *driver.location_ << ": " << m << std::endl;
        driver.error_ = (driver.error_ == 127 ? 127 : driver.error_ + 1);
   }
}
%%

 /* The following paragraph suffices to track locations accurately. Each time
 yylex is invoked, the begin position is moved onto the end position. */
%{
  STEP();
%}

","             {return token::VIRG;}
":"             {return token::DOISP;}
";"             {return token::PVIRG;}
"("             {return token::EPAREN;}
")"             {return token::DPAREN;}
"["             {return token::ECOLCH;}
"]"             {return token::DCOLCH;}
"{"             {return token::ECHAVE;}
"}"             {return token::DCHAVE;}
"."             {return token::PONTO;}
"+"             {return token::MAIS;}
"-"             {return token::MENOS;}
"*"             {return token::ASTERISCO;}
"/"             {return token::BARRA;}
":="            {return token::ATRIB;}
"=="            {return token::IGUAL;}
"!="            {return token::DIF;}
"<"             {return token::MENOR;}
"<="            {return token::MENORIG;}
">"             {return token::MAIOR;}
">="            {return token::MAIORIG;}
"&"             {return token::E;}
"|"             {return token::OU;}
"="             {return token::EQFUNC;}

"pare"          {return token::PARE;}
"continue"      {return token::CONTINUE;}
"para"          {return token::PARA;}
"fpara"         {return token::FPARA;}
"enquanto"      {return token::ENQUANTO;}
"fenquanto"     {return token::FENQUANTO;}
"faca"          {return token::FACA;}
"se"            {return token::SE;}
"fse"           {return token::FSE;}
"verdadeiro"    {return token::VERDADEIRO;}
"falso"         {return token::FALSO;}
"tipo"          {return token::TIPO;}
"de"            {return token::DE;}
"limite"        {return token::LIMITE;}
"global"        {return token::GLOBAL;}
"local"         {return token::LOCAL;}
"inteiro"       {return token::INTEIRO;}
"real"          {return token::REAL;}
"cadeia"        {return token::CADEIA;}
"valor"         {return token::VALOR;}
"ref"           {return token::REF;}
"retorne"       {return token::RETORNE;}
"nulo"          {return token::NULO;}
"inicio"        {return token::INICIO;}
"fim"           {return token::FIM;}
"funcao"        {return token::FUNCAO;}
"acao"          {return token::ACAO;}


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

<cadeiaCond>\" {       
    BEGIN(INITIAL);
    *string_buf_ptr = '\0';
    return token::CADEIA;
}

"/*"  BEGIN(comentarioCond);
<comentarioCond>[^*\n]*          
<comentarioCond>"*"+[^*/\n]*    
<comentarioCond>\n              
<comentarioCond>"*/" {          
  BEGIN(INITIAL);
  STEP();
}


\" string_buf_ptr = string_buf; BEGIN(stringStartCond);
{blank} { STEP(); }

{eol}  { LINE(yyleng); }

.             {
                std::cerr << *driver.location_ << " Unexpected token : "
                                              << *yytext << std::endl;
                driver.error_ = (driver.error_ == 127 ? 127
                                : driver.error_IDENTIFIER + 1);
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

