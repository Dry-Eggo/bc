module cgen;
import diagnostics;
import ast;
import build;
import parser, symbol;
import std.format, std.file, std.stdio;

struct ExprRes
{
    string preamble;
    string result;
    Type type;
}

struct CCodeGen
{
    string source;
    Node program_raw;
    BuildOptions opts;
    ErrorManager* errors;
    string includes;
    string header;
    string globals;
    string body;

    /*---------------------------------*/
    Context globCtx;
    Context currentCtx;
    FunctionTable functions;

    this(string source, Node program, BuildOptions opts, ErrorManager* errors)
    {
        this.source = source;
        this.program_raw = program;
        this.opts = opts;
        this.errors = errors;
        globCtx = Context();
        currentCtx = globCtx;
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
            currentCtx = globCtx;
        }
        else
        {
            currentCtx = *oldCtx.parent;
        }

    }

    void generate()
    {
        ExprRes res;
        string final_stream;
        includes ~= format("#include \"/home/dry/programming/d/bc/runtime/cruntime.h\"\n");
        foreach (node; program_raw.program)
        {
            res.result ~= gen_expr(node).result;
        }
        body ~= res.result;
        final_stream ~= includes;
        final_stream ~= header;
        final_stream ~= globals;
        final_stream ~= body;
        write!string(opts.output, final_stream);
    }

    ExprRes gen_expr(Node node)
    {
        ExprRes res;
        switch (node.kind)
        {
        case NodeKind.Extrn:
            res = gen_extrn(node);
            break;
        case NodeKind.FuncDecl:
            res = gen_func(node.func);
            break;
        case NodeKind.Binding:
            res = gen_binding(node.binding);
            break;
        case NodeKind.Int:
            res.result = node.token_data;
            break;
        case NodeKind.CString:
            res.result = format("\"%s\"", node.token_data);
            break;
        case NodeKind.Ident:
                // TODO: Add Actual Checking for Variable Exsisence
            res.result = node.token_data;
            break;
        case NodeKind.Expr:
            res = gen_expr(*node.expr.node);
            break;
        case NodeKind.FCall:
            res = gen_fcall(node);
            break;
        default:
            break;
        }
        return res;
    }

    ExprRes gen_fcall(Node node)
    {
        ExprRes res;
        auto fcall = node.fcall;
        switch (fcall.callee.kind)
        {
        case NodeKind.Ident:
            res.result ~= format("    %s(", fcall.callee.token_data);
            foreach (expr; fcall.params)
            {
                auto expr_res = gen_expr(*expr);
                res.result ~= expr_res.result;
            }
            res.result ~= ");\n";
            break;
        default:
            assert(0);
        }
        return res;
    }

    ExprRes gen_extrn(Node node)
    {
        auto extrn = node.extrn;
        ExprRes res;
        switch (extrn.kind)
        {
        case ExtrnKind.Function:
            auto fn = extrn.func;
            header ~= format("extern %s %s (%s);\n", type_tostr(fn.type), fn.name, param_spread(
                    fn.params));
            functions.add(Function(false, fn.name, fn.params, fn.type, true, node
                    .span));
            break;
        default:
            assert(0);
        }
        return res;
    }

    ExprRes gen_binding(VarBind bind)
    {
        ExprRes res;
        res.result ~= format("    %s %s = %s;\n", type_tostr(bind.type), bind.name, gen_expr(
                *bind.value).result);
        currentCtx.add(Variable(false, bind.name, bind.type));
        return res;
    }

    ExprRes gen_func(FnDecl fn)
    {
        ExprRes res;
        res.result ~= format("%s %s (%s) {\n", type_tostr(fn.type), fn.name, param_spread(fn.params));
        res.result ~= gen_body(fn.fn_body).result;
        res.result ~= format("}");
        return res;
    }

    ExprRes gen_body(Node[] body)
    {
        ExprRes res;
        foreach (node; body)
        {
            res.result ~= gen_expr(node).result;
        }
        return res;
    }

    string type_tostr(Type ty)
    {
        string res;
        switch (ty.kind)
        {
        case BaseKind.Void:
            res = "void";
            break;
        case BaseKind.I32:
            res = "i32";
            break;
        case BaseKind.Cstr:
            res = "cstr";
            break;
        default:
            break;
        }
        return res;
    }

    string param_spread(Param[] params)
    {
        string res;
        foreach (i, param; params)
        {
            res ~= format("%s %s", type_tostr(param.type), param.name);
            if (i != params.length - 1)
            {
                res ~= ",";
            }
        }
        return res;
    }
}
