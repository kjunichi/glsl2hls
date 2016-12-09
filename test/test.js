// Copyright (c) 2016 Junichi Kajiwara
// Released under the MIT license
// https://github.com/kjunichi/glsl2hls/blob/master/LICENSE

const fs = require('fs')
const assert = require('assert')
const Nightmare = require('nightmare')

describe('GLSL start page.', () => {
  let nightmare;
  let m3u8FilePath;
  
  beforeEach(()=> {
    // runs before each test in this block
    nightmare = Nightmare({
          show: false,
          switches: {'ignore-certificate-errors': 'true' }
    })
    nightmare.viewport(1024, 768)
        .on('console',(type,args) =>{
          console.log(args)
        })
        .goto('http://localhost:8000/static/index.html')
  });
  describe('index.html', () => {
    it('should index.html', (done) => {
        nightmare.evaluate(()=>{
          return document.body.innerHTML
        })
        .end()
        .then((result) => {
          console.log(`result = ${result}`)
          assert.notEqual(-1,result.indexOf('button '))
          done()
        })
        .catch((error) => {
          console.error('index.htlm failed:', error)
          done()
        })
    })
    it('should render GLSL', (done) => {
      nightmare.click('#btnRun')
        .wait(9000)
        .evaluate(()=>{
            return document.getElementById('out').src
        })
        .end()
        .then((result) => {
          console.log(result)
          //console.log(result.src)
          assert.notEqual(0, result.length)
          console.log(process.cwd())
          const exec = require('child_process').exec;
          exec('ls -la ./static', (err, stdout, stderr) => {
            if (err) { console.log(err) }
            console.log(stdout);
            m3u8FilePath = result.replace('http://localhost:8000/','./')
            console.log(m3u8FilePath)
            //const m3u8 = fs.readFileSync(filePath, 'utf8')
            //console.log(m3u8)
            done()
          });
          
        })
        .catch((error) => {
          console.error('render GLSL failed:', error);
          done()
        })
    })
    it('shoud create m3u8', (done)=>{
      setTimeout(()=>{
        exec('ls -la ./static', (err, stdout, stderr) => {
            if (err) { console.log(err) }
            console.log(stdout);
            
            //const m3u8 = fs.readFileSync(m3u8FilePath, 'utf8')
            //console.log(m3u8)
            done()
          });
      },14000)
    })
  })
})

