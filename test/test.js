const assert = require('assert');
const Nightmare = require('nightmare')

describe('GLSL start page.', () => {
  describe('index.html', () => {
    it('should index.html', () => {
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
      },(resulst) => {
        assert.equal('html',result)
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

