import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let host = "127.0.0.1"
let user = "root"
let password = "12345q"
let db = "permutation"

let server = HTTPServer()

var routes = Routes()

routes.add(method: .get, uri: "/", handler: indexHandler)
routes.add(method: .get, uri: "/index.php", handler: indexHandler)
routes.add(method: .get, uri: "/info.php", handler: infoHandler)
routes.add(method: .get, uri: "/methodInfo.php", handler: methodInfoHandler)
routes.add(method: .get, uri: "/add.php", handler: addHandler)
routes.add(method: .get, uri: "/addAuthor.php", handler: addAuthorHandler)
routes.add(method: .get, uri: "/addMethod.php", handler: addMethodHandler)
routes.add(method: .get, uri: "/listMethod.php", handler: listByMethodHandler)

server.addRoutes(routes)
server.serverPort = 8181

do
{
    try server.start()
}
catch
{
    fatalError("\(error)")
}
