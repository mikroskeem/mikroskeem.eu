var Nightmare = require('nightmare'),
    should = require('chai').should();

describe('mikroskeem.eu', function(){
    this.timeout(15000);
    var url = 'http://127.0.0.1:8080';

    describe('Main page', function(){
        it('"Back to top" button should be hidden when page not scrolled', function(done){
            new Nightmare()
                .goto(url)
                .evaluate(function(){
                    return document.querySelector("#stw").className;
                }, function(result){
                    result.should.equal("");
                    done();
                })
                .run();
        });
        it('Header with text "Hello" should be <h1> and have anchor #hello', function(done){
            new Nightmare()
                .goto(url)
                .evaluate(function(){
                    return document.getElementById("hello").nodeName.toLowerCase();
                }, function(result){
                    result.should.equal("h1");
                    done();
                })
                .run();
        });
    });
    describe('Page with a lot of content', function(){
        it("\"Back to top\" button shouldn't be hidden when page is scrolled", function(done){
            new Nightmare()
                .viewport(1366,768)
                .goto(url+"/pages/longpage")
                .scrollTo(200,0)
                .evaluate(function(){
                    return document.querySelector("#stw").className;
                }, function(result){
                    result.should.equal("show");
                    done();
                })
                .run();
        });
        it('"Back to top" button should scroll back to top', function(done){
            new Nightmare()
                .viewport(1366,768)
                .goto(url+"/pages/longpage")
                .scrollTo(200,0)
                .click("div[id=stw]")
                .wait(500)
                .evaluate(function(){
                    return document.body.scrollTop;
                }, function(result){
                    result.should.equal(0);
                    done();
                })
                .run();
        });
    });
});
