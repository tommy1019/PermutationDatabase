import PerfectHTTP
import PerfectMySQL

func infoHandler (request: HTTPRequest, response: HTTPResponse)
{
    let n = Int(request.param(name: "n", defaultValue: "1")!)!
    let d = Int(request.param(name: "d", defaultValue: "1")!)!
    let delta = n - d

    let mysql = SQLPool.getConnection()

    let requestSuccess = mysql.0.query(statement: "SELECT result.n, result.d, result.m, result.verified, author.name, method.name FROM result LEFT JOIN method ON result.method = method.id LEFT JOIN author ON result.author = author.id WHERE result.n = \(n) AND result.d = \(d);")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Permutation Info"))

    response.appendBody(string: "<form>")
    response.appendBody(string: "<br><h1>Results for M(<input type=\"text\" name=\"n\" value=\"\(n)\" size=\"8\">, <input type=\"text\" name=\"d\" value=\"\(d)\" size=\"8\">)</h1>")
    response.appendBody(string: "<input type=\"submit\">")
    response.appendBody(string: "</form>")
    response.appendBody(string: "<h3>M(\(n), \(n)-\(delta))</h3><br><br>")

    if !requestSuccess
    {
        response.appendBody(string: "<h3>Error requesting data from the database</h3><br><h5>\(mysql.0.errorMessage())</h5>")
    }

    if requestSuccess
    {
        let results = mysql.0.storeResults()

        response.appendBody(string: "<table>")

        response.appendBody(string: "<tr><th>N</th><th>D</th><th>M(n,d)</th><th>Verified</th><th>Author</th><th>Type</th></tr>")

        results?.forEachRow
        {
            row in

            response.appendBody(string: "<tr>")
            for i in 0...4
            {
                response.appendBody(string: "<td>\(row[i] ?? "")</td>")
            }

            response.appendBody(string: "<td><a href=\"methodInfo.php?name=\(row[5] ?? "")\">\(row[5] ?? "")</a></td>")

            response.appendBody(string: "</tr>")
        }

        response.appendBody(string: "</table>")
    }

    SQLPool.returnConnection(mysql.1)

    response.appendBody(string: HTMLConstants.footer)

    response.completed()
}
