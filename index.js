var minute = 6000;

function set(n, reset) {
    $('input')
        .attr('size', n)
        .attr('maxlength', n);
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
            burrito.add([$i.attr('size'), ' '+$i.prop('value')]);
            reset();
        }
    });
    $('button').click(burrito.clear.bind(burrito));
    burrito.load();
    reset();
};
