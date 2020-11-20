/*

 `refresh` is the main rendering function, called in the handler of
 many events. It clears the document, then goes through the state and
 renders it again.

 The state and a few methods associated with it are in `burrito`

 */
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
  function reportTime(entry){
    var time = Main.getDuration(entry)
    reporters.all.add(time);
  }
  var state = burrito.state

  reporters = {
    all: new Reporter()
  };
  reporters.all.set.node($('.all.reporter'));
  Main.getEntries(state).map(reportTime);

  $('.report').empty();
  $('.report').prepend(Main.renderEntries(state));

  $('.folders').empty()
  allKeys()
    .map(Main.renderFolder(location.href.split('?')[0]))
    .map(function (e) {
      $('.folders').prepend(e)
    })

  change(Main.getChartData(state))
}

function stateLabel () {
  return location.search.substr(1) || "default"
}

// this is a wrapper around our state, which takes care of storing all
// state changes in local storage, in order to be recoverable on the
// next page load
var burrito = {
  state: Main.initialState,
  update: function (newState) {
    this.state = newState
    this.save()
  },
  updateWith: function (f) {
    this.state = f(this.state)
    this.save()
  },
  save: function() {
    localStorage[stateLabel()] = JSON.stringify(this.state);
  },
  load: function() {
    var stored = localStorage.getItem(stateLabel())
    if (stored) {
      try {
        this.state = JSON.parse(stored)
      } catch(e) {
        console.log('error parsing '+stored)
      }
    } else {
      console.log('no state saved locally')
    }
  }
};

onload = function() {
  $('input').keyup(function(e) {
    if(e.which===13) {
      var $i = $('input')
      updateInput();
      var minutes = $i.attr('size') - 1;
      var value = $i.prop('value')
      var d = new Date();
      burrito.updateWith(Main.addEntry(minutes)(value)(d));
      refresh();
      reset();
      $('.hour').text(d.getHours()+':'+d.getMinutes());
    }
  });
  $('button#drop').click(function () {
    reset();
  });
  $('button#clear').click(function () {
    burrito.update(Main.initialState);
    refresh();
  });
  var exportAnchor = '#export a'
  function toggleExport () { $('#export *').toggle() }
  $('#export button').click(function () {
    var s = JSON.stringify(Main.exportAsMarginFile(burrito.state))
    var b = new Blob([s], { type: 'application/json' })
    var u = URL.createObjectURL(b)
    var fileName = 'crumbs-margin-export-' + (new Date()).toISOString() + '.json'
    $(exportAnchor).attr({
      'href': u,
      'download': fileName
    })
    toggleExport()
  });
  $(exportAnchor)
    .toggle()
    .click(toggleExport)
  burrito.load();
  refresh();
  reset();
  $(document)
    .on('mouseenter mouseleave', '.report a', function(e) {
      var r = reporters['#'+$(e.target).attr('data-name')];
      $('.prompt').text(r.counter).toggle();
    })
    .on('keypress', function (ev) {
      if (ev.key === '/') {
        $('input').focus();
        ev.preventDefault();
      }
    });
};

function allKeys (maybeN) {
  var n = maybeN || 0
  var currentKey = localStorage.key(n)
  if (currentKey) {
    var otherKeys = allKeys(n+1)
    otherKeys.push(currentKey)
    return otherKeys
  } else {
    return []
  }
}
