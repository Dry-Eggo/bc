import std.stdio;
import std.file;
import std.path;
import core.stdc.stdlib : exit;
import lexer;
import build;
import parser;
import llvm;
import cgen;
import std.string;
import diagnostics;

void main(string[] args)
{
    BuildOptions opts = parse_args(args);
    if (!exists(opts.input))
    {
        writeln(format("BC: No such file '%s'", opts.input));
        exit(1);
    }
    if (opts.input.length == 0 || opts.input.empty())
    {
        writeln("BC: Parsing Empty Source is Forbidden");
        exit(1);
    }
    ErrorManager* e = new ErrorManager;
    auto ext = extension(opts.input);
    if (ext != ".bcs")
    {
        writeln(format("BC: Unknown File format: '%s'", ext));
        writeln("BC: BC input files must be of extension 'bcs'");
        exit(1);
    }
    auto src = readText(opts.input);
    Lexer lexer = Lexer(src, e);
    auto tokens = lexer.lex();
    if (opts.debug_enabled)
    {
        foreach (tok; tokens)
        {
            writeln(tok.tostr());
        }
    }
    auto parser = Parser(tokens, e, lexer.source);
    auto ast = parser.parse();
    if (opts.output.length == 0)
    {
        if (opts.buildtarget == Target.LLVM)
        {
            opts.output = baseName(opts.input[0 .. opts.input.length - 3] ~ "ll");
        }
        else
        {
            opts.output = baseName(opts.input[0 .. opts.input.length - 3] ~ "c");
        }
    }
    final switch (opts.buildtarget)
    {
    case Target.C:
        auto cgen = CCodeGen(src, ast, opts, e);
        cgen.generate();
        break;
    case Target.LLVM:
        auto llvm = LLvmCodeGen(src, ast, opts, e);
        llvm.generate();
        break;
    }
    e.reportall();
}
