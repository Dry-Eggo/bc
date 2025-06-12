module ast;
import token;

enum NodeKind {
    FuncDecl,
    Binding,
    Int, String, Ident,
    BinaryOP, UnaryOp,
    Program,
}

enum BaseKind {
    I8, I16, I32, I64, U8, U16, U32, U64, Str, Void, Bool, Chr,
}

struct Type {
    BaseKind kind;
    bool is_ptr;
    string name;
    this(BaseKind k) {
        this.kind = k;
        this.is_ptr = false;
        this.name = "";
    }
    this(BaseKind k, bool isptr, string name) {
        this.kind = k;
        this.is_ptr = isptr;
        this.name = name;
    }
    string tostr() {
        string res;
        switch (kind) {
            case BaseKind.Void: return "void";
            case BaseKind.I32: return "i32";
            case BaseKind.I8: return "i8";
            case BaseKind.I16: return "i16";
            case BaseKind.I64: return "i64";
            default: assert(0);
        }
    }
    static Type create_void() {
        return Type(BaseKind.Void, false, "");
    }
}

struct Param {
    string name;
    Type type;
}

struct VarBind {
    string name;
    Node* value;
    bool is_const;
    bool is_initialized;
    Type type;
    this(string name) {
        this.name = name;
        this.is_const = true;
        this.is_initialized = false;
    }
    this(string name, Node *value) {
        this.name = name;
        this.is_const = true;
        this.is_initialized = true;
        this.value = value;
    }
}

struct BinaryOp {
    Tokenkind op;
    Node* lhs;
    Node* rhs;
}

struct UnaryOp {
    Tokenkind op;
    Node* value;
}

struct FnDecl {
    string name;
    Param[] params;
    Type type;
    Node[] fn_body;
}

struct Node {
    NodeKind kind;
    union {
        Token token_data;
        FnDecl func;
        Node[] program;
        VarBind binding;
        BinaryOp binop;
        UnaryOp unop;
    }
}
