var minute = 60000;

function set(n) {
    $('input')
        .prop('value', '')
        .attr('size', n)
        .attr('maxlength', n);
}

function reset() { set(1); } // size 0 won't work

setInterval(function() {
    var n = Number($('input').attr('maxlength')) + 1;
    set(n);
}, minute);

var burrito = {
    append: function(record){
        $('.report').append('<br>', record);
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
        } catch(e) {
            console.log('error parsing '+localStorage['records']);
            this.records = [];
        }
        this.records.map(this.append);
        $('.report').append('<hr>');
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
