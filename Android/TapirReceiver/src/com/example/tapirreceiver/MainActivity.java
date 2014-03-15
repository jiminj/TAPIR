package com.example.tapirreceiver;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.app.Activity;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ToggleButton;
import java.text.*;
import java.util.*;

import com.example.tapirreceiver.TapirReceiver;

public class MainActivity extends Activity {
	
	TapirReceiver tapirInterface;
	Handler callbackHdlr;
	ToggleButton tb;
	TextView tv; 
	SimpleDateFormat dateFormat;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        tb = (ToggleButton) findViewById(R.id.toggleButton1);
        tv = (TextView)findViewById(R.id.tv);
        
        dateFormat = new SimpleDateFormat("hh:mm:ss a");
        callbackHdlr = new Handler()
        {
        	public void handleMessage(Message msg)
        	{
        		Bundle bdle = msg.getData();
        		String curTimestamp = dateFormat.format(new Date());        		
            	tv.setText(curTimestamp + "\t\t" + bdle.getString("Result")+"\n" + tv.getText());
        	}
        };

        tapirInterface = new TapirReceiver(callbackHdlr);
        
        tb.setOnClickListener(new OnClickListener() {
			public void onClick(View view) {
				if(((ToggleButton) view).isChecked()){
					tapirInterface.startTapir();
				}else{
					tapirInterface.stopTapir();
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
}
