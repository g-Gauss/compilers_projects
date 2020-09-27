%{     /* PARSER */

#include "parser.hh"
#include "scanner.hh"

#define yylex driver.scanner_->yylex

SNode::Program* programBlock;
%}

%code requires
{
  #include <string>
  #include <iostream>
  #include "driver.hh"
  #include "location.hh"
  #include "position.hh"

  #include "node.h"
}

%code provides
{
  namespace parse
  {
    // Forward declaration of the Driver class
    class Driver;

    inline void
    yyerror (const char* msg)
    {
      std::cerr << msg << std::endl;
    }
  }
}



%require "2.4"
%language "C++"
%locations
%defines
%debug
%define api.namespace {parse}
%define parser_class_name {Parser}
%parse-param {Driver &driver}
%lex-param {Driver &driver}
%error-verbose

%union
{
    SNode::Node* node;
    SNode::Block* block;
    SNode::Expression* expression;
    SNode::Statement* statement;
    SNode::Identifier* identifier;
    SNode::Program* program;
    SNode::Value* value;
    SNode::DataStructure* dataStructure;
    std::string* var;
}

%token TOK_EOF 0

%token <var> IDENTIFIER INTEGER FLOAT STRING

%token SET
%token TO
%token AS
%token LIST
%token MATRIX
%token BY
%token AT
%token READ
%token PRINT
%token IF
%token OTHERWISE
%token BEGIN_BLOCK
%token END_BLOCK
%token WHILE
%token COUNTING
%token DEFINE
%token FUNCTION
%token ANSWER
%token CALL
%token WITH
%token PARAMETERS
%token ARGUMENTS
%token NOT
%token AND
%token OR
%token XOR
%token ADDITION
%token SUBSTRACTION
%token MULTIPLICATION
%token DIVISION
%token EQUALS
%token GEQ
%token LEQ
%token GREATER
%token LESS
%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token QUOTES_ERROR
%token HASH
%token OPEN_BRACKETS
%token CLOSE_BRACKETS
%token COMMA
%token IS
%token FALSE
%token TRUE
%token FROM

%type <program> program
%type <block> block
%type <body> body
%type <value> value boolean numvalue intvalue
%type <expression> assignment
%type <statement> statement set
%type <dataStructure> data_structure

%%
%start input;
input: program { programBlock = $1 } ;

program: function { $$ = new SNode::Program(); $$->functions.push_back($1); }
            | program function { $1->functions.push_back($2); }
            ;

block: BEGIN_BLOCK
        body { $$ = new SNode::Block(); $$->body = $2; }
        END_BLOCK;

body:       statement { $$ = new SNode::Body(); $$->statements.push_back($<statement>1); }
            | body statement { $1->statements.push_back($<statement>2); }
            ;

statement: read 
            | set { $$ = $1 }
            | print 
            | if_statement 
            | while 
            | while_counting
            ;

set : SET IDENTIFIER assignment 
            { $$ = new SNode::VariableDeclaration($2, $3); }
            ;

read: READ TO IDENTIFIER;

assignment: TO numvalue { $$ = $2 } 
            | AS data_structure { $$ = $2 }
            | pos_assignment { $$ = $1 }
            ;

print: PRINT value; 

function: DEFINE FUNCTION IDENTIFIER block 
            | DEFINE FUNCTION IDENTIFIER WITH ARGUMENTS arguments block
            ;

arguments: IDENTIFIER 
            | IDENTIFIER COMMA arguments;

pos_assignment: OPEN_BRACKETS position CLOSE_BRACKETS TO value; 

position: intvalue 
            | intvalue COMMA intvalue;

data_structure: LIST { $$ = new SNode::List(); }
            | MATRIX intvalue BY intvalue { $$ = new SNode::Matrix($2, $4); }
            ;

if_statement: IF condition block; 

while: WHILE condition block;

while_counting: WHILE IDENTIFIER COUNTING FROM intvalue TO intvalue block;

condition: comparison 
            | {std::cout << "boolean" << std::endl;} boolean 
            | {std::cout << "not" << std::endl;} NOT condition
            ;

comparison: {std::cout << "comparison" << std::endl;} value comp_operator value
            ;

// No se ocupa para armar árbol
comp_operator: {std::cout << "xor" << std::endl;} XOR 
            | LEQ
            | GREATER  
            | LESS 
            | EQUALS 
            | IS NOT
            ; 

boolean: {std::cout << "true" << std::endl;} TRUE { $$ = new SNode::Boolean(true); }
            | {std::cout << "false" << std::endl;} FALSE { $$ = new SNode::Boolean(false); }
            ;


numvalue: intvalue 
            | FLOAT { $$ = new SNode::Double(atof($1->c_str())); delete $1; }
            ;

intvalue:  INTEGER { $$ = new SNode::Integer(atoll($1->c_str())); delete $1; }
            | IDENTIFIER { $$ = new SNode::Identifier(*$1); delete $1; }
            ;

value: numvalue 
            | STRING { $$ = new SNode::String(*$1); delete $1; }
            ;



%%

namespace parse
{
    void Parser::error(const location&, const std::string& m)
    {
        std::cerr << *driver.location_ << ": " << m << std::endl;
        driver.error_ = (driver.error_ == 127 ? 127 : driver.error_ + 1);
    }
}
