module.exports = {
    method: "get",
    route: "/ping",
    middleware: [],
    controller: (req, res) => {
        res.send("pong")
    }
}