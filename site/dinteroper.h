#pragma once
#include <dinterp/interp/closure.h>

struct Response {
public:
    Response(int statuscode, std::string document, std::string mime, bool isInPlace);
    int StatusCode;
    std::string Document;
    std::string MIME;
    bool IsInPlace;
};

class DSite {
    std::string host;
    uint16_t port;
    std::shared_ptr<dinterp::runtime::Closure> func;

public:
    DSite(std::string filename);
    std::optional<Response> Request(const std::string& url,
                                    const std::vector<std::pair<std::string, std::string>>& headers);
    std::string Host() const;
    uint16_t Port() const;
};
