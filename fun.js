// @flow

// > format(1234)
// '20 hours, 34 minutes'
function format(minutes) {
  var a = hours(minutes);
  return a[0] + ' hours, ' + a[1] + ' minutes';
}

// > hours(1234)
// [20, 34]
function hours(minutes) {
  var reminder = minutes % 60,
      integer = minutes - reminder;
  return [integer/60, reminder];
}

// > crumbify('short message', 30)
// 'short message ................'
// > crumbify('long message', 5)
// 'long <span class="extra">message</span>'
function crumbify(s, n) {
  if(s.length >= n) {
    var fair = s.slice(0, n),
        extra = s.slice(n);
    return fair + '<span class="extra">' + extra + '</span>'
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
// > h.read('this is a partial #hash#tag').match;
// ['#hash']
// > h.read('#hash at the beginning').match;
// ['#hash']
// > h.read('#hash#tag at the beginning').match;
// ['#hash']
// > h.read('this is my #hash#tag').html;
// 'this is my <a data-name="hash" href="javascript:void(0)" class="hashtag">hash</a>tag'
var h = {
  read: function(s) {
    var r = /\B#([a-zA-Z0-9]+)/g
    this.s = s;
    this.test = r.test(s);
    this.match = s.match(r);
    this.html = s
      .replace(r, '<a data-name="$1" href="javascript:void(0)" class="hashtag">$1</a>')
      .replace(/#/, '');
    return this;
  }
}
