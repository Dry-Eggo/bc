module parser;
import ast;
import token;
import std.array;
import std.stdio;
import core.stdc.stdlib : exit;
import diagnostics;

struct Parser
{
    Token[] tokens;
    ErrorManager* errors;
    int pos;
    int max;
    string source;

    this(Token[] tokens, ErrorManager* error, string s)
    {
        this.pos = 0;
        this.tokens = tokens;
        this.max = cast(int) tokens.length;
        this.errors = error;
        this.source = s;
    }

    void expect(Tokenkind k)
    {
        if (peek().kind != k)
        {
            if (peek().kind != Tokenkind.EOF)
                errors.add(Diagnostics(peek().span, source, "BC: Expected Qualified ID: '" ~ TK_tostr(k) ~ "'", "", DiagType
                        .Error));
            else
            {
                errors.add(Diagnostics(before().span, source, "BC: Expected Qualified ID: '" ~ TK_tostr(k) ~ "'", "", DiagType
                        .Error));
            }
        }
        advance();
    }

    bool match(Tokenkind k)
    {
        return peek().kind == k;
    }

    Node parse()
    {
        Node program;
        Appender!(Node[]) nodes;
    anchor: while (peek().kind != Tokenkind.EOF)
        {
            switch (peek().kind)
            {
            case Tokenkind.Fn:
                nodes.put(parse_fn());
                continue;
            case Tokenkind.EXTRN:
                nodes.put(parse_extrn());
                continue;
            default:
                errors.add(Diagnostics(peek().span, source, "Invalid Top-Level item", "", DiagType
                        .Error));
                advance();
		break anchor;
            }
            advance();
        }
        program.program = nodes.data;
        program.kind = NodeKind.Program;
        return program;
    }

    Token peek()
    {
        if (pos >= max)
        {
            return Token(Tokenkind.EOF, "");
        }
        return tokens[pos];
    }

    Token before()
    {
        if (pos < 0)
        {
            return Token(Tokenkind.EOF, "");
        }
        return tokens[pos - 1];
    }

    void advance()
    {
        pos++;
    }

    Node parse_extrn()
    {
        Node extrn;
        extrn.kind = NodeKind.Extrn;
        expect(Tokenkind.EXTRN);
        if (match(Tokenkind.Fn))
        {
            // extrn fn...
            extrn.extrn.kind = ExtrnKind.Function;
            Node func = parse_fn();
            func.func.is_extrn = true;
            // TODO: Add support for
            // extrn("linkage_name") fn alias(...);
            func.func.extrn_name = func.func.name;
            extrn.extrn.func = func.func;
        }
        return extrn;
    }

    Param[] parse_args()
    {
        auto params = appender!(Param[]);
        while (peek().kind != Tokenkind.CParen)
        {
            Param p;
            if (match(Tokenkind.Identifier))
            {
                p.name = peek().text;
                p.span = peek().span;
                advance();
            }
	    expect(Tokenkind.Colon);
            p.type = parse_type();
            params.put(p);
            if (match(Tokenkind.Comma))
            {
                advance();
            }
        }
        return params.data;
    }

    Node parse_fn()
    {
        Node fn;
        FnDecl funcStmt;
        expect(Tokenkind.Fn);
        if (
            match(Tokenkind.Identifier))
        {
            fn.span = peek().span;
            funcStmt.name = peek().text;
            advance();
        }
        else
        {
            writeln("Expected identifier");
            exit(1);
        }
        expect(Tokenkind.OParen);
        funcStmt.params = parse_args();
        expect(Tokenkind.CParen);
        if (match(Tokenkind.OBrace))
            funcStmt.type = Type
                .create_void();
        else {
	  expect(Tokenkind.Colon);
	  funcStmt.type = parse_type();
	}
        if (match(Tokenkind.OBrace))
        {
            expect(
                Tokenkind.OBrace);
            funcStmt.fn_body = parse_body();
            expect(Tokenkind.CBrace);
        }
        else
        {
            expect(Tokenkind.Semi);
        }
        fn.kind = NodeKind
            .FuncDecl;
        fn.func = funcStmt;
        return fn;
    }

