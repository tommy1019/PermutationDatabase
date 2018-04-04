import PerfectHTTP
import PerfectMySQL

import Foundation

func methodInfoHandler (request: HTTPRequest, response: HTTPResponse)
{
    let name = request.param(name: "name")

    let mysql = SQLPool.getConnection()

    let requestSuccess = mysql.0.query(statement: "SELECT name, description FROM permutation.method WHERE name = '\(name!)';")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Method Info"))

    response.appendBody(string: "<br><h2>Method Description</h2>")

    if !requestSuccess
    {
        response.appendBody(string: "<h3>Error requesting data from the database</h3><br><h5>\(mysql.0.errorMessage())</h5>")
    }

    if requestSuccess
    {
        let results = mysql.0.storeResults()

        results?.forEachRow
        {
            row in

            response.appendBody(string: "<h1>\(row[0]!)</h1><br>")
            response.appendBody(string: "<p>\(row[1]!)</p>")
        }
    }

    SQLPool.returnConnection(mysql.1)

    response.appendBody(string: HTMLConstants.footer)

    response.completed()
}
