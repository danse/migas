var minute = 60000;
function set(n) {
    $('input')
        .prop('value', '')
        .attr('size', n+1) // size 0 won't work
        .attr('maxlength', n);
}
function reset() { set(0); }
setInterval(function() {
    var n = Number($('input').attr('size')) + 1;
    set(n);
}, minute);
var wrapper = {
    records: [],
    handler: function(){},
    add: function(record) {
        this.handler(record);
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
        }
        if(this.records) {
            this.records.map(this.handler);
        } else {
            this.records = [];
        }
    },
    clear: function() {
        this.records = [];
        this.save();
    }
};
var handler = function(record) {
    $('body').append('<br>', record);
};
wrapper.handler = handler;
onload = function() {
    $('input').keyup(function(e) {
        if(e.which===13) {
            var $i = $('input');
            wrapper.add([$i.attr('size'), ' '+$i.prop('value')]);
            reset();
        }
    });
    wrapper.load();
    $('button').click(wrapper.clear());
    reset();
};
