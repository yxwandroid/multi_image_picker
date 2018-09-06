package com.vitanov.multiimagepickerexample;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.vitanov.multiimagepicker.FileDirectory;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    GeneratedPluginRegistrant.registerWith(this);

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
      {
          Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
          //File f = new File("file://"+ Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES));
          File f = new File("file//storage/emulated/0/Picturses/flutter_test/IMG_20180906_2348.jpg") ;
          Uri contentUri = Uri.fromFile(f);
          mediaScanIntent.setData(contentUri);
          this.sendBroadcast(mediaScanIntent);
          Log.d("DEBUG_MSG" , "Testest") ;
      }
      else
      {
          sendBroadcast(new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://" + Environment.getExternalStorageDirectory())));
      }
      Log.d("DEBUG_MSG" ,"external path :" +
              "file://"+ Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)) ;

      ///storage/emulated/0/Pictures/flutter_test/1536245688624.jpg
      Log.d("DEBUG_MSG" ,"path :" +
              FileDirectory.getPath(this, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)) ;

  }
}
