module ast;
import token;
import std.array;
import symbol;

enum NodeKind
{
    FuncDecl,
    FCall,
    Binding,
    Int,
    String,
    CString,
    Ident,
    BinaryOp,
    UnaryOp,
    Program,
    Expr,
    Extrn,
    If,
    While,
    Loop,
    Assign,
    Until,
    For,
    ForEach,
    Break,
    Return,
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
    Cstr,
    Ptr,
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

    bool match(Type t)
    {
        return true;
    }

    string tostr()
    {
        // llvm backend only
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
        case BaseKind.Ptr:
            return "ptr";
        case BaseKind.Cstr:
            return "ptr";
        default:
            assert(0);
        }
    }

    static Type create_void()
    {
        return Type(BaseKind.Void, false, "");
    }

    static Type create_ptr()
    {
        return Type(BaseKind.Ptr, false, "");
    }

    static Type create_int()
    {
        return Type(BaseKind.I32, false, "");
    }
}

struct Param
{
    Span span;
    string name;
    Type type;
}

string param_spread(Param[] p, Context ctx)
{
    string res;
    foreach (i, param; p)
    {
        res ~= param.type.tostr() ~ " " ~ ctx.next_ssa();
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

struct STokenkind
{
    Tokenkind token;
    Span span;
}

struct BinaryOp
{
    STokenkind op;
    Node* lhs;
    Node* rhs;
}

struct UnaryOp
{
    Tokenkind op;
    Node* value;
}

struct Block
{
    Node[] body;
}

struct IfExpr
{
    Node* cond;
    Block then;
    Appender!(Block[]) branches;
    Block* else_body = null;
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

// TODO:
struct Break
{
    string label;
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

struct Assign
{
    Node* lhs;
    Node* rhs;
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

struct Loop
{
    Block body;
}

struct ReturnValue
{
    Node* expr;
}

struct Node
{
  NodeKind kind;
  Span span;
  union
    {
      Expr expr;
      string token_data;
      ExtrnStmt extrn;
      FnDecl func;
      Node[] program;
      VarBind binding;
      BinaryOp binop;
      UnaryOp unop;
      Funccall fcall;
      Block block;
      IfExpr if_expr;
      ReturnValue ret_value;
      Assign assign;
      Loop loop;
  }
}
