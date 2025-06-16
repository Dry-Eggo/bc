module llvm;
import token;
import std.format;
import core.stdc.stdlib : exit;
import std.file;
import std.stdio;
import build;
import ast;
import diagnostics;
import symbol;
import std.array;

struct ExprRes
{
    string result;
    string preamble;
    Type type;
    this(string res)
    {
        this.result = res;
    }

    this(string res, Type t)
    {
        this.result = res;
        this.type = t;
    }
}

string string_escape(string str)
{
    string escaped = replace(str, "\\n", "\\0A");
    return escaped;
}

int string_escaped_len(string str)
{
    //
    string tmp = replace(str, "\\0A", "-");
    return cast(int) tmp.length;
}

enum ContextType
{
    IF,
    ELSE,
    FUNC,
    LOOP,
}

struct ContextPort
{
    ContextType type;
    string expected_return_Label;
    bool has_returned;
}

struct LLvmCodeGen
{
    Node program;
    BuildOptions opts;
    ErrorManager* errors;
    string extrn_stream;
    string globals;
    Context globalCtx;
    Context currentCtx;
    FunctionTable functions;
    string source;
    Type current_context_expected_return_type;
    ContextPort currentPort;

    int globals_counter = 0;
    this(string source, Node program, BuildOptions opts, ErrorManager* e)
    {
        this.source = source;
        this.program = program;
        this.opts = opts;
        this.errors = e;
        globalCtx = Context();
        currentCtx = globalCtx;
    }

    Context newCtx()
    {
        return Context(&this.currentCtx);
    }

    void exitCtx()
    {
        auto oldCtx = this.currentCtx;
        if (currentCtx.parent == null)
        {
            currentCtx = globalCtx;
        }
        else
        {
            currentCtx = *oldCtx.parent;
        }

    }

    void generate()
    {
        if (program.kind != NodeKind.Program)
        {
            writeln("BC: Invalid Program");
            exit(1);
        }
        string stream;
        string final_stream;
        final_stream ~= "; ModuleId = '" ~ opts.output[0 .. opts.output.length - 3] ~ "'\n";
        final_stream ~= "source_filename = \"" ~ opts.input ~ "\"\n";
        foreach (node; program.program)
        {
            stream ~= gen_expr(node).result;
        }
        stream ~= "\n" ~ extrn_stream ~
            "\n";
        final_stream ~= globals;
        final_stream ~= "\n" ~ stream ~ "\n";
        write!(string)(opts.output, final_stream);
    }

