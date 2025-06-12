module parser;
import ast;
import token;
import std.array;
import std.stdio;
import core.stdc.stdlib: exit;


struct Parser {
    Token[] tokens;
    int pos;
    int max;

    this(Token[] tokens) {
        this.pos = 0;
        this.tokens = tokens;
        this.max = cast(int)tokens.length;
    }
    void expect(Tokenkind k) {
        if (peek().kind != k) {
            writeln("BC: Expected Qualified ID");
            exit(1);
        }
        advance();
    }
    bool match(Tokenkind k) {
        return peek().kind == k;
    }
    Node parse() {
        Node program;
        Appender!(Node[]) nodes;
        while(peek().kind != Tokenkind.EOF) {
            switch(peek().kind) {
                case Tokenkind.Fn: nodes.put(parse_fn()); continue;
                default: continue;
            }
            advance();
        }
        program.program = nodes.data;
        program.kind = NodeKind.Program;
        return program;
    }
    Token peek() {
        if (pos >= max) {
            return Token(Tokenkind.EOF, "");
        }
        return tokens[pos];
    }
    void advance() {pos++;};
    Node parse_fn() {
        Node fn;
        FnDecl funcStmt;
        expect(Tokenkind.Fn);
        if (match(Tokenkind.Identifier)) {
            funcStmt.name = peek().text;
            advance();
        } else {
            writeln("Expected identifier");
            exit(1);
        }
        expect(Tokenkind.OParen);
        expect(Tokenkind.CParen);
        if (match(Tokenkind.OBrace)) 
            funcStmt.type = Type.create_void();
        else
            funcStmt.type = parse_type();
        expect(Tokenkind.OBrace);
        funcStmt.fn_body = parse_body();
        expect(Tokenkind.CBrace);
        fn.kind = NodeKind.FuncDecl;
        fn.func = funcStmt;
        return fn;
    }
    Node parse_binding() {
        VarBind Binding;
        Node n;
        if(match(Tokenkind.LET) || match(Tokenkind.CONST))
            Binding.is_const = true;
        else
            Binding.is_const = false;

        advance();
        if (match(Tokenkind.Identifier)) {
            Binding.name = peek().text;
        } else {
            writeln("Expected Identifier");
            exit(1);
        }
        advance();

        Binding.type = parse_type();
        expect(Tokenkind.EQ);
        Node* expr = parse_expr();
        Binding.value = expr;
        n.kind = NodeKind.Binding;
        n.binding = Binding;
        return n;
    }
    Type parse_type() {
        switch(peek().kind) {
            case Tokenkind.Void:{
                Type ty = Type(BaseKind.Void);
                advance();
                return ty;
            }break;
            case Tokenkind.I32:{
                Type ty = Type(BaseKind.I32);
                advance();
                return ty;
            }break;
            case Tokenkind.I8:{
                Type ty = Type(BaseKind.I8);
                advance();
                return ty;
            }break;
            case Tokenkind.I16:{
                Type ty = Type(BaseKind.I16);
                advance();
                return ty;
            }break;
            case Tokenkind.I64:{
                Type ty = Type(BaseKind.I64);
                advance();
                return ty;
            }break;
            default: break;
        }
        writeln("BC: Invalid Type");
        exit(1);
    }
    Node[] parse_body() {
        Appender!(Node[]) nodes;
        while (peek().kind != Tokenkind.EOF && peek().kind != Tokenkind.CBrace) {
            switch(peek().kind) {
                case Tokenkind.LET:
                case Tokenkind.MUT:
                case Tokenkind.CONST:
                    nodes.put(parse_binding());
                    expect(Tokenkind.Semi);
                    continue;
                default: continue;
            }
        }
        return nodes.data;
    }
    Node* parse_expr() {
        Node* lhs = parse_term();
        while (match(Tokenkind.ADD) || match(Tokenkind.SUB)) {
            Tokenkind op = peek().kind;
            advance();
            Node* rhs = parse_term();
            lhs.binop = BinaryOp(op, lhs, rhs);
        }
        return lhs;
    }
    Node* parse_term() {
        Node* lhs = parse_atom();
        while (match(Tokenkind.MUL) || match(Tokenkind.DIV)) {
            Tokenkind op = peek().kind;
            advance();
            Node* rhs = parse_expr();
            lhs.binop = BinaryOp(op, lhs, rhs);
        }
        return lhs;
    }
    Node* parse_atom() {
        Node* n = new Node;
        switch(peek().kind) {
            case Tokenkind.Number:
               n.kind = NodeKind.Int; 
               n.token_data = peek();
               advance();
               return n;
            default:
               return n;
        }
    }
}

