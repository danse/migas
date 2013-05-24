var minute = 60000;

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

var reporters = {};

[
    'all',
].forEach(function(n) {
    reporters[n] = new Reporter();
});

function set(n, reset) {
    $('input').attr('size', n);
    if(reset) { $('input').prop('value', ''); }
}

function reset() { set(1, true); } // size 0 won't work

setInterval(function() {
    var n = Number($('input').attr('size')) + 1;
    set(n);
}, minute);

var burrito = {
    reports: {},
    append: function(record){
        var time = record[0];
        var desc = record[1];
        h.read(desc);
        if(h.test) {
            desc = h.html;
            h.match.map(function(tag) {
                if(tag in burrito.reports) {
                    burrito.reports[tag] += Number(time);
                } else {
                    burrito.reports[tag] =  Number(time);
                }
            }.bind(this));
        } else {
            desc = record[1];
        }
        reporters.all.add(time);
        $('.report').prepend('<br>', time+' '+desc);
    },
    add: function(record) {
        this.append(record);
        this.records.push(record);
        this.save();
    },
    save: function() {
        localStorage['records'] = JSON.stringify(this.records);
    },
    load: function() {
        try {
            this.records = JSON.parse(localStorage.getItem('records'));
            this.records.map(this.append);
            $('.report').prepend('<hr>');
        } catch(e) {
            console.log('error parsing '+localStorage['records']);
            this.records = [];
        }
    },
    clear: function() {
        this.reports = {};
        this.records = [];
        this.save();
        $('.report').empty();
    }
};

onload = function() {
    $('input').keyup(function(e) {
        if(e.which===13) {
            var $i = $('input');
            var size = $i.attr('size');
            var value = crumbify($i.prop('value'), size);
            burrito.add([size, value]);
            reset();
            var d = new Date();
            $('.hour').text(d.getHours()+':'+d.getMinutes());
        }
    });
    $('button').click(burrito.clear.bind(burrito));
    burrito.load();
    reset();
    $('input').focus();
    $(document).on('mouseenter mouseleave', '.report a', function(e) {
        var report = burrito.reports['#'+$(e.target).attr('data-name')];
        $('.prompt').text(report).toggle();
    });

    reporters.all.set.node($('.all.reporter'));
};
onpageshow = function() {
    $('input').focus();
}
