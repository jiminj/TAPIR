package com.example.tapirtest;

import android.app.Activity;
import android.widget.TextView;
import android.os.Bundle;

public class TapirTest extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        TextView  tv = new TextView(this);
        tv.setText( stringFromJNI() );
//        tv.setText("Hello world");
        setContentView(tv);
        
    }	
    public native String stringFromJNI();
    static {
    	System.loadLibrary("TapirTest");
    }
}
