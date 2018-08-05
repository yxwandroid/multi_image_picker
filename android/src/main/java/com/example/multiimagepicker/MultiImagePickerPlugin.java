package com.vitanov.multiimagepicker;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;

import com.zhihu.matisse.Matisse;
import com.zhihu.matisse.MimeType;
import com.zhihu.matisse.engine.impl.GlideEngine;

import android.content.pm.ActivityInfo;

import java.util.ArrayList;
import java.util.List;

import android.Manifest;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/** MultiImagePickerPlugin */
public class MultiImagePickerPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
    private static final int PICK_MULTI_IMAGES = 1000;
    private static final String CHANNEL_NAME = "multi_image_picker";
    private static final String PICK_IMAGES = "pickImages";
    private static final String MAX_IMAGES = "maxImages";
    private static final  int REQUEST_CODE_CHOOSE = 1001;
    private static final  int REQUEST_CODE_GRANT_PERMISSIONS = 2001;
    private final MethodChannel channel;
    private Activity activity;
    private Context context;
    private Result pendingResult;
    private MethodCall methodCall;

    private MultiImagePickerPlugin(Activity activity, Context context, MethodChannel channel) {
        this.activity = activity;
        this.context = context;
        this.channel = channel;
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        MultiImagePickerPlugin instance = new MultiImagePickerPlugin(registrar.activity(), registrar.context(), channel);
        registrar.addActivityResultListener(instance);
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError();
            return;
        }

        if (PICK_IMAGES.equals(call.method)) {
            openImagePicker();
        } else {
            pendingResult.notImplemented();
        }
    }

    private void openImagePicker(){

        if (ContextCompat.checkSelfPermission(this.activity,
                Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this.activity,
                    Manifest.permission.READ_EXTERNAL_STORAGE)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
            } else {
                // No explanation needed; request the permission
                ActivityCompat.requestPermissions(this.activity,
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                        REQUEST_CODE_GRANT_PERMISSIONS);
            }
        } else {
            presentPicker();
        }

    }

    private void presentPicker() {
        int maxImages = this.methodCall.argument(MAX_IMAGES);
        Matisse.from(this.activity)
                .choose(MimeType.ofImage())
                .countable(true)
                .maxSelectable(maxImages)
                .restrictOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED)
                .imageEngine(new GlideEngine())
                .forResult(REQUEST_CODE_CHOOSE);
    }

    private static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        }
        finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_CHOOSE && resultCode == Activity.RESULT_OK) {
            List<Uri> photos = Matisse.obtainResult(data);
            List<String> result = new ArrayList<String>(photos.size());
            for (Uri url : photos) {
                result.add(getDataColumn(this.context, url, null, null));
            }
            finishWithSuccess(result);
            return true;
        } else if (requestCode == REQUEST_CODE_GRANT_PERMISSIONS && resultCode == Activity.RESULT_OK) {
            presentPicker();
        }
        return false;
    }

    private void finishWithSuccess(List imagePathList) {
        pendingResult.success(imagePathList);
        clearMethodCallAndResult();
    }


    private void finishWithSuccess(String imagePath) {
        pendingResult.success(imagePath);
        clearMethodCallAndResult();
    }

    private void finishWithAlreadyActiveError() {
        finishWithError("already_active", "Image picker is already active");
    }

    private void finishWithError(String errorCode, String errorMessage) {
        pendingResult.error(errorCode, errorMessage, null);
        clearMethodCallAndResult();
    }

    private void clearMethodCallAndResult() {
        methodCall = null;
        pendingResult = null;
    }

    private boolean setPendingMethodCallAndResult(
            MethodCall methodCall, MethodChannel.Result result) {
        if (pendingResult != null) {
            return false;
        }

        this.methodCall = methodCall;
        pendingResult = result;
        return true;
    }
}
