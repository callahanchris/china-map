$( function() {
  loadMap();
});

var loadMap = function() {
  $.getJSON( '/provinces', function( data ) {
    var provinceNames = {},
        population = {},
        popDensity = {},
        gdpUsd = {},
        gdpPerCap = {},
        areaKmSq = {};

    for ( var i = 0; i < data.length; i++ ) {
      provinceNames[data[i]["jvector_code"]] = data[i]["name"];
      population[data[i]["jvector_code"]] = data[i]["population"];
      popDensity[data[i]["jvector_code"]] = data[i]["population_density"];
      gdpUsd[data[i]["jvector_code"]] = data[i]["gdp_usd"];
      gdpPerCap[data[i]["jvector_code"]] = data[i]["gdp_per_capita"];
      areaKmSq[data[i]["jvector_code"]] = data[i]["area_km_sq"];
    }

    $( '#population' ).on( 'click', function() {
      clearMap();
      showPopulation( data, provinceNames, population );
    });

    $( '#pop-density' ).on( 'click', function() {
      clearMap();
      showPopulationDensity( data, provinceNames, popDensity );
    });

    $( '#gdp-usd' ).on( 'click', function() {
      clearMap();
      showGdp( data, provinceNames, gdpUsd );
    });

    $( '#gdp-per-cap' ).on( 'click', function() {
      clearMap();
      showGdpPerCap( data, provinceNames, gdpPerCap );
    });

    $( '#area-km-sq' ).on( 'click', function() {
      clearMap();
      showArea( data, provinceNames, areaKmSq );
    });
  });
},

showPopulation = function( data, provinceNames, population ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: 'none',
    series: {
      regions: [{
        values: population,
        scale: ['#FFF0F0', '#F5442C'],
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

showPopulationDensity = function( data, provinceNames, popDensity ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: 'none',
    series: {
      regions: [{
        values: popDensity,
        scale: ['#FFF0F0', '#F5442C'],
        max: 600
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
      label.html( provinceNames[code] + '<br>' + densitize( popDensity[code] ) );
    },
    onMarkerLabelShow: function( event, label, code ) {
      for ( var i = 0; i < data.length; i++ ) {
        var obj = data[i];
        if ( code === obj.name ) {
          label.html( obj.name + '<br>' + densitize( obj.population_density ) );
        }
      }
    }
  });
},

showGdp = function( data, provinceNames, gdpUsd ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: 'none',
    series: {
      regions: [{
        values: gdpUsd,
        scale: ['#FFF0F0', '#F5442C'],
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

showGdpPerCap = function( data, provinceNames, gdpPerCap ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: 'none',
    series: {
      regions: [{
        values: gdpPerCap,
        scale: ['#FFF0F0', '#F5442C'],
        max: 14000
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
      label.html( provinceNames[code] + '<br>' + monetize( gdpPerCap[code] ) );
    },
    onMarkerLabelShow: function( event, label, code ) {
      for ( var i = 0; i < data.length; i++ ) {
        var obj = data[i];
        if ( code === obj.name ) {
          label.html( obj.name + '<br>' + monetize( obj.gdp_per_capita ) );
        }
      }
    }
  });
},

showArea = function( data, provinceNames, areaKmSq ) {
  $( '#map' ).vectorMap({
    map: 'cn_merc_en',
    backgroundColor: 'none',
    series: {
      regions: [{
        values: areaKmSq,
        scale: ['#FFF0F0', '#F5442C'],
        max: 1500000
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
      label.html( provinceNames[code] + '<br>' + kilometerize( areaKmSq[code] ) );
    },
    onMarkerLabelShow: function( event, label, code ) {
      for ( var i = 0; i < data.length; i++ ) {
        var obj = data[i];
        if ( code === obj.name ) {
          label.html( obj.name + '<br>' + kilometerize( obj.area_km_sq ) );
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
  return "$" + addCommasToInt( int );
};

kilometerize = function( int ) {
  return addCommasToInt( int ) + " km&#178;";
},

densitize = function( int ) {
  return addCommasToInt( int ) + " per km&#178;";
};

