#include <csignal>
#include <memory>
#include <mutex>
#include <stdexcept>

#include "oatpp/network/Server.hpp"
#include "oatpp/network/tcp/server/ConnectionProvider.hpp"
#include "oatpp/web/protocol/http/Http.hpp"
#include "oatpp/web/protocol/http/outgoing/ResponseFactory.hpp"
#include "oatpp/web/protocol/http/outgoing/StreamingBody.hpp"
#include "oatpp/web/server/HttpConnectionHandler.hpp"
#include "oatpp/web/server/HttpRequestHandler.hpp"
#include "oatpp/data/stream/FileStream.hpp"

#include "dinteroper.h"
#include "statusMap.h"
using namespace std;
using namespace oatpp::web::protocol::http::outgoing;

unique_ptr<oatpp::network::Server> serv;

unique_ptr<DSite> site;
mutex site_lock;

const char* const PAGE =
"<!DOCTYPE HTML><html><head><title>oatpp</title></head><body><h1>Hello from oatpp</h1><p><img src=\"/cat.jpg\"></p></body></html>";

void sighandler(int signal) { serv->stop(); }

class Handler : public oatpp::web::server::HttpRequestHandler {
public:
    std::shared_ptr<OutgoingResponse> handle(const std::shared_ptr<IncomingRequest> &request) override {
        string url = "/" + request->getPathTail();
        vector<pair<string, string>> headers;
        for (auto h : request->getHeaders().getAll())
            headers.emplace_back(h.first.toString(), h.second.toString());
        site_lock.lock();
        auto optResponse = site->Request(url, headers);
        site_lock.unlock();
        if (!optResponse) {
            auto resp = oatpp::web::protocol::http::outgoing::ResponseFactory::createResponse(Status::CODE_500,
                                                                                              "Internal server error");
            resp->putHeader("Content-Type", "text/plain");
            return resp;
        }
        auto& response = optResponse.value();
        shared_ptr<OutgoingResponse> res;
        const Status* pstatus = nullptr;
        if (response.StatusCode >= 0 && response.StatusCode < sizeof(IntToStatus) / sizeof(IntToStatus[0]))
            pstatus = IntToStatus[response.StatusCode];
        Status status = pstatus ? *pstatus : Status::CODE_400;
        if (!pstatus)
            cerr << "D returned status code " << response.StatusCode << ", replacing with 400" << endl;
        if (response.IsInPlace)
            res = ResponseFactory::createResponse(status, response.Document);
        else
            res = make_shared<OutgoingResponse>(
                status, make_shared<StreamingBody>(
                            make_shared<oatpp::data::stream::FileInputStream>(response.Document.c_str())));
        res->putHeader("Content-Type", response.MIME);
        return res;
    }
};

void run() {
    auto router = oatpp::web::server::HttpRouter::createShared();
    router->route("GET", "/*", make_shared<Handler>());
    auto connectionHandler = oatpp::web::server::HttpConnectionHandler::createShared(router);
    auto connectionProvider = oatpp::network::tcp::server::ConnectionProvider::createShared(
        {site->Host(), site->Port(), oatpp::network::Address::IP_4});
    serv = make_unique<oatpp::network::Server>(connectionProvider, connectionHandler);

    OATPP_LOGi("dsite", "Server running on port {}", connectionProvider->getProperty("port").toString());
    serv->run();
    OATPP_LOGi("dsite", "Server stopped");
}

int main() {
    signal(SIGINT, sighandler);
    signal(SIGQUIT, sighandler);
    signal(SIGTERM, sighandler);

    try {
        site = make_unique<DSite>("site.d");
    } catch (runtime_error err) {
        cerr << err.what() << endl;
        return -1;
    }

    oatpp::Environment::init();
    run();
    oatpp::Environment::destroy();
}
