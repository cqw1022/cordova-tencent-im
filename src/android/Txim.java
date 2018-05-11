package cordova.plugins.txim;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.text.SpannableStringBuilder;
import android.util.Log;

import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMMessage;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Observable;
import java.util.Observer;

import cordova.plugins.txim.event.MessageEvent;

/**
 * 腾讯云通信插件
 *
 * @author hewz
 *
 */
@SuppressWarnings("unused")
public class Txim extends CordovaPlugin implements Observer{

	private static final String LOG_TAG = "Plugin#Txim";
	private static CallbackContext gCallbackContext = null;
	private final static List<String> methodList =
			Arrays.asList(
					"login",
					"logout",,
					"registerNewMessageListerner",
					"deleteFriend",
					"addFriendReq",
					"agreeAddFriend",
					"refuseAddFriend",
					"getFriendList",
					"setFriendBlackList",
					"sendMessageToUser"
			);

	private Activity activity;

	static Txim instance;
	public Txim() {
		instance = this;
	}

	static void addObserver(){
		MessageEvent.getInstance().addObserver(instance);
	}

	/**
	 * 插件主入口
	 */
	@Override
	public boolean execute(final String action, final JSONArray args,
			final CallbackContext callbackContext) throws JSONException {
		LOG.d(LOG_TAG, "Txim#execute");

		// if (!methodList.contains(action)) {
		// 	return false;
		// }
		// if(activity == null)
		// {
		// 	activity = this.cordova.getActivity();
		// 	ApplicationInfo info = null;
		// 	try {
		// 		info = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
		// 	} catch (PackageManager.NameNotFoundException e) {
		// 		e.printStackTrace();
		// 	}
		// 	if(info == null)
		// 	{
		// 		LOG.e(LOG_TAG, "Txim#unable to get im appid");
		// 		return false;
		// 	}
		// 	int appid = info.metaData.getInt("Txim.AppID");
		// 	IMHelper.initIMSdk(appid);
		// }
		cordova.getThreadPool().execute(new Runnable() {
			@Override
			public void run() {
				try {
					Method method = Txim.class.getDeclaredMethod(action,
							JSONObject.class, CallbackContext.class);
					method.invoke(Txim.this, args.getJSONObject(0), callbackContext);
				} catch (Exception e) {
					Log.e(LOG_TAG, e.toString());
				}
			}
		});
		return true;
	}

	void initSdk(JSONObject data, CallbackContext callbackContext) {
		Log.d(LOG_TAG, data.toString());
		try {
			IMHelper.initIMSdk(Integer.parseInt( data.getString("sdkAppId")) );
			callbackContext.success();
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void login(JSONObject data, CallbackContext callbackContext) {
		Log.d(LOG_TAG, data.toString());
		try {
			IMHelper.login(callbackContext, data.getString("identifier"), data.getString("userSig"));
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void logout(JSONObject data, CallbackContext callbackContext) {
		IMHelper.logout(callbackContext);
	}

	void registerNewMessageListerner(JSONObject data, CallbackContext callbackContext) {
		gCallbackContext = callbackContext;
		PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, connectionType);
    pluginResult.setKeepCallback(true);
    callbackContext.sendPluginResult(pluginResult);
	}

	void addFriendReq(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.addFriendReq(data.getString("identifier"), data.getString("remark"), data.getString("addWording"), callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void agreeAddFriend(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.agreeAddFriend(data.getString("identifier"), callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}


	void deleteFriend(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.deleteFriend(data.getString("identifier"), callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void refuseAddFriend(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.refuseAddFriend(data.getString("identifier"), callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void getFriendList(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.getFriendList(callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void sendMessageToUser(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.sendMessageToUser(data, callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}
	

	void setFriendBlackList(JSONObject data, CallbackContext callbackContext) {
		try {
			IMHelper.setFriendBlackList(data.getString("identifier"), callbackContext);
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void setOfflinePush(JSONObject data, CallbackContext callbackContext){
		Log.d(LOG_TAG, data.toString());
		try {
			IMHelper.setOfflinePush(data.getBoolean(0));
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void getOfflinePushStatus(JSONObject data, CallbackContext callbackContext){
		IMHelper.getOfflinePushStatus(callbackContext);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		LOG.d(LOG_TAG, "Txim#destory");
	}

	@Override
	public void update(Observable observable, Object data) {
		Log.d(LOG_TAG, "Observer update");
		if (observable instanceof MessageEvent && data instanceof TIMMessage) {
			JSONObject mJson = new JSONObject();
			TIMMessage msg = (TIMMessage) data;
			try {
				mJson.put("peer", msg.getConversation().getPeer());

				boolean hasText = false;
				List<TIMElem> elems = new ArrayList<TIMElem>();
				for (int i = 0; i < msg.getElementCount(); ++i) {
					elems.add(msg.getElement(i));
					if (msg.getElement(i).getType() == TIMElemType.Text) {
						hasText = true;
					}
				}
				SpannableStringBuilder stringBuilder = MessageFactory.getString(elems, instance.cordova.getActivity().getApplicationContext());
				if (!hasText) {
					stringBuilder.insert(0, " ");
				}
				Log.i(LOG_TAG, stringBuilder.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}

			String format = "window.im.onNewMessages(%s);";
			final String js = String.format(format, mJson.toString());
			instance.cordova.getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if (instance == null) {
						Log.i(LOG_TAG, "instance is null");
						return;
					}
					instance.webView.loadUrl("javascript:" + js);
				}
			});
		}
	}
}
