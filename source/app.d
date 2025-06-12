import std.stdio;
import std.file;
import std.path;
import core.stdc.stdlib: exit;
import lexer;
import build;
import parser;
import llvm;

void main(string[] args)
{
    BuildOptions opts = parse_args(args);
    if (opts.input.length == 0) {
        writeln("BC: Parsing Empty Source is Forbidden");
        exit(1);
    }
    auto tokens = lex(readText(opts.input));
    if (opts.debug_enabled) {
        foreach(tok; tokens) {
            writeln(tok.tostr());
        }
    }
    auto parser = Parser(tokens);
    auto ast = parser.parse();
    if (opts.output.length == 0) {
        opts.output = baseName(opts.input[0 .. opts.input.length - 2] ~ "ll");
    }
    auto llvm = LLvmCodeGen(ast, opts);
    llvm.generate();
}
