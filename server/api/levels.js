const fs = require('fs')
module.exports = {
    method: "get",
    route: "/levels",
    middleware: [],
    controller: (req, res) => {
        fs.readdir("./gooseFiles", (err, files) => {
            if (err) {
                console.log(err)
                return
            }

            res.send(files.map((item) => item.toString().slice(0,-6)))
        })
    }
}