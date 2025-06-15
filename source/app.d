import std.stdio;
import std.file;
import std.path;
import core.stdc.stdlib : exit;
import lexer;
import build;
import parser;
import llvm;
import std.string;
import diagnostics;

void main(string[] args)
{
  BuildOptions opts = parse_args(args);
  if (opts.input.length == 0 || opts.input.empty())
  {
    writeln("BC: Parsing Empty Source is Forbidden");
    exit(1);
  }
  ErrorManager* e = new ErrorManager;
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
    opts.output = baseName(opts.input[0 .. opts.input.length - 2] ~ "ll");
  }
  auto llvm = LLvmCodeGen(src, ast, opts, e);
  llvm.generate();
  e.reportall();
}
