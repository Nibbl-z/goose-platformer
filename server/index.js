const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const fs = require('fs')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

app.get('/getLevelList', (req, res) => {
    let levelNames = []

    fs.readdir("./gooseFiles", (err, files) => {
        if (err) {
            console.error(err)
            return
        }
        

        files.forEach((item) => {
            console.log("Hai!")
            levelNames.push(item.toString().slice(0,-6))
        })

        console.log(levelNames)
    
        res.send(levelNames)
    })
})

app.get("/getLevelData", (req, res) => {
    let name = req.query.name

    fs.readFile("./gooseFiles/".concat(name).concat(".goose"), "utf8", (err, data) => {
        if (err) {
            console.error(err)
            return
        }
        
        res.send(data)
    })
})

app.listen(3000, () => { 
    console.log('Listening!')
})