import PerfectHTTP
import PerfectMySQL

func deleteHandler (request: HTTPRequest, response: HTTPResponse)
{
    let id = request.param(name: "id")?.intValue
    let pass = request.param(name: "pass")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Delete"))

    if let id = id
    {
        if let pass = pass, pass == HTMLConstants.password
        {
            let mysql = SQLPool.getConnection()
            let requestSuccess = mysql.0.query(statement: "DELETE FROM result WHERE id = \(id)")

            if requestSuccess
            {
                response.appendBody(string: "<br><h1>Deleted permutation</h1><br><h2><a href=\"index.php\">Home</a></h2>")
            }
            else
            {
                response.appendBody(string: "<br><h1>Error: no result exists at that id, perhaps it is already deleted.</h1><br><h2><a href=\"index.php\">Home</a></h2>")
            }
        }
        else
        {
            let mysql = SQLPool.getConnection()
            let requestSuccess = mysql.0.query(statement: "SELECT result.id, result.n, result.d, result.m, result.verified, author.name, method.name FROM result LEFT JOIN method ON result.method = method.id LEFT JOIN author ON result.author = author.id WHERE result.id = \(id);")

            if requestSuccess, let res = mysql.0.storeResults(), res.numRows() == 1
            {
                response.appendBody(string: "<br><h1>Deleting Permutation</h1><br><br>")

                let row  = res.next()!

                response.appendBody(string: "<br><h3>M(\(row[1] ?? ""), \(row[2] ?? "")) = \(row[3] ?? "")</h3>")
                response.appendBody(string: "<h3>\(row[4] == "0" ? "Not " : "")Verified, Using method: \(row[6] ?? "")</h3>")
                response.appendBody(string: "<h3>Author: \(row[5] ?? "")</h3>")

                response.appendBody(string: "<br><h4>Enter password to delete</h4>")
                response.appendBody(string: "<form>")
                if pass != nil
                {
                    response.appendBody(string: "<font color=\"red\">Incorrect password.</font><br>")
                }
                response.appendBody(string: "<input type=\"password\" name=\"pass\">")
                response.appendBody(string: "<input type=\"hidden\" name=\"id\" value=\"\(id)\">")
                response.appendBody(string: "<input type=\"submit\">")
                response.appendBody(string: "</form>")
            }
            else
            {
                response.appendBody(string: "<br><h1>Error: no result exists at that id, perhaps it is already deleted.</h1><br><h2><a href=\"index.php\">Home</a></h2>")
            }
        }
    }
    else
    {
        response.appendBody(string: "<br><h1>Error: no result specified to delete.</h1><br><h2><a href=\"index.php\">Home</a></h2>")
    }

    response.appendBody(string: HTMLConstants.footer)
    response.completed()
}
