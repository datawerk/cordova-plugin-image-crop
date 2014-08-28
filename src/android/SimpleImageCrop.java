package de.datawerk.cordova.plugin.image;

import java.io.ByteArrayOutputStream;
import java.io.File;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.util.Base64;
import android.util.Log;

public class SimpleImageCrop extends CordovaPlugin {

    private static final String LOG_TAG = "SimpleImageCrop";
    
    public static int FILE_NOT_FOUND_ERR = 1;
    public static int FILE_NOT_REMOVED_ERR = 2;
    @Override
    public boolean execute(String action, final String rawArgs, final CallbackContext callbackContext) throws JSONException {
	
    	if ("crop".equals(action)) {
			Log.d(LOG_TAG, "crop called");
			
			cordova.getThreadPool().execute(new Runnable() {
				public void run() {
					
					try {
					
						JSONArray args = new JSONArray(rawArgs);
						String filename = args.getString(0);
						boolean removeFile = args.optBoolean(1);
						
						int x = args.getInt(2);
						int y = args.getInt(3);
						int width = args.getInt(4);
						int height = args.getInt(5);
						
						int quality = args.getInt(6);
						int maxWidth = args.getInt(7);
						
						CordovaResourceApi resourceApi = webView.getResourceApi();
						
						Uri tmpSrc = Uri.parse(filename);
				        Uri sourceUri = resourceApi.remapUri(tmpSrc.getScheme() != null ? tmpSrc : Uri.fromFile(new File(filename)));
				        Log.d(LOG_TAG, "sourceUri: " + sourceUri);
				        
	                    File file = resourceApi.mapUriToFile(sourceUri);
	                    BitmapFactory.Options options = new BitmapFactory.Options();
	                    options.inSampleSize = 1;
	                    options.inJustDecodeBounds = false;
	                    
	                    //Log.d(LOG_TAG, "file path: " + file.getAbsolutePath());
	                    
	                    Bitmap bmpOrig = BitmapFactory.decodeFile(file.getAbsolutePath(), options);
	                    Bitmap bmp = Bitmap.createBitmap(bmpOrig, x, y, width, height);
	                    
	                    bmpOrig.recycle();
	                    
	                    //Log.d(LOG_TAG, "width: " + width);
	                    //Log.d(LOG_TAG, "height: " + height);
	                    //Log.d(LOG_TAG, "maxWidth: " + maxWidth);
	                    
	                    float scale = (float) maxWidth / width ;
	                    
	                    //Log.d(LOG_TAG, "scale: " + scale);
	                    
	                    bmp = getResizedBitmap(bmp, scale);
	                    String base64 = encodeTobase64(bmp, quality);
	                    
	                    bmp.recycle();
	                    
	                    String result = "data:image/jpeg;base64,"+base64;
	                    
	                    if(removeFile) {
		                    if(file.delete() == false) {
		                    	callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, FILE_NOT_REMOVED_ERR));
		                    	return;
		                    }
	                    }
	                    
	                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
	                    
					} catch (Exception e) {
						Log.d(LOG_TAG, "crop error: "+e.getMessage());
						callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
					}
				}
			});
		}
    	
    	if ("resize".equals(action)) {
    		
    		cordova.getThreadPool().execute(new Runnable() {
				public void run() {
			
					try {
					
						JSONArray args = new JSONArray(rawArgs);
			    		
			    		final String filename = args.getString(0);
						final boolean removeFile = args.optBoolean(1);
						
						final int quality = args.getInt(2);
						final int maxWidth = args.getInt(3);
						
						CordovaResourceApi resourceApi = webView.getResourceApi();
						
						Uri tmpSrc = Uri.parse(filename);
				        Uri sourceUri = resourceApi.remapUri(tmpSrc.getScheme() != null ? tmpSrc : Uri.fromFile(new File(filename)));
				        Log.d(LOG_TAG, "sourceUri: " + sourceUri);
				        
	                    File file = resourceApi.mapUriToFile(sourceUri);
	                    BitmapFactory.Options options = new BitmapFactory.Options();
	                    options.inSampleSize = 1;
	                    options.inJustDecodeBounds = false;
	                    
	                    Bitmap bmp = BitmapFactory.decodeFile(file.getAbsolutePath(), options);
	                    
	                    float scale = (float) maxWidth / bmp.getWidth() ;
	                    
	                    bmp = getResizedBitmap(bmp, scale);
	                    String base64 = encodeTobase64(bmp, quality);
	                    
	                    bmp.recycle();
	                    
	                    String result = "data:image/jpeg;base64,"+base64;
	                    
	                    if(removeFile) {
		                    if(file.delete() == false) {
		                    	callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, FILE_NOT_REMOVED_ERR));
		                    	return;
		                    }
	                    }
	                    
	                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
	                    
					} catch (Exception e) {
						Log.d(LOG_TAG, "crop error: "+e.getMessage());
						callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
					}
				}
			});
    	}
    	return true;
	}
    
    private Bitmap getResizedBitmap(Bitmap bm, float factor) {
        int width = bm.getWidth();
        int height = bm.getHeight();
        // create a matrix for the manipulation
        Matrix matrix = new Matrix();
        // resize the bit map
        matrix.postScale(factor, factor);
        // recreate the new Bitmap
        Bitmap resizedBitmap = Bitmap.createBitmap(bm, 0, 0, width, height, matrix, false);
        return resizedBitmap;
    }
    
    public static String encodeTobase64(Bitmap image, int quality)
    {
        Bitmap immagex=image;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();  
        immagex.compress(Bitmap.CompressFormat.JPEG, quality, baos);
        byte[] b = baos.toByteArray();
        String imageEncoded = Base64.encodeToString(b,Base64.DEFAULT);

        return imageEncoded;
    }
}
