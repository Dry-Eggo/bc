module token;
import std.format;

enum Tokenkind
{
    Identifier,
    Number,
    Fn,
    CString,
    String,
    OParen,
    CParen,
    Bang,
    OBrace,
    CBrace,
    Comma,
    Colon,
    Semi,
    // types
    I8,
    I16,
    I32,
    I64,
    U8,
    U16,
    U32,
    U64,
    Str,
    CStr,
    Void,
    Bool,
    Chr,
    // operators
    ADD,
    ADDADD,
    ADDEQ,
    SUB,
    SUBSUB,
    SUBEQ,
    MUL,
    MULEQ,
    DIV,
    DIVEQ,
    EQ,
    EQEQ,
    NEQ,
    SHR,
    SHREQ,
    SHL,
    SHLEQ,
    OR,
    BWOR, /* | */
    BWOREQ, /* != */
    AND,
    APS /* & */ ,
    APSEQ,
    MOD,
    MODEQ,
    LT,
    LTEQ,
    GT,
    GTEQ,
    // bindings
    PUB,
    LET,
    CONST,
    MUT,
    PRIV,
    STAT /* static */ ,
    EXTRN,
    EOF,
    // keywords
    IF,
    ELSE,
    MATCH,
    FOR,
    FOREACH,
    WHILE,
    LOOP,
    UNTIL,
    BREAK,
    UNCHECKED,
    UNSAFE,
    TYPE,
    STRUCT,
    ENUM,
    RETURN,
}

string TK_tostr(Tokenkind k)
{
    switch (k)
    {
    case Tokenkind.EQ:
        return "=";
    default:
        return "nil";
    }
}

struct Span
{
    int line;
    int cols;
    int cole;
}

struct Token
{
    Tokenkind kind;
    string text;
    Span span;

    string tostr() const
    {
        return format("(%s, \"%s\")", kind, text);
    }
}
