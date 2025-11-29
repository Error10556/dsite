#include "oatpp/web/server/HttpConnectionHandler.hpp"

#include "oatpp/network/Server.hpp"
#include "oatpp/network/tcp/server/ConnectionProvider.hpp"
#include <csignal>
using namespace std;

unique_ptr<oatpp::network::Server> serv;

void sighandler(int signal) {
    serv->stop();
}

void run() {

  /* Create Router for HTTP requests routing */
  auto router = oatpp::web::server::HttpRouter::createShared();

  /* Create HTTP connection handler with router */
  auto connectionHandler = oatpp::web::server::HttpConnectionHandler::createShared(router);

  /* Create TCP connection provider */
  auto connectionProvider = oatpp::network::tcp::server::ConnectionProvider::createShared({"localhost", 8000, oatpp::network::Address::IP_4});

  /* Create server which takes provided TCP connections and passes them to HTTP connection handler */
  serv = make_unique<oatpp::network::Server>(connectionProvider, connectionHandler);

  /* Print info about server port */
  OATPP_LOGi("MyApp", "Server running on port {}", connectionProvider->getProperty("port").toString());

  /* Run server */
  serv->run();
  OATPP_LOGi("MyApp", "Server stopped");
}

int main() {

    signal(SIGINT, sighandler);

  /* Init oatpp Environment */
  oatpp::Environment::init();

  /* Run App */
  run();

  /* Destroy oatpp Environment */
  oatpp::Environment::destroy();

  return 0;

}
