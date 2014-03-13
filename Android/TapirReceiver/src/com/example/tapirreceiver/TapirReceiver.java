package com.example.tapirreceiver;
import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ToggleButton;

public class TapirReceiver extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        ToggleButton tb = (ToggleButton) findViewById(R.id.toggleButton1);
        
        initTapir();
        
        
        tb.setOnClickListener(new OnClickListener() {
			public void onClick(View view) {
				if(((ToggleButton) view).isChecked()){
					startTapir();
				}else{
					stopTapir();
				}
			}
		});
        

    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    public	native void initTapir();
    public  native void startTapir();
    public  native void stopTapir();
    
    public void tapirCallback(String message){
    	System.out.println(message);
    	TextView tv = (TextView) findViewById(R.id.tv);
    	tv.setText(message);
    	WebView wv = (WebView) findViewById(R.id.webView1);
    	wv.loadUrl(message);
    }
    
    public String tc(String message){
    	TextView tv = (TextView) findViewById(R.id.tv);
    	tv.setText(message);
    	return "rec";
    }
    
    static {
    	System.load("/system/lib/libandroid_runtime.so");
        System.loadLibrary("android_runtime");
        System.loadLibrary("TapirReceiver");
   }
}
