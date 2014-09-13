$( function() {
  loadMap();
});

var loadMap = function() {
  $.getJSON( '/regions', function( data ) {
    var regionNames = {},
        population = {},
        popDensity = {},
        gdpUsd = {},
        gdpPerCap = {},
        areaKmSq = {};

    for ( var i = 0; i < data.length; i++ ) {
      regionNames[data[i]["jvector_code"]] = data[i]["name"];
      population[data[i]["jvector_code"]] = data[i]["population"];
      popDensity[data[i]["jvector_code"]] = data[i]["population_density"];
      gdpUsd[data[i]["jvector_code"]] = data[i]["gdp_usd"];
      gdpPerCap[data[i]["jvector_code"]] = data[i]["gdp_per_capita"];
      areaKmSq[data[i]["jvector_code"]] = data[i]["area_km_sq"];
    }

    $( '#population' ).on( 'click', function() {
      clearMap();
      showPopulation( data, regionNames, population );
    });

    $( '#pop-density' ).on( 'click', function() {
      clearMap();
      showPopulationDensity( data, regionNames, popDensity );
    });

    $( '#gdp-usd' ).on( 'click', function() {
      clearMap();
      showGdp( data, regionNames, gdpUsd );
    });

    $( '#gdp-per-cap' ).on( 'click', function() {
      clearMap();
      showGdpPerCap( data, regionNames, gdpPerCap );
    });

    $( '#area-km-sq' ).on( 'click', function() {
      clearMap();
      showArea( data, regionNames, areaKmSq );
    });
  });
},

showPopulation = function( data, regionNames, population ) {
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
      label.html( regionNames[code] + '<br>' + addCommasToInt( population[code] ) );
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

showPopulationDensity = function( data, regionNames, popDensity ) {
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
      label.html( regionNames[code] + '<br>' + densitize( popDensity[code] ) );
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

showGdp = function( data, regionNames, gdpUsd ) {
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
      label.html( regionNames[code] + '<br>' + monetize( gdpUsd[code] ) );
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

showGdpPerCap = function( data, regionNames, gdpPerCap ) {
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
      label.html( regionNames[code] + '<br>' + monetize( gdpPerCap[code] ) );
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

showArea = function( data, regionNames, areaKmSq ) {
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
      label.html( regionNames[code] + '<br>' + kilometerize( areaKmSq[code] ) );
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

