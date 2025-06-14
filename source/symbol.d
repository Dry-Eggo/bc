module symbol;
import std.array;
import ast;

struct Variable
{
    bool poison = false;
    string name;
    Type type;
}

Variable poisonValue = Variable(true);

struct Function
{
    bool poison = false;
    string name;
    Param[] params;
    Type type;
    bool is_extrn;
}

Function poisonFunc = Function(true);

struct Context
{
    Appender!(Variable[]) variables;
    int ssa_counter = 0; /*  %1, %2, %3, ... */
    Context* parent = null;
    this(Context* parent)
    {
        this.parent = parent;
        this.ssa_counter = 0;
    }

    void add(Variable v)
    {
        variables.put(v);
    }

    bool has(string name)
    {
        foreach (var; variables)
        {
            if (var.name == name)
                return true;
        }
        if (parent != null)
            return parent.has(name);
        return false;
    }

    Variable get(string name)
    {
        foreach (var; variables)
        {
            if (var.name == name)
            {
                return var;
            }
        }
        if (parent != null)
            return parent.get(name);
        return poisonValue;
    }
}

struct FunctionTable
{
    Appender!(Function[]) functions;
    void add(Function f)
    {
        functions.put(f);
    }

    Function find(string name)
    {
        foreach (func; functions)
        {
            if (func.name == name)
                return func;
        }
        return poisonFunc;
    }
}
