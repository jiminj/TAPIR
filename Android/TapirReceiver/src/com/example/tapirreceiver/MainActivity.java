package com.example.tapirreceiver;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.widget.TextView;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        startTapir();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    

    public  native void startTapir();
    public  native void stopTapir();
    
    public void tapirCallback(String message){
    	System.out.println(message);
    	TextView tv = (TextView) findViewById(R.id.tv);
    	tv.setText(message);
    	
    }
    
    public String tc(String message){
    	TextView tv = (TextView) findViewById(R.id.tv);
    	tv.setText(message);
    	return "rec";
    }
    
    static {
        System.loadLibrary("TapirReceiver");
   }
}
