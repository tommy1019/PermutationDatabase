import PerfectHTTP
import PerfectMySQL

struct DoubleInt : Hashable
{
    var hashValue: Int {
        get {
            return n & d
        }
    }

    static func ==(lhs: DoubleInt, rhs: DoubleInt) -> Bool {
        return lhs.n == rhs.n && lhs.d == rhs.d
    }

    var n : Int
    var d : Int
}


func indexHandler (request: HTTPRequest, response: HTTPResponse)
{
    let lowerN = Int(request.param(name: "lowerN", defaultValue: "2")!)!
    let upperN = Int(request.param(name: "upperN", defaultValue: "10")!)!
    let lowerD = Int(request.param(name: "lowerD", defaultValue: "2")!)!
    let upperD = Int(request.param(name: "upperD", defaultValue: "10")!)!

    let mysql = SQLPool.getConnection()

    let requestSuccess = mysql.0.query(statement: "SELECT n, d, m, bgColor, txtColor FROM result JOIN method ON method = method.id WHERE result.n BETWEEN \(lowerN) AND \(upperN) AND result.d BETWEEN \(lowerD) AND \(upperD);")

    var resultMap = [DoubleInt : MySQL.Results.Element]()

    if requestSuccess
    {
        let results = mysql.0.storeResults()

        results?.forEachRow
        {
            row in

            let index = DoubleInt(n: Int(row[0]!)!, d: Int(row[1]!)!)

            if resultMap[index] == nil
            {
                resultMap[index] = row
            }
            else if Int(resultMap[index]![2]!)! < Int(row[2]!)!
            {
                resultMap[index] = row
            }
        }
    }

    response.addHeader(.contentType, value: "text/html")
    response.appendBody(string: HTMLConstants.getHeader(title: "Permutation Database"))

    let htmlFourm = """
    <form>
        <fieldset>
            n &#8712; [\(getText("lowerN", lowerN)), \(getText("upperN", upperN))] <br>
            d &#8712; [\(getText("lowerD", lowerD)), \(getText("upperD", upperD))] <br>
            <input type="submit" value="Submit">
        </fieldset>
    </form>
    <a href=\"listMethod.php\">List by Method</a><br><br>
    """
    response.appendBody(string: htmlFourm)

    if !requestSuccess
    {
        response.appendBody(string: "<h3>Error requesting data from the database</h3>")
        response.appendBody(string: "<h5>\(mysql.0.errorMessage())</h5>")
    }

    SQLPool.returnConnection(mysql.1)

    response.appendBody(string: "<table>")

    response.appendBody(string: "<tr>")
    response.appendBody(string: "<th> </th>")
    for d in lowerD ... upperD
    {
        response.appendBody(string: "<th>\(d)</th>")
    }
    response.appendBody(string: "</tr>")

    for n in lowerN ... upperN
    {
        response.appendBody(string: "<tr>")
        response.appendBody(string: "<td><b>\(n)</b></td>")
        for d in lowerD ... upperD
        {
            let curIndex = DoubleInt(n: n, d: d)
            let row = resultMap[curIndex]


            if let row = row
            {
                response.appendBody(string: "<td bgcolor=\"\(row[3]!)\"><a href=\"info.php?n=\(n)&d=\(d)\">\(row[2]!)</a></td>")
            }
            else
            {
                response.appendBody(string: "<td></td>")
            }
        }
        response.appendBody(string: "</tr>")
    }

    response.appendBody(string: "</table>")

    response.appendBody(string: HTMLConstants.footer)
    response.completed()
}

func getText(_ id : String, width : Int = 70, _ defaultValue : Int) -> String
{
    return """
    <input type="text" name="\(id)" style="width:\(width)px" value="\(defaultValue)">
    """
}
