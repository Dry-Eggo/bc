module diagnostics;
import token;
import std.array;
import std.stdio;
import core.stdc.stdlib : exit;
import std.string;
import std.range : repeat;
import std.algorithm : joiner;

enum DiagType
{
  Error,
  Warning,
  Trace,
}

struct Diagnostics
{
  Span span;
  string source;
  string text;
  string help;
  DiagType type = DiagType.Warning;
}

struct ErrorManager
{
  Appender!(Diagnostics[]) diagnostics;
  void add(Diagnostics d)
  {
    this.diagnostics.put(d);
  }

  void reportall()
  {
    bool shld_exit = false;
    foreach (d; diagnostics)
    {
      report(d, false);
      if (d.type == DiagType.Error)
      {
        shld_exit = true;
      }
    }
    if (shld_exit)
      exit(1);
  }

  void report(Diagnostics d, bool discard)
  {
    auto lines = d.source.splitLines();
    auto line = lines[d.span.line - 1];
    auto tag = "\033[1;31mError\033[m";
    if (d.type == DiagType.Trace)
      tag = "Info";
    else if (d.type == DiagType.Warning)
      tag = "\033[33mWarning\033[0m";
    writeln(format("%s(%d:%d): %s", tag, d.span.line, d.span.cols, d.text));
    auto space = repeat(" ", format("%d", d.span.line).length).joiner;
    writeln(space, "| ");
    writeln(d.span.line, "| ", line);
    write(space, "| ");

    int fnws = 0;
    foreach (c; line)
    {
      if (line[fnws] != ' ')
      {
        break;
      }
      fnws++;
    }

    write("\033[33m");
    for (int i = 0; i <= d.span.cole; ++i)
    {
      if (i == d.span.cols - 1)
      {
        write("^");
        while (i < d.span.cole - 1)
        {
          write("^");
          i++;
        }
      }
      else
      {
        if (fnws <= i && i < d.span.cole)
        {
          write("~");
        }
        else
          write(" ");
      }
    }
    write("\033[0m");
    if (!d.help.empty())
      write(": \033[33m", d.help, "\033[0m");
    writeln("");
    if (discard)
    {
      if (d.type == DiagType.Error)
      {
        exit(1);
      }
    }
  }
}
