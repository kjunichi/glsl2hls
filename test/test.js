const assert = require('assert');
const Nightmare = require('nightmare')

describe('GLSL start page.', () => {
  describe('index.html', () => {
    it('should index.html', (done) => {
      const nightmare = Nightmare({
          show: false,
          switches: {'ignore-certificate-errors': 'true' }
      })
      nightmare
        .viewport(1024, 768)
        .on('console',(type,args) =>{
          console.log(args)
        })
        .goto('http://localhost:8000/static/index.html')
        .evaluate(()=>{
          return document.body.innerHTML
        },(result) => {
          console.log(`result = ${result}`)
          assert.equal('html',result)
          done()
        })
        .end()
        .then(function (result) {
          console.log(result)
        })
        .catch(function (error) {
          console.error('index.htlm failed:', error);
        })
  
    })
  })
})

