var minute = 60000;

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

function set(n, reset) {
    $('input')
        .attr('size', n)
        .attr('maxlength', n);
    var d = new Date();
    $('.hour').text(d.getHours()+':'+d.getMinutes());
    if(reset) { $('input').prop('value', ''); }
}

function reset() { set(1, true); } // size 0 won't work

setInterval(function() {
    var n = Number($('input').attr('maxlength')) + 1;
    set(n);
}, minute);

var burrito = {
    append: function(record){
        $('.report').prepend('<br>', record);
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
            burrito.add([size, ' '+value]);
            reset();
        }
    });
    $('button').click(burrito.clear.bind(burrito));
    burrito.load();
    reset();
    $('input').focus();
};
