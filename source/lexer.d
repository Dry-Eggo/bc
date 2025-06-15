module lexer;
import std.string;
import std.ascii : isDigit;
import std.uni;
import core.stdc.stdlib : exit;
import std.array;
import std.stdio;
import token;
import diagnostics;

struct Lexer
{
  int line = 1;
  int column = 1;
  int pos = 0;
  string source;
  ErrorManager* errors;
  Appender!(Token[]) tokens;
  this(string source, ErrorManager* e)
  {
    this.source = source;
    this.errors = e;
  }

  void advance()
  {
    auto c = peek();
    if (c == '\n')
    {
      line++;
      column = 1;
    }
    else
    {
      column++;
    }
    pos++;
  }

  char peek()
  {
    return source[pos];
  }

  Token[] lex()
  {
    while (pos < source.length)
    {
      if (isWhite(peek()))
      {
        advance();
        continue;
      }
      if (peek() == 'c' && source[pos + 1] == '\"')
      {
        advance();
        advance();
        int start = pos;
        int sc = column;
        string buf;
        while (pos < source.length && peek() != '\"')
        {
          advance();
        }
        buf = source[start .. pos];
        advance();
        tokens.put(Token(Tokenkind.CString, buf, Span(line, sc, column - 1)));
        continue;
      }
      if (isAlpha(peek()) || peek() == '_')
      {
        int start = pos;
        int sc = column;
        while (pos < source.length && (isAlphaNum(peek()) || peek() == '_'))
        {
          advance();
        }
        Tokenkind kind = Tokenkind.Identifier;
        string word = source[start .. pos];
        switch (word)
        {
        case "fn":
          kind = Tokenkind.Fn;
          break;
        case "void":
          kind = Tokenkind.Void;
          break;
        case "i8":
          kind = Tokenkind.I8;
          break;
        case "i16":
          kind = Tokenkind.I16;
          break;
        case "i32":
          kind = Tokenkind.I32;
          break;
        case "i64":
          kind = Tokenkind.I64;
          break;
        case "u64":
          kind = Tokenkind.U64;
          break;
        case "u32":
          kind = Tokenkind.U32;
          break;
        case "u16":
          kind = Tokenkind.U16;
          break;
        case "u8":
          kind = Tokenkind.U8;
          break;
        case "chr":
          kind = Tokenkind.Chr;
          break;
        case "str":
          kind = Tokenkind.Str;
          break;
        case "cstr":
          kind = Tokenkind.CStr;
          break;
        case "let":
          kind = Tokenkind.LET;
          break;
        case "mut":
          kind = Tokenkind.MUT;
          break;
        case "const":
          kind = Tokenkind.CONST;
          break;
        case "pub":
          kind = Tokenkind.PUB;
          break;
        case "priv":
          kind = Tokenkind.PRIV;
          break;
        case "stat":
          kind = Tokenkind.STAT;
          break;
        case "extrn":
          kind = Tokenkind.EXTRN;
          break;
        default:
          break;
        }
        tokens.put(Token(kind, word, Span(line, sc, column - 1)));
        continue;
      }
      if (isDigit(peek()))
      {
        size_t start = pos;
        int sc = column;
        while (pos < source.length && isDigit(
            peek()))
        {
          advance();
        }
        string num = source[start .. pos];
        tokens.put(Token(Tokenkind.Number, num, Span(
            line, sc, column - 1)));
        continue;
      }
      int start = column;
      switch (peek())
      {
      case '<':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.LTEQ, "<=", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.LT, "<", Span(line, start, column)));
        break;
      case '>':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.GTEQ, ">=", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.GT, ">", Span(line, start, column)));
        break;
      case '!':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.NEQ, "!=", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.Bang, "!", Span(line, start, column)));
        break;
      case '|':
        advance();
        if (peek() == '|')
        {
          advance();
          tokens.put(Token(Tokenkind.OR, "||", Span(line, start, column)));
          break;
        }
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.BWOREQ, "|=", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.BWOR, "|", Span(line, start, column)));
        break;
      case '&':
        advance();
        if (peek() == '&')
        {
          advance();
          tokens.put(Token(Tokenkind.AND, "&&", Span(line, start, column)));
          break;
        }
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.APSEQ, "&=", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.APS, "&", Span(line, start, column)));
        break;
      case '{':
        tokens.put(Token(Tokenkind.OBrace, "{", Span(line, start, column)));
        advance();
        break;
      case '}':
        tokens.put(Token(Tokenkind.CBrace, "}", Span(line, start, column)));
        advance();
        break;
      case '(':
        tokens.put(Token(Tokenkind.OParen, "(", Span(line, start, column)));
        advance();
        break;
      case ')':
        tokens.put(Token(Tokenkind.CParen, ")", Span(line, start, column)));
        advance();
        break;
      case ':':
        tokens.put(Token(Tokenkind.Colon, ",", Span(line, start, column)));
        advance();
        break;
      case ';':
        tokens.put(Token(Tokenkind.Semi, ";", Span(line, start, column)));
        advance();
        break;
      case ',':
        tokens.put(Token(Tokenkind.Comma, ",", Span(line, start, column)));
        advance();
        break;
      case '=':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.EQEQ, "==", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.EQ, "=", Span(line, start, column)));
        break;
      case '+':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.ADDEQ, "+=", Span(line, start, column)));
          break;
        }
        if (peek() == '+')
        {
          advance();
          tokens.put(Token(Tokenkind.ADDADD, "++", Span(line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.ADD, "+", Span(line, start, column)));
        break;
      case '-':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.SUBEQ, "-=", Span(
              line, start, column)));
          break;
        }
        if (peek() == '-')
        {
          advance();
          tokens.put(Token(Tokenkind.SUBSUB, "--", Span(
              line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.SUB, "-", Span(line, start, column)));
        break;
      case '*':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.MULEQ, "*=", Span(
              line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.MUL, "*", Span(line, start, column)));
        break;
      case '/':
        advance();
        if (peek() == '=')
        {
          advance();
          tokens.put(Token(Tokenkind.DIVEQ, "/=", Span(
              line, start, column)));
          break;
        }
        tokens.put(Token(Tokenkind.DIV, "/", Span(line, start, column)));
        break;
      default:
        errors.report(Diagnostics(Span(line, start, column), source, "Unexpected char", "", DiagType
            .Error), true);
        break;
      }
    }
    return tokens.data;
  }
}
