const fs = require('fs')
const assert = require('assert')
const Nightmare = require('nightmare')

describe('GLSL start page.', () => {
  let nightmare;
  
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
        },(result) => {
          console.log(`result = ${result}`)
          assert.notEqual(-1,result.indexOf('button '))
        })
        .end()
        .then(function (result) {
          console.log(result)
          done()
        })
        .catch(function (error) {
          console.error('index.htlm failed:', error);
          done()
        })
    })
    it('should render GLSL', (done) => {
      nightmare.click('#btnRun')
        .wait(9000)
        .evaluate(()=>{
            return document.getElementById('out')
          },(result)=>{
            assert.notEqual(0, result.src.length)
            console.log(`result.src = ${result.src}`)
        })
        .end()
        .then(function (result) {
          console.log(result)
          done()
        })
        .catch(function (error) {
          console.error('render GLSL failed:', error);
          done()
        })
    })
  })
})

