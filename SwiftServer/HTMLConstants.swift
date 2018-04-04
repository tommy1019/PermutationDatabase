class HTMLConstants
{
    static let menu = """
        <fieldset>
            <a href="index.php">Home</a><br>
            <a href="add.php">Add Result</a><br>
            <a href="addAuthor.php">Add Author</a><br>
            <a href="addMethod.php">Add Method</a><br>
        </fieldset>
    """

    static let footer = """
                </center>
            </body>
        </html>
    """

    static func getHeader(title : String) -> String
    {
        return """
        <html>
            <head>
                <title>\(title)</title>
                <style>
                    table {
                        width:80%;
                    }

                    table, th, td {
                        border: 1px solid black;
                    }

                    th, td {
                        padding: 5px;
                        text-align: left;
                    }
                </style>
            </head>
        <body>
            <center>
                \(HTMLConstants.menu)
        """
    }
}
