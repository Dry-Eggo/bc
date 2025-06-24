module build;
import std.stdio;
import core.stdc.stdlib;


enum Target {
  LLVM,
  C,
}

struct BuildOptions
{
  string input;
  string output;
  bool debug_enabled   = false;
  Target buildtarget   = Target.LLVM;
}

BuildOptions parse_args(string[] args)
{
    BuildOptions opts;
    if (args.length <= 1)
    {
        writeln("BC: No arguments were passed");
        exit(1);
    }
    for (int i = 0; i < args.length; i++)
    {
        if (args[i] == "-o")
        {
            if (i + 1 >= args.length)
            {
                writeln("BC: '-o' expected an argument");
                exit(1);
            }
            opts.output = args[i++ + 1];
        }
        else if (args[i] == "--debug")
        {
            opts.debug_enabled = true;
        } else if (args[i][0..3] == "--t") {
    	    if (args[i].length <= 3) {
	            writeln("BC: '--t' expected and argument");
    	        exit(1);
	        }
        	auto target = args[i][3..$]; 
	        switch(target) {
    	    case "c":
    	        opts.buildtarget = Target.C;
                break;
              case "llvm":
                opts.buildtarget = Target.LLVM;
                break;
              default:
                writeln("BC: Unknown Target: ", target);
                exit(1);
            }
		i++;
	    }
        else if (args[i][0] != '-')
        {
            opts.input = args[i];
        }
    }
    return opts;
}
