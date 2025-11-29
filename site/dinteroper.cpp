#include "dinteroper.h"
#include <dinterp/complog/CompilationLog.h>
#include <dinterp/complog/CompilationMessage.h>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <dinterp/lexer.h>
#include <dinterp/syntax.h>
#include <dinterp/semantic.h>
#include <dinterp/semantic/valueTimeline.h>
#include <dinterp/semantic/statementChecker.h>
#include <dinterp/interp.h>
using namespace std;
using namespace dinterp;
using namespace complog;
using namespace ast;
using namespace interp;

Response::Response(int statuscode, std::string document, std::string mime, bool isInPlace)
    : StatusCode(statuscode), Document(document), MIME(mime), IsInPlace(isInPlace) {}

bool SemanticAnalysis(const std::shared_ptr<ast::Body>& program, ICompilationLog& log) {
    semantic::ValueTimeline tl;
    tl.StartScope();
    {
        auto zeroLoc = locators::SpanLocator(program->pos.File(), 0, 0);
        tl.Declare("host", zeroLoc);
        tl.Declare("port", zeroLoc);
        tl.Declare("handle", zeroLoc);
    }
    semantic::StatementChecker chk(log, tl, false, false);
    program->AcceptVisitor(chk);

    return chk.Terminated() != semantic::StatementChecker::TerminationKind::Errored;
}

void ReportError(const RuntimeState::Throwing& error) {
    error.StackTrace.WriteToStream(cerr);
    cerr << "\nAt " << error.Position.Pretty() << ":\n";
    error.Position.WritePrettyExcerpt(cerr, 100);
    cerr << "\n" << error.Error.what() << endl;
}

DSite::DSite(std::string filename) {
    StreamingCompilationLog log(cerr, CompilationMessage::FormatOptions::All(80), Severity::Info());
    shared_ptr<const locators::CodeFile> file;
    {
        ifstream fs(filename);
        if (!fs) throw std::runtime_error("Cannot open program file");
        stringstream contents;
        contents << fs.rdbuf();
        fs.close();
        file = make_shared<locators::CodeFile>(filename, contents.str());
    }
    auto optTokens = Lexer::tokenize(file, log, true);
    if (!optTokens) throw runtime_error("Lexical error");
    auto optProg = SyntaxAnalyzer::analyze(*optTokens, file, log);
    if (!optProg) throw std::runtime_error("Syntax error");
    auto& prog = *optProg;
    if (!SemanticAnalysis(prog, log)) throw std::runtime_error("Semantic error");

    auto scopes = make_shared<ScopeStack>();
    auto varHost = make_shared<Variable>("host", make_shared<runtime::NoneValue>());
    auto varPort = make_shared<Variable>("port", make_shared<runtime::NoneValue>());
    auto varHandle = make_shared<Variable>("handle", make_shared<runtime::NoneValue>());
    scopes->Declare(varHost);
    scopes->Declare(varPort);
    scopes->Declare(varHandle);
    istringstream input;
    RuntimeContext context(input, cout, 1000, 20);
    Executor exec(context, scopes);
    prog->AcceptVisitor(exec);
    if (context.State.IsThrowing()) {
        ReportError(context.State.GetError());
        throw runtime_error("Runtime initialization error");
    }
    auto valHost = varHost->Content();
    auto strObj = dynamic_pointer_cast<runtime::StringValue>(valHost);
    if (!strObj)
        throw runtime_error("\"host\" must be a string, but got \"" + valHost->TypeOfValue()->Name() + "\"");
    host = strObj->Value();
    auto valPort = varPort->Content();
    auto intObj = dynamic_pointer_cast<runtime::IntegerValue>(valPort);
    if (!intObj)
        throw runtime_error("\"port\" must be an integer, but got \"" + valPort->TypeOfValue()->Name() + "\"");
    auto bigport = intObj->Value();
    if (bigport > 65535 || bigport < 0) throw runtime_error("Port " + bigport.ToString() + " is not a uint16");
    port = bigport.ClampToLong();
    auto valHandle = varHandle->Content();
    func = dynamic_pointer_cast<runtime::Closure>(valHandle);
    if (!func)
        throw runtime_error("\"handle\" must be a user-defined function, but got \"" + valHandle->TypeOfValue()->Name() +
                            "\"");
    if (func->FunctionType()->ArgTypes()->size() != 2)
        throw runtime_error("The handle function must accept 2 arguments: the url and header key-value list");
}

std::optional<Response> DSite::Request(const std::string& url,
                                const std::vector<std::pair<std::string, std::string>>& headers) {
    using namespace runtime;
    istringstream input;
    RuntimeContext context(input, cout, 1000, 20);
    vector<shared_ptr<RuntimeValue>> headerTuples(headers.size());
    ranges::transform(headers, headerTuples.begin(), [](const pair<string, string>& kv) -> shared_ptr<RuntimeValue> {
        auto key = make_shared<StringValue>(kv.first);
        auto value = make_shared<StringValue>(kv.second);
        return make_shared<TupleValue>(
            vector<pair<optional<string>, shared_ptr<RuntimeValue>>>{{"key", key}, {"value", value}});
    });
    auto res = func->UserCall(context, {make_shared<StringValue>(url), make_shared<ArrayValue>(headerTuples)});
    if (context.State.IsThrowing()) {
        ReportError(context.State.GetError());
        return {};
    }
    auto tuple = dynamic_pointer_cast<TupleValue>(res);
    if (!tuple) {
        cerr << "The returned value was not a tuple (was \"" << res->TypeOfValue()->Name() << "\")" << endl;
        return {};
    }
    auto vals = tuple->Values();
    if (vals.size() != 4) {
        cerr << "The returned tuple contained " << vals.size() << " values, but 4 were expected" << endl;
        return {};
    }
    auto code = dynamic_pointer_cast<IntegerValue>(vals[0]);
    auto str = dynamic_pointer_cast<StringValue>(vals[1]);
    auto mime = dynamic_pointer_cast<StringValue>(vals[2]);
    auto isheredoc = dynamic_pointer_cast<BoolValue>(vals[3]);
    if (!code || !str || !mime || !isheredoc) {
        cerr << "The returned tuple consisted of {\"" << vals[0]->TypeOfValue()->Name() << "\", \""
             << vals[0]->TypeOfValue()->Name() << "\", \"" << vals[0]->TypeOfValue()->Name() << "\", \""
             << vals[0]->TypeOfValue()->Name() << "\"}, but expected {\"int\", \"string\", \"string\", \"bool\"}."
             << endl;
        return {};
    }
    return {{ static_cast<int>(code->Value().ClampToLong()), str->Value(), mime->Value(), isheredoc->Value() }};
}

std::string DSite::Host() const {
    return host;
}

uint16_t DSite::Port() const {
    return port;
}
