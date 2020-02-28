package com.example.matching_tantan_app;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.lang.String;

public class MainActivity extends FlutterActivity {
  
  private static final String CHANNEL = "flutter.native/helper";
  Activity activity = MainActivity.this;
  String TAG = "PhoneActivityTAG";
  String wantPermission = Manifest.permission.READ_PHONE_STATE;
  String serialNumber = "";
  private static final int PERMISSION_REQUEST_CODE = 1;
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, MethodChannel.Result result) {
          if (call.method.equals("getSimCardSerialNumber")) {
            String greetings = getSerialNumber();
            result.success(greetings);
          }
        }
      }
    );
  }

  private String getSerialNumber() {
    if (!checkPermission(wantPermission)) {
      requestPermission(wantPermission);
    } else {
      serialNumber = getPhone();
    }
    return serialNumber;
  }

  @TargetApi(Build.VERSION_CODES.O)
  private String getPhone() {
    TelephonyManager phoneMgr = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
    if (ActivityCompat.checkSelfPermission(activity, wantPermission) != PackageManager.PERMISSION_GRANTED) {
      return "";
    }
    String serial = phoneMgr.getSimSerialNumber();
    
    return serial;
  }

  private void requestPermission(String permission){
    if (ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)){
      Toast.makeText(activity, "Phone state permission allows us to get phone number. Please allow it for additional functionality.", Toast.LENGTH_LONG).show();
    }
    ActivityCompat.requestPermissions(activity, new String[]{permission},PERMISSION_REQUEST_CODE);
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
    switch (requestCode) {
      case PERMISSION_REQUEST_CODE:
        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
          Log.d(TAG, "Phone number: " + getPhone());
        } else {
          Toast.makeText(activity,"Permission Denied. We can't get phone number.", Toast.LENGTH_LONG).show();
        }
        break;
    }
  }

  private boolean checkPermission(String permission){
    if (Build.VERSION.SDK_INT >= 23) {
      int result = ContextCompat.checkSelfPermission(activity, permission);
      if (result == PackageManager.PERMISSION_GRANTED){
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}




















