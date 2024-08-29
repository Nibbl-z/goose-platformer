const fs = require('fs')
module.exports = {
    method: "get",
    route: "/data/:name",
    middleware: [],
    controller: (req, res) => {
        const { name } = req.params

        fs.readFile(`./gooseFiles/${name}.goose`, "utf8", (err, data) => {
            if (err) {
                console.error(err)
                return
            }
            
            res.send(data)
        })
    }
}