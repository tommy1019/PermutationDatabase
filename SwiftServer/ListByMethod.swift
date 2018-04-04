import PerfectHTTP
import PerfectMySQL

func listMethodHTMLFourm() -> String
{
    var methods = "<select name=\"method\">"

    let mysql = SQLPool.getConnection()

    if mysql.0.query(statement: "SELECT name FROM method;")
    {
        let results = mysql.0.storeResults()!
        results.forEachRow
            {
                row in

                let method = row.first!!

                methods += "<option value=\"\(method)\">\(method)</option>"
        }

        methods += "</select>"
    }
    else
    {
        methods = "<input type=\"text\" name=\"method\" style=\"width:125px;\">"
    }

    SQLPool.returnConnection(mysql.1)

    return """
    <form>
    <fieldset>
    Method: \(methods)  <input type="submit" value="Submit">
    </fieldset>
    </form>
    """
}

func listByMethodHandler (request: HTTPRequest, response: HTTPResponse)
{
    let method = request.param(name: "method")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Permutation Info"))

    if let method = method
    {
        let mysql = SQLPool.getConnection()

        let requestSuccess = mysql.0.query(statement: "SELECT result.n, result.d, result.m, result.verified, author.name, method.name FROM result LEFT JOIN method ON result.method = method.id LEFT JOIN author ON result.author = author.id WHERE method.name = \"\(method)\";")

        response.appendBody(string: "<br><h1>Results for \(method)</h1>")

        if requestSuccess
        {
            let results = mysql.0.storeResults()

            response.appendBody(string: "<a href=\"listMethod.php\">Back</a><br><br>")
            response.appendBody(string: "<table>")

            response.appendBody(string: "<tr><th>N</th><th>D</th><th>M(n,d)</th><th>Verified</th><th>Author</th><th>Type</th></tr>")

            results?.forEachRow
                {
                    row in

                    response.appendBody(string: "<tr>")

                    response.appendBody(string: "<td>\(row[0] ?? "")</td>")
                    response.appendBody(string: "<td>\(row[1] ?? "")</td>")
                    response.appendBody(string: "<td><a href=\"info.php?n=\(row[0]?.intValue ?? 0)&d=\(row[0]?.intValue ?? 0)\">\(row[2] ?? "")</a></td>")
                    response.appendBody(string: "<td>\(row[3] ?? "")</td>")
                    response.appendBody(string: "<td>\(row[4] ?? "")</td>")

                    response.appendBody(string: "<td><a href=\"methodInfo.php?name=\(row[5] ?? "")\">\(row[5] ?? "")</a></td>")

                    response.appendBody(string: "</tr>")
            }

            response.appendBody(string: "</table>")
        }
        else
        {
            response.appendBody(string: "<h3>Error requesting data from the database</h3><br><h5>\(mysql.0.errorMessage())</h5>")
        }

        SQLPool.returnConnection(mysql.1)
    }
    else
    {
        response.appendBody(string:  listMethodHTMLFourm())
    }

    response.appendBody(string: HTMLConstants.footer)
    response.completed()
}
