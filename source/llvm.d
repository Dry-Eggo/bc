module llvm;
import core.stdc.stdlib: exit;
import std.file;
import std.stdio;
import build;
import ast;

struct ExprRes {
    string result;
    string preamble;
    this(string res) { this.result = res; }
}

struct LLvmCodeGen {
    Node program;
    BuildOptions opts;
    this(Node program, BuildOptions opts) {
        this.program = program;
        this.opts = opts;
    }
    void generate() {
        if (program.kind != NodeKind.Program)
        {
            writeln("BC: Invalid Program");
            exit(1);
        }
        string stream;
        stream ~= "; ModuleId = '" ~ opts.output[0..opts.output.length - 3] ~ "'\n";
        stream ~= "source_filename = \"" ~ opts.input ~ "\"\n";
        foreach(node; program.program) {
            stream ~= gen_expr(node).result;
        }
        write!(string)(opts.output, stream);
    }
    ExprRes gen_expr(Node node) {
        switch (node.kind) {
            case NodeKind.FuncDecl: {
                ExprRes res = gen_funcstmt(node);
                return res;
            }break;
            case NodeKind.Int:
                ExprRes res;
                res.result ~= node.token_data.text;
                return res;
            default: break;
        }
        return ExprRes();
    }
    ExprRes gen_funcstmt(Node node) {
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
    ExprRes gen_body(Node[] bod) {
        ExprRes stream;
        foreach(node; bod) {
            switch(node.kind) {
                case NodeKind.Binding:{
                    stream.result ~= gen_binding(node).result;
                    continue;
                }break;
                default: writeln("Invalid Node"); exit(1);
            }
        }
        return stream;
    }
    ExprRes gen_binding(Node n) {
        VarBind var = n.binding;
        ExprRes res;
        res.result ~= "    %" ~ var.name ~ " = alloca " ~ var.type.tostr() ~ "\n";
        auto exprres = gen_expr(*var.value);
        res.result ~= "    store " ~ var.type.tostr() ~ " " ~ exprres.result ~ ", " ~ "ptr %" ~ var.name ~ "\n";
        return res;
    }
}
