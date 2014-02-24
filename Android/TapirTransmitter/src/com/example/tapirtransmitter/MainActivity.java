package com.example.tapirtransmitter;

import android.os.Bundle;
import android.app.Activity;
import android.text.Editable;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        startTapir();
        
        ((Button) findViewById(R.id.play)).setOnClickListener(new OnClickListener() {
            public void onClick(View view) {
                // ignore the return value
            	Editable e = ((EditText) findViewById(R.id.tv)).getText();
                playSample(e.toString());
            }
        });
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    

    public  native void startTapir();
    public  native void stopTapir();
    public  native void playSample(String message);
    
    
    public String tc(String message){
    	TextView tv = (TextView) findViewById(R.id.tv);
    	tv.setText(message);
    	return "rec";
    }
    
    static {
        System.loadLibrary("TapirTransmitter");
   }
}