    Node parse_binding()
    {
        VarBind Binding;
        Node n;
        if (match(Tokenkind.LET) || match(
                Tokenkind.CONST))
            Binding.is_const = true;
        else
            Binding.is_const = false;
        advance();
        if (
            match(
                Tokenkind
                .Identifier))
        {
            Binding.name = peek().text;
        }
        else
        {
            writeln(
                "Expected Identifier");
            exit(1);
        }
        advance();
	expect(Tokenkind.Colon);
        Binding.type = parse_type();
        expect(Tokenkind.EQ);
        Node* expr = parse_logical_or();
        Binding.value = expr;
        n.kind = NodeKind
            .Binding;
        n.binding = Binding;
        return n;
    }

    Type parse_type()
    {
        switch (peek().kind)
        {
        case Tokenkind.Void:
            {
                Type ty = Type(
                    BaseKind.Void);
                advance();
                return ty;
            }
            break;
        case Tokenkind.I32:
            {
                Type ty = Type(
                    BaseKind.I32);
                advance();
                return ty;
            }
            break;
        case Tokenkind.I8:
            {
                Type ty = Type(
                    BaseKind.I8);
                advance();
                return ty;
            }
            break;
        case Tokenkind.I16:
            {
                Type ty = Type(
                    BaseKind.I16);
                advance();
                return ty;
            }
            break;
        case Tokenkind.I64:
            {
                Type ty = Type(
                    BaseKind.I64);
                advance();
                return ty;
            }
            break;
        case Tokenkind.CStr:
            {
                Type ty = Type(
                    BaseKind.Cstr);
                advance();
                return ty;
            }
            break;
        default:
            break;
        }
        errors.add(Diagnostics(peek().span, source, "Expected a Type", "", DiagType.Error));
        advance();
        return Type(BaseKind.I32);
    }

    Node[] parse_body()
    {
        Appender!(Node[]) nodes;
        while (peek().kind != Tokenkind.EOF && peek()
            .kind != Tokenkind
            .CBrace)
        {
            switch (peek().kind)
            {
            case Tokenkind.LET:
            case Tokenkind.MUT:
            case Tokenkind.CONST:
                nodes.put(
                    parse_binding());
                expect(
                    Tokenkind
                        .Semi);
                continue;
            default:
                {
                    Node n;
                    n.span = peek().span;
                    n.kind = NodeKind.Expr;
                    n.expr.node = parse_logical_or();
                    if (n.expr.node.kind != NodeKind.If && n.expr.node.kind != NodeKind.Loop)
                        expect(Tokenkind.Semi);

                    nodes.put(n);
                    continue;
                }
            }
        }
        return nodes.data;
    }

    Node* parse_logical_or()
    {
        Node* lhs = parse_logical_and();
        while (peek().kind == Tokenkind.OR)
        {
            auto op = peek();
            advance();
            Node* rhs = parse_logical_or();
            Node* n = new Node;
            n.binop = BinaryOp(STokenkind(op.kind, op.span), lhs, rhs);
            n.kind = NodeKind.BinaryOp;
            if (!match(Tokenkind.OR))
            {
                return n;
            }
        }
        return lhs;
    }

    Node* parse_logical_and()
    {

        Node* lhs = parse_conditional();
        while (peek().kind == Tokenkind.AND)
        {
            auto op = peek();
            advance();
            Node* rhs = parse_logical_or();
            Node* n = new Node;
            n.binop = BinaryOp(STokenkind(op.kind, op.span), lhs, rhs);
            n.kind = NodeKind.BinaryOp;
            if (!match(Tokenkind.AND))
            {
                return n;
            }
        }
        return lhs;
    }

    Node* parse_conditional()
    {

        Node* lhs = parse_bitwise();
        while (peek().kind == Tokenkind.EQEQ || peek().kind == Tokenkind.NEQ || match(Tokenkind.LT) || match(
                Tokenkind.LTEQ) || match(Tokenkind.GT) || match(Tokenkind.GTEQ))
        {
            auto op = peek();
            advance();
            Node* rhs = parse_logical_or();
            Node* n = new Node;
            n.binop = BinaryOp(STokenkind(op.kind, op.span), lhs, rhs);
            n.kind = NodeKind.BinaryOp;
            if (!match(Tokenkind.EQEQ) && !match(Tokenkind.NEQ) && !match(Tokenkind.LT) && !match(
                    Tokenkind.LTEQ) && !match(Tokenkind.GT) && !match(Tokenkind.GTEQ))
            {
                return n;
            }
        }
        return lhs;
    }

    Node* parse_bitwise()
    {

        Node* lhs = parse_expr();
        // TODO
        return lhs;
    }

