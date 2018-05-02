import PerfectHTTP
import PerfectMySQL

import Foundation

func getAddHTMLFourm(_ pass : String?) -> String
{
    var authors = "<select name=\"author\">"
    var methods = "<select name=\"method\">"

    let mysql = SQLPool.getConnection()

    if mysql.0.query(statement: "SELECT name FROM author;")
    {
        let results = mysql.0.storeResults()!
        results.forEachRow
            {
                row in

                let author = row.first!!

                authors += "<option value=\"\(author)\">\(author)</option>"
        }

        authors += "</select>"
    }
    else
    {
        authors = "<input type=\"text\" name=\"author\" style=\"width:125px;\">"
    }

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
    N: <input type="text" name="n" style="width:50px;"> D: <input type="text" name="d" style="width:50px;"><br>
    M: <input type="text" name="m" style="width:150px;"><br>
    Author: \(authors)<br>
    Method: \(methods)<br>
    Verified <input name="verified" type="checkbox"><br>
    Password: \(pass != nil ? "<font color=\"red\">Incorrect password.</font><br>" : "")<input type='password' name='pass'><br>
    <input type="submit" value="Submit">
    </fieldset>
    </form>
    """
}

let addAuthorHtmlForum = """
<form>
<fieldset>
Name: <input type="text" name="name" style="width:150px;"><br>
Password: <input type='password' name='pass'><br>
<input type="submit" value="Submit">
</fieldset>
</form>
"""

let addMethodHtmlForum = """
<form>
<fieldset>
Name: <input type="text" name="name" style="width:150px;"><br>
Description: <input type="text" name="description" style="width:300px;"><br>
Password: <input type='password' name='pass'><br>
<input type="submit" value="Submit">
</fieldset>
</form>
"""

func addHandler (request: HTTPRequest, response: HTTPResponse)
{
    let n = request.param(name: "n")?.intValue
    let d = request.param(name: "d")?.intValue
    let m = request.param(name: "m")?.longValue
    let author = request.param(name: "author")
    let method = request.param(name: "method")
    let verified = request.param(name: "verified", defaultValue: "off")?.boolValue
    let pass = request.param(name: "pass")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Add Result"))

    let mysql = SQLPool.getConnection()

    if  let n = n,
        let d = d,
        let m = m,
        let author = author,
        let method = method,
        let verified = verified,
        let pass = pass,
        pass == HTMLConstants.password
    {
        var authorFound = mysql.0.query(statement: "SELECT id FROM author WHERE name = '\(author)';")
        var authorId = -1
        if authorFound
        {
            authorFound = false
            let results = mysql.0.storeResults()!
            results.forEachRow
                {
                    row in
                    authorId = Int(row.first!!)!
                    authorFound = true
            }
        }
        else
        {
            response.appendBody(string: "<h3>Error: Invaild author string</h3>")
        }

        var methodFound = mysql.0.query(statement: "SELECT id FROM method WHERE name = '\(method)';")
        var methodId = -1
        if methodFound
        {
            methodFound = false
            let results = mysql.0.storeResults()!
            results.forEachRow
                {
                    row in
                    methodId = Int(row.first!!)!
                    methodFound = true
            }
        }
        else
        {
            response.appendBody(string: "<h3>Error: Invaild method string</h3>")
        }

        if authorFound && methodFound
        {
            let addSuccess = mysql.0.query(statement: """
                INSERT INTO result (n, d, m, verified, method, author)
                VALUES ('\(n)', '\(d)', '\(m)', '\(verified ? "1" : "0")', '\(methodId)', '\(authorId)');
                """)

            if addSuccess
            {
                response.appendBody(string: "<h1>Data Inputted</h1><br><h3 href=\"add\">Add More</h3>")
            }
            else
            {
                response.appendBody(string: "<h3>Error: adding</h3><br><h5>\(mysql.0.errorMessage())</h5>")
            }
        }
        else
        {
            if !authorFound
            {
                response.appendBody(string: "<h3>Error: No author found by that name</h3>")
            }

            if !methodFound
            {
                response.appendBody(string: "<h3>Error: No method found by that name</h3>")
            }
        }
    }
    else
    {
        response.appendBody(string: getAddHTMLFourm(pass))
    }

    SQLPool.returnConnection(mysql.1)

    response.appendBody(string: HTMLConstants.footer)
    response.completed()
}

func addAuthorHandler (request: HTTPRequest, response: HTTPResponse)
{
    let author = request.param(name: "name")
    let pass = request.param(name: "pass")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Add Author"))

    if  let name = author,
        let pass = pass,
        pass == HTMLConstants.password
    {
        let mysql = SQLPool.getConnection()

        let addSuccess = mysql.0.query(statement: """
            INSERT INTO author (name)
            VALUES ('\(name)');
            """)

        if addSuccess
        {
            response.appendBody(string: "<h1>Data Inputted</h1><br><a href=\"addAuthor.php\">Add More</a>")
        }
        else
        {
            response.appendBody(string: "<h3>Error: adding</h3><br><h5>\(mysql.0.errorMessage())</h5>")
        }

        SQLPool.returnConnection(mysql.1)
    }
    else
    {
        response.appendBody(string: addAuthorHtmlForum)
        response.appendBody(string: "\(pass != nil ? "<font color=\"red\">Incorrect password.</font><br>" : "")")
    }

    response.appendBody(string: HTMLConstants.footer)

    response.completed()
}

func addMethodHandler (request: HTTPRequest, response: HTTPResponse)
{
    let name = request.param(name: "name")
    let description = request.param(name: "description")
    let pass = request.param(name: "pass")

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Add Method"))

    if  let name = name,
        let description = description,
        let pass = pass,
        pass == HTMLConstants.password
    {
        let mysql = SQLPool.getConnection()

        let addSuccess = mysql.0.query(statement: """
            INSERT INTO method (name, description)
            VALUES ('\(name)', '\(description)');
            """)

        if addSuccess
        {
            response.appendBody(string: "<h1>Data Inputted</h1><br><a href=\"addMethod\">Add More</a>")
        }
        else
        {
            response.appendBody(string: "<h3>Error: adding</h3><br><h5>\(mysql.0.errorMessage())</h5>")
        }

        SQLPool.returnConnection(mysql.1)
    }
    else
    {
        response.appendBody(string: addMethodHtmlForum)
        response.appendBody(string: "\(pass != nil ? "<font color=\"red\">Incorrect password.</font><br>" : "")")
    }

    response.appendBody(string: HTMLConstants.footer)

    response.completed()
}
