var minute = 1000;
setInterval(function() {
    var size = $('input').attr('size');
    $('input').attr('size', Number(size)+1);
}, minute);
var wrapper = {
    records: [],
    handler: function(){},
    add: function(record) {
        this.handler(record);
        this.records.push(record);
        localStorage['records'] = JSON.stringify(this.records);
    },
    reload: function() {
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
            $i.prop('value', '').attr('size', 0);
        }
    });
    wrapper.reload();
};
