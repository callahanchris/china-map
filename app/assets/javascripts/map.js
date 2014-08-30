$( function(){
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: '#eee',

    regionStyle: {
      initial: {
        fill: 'white',
        "fill-opacity": 1,
        stroke: 'black',
        "stroke-width": 1,
        "stroke-opacity": 1
      },
      hover: {
        fill: 'red',
        "fill-opacity": 1,
      },
    },

    onRegionHover: function( event, code ) {

    },

    onRegionClick: function( event, code ) {
      console.log(code);
    },
  });

  // $( '#map-events' ).vectorMap({
  //   map: 'cn_merc_en',
  //   onLabelShow: function( event, label, code ) {
  //     label.text('hi');
  //   }
  // });

});
