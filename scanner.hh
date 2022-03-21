#pragma once

#include "parser.hh"

# ifndef YY_DECL
#  define YY_DECL Simples::Parser::token_type                         \
     Simples::Scanner::yylex(Simples::Parser::semantic_type* yylval,    \
                              Simples::Parser::location_type*,        \
                              Simples::Driver& driver)
# endif


# ifndef __FLEX_LEXER_H
#  define yyFlexLexer SimplesFlexLexer
#  include <FlexLexer.h>
#  undef yyFlexLexer
# endif


namespace Simples {
  class Scanner : public SimplesFlexLexer {
  public:
    Scanner();
    virtual ~Scanner();
    virtual Parser::token_type yylex(Parser::semantic_type* yylval,
				     Parser::location_type* l,
				     Driver& driver);
    void set_debug(bool b);
  };
}

