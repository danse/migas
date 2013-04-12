var minute = 1000;
setInterval(function() {
    var size = $('input').attr('size');
    $('input').attr('size', Number(size)+1);
}, minute);
onload = function() {
    $('input').keyup(function(e) {
        if(e.which===13) {
            var $i = $('input'),
                $b = $('body');
            $b.append('<br>', [$i.attr('size'), ' '+$i.prop('value')]);
            $i.prop('value', '').attr('size', 0);
        }
    });
};
