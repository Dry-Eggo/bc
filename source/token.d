module token;
import std.format;

enum Tokenkind {
    Identifier,
    Number,
    Fn,
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
    I8, I16, I32, I64, U8, U16, U32, U64, Str, Void, Bool, Chr,
    // operators
    ADD, ADDADD, ADDEQ, SUB, SUBSUB, SUBEQ, MUL, MULEQ, DIV, DIVEQ, EQ, EQEQ,
    SHR, SHREQ, SHL, SHLEQ, OR, AND, APS /* & */, APSEQ, MOD, MODEQ,
    // bindings
    PUB, LET, CONST, MUT, PRIV, STAT /* static */,
    EOF,
}

struct Token {
    Tokenkind kind;
    string text;

    string tostr() const {
        return format("(%s, \"%s\")", kind, text);
    }
}
