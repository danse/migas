// > crumbify('short message', 30)
// 'short message ................'
function crumbify(s, n) {
    if(s.length >= n) {
        return s;
    } else {
        s += ' '; // for readability
        for(var i=s.length; i<n; i++) {
            s+= '.';
        }
        return s;
    }
}

// > h.read('this is my #hashtag').test;
// true
// > h.match;
// ['#hashtag']
// > h.html;
// 'this is my <a data-name="hashtag" href="javascript:void(0)" class="hashtag">hashtag</a>'
// > h.read('this is a # normal string').test;
// false
// > h.read('these are #multiple #hashtags').match;
// ['#multiple', '#hashtags']
var h = {
    read: function(s) {
        var r = /#([a-zA-Z0-9]+)/g
        this.s = s;
        this.test = r.test(s);
        this.match = s.match(r);
        this.html = s.replace(r, '<a data-name="$1" href="javascript:void(0)" class="$1">$1</a>');
        return this;
    }
}
