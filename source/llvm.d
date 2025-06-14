module llvm;
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
    this(string res)
    {
        this.result = res;
    }
}

struct LLvmCodeGen
{
    Node program;
    BuildOptions opts;
    ErrorManager* errors;
    string extrn_stream;
    Context globalCtx;
    Context currentCtx;
    FunctionTable functions;
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
        stream ~= "; ModuleId = '" ~ opts.output[0 .. opts.output.length - 3] ~ "'\n";
        stream ~= "source_filename = \"" ~ opts.input ~ "\"\n";
        foreach (node; program.program)
        {
            stream ~= gen_expr(node).result;
        }
        stream ~= "\n" ~ extrn_stream ~
            "\n";
        write!(string)(opts.output, stream);
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
            res.result ~= node.token_data.text;
            return res;
        case NodeKind.Ident:
            {
                ExprRes res;
                auto var = currentCtx.get(node.token_data.text);
                int t = currentCtx.ssa_counter++;
                res.preamble ~= "    %" ~ format("%d", t) ~ " = load " ~ var
                    .type.tostr() ~ ", ptr %" ~ var
                    .name ~ "\n";
                res.result ~= var.type.tostr() ~ " %" ~ format("%d", t);
                return res;
            }
        default:
            break;
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
        writeln("here");
        ExprRes res;
        Funccall f = node.fcall;
        switch (f.callee.kind)
        {
        case NodeKind.Ident:
            {
                auto query = functions.find(f.callee.token_data.text);
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
                    res.result ~= exprres.result;
                }
                res.result ~= ")\n";
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
        res.result ~= "    store " ~ var.type.tostr() ~ " " ~ exprres.result ~ ", " ~ "ptr %" ~ var.name ~ "\n";
        Variable newVar = Variable(false, var.name, var.type);
        this.currentCtx.add(newVar);
        return res;
    }
}
