var argscheck = require('cordova/argscheck'),
    exec = require('cordova/exec');

/**
 * SimpleDataTransfer uploads a file to a remote server.
 * @constructor
 */
var SimpleImageCrop = function() {
};

SimpleDataTransfer.prototype.crop = function(file, url, successCallback, errorCallback, json, options, encryption) {
    argscheck.checkArgs('ssFFOAO*', 'SimpleImageCrop.crop', arguments);

	// add custom id
	/*options[1] = this._id;
	
    var fail = errorCallback && function(e) {
    	var error = simpleDataError(e);
    	errorCallback(error);
    };

    var self = this;
    var win = function(result) {
    	if (typeof result.loaded != "undefined" && typeof result.total != "undefined") {
            if (self.onprogress) {
                self.onprogress(newSimpleDataProgressEvent(result));
            }
        } else {
            successCallback && successCallback(result);
        }
    };

    exec(win, fail, 'SimpleDataTransfer', 'uploadFileAsJson', [file, url, json, options, encryption]);*/
};

module.exports = SimpleImageCrop;