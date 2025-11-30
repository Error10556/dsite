var stringReplace := func(from, to, s) => to.Join(s.Split(from))

var digitToStr := func(n) is
        if n = 1 => return "1"
        if n = 2 => return "2"
        if n = 3 => return "3"
        if n = 4 => return "4"
        if n = 5 => return "5"
        if n = 6 => return "6"
        if n = 7 => return "7"
        if n = 8 => return "8"
        if n = 9 => return "9"
        return "0"
    end,
    intToStr := func(n) is
        var res := ""
        while n > 0 loop
            var nextn := n / 10,
                digit := n - nextn * 10
            res := digitToStr(digit) + res
            n := nextn
        end
        return res
    end

var SITENAME_EN := "The D language",
    SITENAME_RU := "Язык D",
    PAGE_NOT_FOUND_EN := "Page Not Found",
    PAGE_NOT_FOUND_RU := "Страница не найдена",
    page_not_found := func(rus) is
        if rus => return PAGE_NOT_FOUND_RU
        return PAGE_NOT_FOUND_EN
    end,
    TAG_HEAD_EN := "<head><title>" + SITENAME_EN + "</title><link rel=\"stylesheet\" type=\"text/css\" href=\"/css.css\"></head>",
    TAG_HEAD_RU := "<head><title>" + SITENAME_RU + "</title><link rel=\"stylesheet\" type=\"text/css\" href=\"/css.css\"></head>",
    tag_head := func(rus) is
        if rus => return TAG_HEAD_RU
        return TAG_HEAD_EN
    end

var PURPOSE_EN := ("<h3>What is the <span style=\"font-family: serif; font-size: 110%\">D</span> language?</h3>" +
    "<p>It is a dynamically typed, interpreted toy language developed as a Compiler Construction course project. " +
    "The purpose of the present site is to show off the language capabilities.</p>")
var PURPOSE_RU := ("<h3>Язык программирования <span style=\"font-family: serif; font-size: 110%\">D</span>?</h3>" +
    "<p>Это динамически типизированный интерпретируемый \"игрушечный\" язык программирования, разработанный как " +
    "курсовой проект по построению компиляторов. Цель этого сайта &mdash; показать возможности языка.</p>")

var SITELINKS_EN := ("<h3>Site</h3><p>This site is available in Russian! " +
    "Change your browser settings to get served pages in Russian.</p>" +
    "<p><a href=\"/mirror\">Doxx my IP</a></p><p><a href=\"/counter\">Clicker</a></p>")
var SITELINKS_RU := ("<h3>Сайт</h3><p>Этот сайт поддерживает английский язык! " +
        "Настройте язык браузера, чтобы получать страницы на английском.</p>" +
        "<p><a href=\"/mirror\">Вычисли меня по IP</a></p><p><a href=\"/counter\">Кликер</a></p>")

var EXTLINKS_EN := ("<h3>Links</h3>" +
    "<p>(GitHub) <a href=\"https://github.com/Error10556/d-interpreter\">The language repository</a></p>" +
    "<p>(GitHub) <a href=\"https://github.com/Error10556/dsite\">The site repository</a></p>")
var EXTLINKS_RU := ("<h3>Ссылки</h3>" +
    "<p>(GitHub) <a href=\"https://github.com/Error10556/d-interpreter\">Исходный код языка</a></p>" +
    "<p>(GitHub) <a href=\"https://github.com/Error10556/dsite\">Исходный код сайта</a></p>")

var DEVELOPERS_STYLES := ("<style>.authorbox{display:flex;flex-direction:column;justify-content:top;text-align:center;align-items:center;}" +
".authorbox p{margin:0;}.authorbox img{width:60%;padding:1cm;box-sizing:border-box;margin:0;}" +
".authorname{font-size:200%;font-weight:bold;}</style>")

var DEVS_CONTAINER_OPEN := "<div style=\"display: grid; grid-template-columns: repeat(2, 1fr); width: 100%\">" 

var render_dev := func(photo, name, roles) is
    var res := "<div class=\"authorbox\"><img src=\"" + photo + "\"><p class=\"authorname\">" + name + "</p>"
    for i in roles loop
        res := res + ("<p>" + i + "</p>")
    end
    return res + "</div>"
end

