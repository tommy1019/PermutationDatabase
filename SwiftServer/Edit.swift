import PerfectHTTP
import PerfectMySQL

func editHandler (request: HTTPRequest, response: HTTPResponse)
{
    let id = request.param(name: "id")?.intValue

    let pass = request.param(name: "pass")
    let m = request.param(name: "m")?.longValue
    let author = request.param(name: "author")
    let method = request.param(name: "method")
    let verified = request.param(name: "verified", defaultValue: "off")?.boolValue

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Delete"))

    if let id = id
    {
        if let pass = pass, pass == HTMLConstants.password, let m = m, let author = author, let method = method, let verified = verified
        {
            let mysql = SQLPool.getConnection()
            let requestSuccess = mysql.0.query(statement: "UPDATE result SET m='\(m)', author='\(author)', method='\(method)', verified='\(verified ? 1 : 0)' WHERE id = \(id)")

            if requestSuccess
            {
                response.appendBody(string: "<br><h1>Updated permutation</h1><br><h2><a href=\"index.php\">Home</a></h2>")
            }
            else
            {
                response.appendBody(string: "<br><h1>Error: no result exists at that id</h1><br><h2><a href=\"index.php\">Home</a></h2>")
                response.appendBody(string: "\(mysql.0.errorMessage())")
            }

            SQLPool.returnConnection(mysql.1)
        }
        else
        {
            let mysql = SQLPool.getConnection()
            let requestSuccess = mysql.0.query(statement: "SELECT result.id, result.n, result.d, result.m, result.verified, author.name, method.name FROM result LEFT JOIN method ON result.method = method.id LEFT JOIN author ON result.author = author.id WHERE result.id = \(id);")

            if requestSuccess, let res = mysql.0.storeResults(), res.numRows() == 1
            {
                response.appendBody(string: "<br><h1>Editing Permutation</h1><br><br>")

                response.appendBody(string: "<form>")

                let row  = res.next()!

                response.appendBody(string: "<br><h3>M(\(row[1] ?? ""), \(row[2] ?? "")) = <input type='text' name='m' value='\(row[3] ?? "")'</h3>")

                let aMysql = SQLPool.getConnection()

                var methods = "<select name=\"method\">"
                if aMysql.0.query(statement: "SELECT name, id FROM method;")
                {
                    let results = aMysql.0.storeResults()!
                    results.forEachRow
                        {
                            mRow in

                            let method = mRow.first!!
                            let mId = mRow[1]?.intValue ?? -1

                            methods += "<option value=\"\(mId)\" \(method == row[6] ? "selected" : "")>\(method)</option>"
                    }

                    methods += "</select>"
                }
                else
                {
                    methods = "<input type=\"text\" name=\"method\" style=\"width:125px;\">"
                }

                response.appendBody(string: "<h3><input type='checkbox' name='verified' value='\(row[4] == "0" ? "off" : "on")'>Verified, Using method: \(methods)</h3>")

                var authors = "<select name=\"author\">"
                if aMysql.0.query(statement: "SELECT name, id FROM author;")
                {
                    let results = aMysql.0.storeResults()!
                    results.forEachRow
                        {
                            aRow in

                            let author = aRow.first!!
                            let aId = aRow[1]?.intValue ?? -1

                            authors += "<option value=\"\(aId)\" \(author == row[5] ? "selected" : "")>\(author)</option>"
                    }

                    authors += "</select>"
                }
                else
                {
                    authors = "<input type=\"text\" name=\"author\" style=\"width:125px;\">"
                }

                SQLPool.returnConnection(aMysql.1)

                response.appendBody(string: "<h3>Author: \(authors)</h3>")

                response.appendBody(string: "<br><h4>Enter password to edit</h4>")

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
                response.appendBody(string: "<br><h1>Error: no result exists at that id</h1><br><h2><a href=\"index.php\">Home</a></h2>")
            }

            SQLPool.returnConnection(mysql.1)
        }
    }
    else
    {
        response.appendBody(string: "<br><h1>Error: no result specified to edit.</h1><br><h2><a href=\"index.php\">Home</a></h2>")
    }

    response.appendBody(string: HTMLConstants.footer)
    response.completed()
}

