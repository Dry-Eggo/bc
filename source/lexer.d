module lexer;
import std.string;
import std.ascii: isDigit;
import std.uni;
import std.array;
import std.stdio;
import token;


Token[] lex(string source) {
    Appender!(Token[]) tokens;
    size_t i = 0;
    while (i < source.length) {
        if (isWhite(source[i]))  {
            i++;
            continue;
        }
        if (isAlpha(source[i]) || source[i] == '_') {
            size_t start = i;
            while (i < source.length && isAlphaNum(source[i]) || source[i] == '_') {
                i++;
            }
            Tokenkind kind = Tokenkind.Identifier;
            string word = source[start .. i];
            switch(word) {
                case "fn" : kind = Tokenkind.Fn; break;
                case "void": kind = Tokenkind.Void; break;
                case "i8": kind = Tokenkind.I8; break;
                case "i16": kind = Tokenkind.I16; break;
                case "i32": kind = Tokenkind.I32; break;
                case "i64": kind = Tokenkind.I64; break;
                case "u64": kind = Tokenkind.U64; break;
                case "u32": kind = Tokenkind.U32; break;
                case "u16": kind = Tokenkind.U16; break;
                case "u8": kind = Tokenkind.U8; break;
                case "chr": kind = Tokenkind.Chr; break;
                case "str": kind = Tokenkind.Str; break;
                case "let": kind = Tokenkind.LET; break;
                case "mut": kind = Tokenkind.MUT; break;
                case "const": kind = Tokenkind.CONST; break;
                case "pub": kind = Tokenkind.PUB; break;
                case "priv": kind = Tokenkind.PRIV; break;
                case "stat": kind = Tokenkind.STAT; break;
                default: break;
            }
            tokens.put(Token(kind, word));
            continue;
        }
        if(isDigit(source[i])) {
            size_t start = i;
            while (i < source.length && isDigit(source[i])) {
                i++;
            }
            string num = source[start .. i];
            tokens.put(Token(Tokenkind.Number, num));
            continue;
        }
        switch(source[i]) {
            case '{': tokens.put(Token(Tokenkind.OBrace, "{")); i++; break;
            case '}': tokens.put(Token(Tokenkind.CBrace, "}")); i++; break;
            case '(': tokens.put(Token(Tokenkind.OParen, "(")); i++; break;
            case ')': tokens.put(Token(Tokenkind.CParen, ")")); i++; break;
            case ':': tokens.put(Token(Tokenkind.Colon, ",")); i++; break;
            case ';': tokens.put(Token(Tokenkind.Semi, ";")); i++; break;
            case '=': 
               i++; 
               if (source[i] == '=') {
                   i++;
                   tokens.put(Token(Tokenkind.EQEQ, "==")); 
                   break;
               }
               tokens.put(Token(Tokenkind.EQ, "=")); 
               break;
            case '+': 
               i++; 
               if (source[i] == '=') {
                   i++;
                   tokens.put(Token(Tokenkind.ADDEQ, "+=")); 
                   break;
               }
               if (source[i] == '+') {
                   i++;
                   tokens.put(Token(Tokenkind.ADDADD, "++")); 
                   break;
               }
               tokens.put(Token(Tokenkind.ADD, "+")); 
               break;
            case '-': 
               i++; 
               if (source[i] == '=') {
                   i++;
                   tokens.put(Token(Tokenkind.SUBEQ, "-=")); 
                   break;
               }
               if (source[i] == '-') {
                   i++;
                   tokens.put(Token(Tokenkind.SUBSUB, "--")); 
                   break;
               }
               tokens.put(Token(Tokenkind.SUB, "-")); 
               break;
            case '*': 
               i++; 
               if (source[i] == '=') {
                   i++;
                   tokens.put(Token(Tokenkind.MULEQ, "*=")); 
                   break;
               }
               tokens.put(Token(Tokenkind.MUL, "*")); 
               break;
            case '/': 
               i++; 
               if (source[i] == '=') {
                   i++;
                   tokens.put(Token(Tokenkind.DIVEQ, "/=")); 
                   break;
               }
               tokens.put(Token(Tokenkind.DIV, "/")); 
               break;
            default: break;
        }
    }
    return tokens.data;
}