    ExprRes gen_expr(Node node)
    {
        switch (node.kind)
        {
        case NodeKind.FuncDecl:
            {
                ExprRes res = gen_funcstmt(node);
                return res;
            }
            break;
        case NodeKind.Extrn:
            {
                ExprRes res = gen_extrn(node);
                return res;
            }
        case NodeKind.Expr:
            return gen_expr(*node.expr.node);
        case NodeKind.FCall:
            {
                ExprRes res = gen_funccall(node);
                return res;
            }
        case NodeKind.Int:
            ExprRes res;
            res.result = node.token_data;
            res.type = Type.create_int();
            return res;
        case NodeKind.CString:
            ExprRes res;
            string tmp = "@" ~ format("%d", globals_counter++);
            string tmp2 = currentCtx.next_ssa();
            auto str = string_escape(node.token_data);
            int str_len = cast(int) string_escaped_len(str) + 1;
            globals ~= format("%s = global [%d x i8] c\"%s\\00\"\n", tmp, str_len, str);
            res.preamble ~= format("    %s = getelementptr [%d x i8], ptr %s, i32 0, i32 0\n", tmp2, str_len, tmp);
            res.result = tmp2;
            res.type = Type.create_ptr();
            return res;
        case NodeKind.BinaryOp:
            ExprRes res;
            BinaryOp expr = node.binop;
            auto lres = gen_expr(*expr.lhs);
            auto rres = gen_expr(*expr.rhs);
            res.preamble ~= lres.preamble;
            res.preamble ~= rres.preamble;
            switch (expr.op.token)
            {
            case Tokenkind.ADD:
                auto tmp = currentCtx.next_ssa();
                res.preamble ~= "    " ~ tmp ~ " = add " ~ lres.type.tostr() ~ " " ~ lres.result ~ ", " ~ rres
                    .result ~ "\n";
                res.result = tmp;
                res.type = Type.create_int();
                return res;
            case Tokenkind.SUB:
                auto tmp = currentCtx.next_ssa();
                res.preamble ~= "    " ~ tmp ~ " = sub nsw " ~ lres.type.tostr() ~ " " ~ lres.result ~ ", " ~ rres
                    .result ~ "\n";
                res.result = tmp;
                res.type = Type.create_int();
                return res;
            case Tokenkind.MUL:
                auto tmp = currentCtx.next_ssa();
                res.preamble ~= "    " ~ tmp ~ " = mul " ~ lres.type.tostr() ~ " " ~ lres.result ~ ", " ~ rres
                    .result ~ "\n";
                res.result = tmp;
                res.type = Type.create_int();
                return res;
            case Tokenkind.EQEQ:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp eq %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.NEQ:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp ne %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.LT:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp slt %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.GT:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp sgt %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.LTEQ:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp sle %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.GTEQ:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp sge %s %s, %s\n", tmp, lres.type.tostr(), lres.result, rres
                        .result);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp2, tmp);
                res.result = tmp2;
                res.type = Type.create_int();
                return res;
            case Tokenkind.OR:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                auto tmp3 = currentCtx.next_ssa();
                auto tmp4 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp ne %s %s, 0\n", tmp, lres.type.tostr(), lres
                        .result);
                res.preamble ~= format("    %s = icmp ne %s %s, 0\n", tmp2, rres.type.tostr(), rres
                        .result);
                res.preamble ~= format("    %s = or i1 %s, %s\n", tmp3, tmp, tmp2);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp4, tmp3);
                res.result = tmp4;
                res.type = Type.create_int();
                return res;
            case Tokenkind.AND:
                auto tmp = currentCtx.next_ssa();
                auto tmp2 = currentCtx.next_ssa();
                auto tmp3 = currentCtx.next_ssa();
                auto tmp4 = currentCtx.next_ssa();
                res.preamble ~= format("    %s = icmp ne %s %s, 0\n", tmp, lres.type.tostr(), lres
                        .result);
                res.preamble ~= format("    %s = icmp ne %s %s, 0\n", tmp2, rres.type.tostr(), rres
                        .result);
                res.preamble ~= format("    %s = and i1 %s, %s\n", tmp3, tmp, tmp2);
                res.preamble ~= format("    %s = zext i1 %s to i32\n", tmp4, tmp3);
                res.result = tmp4;
                res.type = Type.create_int();
                return res;
            default:
                errors.report(Diagnostics(expr.op.span, source, "BC: invalid operator", "", DiagType
                        .Error), true);
                exit(1);
            }
            return res;
        case NodeKind.Ident:
            {
                ExprRes res;
                auto var = currentCtx.get(node.token_data);
                int t = currentCtx.ssa_counter++;
                res.preamble ~= "    %" ~ format("%d", t) ~ " = load " ~ var
                    .type.tostr() ~ ", ptr %" ~ var
                    .name ~ "\n";
                res.result ~= " %" ~ format("%d", t);
                res.type = var.type;
                return res;
            }
        case NodeKind.Return:
            ExprRes res;
            ReturnValue r = node.ret_value;
            auto e = gen_expr(*r.expr);
            auto ty = current_context_expected_return_type;
            if (e.type != ty)
            {
                errors.report(Diagnostics(r.expr.span, source, "Invalid Return Type", format("Expected %s", ty.tostr()), DiagType
                        .Error), true);
            }
            res.preamble ~= e.preamble;
            res.preamble ~= format("    ret %s %s\n", e.type.tostr(), e.result);
            res.type = e.type;
            currentPort.has_returned = true;
            return res;
        case NodeKind.Break:
            ExprRes res;
            if (currentPort.type != ContextType.LOOP)
            {
                errors.add(Diagnostics(node.span, source, "Cannot Break in non-loop context", "", DiagType
                        .Error));
                return res;
            }
            currentPort.has_returned = true;
            res.preamble ~= format("   br label %s", currentPort.expected_return_Label);
            return res;
        case NodeKind.If:
            ExprRes res;
            IfExpr if_expr = node.if_expr;
            auto then_branch = format("%%.if%s", currentCtx.next_if()[1 .. $]);
            auto else_branch = format("%%%s.else", then_branch[1 .. $]);
            auto merge_brach = format("%%%s.done", then_branch[1 .. $]);
            auto cond_res = gen_expr(*if_expr.cond);
            res.preamble ~= cond_res.preamble;
            auto tmp = currentCtx.next_ssa();
            res.preamble ~= format("    %s = icmp ne %s %s, 0\n", tmp, cond_res.type.tostr(), cond_res
                    .result);
            if (if_expr.else_body != null)
                res.preamble ~= format("    br i1 %s, label %s, label %s\n", tmp, then_branch, else_branch);
            else
                res.preamble ~= format("    br i1 %s, label %s, label %s\n", tmp, then_branch, merge_brach);
            res.preamble ~= format("%s:\n", then_branch[1 .. $]);
            auto fbres = gen_body(if_expr.then.body);
            res.preamble ~= gen_body(if_expr.then.body).result;
            if (if_expr.then.body[$ - 1].kind != NodeKind.Expr && if_expr.then.body[$ - 1].expr.node.kind != NodeKind
                .Return)

                res.preamble ~= format("    br label %s\n", merge_brach);
            if (if_expr.else_body != null)
            {
                res.preamble ~= format("%s:\n", else_branch[1 .. $]);
                res.preamble ~= gen_body(if_expr.else_body.body)
                    .result;
                if (if_expr.else_body.body[$ - 1].kind != NodeKind.Expr && if_expr
                    .else_body.body[$ - 1].expr.node.kind != NodeKind
                    .Return)
                    res.preamble ~= format("    br label %s\n", merge_brach);
            }
            res.preamble ~= format("%s:\n", merge_brach[1 .. $]);
            return res;
        case NodeKind.Loop:
            ExprRes res;
            string loop_label = format("%%.loop%s", currentCtx.next_loop()[1 .. $]);
            string loop_done = loop_label[0 .. $] ~ ".done";
            auto prePort = currentPort;
            currentPort = ContextPort(ContextType.LOOP, loop_done, false);
            res.preamble ~= format("    br label %s\n", loop_label);
            res.preamble ~= format("%s:\n", loop_label[1 .. $]);
            res.preamble ~= format("%s", gen_body(node.loop.body.body).result);
            res.preamble ~= format("    br label %s\n", loop_label);
            res.preamble ~= format("%s:\n", loop_done[1 .. $]);
            if (!currentPort.has_returned)
            {
                errors.add(Diagnostics(node.span, source, "Infinite Loop", "", DiagType.Warning));
            }
            currentPort = prePort;
            return res;
        default:
            writeln("Invalid Expr");
            exit(1);
        }

        return ExprRes();
    }

    ExprRes gen_extrn(Node node)
    {
        ExprRes res;
        switch (node.extrn.kind)
        {
        case ExtrnKind.Function:
            {
                FnDecl fn = node.extrn.func;
                extrn_stream ~= "declare " ~ fn.type.tostr() ~ " @" ~ fn.name ~ "(" ~ param_spread(
                    fn.params, currentCtx) ~ ")\n";
                auto f = Function(false, fn.name, fn.params, fn.type, true, node
                        .span);
                functions.add(f);
            }
            break;
        default:
            assert(0);
            break;
        }

        return res;
    }

    ExprRes gen_funcstmt(Node node)
    {
        auto fn = node.func;
        string stream;
        currentCtx = newCtx();
        stream ~= "define " ~ fn.type.tostr() ~ " @" ~ fn
            .name ~ "(" ~ param_spread(
                fn.params, currentCtx) ~ ") {\n";
        stream ~= "entry:\n";
        foreach (i, p; fn.params)
        {
            string name = p.name;
            string tmp = currentCtx.next_ssa();
            stream ~= format(
                "    %%%s = alloca %s\n", name, p.type.tostr());
            stream ~= format(
                "    store %s %s, ptr %%%s\n", p.type.tostr(), tmp, name);
            Variable var = Variable(false, name, p.type);
            currentCtx.add(var);
        }
        // TODO Add First Pass to collect all functions before codegen
        Function func;
        func.params = fn.params;
        func.type = fn.type;
        func.name = fn.name;
        func.is_extrn = false;
        func.definition_location = node.span;
        functions.add(
            func);
        current_context_expected_return_type = fn.type;
        ExprRes bodyStream = gen_body(
            fn.fn_body);
        stream ~= bodyStream.result;
        stream ~= "    ret " ~ fn.type.tostr();
        if (fn.type.kind != BaseKind.Void)
            stream ~= " 0";
        stream ~= "\n";
        stream ~= "}\n";
        exitCtx();
        return ExprRes(stream);
    }

    ExprRes gen_funccall(Node node)
    {
        ExprRes res;
        Funccall f = node.fcall;
        switch (f.callee.kind)
        {
        case NodeKind.Ident:
            {
                auto query = functions.find(f.callee.token_data);
                if (query.poison)
                {
                    errors.add(Diagnostics(f.callee.span, source, "Use of Undeclared Function", "", DiagType
                            .Error));
                    return res;
                }
                if (f.params.length != query.params.length)
                {
                    errors.add(Diagnostics(f.callee.span, source, format(
                            "Invalid Param Count in %s %s %d %s %d", query.name, ": Expected", query
                            .params.length, "got", f
                            .params.length), "", DiagType.Error));
                    if (
                        query.params.length > f.params.length)
                        errors.add(
                            Diagnostics(query.params[f.params.length].span, source, "Missing this", "", DiagType
                                .Trace));
                    else
                        errors.add(
                            Diagnostics(f.params.data()[$ - 1].span, source, "Not Expecting this", "", DiagType
                                .Trace));
                    return res;
                }
                string preamble;
                string preamble2;
                foreach (i, arg; f.params)
                {
                    /*auto param = query.params[i];*/
                    auto exprres = gen_expr(*arg);
                    preamble ~= exprres.preamble;
                    preamble2 ~= exprres.type.tostr() ~ " " ~ exprres.result;
                }
                string tmp = currentCtx.next_ssa();
                if (query.type.kind != BaseKind
                    .Void)
                {
                    res.preamble ~= "    " ~ tmp ~ " = ";
                    res.result = tmp;
                }
                else
                    res.preamble ~= "    ";
                res.preamble ~= "call " ~ query.type.tostr ~ " @" ~ query.name ~ "(" ~ preamble2;
                res.preamble ~= ")\n";
                res.preamble = format("%s%s", preamble, res
                        .preamble);
                res.type = query.type;
                return res;
            }
            break;
        default:
            errors.report(Diagnostics(f.callee.span, source, "Invalid", "", DiagType
                    .Error), true);
            exit(1);
            break;
        }
        return res;
    }

    ExprRes gen_body(Node[] bod)
    {
        ExprRes stream;
        foreach (i, node; bod)
        {
            switch (node.kind)
            {
            case NodeKind.Binding:
                {
                    auto r = gen_binding(node);
                    stream.preamble ~= r.preamble;
                    stream.result ~= r.result;
                    continue;
                }
                break;
            case NodeKind.Expr:
                {
                    auto n = gen_expr(node);
                    stream.result ~= n.preamble;
                    /*stream.result ~= n.result;*/
                    continue;
                }
            default:
                writeln("Invalid Node");
                exit(1);
            }
        }
        return stream;
    }

    ExprRes gen_binding(Node n)
    {
        VarBind var = n.binding;
        ExprRes res;
        res.result ~= "    %" ~ var.name ~ " = alloca " ~ var
            .type.tostr() ~ "\n";
        auto exprres = gen_expr(*var.value);
        res.result ~= exprres.preamble;
        res.result ~= "    store " ~ var.type.tostr() ~ " " ~ exprres
            .result ~ ", " ~ "ptr %" ~ var.name ~ "\n";
        Variable newVar = Variable(false, var.name, var.type);
        this.currentCtx.add(newVar);
        return res;
    }
}
