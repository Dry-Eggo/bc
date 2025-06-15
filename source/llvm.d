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

    int globals_counter = 0;
    this(Node program, BuildOptions opts, ErrorManager* e)
    {
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
            string tmp2 = "%" ~ format("%d", currentCtx.ssa_counter++);
            int str_len = cast(int) node.token_data.length;
            globals ~= format("\n%s = global [%d x i8] c\"%s\\00\"\n", tmp, node.token_data.length + 1, node
                    .token_data);
            res.preamble ~= format("%s = getelementptr [%d x i8], ptr %s, i32 0, i32 0", tmp2, str_len + 1, tmp);
            res.result = tmp2;
            res.type = Type.create_ptr();
            return res;
        case NodeKind.BinaryOp:
            ExprRes res;
            BinaryOp expr = node.binop;
            auto lres = gen_expr(*expr.lhs);
            auto rres = gen_expr(*expr.rhs);
            switch (expr.op)
            {
            case Tokenkind.ADD:
                auto tmp = "%" ~ format("%d", currentCtx.ssa_counter++);
                res.preamble ~= "    " ~ tmp ~ " = add " ~ lres.type.tostr() ~ " " ~ lres.result ~ ", " ~ rres
                    .result ~ "\n";
                res.result = tmp;
                res.type = Type.create_int();
                return res;
            default:
                writeln("BC: invalid operator");
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
                    fn.params) ~ ")";
                auto f = Function(false, fn.name, fn.params, fn.type, true);
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
        stream ~= "define " ~ fn.type.tostr() ~ " @" ~ fn.name ~ "() {\n";
        stream ~= "entry:\n";

        ExprRes bodyStream = gen_body(fn.fn_body);
        stream ~= bodyStream.result;
        stream ~= "    ret void\n";
        stream ~= "}\n";
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
                    writeln("Use of Undeclared function");
                    exit(1);
                }
                if (f.params.length != query.params.length)
                {
                    writeln("Invalid Param Count in ", query.name, ": Expected ", query.params.length, " got ", f
                            .params.length);
                    exit(1);
                }
                res.result ~= "    call " ~ query.type.tostr ~ " @" ~ query.name ~ "(";
                foreach (arg; f.params)
                {
                    auto exprres = gen_expr(*arg);
                    res.preamble ~= exprres.preamble;
                    res.result ~= exprres.type.tostr() ~ " " ~ exprres.result;
                }
                res.result ~= ")\n";
                res.type = query.type;
                return res;
            }
            break;
        default:
            writeln("Invalid: ", f.callee.kind);
            exit(1);
            break;
        }
        return res;
    }

    ExprRes gen_body(Node[] bod)
    {
        ExprRes stream;
        foreach (node; bod)
        {
            switch (node.kind)
            {
            case NodeKind.Binding:
                {
                    stream.result ~= gen_binding(node).result;
                    continue;
                }
                break;
            case NodeKind.Expr:
                {
                    auto n = gen_expr(node);
                    stream.result ~= n.preamble;
                    stream.result ~= n.result;
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
        res.result ~= "    %" ~ var.name ~ " = alloca " ~ var.type.tostr() ~ "\n";
        auto exprres = gen_expr(*var.value);
        res.result ~= exprres.preamble;
        res.result ~= "    store " ~ var.type.tostr() ~ " " ~ exprres.result ~ ", " ~ "ptr %" ~ var.name ~ "\n";
        Variable newVar = Variable(false, var.name, var.type);
        this.currentCtx.add(newVar);
        return res;
    }
}