    Node* parse_expr()
    {
        Node* lhs = parse_term();
        while (match(Tokenkind.ADD) || match(
                Tokenkind.SUB))
        {
            auto op = peek();
            advance();
            Node* rhs = parse_term();
            Node* n = new Node;
            n.binop = BinaryOp(STokenkind(op.kind, op.span), lhs, rhs);
            n.kind = NodeKind.BinaryOp;
            if (!match(Tokenkind.ADD) || match(
                    Tokenkind.SUB))
            {
                return n;
            }

        }
        return lhs;
    }

    Node* parse_term()
    {
        Node* lhs = parse_atom();
        while (match(Tokenkind.MUL) || match(
                Tokenkind.DIV))
        {
            auto op = peek();
            advance();
            Node* rhs = parse_logical_or();
            Node* n = new Node;
            n.binop = BinaryOp(STokenkind(op.kind, op.span), lhs, rhs);
            n.kind = NodeKind.BinaryOp;
            if (!match(Tokenkind.MUL) || match(
                    Tokenkind.DIV))
            {
                return n;
            }
        }
        return lhs;
    }

    Node* parse_atom()
    {
        Node* n = new Node;
        switch (peek().kind)
        {
        case Tokenkind.Number:
            n.kind = NodeKind
                .Int;
            n.token_data = peek().text;
            n.span = peek().span;
            advance();
            return n;
        case Tokenkind.CString:
            n.kind = NodeKind.CString;
            n.token_data = peek().text;
            n.span = peek().span;
            advance();
            return n;
        case Tokenkind.Identifier:
            {
                n.kind = NodeKind.Ident;
                n.token_data = peek().text;
                n.span = peek().span;
                advance();
                if (peek().kind == Tokenkind.OParen)
                {
                    advance();
                    Node* funcall = new Node;
                    funcall.fcall.callee = n;
                    funcall.kind = NodeKind.FCall;
                    while (peek().kind != Tokenkind.CParen)
                    {
                        funcall.fcall.params.put(parse_logical_or());
                        if (peek().kind == Tokenkind.Comma)
                        {
                            advance();
                        }
                    }
                    expect(Tokenkind.CParen);
                    return funcall;
		}
		else if (peek().kind == Tokenkind.EQ)
		{
		  advance();
		  Node* assign = new Node;
		  assign.kind = NodeKind.Assign;
		  assign.assign.lhs = n;
		  assign.assign.rhs = parse_expr();
		  return assign;
		}
                return n;
            }
            break;
        case Tokenkind.OParen:
            n.span = peek().span;
            advance();
            auto expr = parse_logical_or();
            expect(Tokenkind.CParen);
            n.kind = NodeKind.Expr;
            n.expr.node = expr;
            return n;
        case Tokenkind.BREAK:
            advance();
            n.kind = NodeKind.Break;
            return n;
        case Tokenkind.IF:
            advance();
            IfExpr if_expr;
            n.kind = NodeKind.If;
            if_expr.cond = parse_logical_or();
            expect(Tokenkind.OBrace);
            if_expr.then = Block(parse_body());
            expect(Tokenkind.CBrace);
            if (match(Tokenkind.ELSE))
            {
                advance();
                if (match(Tokenkind.IF))
                {
                    Node* branch = parse_logical_or();
                    if_expr.else_body = new Block;
                    Node e;
                    e.kind = NodeKind.Expr;
                    e.expr.node = branch;
                    if_expr.else_body.body ~= e;
                }
                else
                {
                    expect(Tokenkind.OBrace);
                    if_expr.else_body = new Block;
                    if_expr.else_body.body = parse_body();
                    expect(Tokenkind.CBrace);
                }

            }

            n.if_expr = if_expr;
            return n;
        case Tokenkind.RETURN:
            advance();
            auto expr = parse_logical_or();
            n.kind = NodeKind.Return;
            n.ret_value = ReturnValue(expr);
            return n;
        case Tokenkind.LOOP:
            n.span = peek().span;
            advance();
            n.kind = NodeKind.Loop;
            expect(Tokenkind.OBrace);
            n.loop.body = Block(parse_body());
            expect(Tokenkind.CBrace);
            return n;
        default:
            errors.add(Diagnostics(peek().span, source, "Invalid Expression", "", DiagType
                    .Error));
            return n;
        }
    }
}
