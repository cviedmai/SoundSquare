/*
*   SoundSquare v0.1
*   Author: Cristobal Viedma, cristobal@viedma.es
*   Copyright (c) 2010 Cristobal Viedma
*   Licensed under the MIT license:
*   http://www.opensource.org/licenses/mit-license.php
*/


var lastVenue;

// Initialize JQTouch
$.jQTouch({ formSelector:'.form' });

$(document).ready(function(){
  getLocation();
  //$.getJSON("http://api.foursquare.com/v1/venues.json?q=&l=1&geolat=40.24&geolong=3.41&callback=?", function(data){alert(""+data);});
});

//jQuery(function(){
////  $("#search").bind("pageAnimationEnd", function(e, info){
////    alert("Animating #search "+ info.direction);
////  });
//  getLocation(); // Get the current location of the user to update the search link
//
//});

function getLocation () {
  if(geo_position_js.init()){
    geo_position_js.getCurrentPosition(
      function(pos){$("#fsResults").load("/fs/search", {
        lat: pos.coords.latitude, 
        lng: pos.coords.longitude
      });},
      function(e){
        // There was some error retrieving the location. Let's simulate it
        $("#fsResults").load("/fs/search", {
          lat: 40.24, 
          lng: 3.41
        });
      },
      {enableHighAccuracy:false}
    );
  }
  else{
    alert("Location not available. Sorry.");
  }
}