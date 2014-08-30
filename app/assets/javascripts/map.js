$( function() {
  $.getJSON( '/provinces', function( data ) {
    var population = {},
        gdpUsd = {};

    for ( var i = 0; i < data.length; i++ ) {
      population[data[i]["jvector_code"]] = data[i]["population"];
      gdpUsd[data[i]["jvector_code"]] = data[i]["gdp_usd"];
    }

    $( '#map' ).vectorMap({
      map: 'cn_merc_en',
      backgroundColor: '#eee',
      series: {
        regions: [{
          values: population,
          scale: ['#FFFFFF', '#FF0000'],
          max: 100000000
        }]
      },
      markerStyle: {
        initial: {
          fill: '#FFFF00',
          stroke: '#383f47'
        }
      },
      markers: {
        "HK": {latLng: [22.396428, 114.109497], name: 'Hong Kong'},
        "MO": {latLng: [22.198745, 113.543873], name: 'Macau'}
      },

      onRegionClick: function( event, code ) {
        for( var i = 0; i < data.length; i++ ) {
          var obj = data[i];
          if ( code === obj.jvector_code ) {
            window.location = '/provinces/' + obj.id;
          }
        }
      }
    });
  });
});
