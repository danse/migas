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
