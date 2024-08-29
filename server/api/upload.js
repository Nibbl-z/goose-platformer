const fs = require('fs')
module.exports = {
    method: "post",
    route: "/upload",
    middleware: [],
    controller: (req, res) => {
        const { name, data } = req.body
        if(name === undefined || data === undefined || typeof name != "string" || typeof data != "string") return res.status(400).send("Name or data not provided or not formatted properly")

        fs.writeFile(`./gooseFiles/${name}.goose`, data, err => {
            if (err) {
                console.error(err)
                return
            }
            
            res.send("Uploaded Successfully!")
        })
    }
}