var DEVS_EN := ("<h3>Developers</h3>" + DEVELOPERS_STYLES + DEVS_CONTAINER_OPEN + render_dev("/timur.jpg", "Timur Usmanov",
["Lead developer", "Subsystem designer", "Algorithm designer", "Build system DevOps", "Quality Assurance",
"Fullstack website creator"]) + render_dev("/gleb.jpg", "Gleb Popov", ["General developer", "Quality Assurance",
"Presentation designer"]) + "</div>")
var DEVS_RU := ("<h3>Разработчики</h3>" + DEVELOPERS_STYLES + DEVS_CONTAINER_OPEN + render_dev("/timur.jpg", "Усманов Тимур",
["Ведущий разработчик", "Проектировщик подсистем", "Проектировщик алгоритмов", "Оператор системы сборки", "Контроль качества",
"Фулстек-разработчик сайта"]) + render_dev("/gleb.jpg", "Попов Глеб", ["Разработчик", "Контроль качества",
"Дизайнер презентаций"]) + "</div>")

var LANG_DESIGNER_EN := ("<h3>Language Designer</h3>" +
stringReplace("authorbox\"", "authorbox\" style=\"width: 60%; align-self: center;\"",
render_dev("/zouev.jpg", "Eugene Zouev", ["Language designer", "Quality expert", "Course professor"])))
var LANG_DESIGNER_RU := ("<h3>Проектировщик языка программирования</h3>" +
stringReplace("authorbox\"", "authorbox\" style=\"width: 60%; align-self: center;\"",
render_dev("/zouev.jpg", "Евгений Зуев", ["Проектировщик языка", "Жюри качества", "Профессор курса"])))

var render_badges := func(badges) is
    var res := "<footer><div class=\"badgesection\">"
    for i in badges loop
        res := res + "<div class=\"badge\"><img src=\"/badge/" + i + ".png\"></div>"
    end
    return res + "</div></footer>"
end

var BADGES_FULL := render_badges(["organic", "linux", "cmake", "cpp20", "docker", "gtest", "neovim", "nginx", "oatpp",
                                 "krita"]),
    BADGES_SHORT := render_badges(["organic", "linux"])

var render_page := func(rus, body) => "<!DOCTYPE HTML><html>" + tag_head(rus) + "<body>" + body + "</body></html>"

var INDEX_EN := render_page(false,
"<h2>This website is powered by</h2><h1>The <span style=\"font-family:serif;font-size:110%\">D</span> language</h1>" +
PURPOSE_EN + SITELINKS_EN + EXTLINKS_EN + DEVS_EN + LANG_DESIGNER_EN + BADGES_FULL)
var INDEX_RU := render_page(false,
"<h2>Этот веб-сайт работает на </h2><h1>Языке <span style=\"font-family:serif;font-size:110%\">D</span></h1>" +
PURPOSE_RU + SITELINKS_RU + EXTLINKS_RU + DEVS_RU + LANG_DESIGNER_RU + BADGES_FULL)

var send_file := func(filename, mime) => { 200, filename, mime, false },
    send_404 := func(rus) => { 404, render_page(rus, "<h1>404</h1><h3><i>" + page_not_found(rus) + "</i></h3>"), "text/html", true },
    send_200 := func(rus, body) => { 200, render_page(rus, body), "text/html; charset=UTF-8", true }

var find_header := func(headername, headers) is
    for h in headers loop
        if h.key.Lower = headername => return h.value
    end
end

var accepted_languages := func(headers) is
    var optAccepted := find_header("accept-language", headers)
    if optAccepted is none => return
    var res := optAccepted.Split(",")
    for i in res.Indices loop
        res[i] := res[i].Split(";")[1]
    end
    return res
end

var determine_rus := func(headers) is
    var langs := accepted_languages(headers)
    if langs is none => return false
    for lang in langs loop
        lang := lang.Slice(1, 3, 1).Lower  // first 2 letters
        if lang = "ru" => return true
        if lang = "en" => return false
    end
    return false
end

var BACK_TO_INDEX_EN := "<p><a href=\"/\">&lt;&lt;&lt; Back to index</a></p>",
    BACK_TO_INDEX_RU := "<p><a href=\"/\">&lt;&lt;&lt; Назад на главную</a></p>",
    back_to_index := func(rus) is
        if rus => return BACK_TO_INDEX_RU
        return BACK_TO_INDEX_EN
    end

var get_ip_string := func(headers) is
    var optRes := find_header("x-real-ip", headers)
    if optRes is none => return "0.0.0.0??"
    return optRes
end

var get_user_agent_string := func(headers) is
    var optRes := find_header("user-agent", headers)
    if optRes is none => return "???"
    return optRes
end

