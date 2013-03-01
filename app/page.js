define(

  [
    'data/entries',
    'inte/history',
    'inte/input'
  ],

  function(
    entries,
    history,
    input) {

    function initialize() {
      entries.attachTo(document);
      history.attachTo('body');
      input.attachTo('body');
    }

    return initialize;
  }
);
