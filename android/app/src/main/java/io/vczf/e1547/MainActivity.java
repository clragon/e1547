package io.vczf.e1547;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String TAG = MainActivity.class.getSimpleName();

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Intent startingIntent = getIntent();
    if (Intent.ACTION_VIEW.equals(startingIntent.getAction())) {
      Uri uri = startingIntent.getData();
      Log.d(TAG, uri.toString());
    }
  }
}
