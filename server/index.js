const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const fs = require('fs')
const path = require("path")

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const apiPath = path.join(__dirname, "api")
const apiFiles = fs.readdirSync(apiPath).filter(file => file.endsWith('.js'))

// TODO use a PHPMyAdmin

for (const file of apiFiles) {
    const filePath = path.join(apiPath, file)
    const data = require(filePath)
    
    if(data?.method && data?.route && data?.controller) {
        app[data.method](data.route, ...data.middleware, (req, res, ...params) => { 
            try {
                data.controller(req, res, ...params)
            } catch(err) {
                console.log(`❌ | An error occurred while trying to execute the API route ${data.method.toUpperCase()} ${data.route}: ${err}`)
                res.status(500).json({success: false, message: "Internal server error."})
            }
        })
        console.log(`✅ | API route ${data.method.toUpperCase()} ${data.route} has been loaded successfully!`)
    } else {
        console.log(`❌ | The API route ${file} is missing "method", "route" or "controller" properties.`)
    }
}


app.listen(process.env.PORT || 3600, () => { 
    console.log('👂 | Listening!')
})