var render_accept_languages := func(headers) is
    var langs := accepted_languages(headers)
    if langs is none => return "&em" + ";"
    var res := ""
    for lang in langs loop
        res := res + "<span class=\"lang\">" + lang + "</span>"
    end
    return res
end

var LANG_STYLE := ("<style>.lang{background:#d0d0d0;font-family:mono;font-size:110%;border-radius:1mm;" +
    "border:1px black solid;display:inline-flex;justify-content:center;min-width:15mm;margin-left:5mm;}</style>")

var MIRROR_HEADER2_EN := "<h2>is your IP address</h2>",
    MIRROR_HEADER2_RU := "<h2>это ваш IP-адрес</h2>",
    mirror_header2 := func(rus) is
        if rus => return MIRROR_HEADER2_RU
        return MIRROR_HEADER2_EN
    end,
    MORE_INFO_EN := "<h3>More information</h3>",
    MORE_INFO_RU := "<h3>Ещё информация</h3>",
    more_info := func(rus) is
        if rus => return MORE_INFO_RU
        return MORE_INFO_EN
    end,
    BROWSER_EN := "Browser",
    BROWSER_RU := "Браузер",
    user_agent := func(rus) is
        if rus => return BROWSER_RU
        return BROWSER_EN
    end,
    ACC_LANGUAGES_EN := "Browser languages",
    ACC_LANGUAGES_RU := "Языки браузера",
    acc_languages := func(rus) is
        if rus => return ACC_LANGUAGES_RU
        return ACC_LANGUAGES_EN
    end

var get_mirror := func(headers) is
    var rus := determine_rus(headers)
    var body := (back_to_index(rus) + "<h1>" + get_ip_string(headers) + "</h1>" + mirror_header2(rus) + more_info(rus) +
        LANG_STYLE + "<p><strong>" + user_agent(rus) + ":</strong> " + get_user_agent_string(headers) + "</p>" +
        "<p><strong>" + acc_languages(rus) + ":</strong>" + render_accept_languages(headers) + BADGES_SHORT)
    return send_200(rus, body)
end

var refresh_counter := 0

var PAGE_REQUEST_COUNT_EN := "<h2>This page was requested</h2><h1>{}</h1><h2>times</h2>",
    PAGE_REQUEST_COUNT_RU := "<h2>Эту страницу запросили</h2><h1>{}</h1><h2>раз</h2>",
    page_request_count := func(rus) is
        refresh_counter := refresh_counter + 1
        var template
        if rus then
            template := PAGE_REQUEST_COUNT_RU
        else
            template := PAGE_REQUEST_COUNT_EN
        end
        return stringReplace("{}", intToStr(refresh_counter), template)
    end

var refresh := func(rus) is
    if rus => return "обновить"
    return "refresh"
end

var get_counter := func(headers) is
    var rus := determine_rus(headers)
    var body := (back_to_index(rus) + page_request_count(rus) + "<div style=\"display:block;height:1in\"></div>" +
    "<h2><a href=\"/counter\">" + refresh(rus) + "</a></h2>" + BADGES_SHORT)
    return send_200(rus, body)
end

var STATICS := [
    {"/css.css", "text/css"},
    {"/timur.jpg", "image/jpeg"},
    {"/gleb.jpg", "image/jpeg"},
    {"/zouev.jpg", "image/jpeg"},
    {"/badge/organic.png", "image/png"},
    {"/badge/linux.png", "image/png"},
    {"/badge/cmake.png", "image/png"},
    {"/badge/cpp20.png", "image/png"},
    {"/badge/docker.png", "image/png"},
    {"/badge/gtest.png", "image/png"},
    {"/badge/neovim.png", "image/png"},
    {"/badge/nginx.png", "image/png"},
    {"/badge/oatpp.png", "image/png"},
    {"/badge/krita.png", "image/png"}
]

var try_handle_static := func(url) is
    for i in STATICS loop
        if i.1 = url then
            print url, " is static\n"
            return send_file("www" + url, i.2)
        end
    end
end

var get_index := func(headers) is
    if determine_rus(headers) => return send_200(true, INDEX_RU)
    return send_200(false, INDEX_EN)
end

handle := func(url, headers) is
    print url, "\n"
    url := url.Split("#")[1].Split("?")[1]
    print url, "\n"
    var stat := try_handle_static(url)
    if stat is {} => return stat
    if url = "/" or url = "/index.htm" or url = "/index.html" => return get_index(headers)
    if url = "/counter" => return get_counter(headers)
    if url = "/mirror" => return get_mirror(headers)
    return send_404(determine_rus(headers))
end

host := "0.0.0.0"
port := 3000
