const express = require("express")
const app = express()
const axios = require('axios')
const morgan = require('morgan')
const fileUpload = require('express-fileupload')
const Sound = require('aplay')

app.use(morgan('[:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer"'));
app.use(fileUpload())

// app.use(require('body-parser').json());
// app.use(require('body-parser').urlencoded({ extended: true }));


app.post('/audio', (req, res) => {
    console.log(req.files.file.data);
    let file = req.files.file;

    file.mv('./u/f.wav', function(err) {
        if (err) return res.status(500).send(err);
        play()
        return res.send('File uploaded!');
    });

})

const play = () => {
    new Sound().play('./u/f.wav')
}

app.use("*", (req, res) => {
  res.status(404).json({ error: "Not found" })
});

app.listen(3000, async () => {
  console.log("Running on http://127.0.0.1:3000")
})
