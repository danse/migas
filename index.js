var Main = PS["Main"] // let's make this easier to use
var minute = 60000;
var before = Date.now();

function Reporter() {
  var reporter = this;
  this.$node = false;
  this.update = function() {
    if(this.$node) {
      this.$node.text(format(this.counter));
    }
  }
  this.counter = 0;
  this.add = function(time) {
    this.counter += parseInt(time);
    this.update();
  };
  this.set = {
    node: function($node) {
      reporter.$node = $node;
      reporter.update();
    }
  };
  return this;
};

function set(n, reset) {
  $('input').attr('size', n);
  if(reset) { $('input').prop('value', ''); }
}

function reset() { set(1, true); } // size 0 won't work

function updateInput() {
  var now = Date.now();
  var dif = (now - before)/minute;
  //console.log(dif);
  dif = Math.round(dif);
  //console.log(dif);
  var num = Number($('input').attr('size')) + dif;
  set(num);
  before = now;
}

setInterval(updateInput, minute);

var reporters;

function refresh() {
  function append(record){
    var time = Main.getDuration(record)
    var desc = Main.getDescription(record)
    h.read(desc);
    if(h.test) {
      desc = h.html;
      h.match.map(function(tag) {
        if(!(tag in reporters)) {
          reporters[tag] = new Reporter();
        }
        reporters[tag].add(Number(time));
      }.bind(this));
    }
    reporters.all.add(time);
    var classyTime = '<span class="time">'+time+'</span>';
    $('.report').prepend('<br>', classyTime+' '+desc);
  }
  reporters = {
    all: new Reporter()
  };
  $('.report').empty();
  Main.getRecords(burrito.state).map(append);
  $('.report').prepend('<hr>');
}

// this is a wrapper around our state, which takes care of storing all
// state changes in local storage, in order to be recoverable on the
// next page load
var burrito = {
  state: Main.initialState,
  add: function(number, string) {
    this.state = Main.addEntry(number)(string)(this.state)
    this.save()
  },
  save: function() {
    localStorage['state'] = JSON.stringify(this.state);
  },
  load: function() {
    var stored = localStorage.getItem('state');
    if (stored) {
      try {
        this.state = JSON.parse(stored)
      } catch(e) {
        console.log('error parsing '+stored)
      }
    } else {
      console.log('no state saved locally')
    }
  },
  clear: function() {
    this.state = Main.initialState
    this.save()
  }
};

onload = function() {
  $('input').keyup(function(e) {
    if(e.which===13) {
      var $i = $('input');
      updateInput();
      var minutes = $i.attr('size') - 1;
      var value = crumbify($i.prop('value'), minutes + 1);
      burrito.add(minutes, value);
      refresh();
      reset();
      var d = new Date();
      $('.hour').text(d.getHours()+':'+d.getMinutes());
    }
  });
  $('button').click(function () {
    burrito.clear();
    refresh();
  });
  burrito.load();
  refresh();
  reset();
  $('input').focus();
  $(document).on('mouseenter mouseleave', '.report a', function(e) {
    var amount = reporters['#'+$(e.target).attr('data-name')];
    $('.prompt').text(amount).toggle();
  });

  reporters.all.set.node($('.all.reporter'));
};
onpageshow = function() {
  $('input').focus();
}
