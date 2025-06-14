module diagnostics;
import token;
import std.array;
import std.stdio;
import core.stdc.stdlib : exit;
import std.string;

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
        writeln(format("Error(%d:%d): %s", d.span.line, d.span.cols, d.text));
        writeln("  | ");
        writeln(d.span.line, " | ", line);
        write("  | ");

        int fnws = 0;
        foreach (c; line)
        {
            if (line[fnws] != ' ')
            {
                break;
            }
            fnws++;
        }

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
