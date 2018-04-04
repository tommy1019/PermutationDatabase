import Foundation

import PerfectMySQL

class SQLPool
{
    static var pool : [(MySQL, Bool)] = [(MySQL, Bool)]()

    static func getConnection() -> (MySQL, Int)
    {
        for i in 0 ..< pool.count
        {
            if !pool[i].1
            {
                checkConnection(pool[i].0)
                return (pool[i].0, i)
            }
        }

        let newCon = MySQL();
        connect(newCon);
        pool.append((newCon, true))

        return (newCon, pool.count - 1)
    }

    static func returnConnection(_ i : Int)
    {
        pool[i].1 = true
    }

    static func connect(_ mysql : MySQL)
    {
        let connected = mysql.connect(host: host, user: user, password: password, db: db)
        guard connected else
        {
            print(mysql.errorMessage())
            return
        }
    }

    static func checkConnection(_ mysql : MySQL)
    {
        let connected = mysql.ping()
        if !connected
        {
            connect(mysql)
        }
    }
}
