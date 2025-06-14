module ast;
import token;
import std.array;

enum NodeKind
{
    FuncDecl,
    FCall,
    Binding,
    Int,
    String,
    Ident,
    BinaryOP,
    UnaryOp,
    Program,
    Expr,
    Extrn,
}

enum BaseKind
{
    I8,
    I16,
    I32,
    I64,
    U8,
    U16,
    U32,
    U64,
    Str,
    Void,
    Bool,
    Chr,
}

struct Type
{
    BaseKind kind;
    bool is_ptr;
    string name;
    this(BaseKind k)
    {
        this.kind = k;
        this.is_ptr = false;
        this.name = "";
    }

    this(BaseKind k, bool isptr, string name)
    {
        this.kind = k;
        this.is_ptr = isptr;
        this.name = name;
    }

    string tostr()
    {
        switch (kind)
        {
        case BaseKind.Void:
            return "void";
        case BaseKind.I32:
            return "i32";
        case BaseKind.I8:
            return "i8";
        case BaseKind.I16:
            return "i16";
        case BaseKind.I64:
            return "i64";
        default:
            assert(0);
        }
    }

    static Type create_void()
    {
        return Type(BaseKind.Void, false, "");
    }
}

struct Param
{
    string name;
    Type type;
}

string param_spread(Param[] p)
{
    string res;
    foreach (i, param; p)
    {
        res ~= param.type.tostr() ~ " %" ~ param.name;
        if (i != p.length - 1)
        {
            res ~= ",";
        }
    }
    return res;
}

struct VarBind
{
    string name;
    Node* value;
    bool is_const;
    bool is_initialized;
    Type type;
    this(string name)
    {
        this.name = name;
        this.is_const = true;
        this.is_initialized = false;
    }

    this(string name, Node* value)
    {
        this.name = name;
        this.is_const = true;
        this.is_initialized = true;
        this.value = value;
    }
}

struct BinaryOp
{
    Tokenkind op;
    Node* lhs;
    Node* rhs;
}

struct UnaryOp
{
    Tokenkind op;
    Node* value;
}

struct FnDecl
{
    string name;
    Param[] params;
    Type type;
    Node[] fn_body;
    bool is_extrn;
    string extrn_name;
}

enum ExtrnKind
{
    Function,
    Struct,
    Binding,
}

struct ExtrnStmt
{
    ExtrnKind kind;
    union
    {
        FnDecl func;
        VarBind binding;
    }
}

struct Funccall
{
    Node* callee;
    Appender!(Node*[]) params;
}

struct Expr
{
    Node* node;
}

struct Node
{
    NodeKind kind;
    Span span;
    union
    {
        Expr expr;
        Token token_data;
        ExtrnStmt extrn;
        FnDecl func;
        Node[] program;
        VarBind binding;
        BinaryOp binop;
        UnaryOp unop;
        Funccall fcall;
    }
}
