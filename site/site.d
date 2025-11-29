var SITENAME_EN := "The D language",
    SITENAME_RU := "Язык D",
    sitename := func(rus) is
        if rus => return SITENAME_RU
        return SITENAME_EN
    end,
    PAGE_NOT_FOUND_EN := "Page Not Found",
    PAGE_NOT_FOUND_RU := "Страница не найдена",
    page_not_found := func(rus) is
        if rus => return PAGE_NOT_FOUND_RU
        return PAGE_NOT_FOUND_EN
    end

var tag_title := func(rus) => "<title>" + sitename(rus) + "</title>"

var response_png := func(filename) => { 200, filename, "image/png", false },
    response_jpg := func(filename) => { 200, filename, "image/jpeg", false },
    tag_head := func(rus) => "<head>" + tag_title(rus) + "</head>",
    page := func(rus, body) => "<!DOCTYPE HTML><html>" + tag_head(rus) + "<body>" + body + "</body></html>",
    response_404 := func(rus) => { 404, page(rus, "<h1>404</h1><h3><i>" + page_not_found(rus) + "</i></h3>"),
        "text/html", true },
    response_page200 := func(rus, body) => { 200, page(rus, body), "text/html; charset=UTF-8", true }

var find_header := func(headername, headers) is
    for h in headers loop
        if h.key.Lower = headername => return h.value
    end
end

var determine_rus := func(headers) is
    var optAccepted := find_header("accept-language", headers)
    if not optAccepted is string => return false
    for entry in optAccepted.Split(";") loop
        var lang := entry.Split(",")[1]
        lang := lang.Slice(1, 3, 1).Lower
        if lang = "ru" => return true
        if lang = "en" => return false
    end
    return false
end

handle := func(url, headers) is
    if determine_rus(headers) => return response_page200(true, "<h1>Привет!</h1>")
    return response_page200(false, "<h1>Hello!</h1>")
end

host := "0.0.0.0"
port := 3000
