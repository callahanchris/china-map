$( function() {
  $.getJSON( '/provinces', function( data ) {
    var population = {},
        gdpUsd = {},
        provinceNames = {};

    for ( var i = 0; i < data.length; i++ ) {
      population[data[i]["jvector_code"]] = data[i]["population"];
      gdpUsd[data[i]["jvector_code"]] = data[i]["gdp_usd"];
      provinceNames[data[i]["jvector_code"]] = data[i]["name"];
    }

    $( '#population' ).on( 'click', function() {
      clearMap();
      showPopulation( data, provinceNames, population );
    });

    $( '#gdp-usd' ).on( 'click', function() {
      clearMap();
      showGdp( data, provinceNames, gdpUsd );
    });
  });
});

var showPopulation = function( data, provinceNames, population ) {
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
      "Hong Kong": {latLng: [22.396428, 114.109497], name: 'Hong Kong'},
      "Macau": {latLng: [22.198745, 113.543873], name: 'Macau'}
    },

    // onRegionClick: function( event, code ) {
    //   for ( var i = 0; i < data.length; i++ ) {
    //     var obj = data[i];
    //     if ( code === obj.jvector_code ) {
    //       window.location = '/provinces/' + obj.id;
    //     }
    //   }
    // },
    onRegionLabelShow: function( event, label, code ) {
      label.html( provinceNames[code] + '<br>' + addCommasToInt( population[code] ) );
    },
    onMarkerLabelShow: function( event, label, code ) {
      for ( var i = 0; i < data.length; i++ ) {
        var obj = data[i];
        if ( code === obj.name ) {
          label.html( obj.name + '<br>' + addCommasToInt( obj.population ) );
        }
      }
    }
  });
},

showGdp = function( data, provinceNames, gdpUsd ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: '#eee',
    series: {
      regions: [{
        values: gdpUsd,
        scale: ['#FFFFFF', '#FF0000'],
        max: 800000000000
      }]
    },
    markerStyle: {
      initial: {
        fill: '#FFFF00',
        stroke: '#383f47'
      }
    },
    markers: {
      "Hong Kong": {latLng: [22.396428, 114.109497], name: 'Hong Kong'},
      "Macau": {latLng: [22.198745, 113.543873], name: 'Macau'}
    },
    onRegionLabelShow: function( event, label, code ) {
      label.html( provinceNames[code] + '<br>' + monetize( gdpUsd[code] ) );
    },
    onMarkerLabelShow: function( event, label, code ) {
      for ( var i = 0; i < data.length; i++ ) {
        var obj = data[i];
        if ( code === obj.name ) {
          label.html( obj.name + '<br>' + monetize( obj.gdp_usd ) );
        }
      }
    }
  });
},

clearMap = function() {
  $( '#map' ).contents().remove();
},

addCommasToInt = function( int ) {
  var numString = int.toString(),
      newString = "";

  for ( var i = 0; i < numString.length; i++ ) {
    newString += numString[i];
    if ( ( numString.length - i - 1 ) % 3 === 0 && i !== numString.length - 1 ) {
      newString += ",";
    }
  }

  return newString;
},

monetize = function( int ) {
  return "$" + addCommasToInt(int);
};
