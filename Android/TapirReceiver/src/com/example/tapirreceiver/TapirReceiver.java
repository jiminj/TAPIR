package com.example.tapirreceiver;

import android.os.Handler;
import android.os.Bundle;
import android.os.Message;

public class TapirReceiver {
	static Handler hdlr;
	public TapirReceiver() {}
	public TapirReceiver(Handler h) 
	{ 
		this.hdlr = h;
		initTapir();
	}
	
    public	native void initTapir();
    public  native void startTapir();
    public  native void stopTapir();
    public  void callBack(String str)
    {
    	
    	Bundle bdle = new Bundle();
    	bdle.putString("Result", str); 
    	Message msg = Message.obtain();
    	msg.setData(bdle);
    	msg.setTarget(hdlr);
    	msg.sendToTarget();
    }
    
    static {
        System.loadLibrary("TapirReceiver");
   }
}
