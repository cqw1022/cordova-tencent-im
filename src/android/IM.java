package hewz.plugins.im;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

/**
 * 腾讯云通信插件
 *
 * @author hewz
 *
 */
@SuppressWarnings("unused")
public class IM extends CordovaPlugin {

	private static final String LOG_TAG = "Plugin#IM";

	private final static List<String> methodList =
			Arrays.asList(
					"login",
					"logout",
					"getOfflinePushStatus",
					"setOfflinePush"
			);

	private Activity activity;

	static IM instance;
	public IM() {
		instance = this;
	}

	/**
	 * 插件主入口
	 */
	@Override
	public boolean execute(final String action, final JSONArray args,
			final CallbackContext callbackContext) throws JSONException {
		LOG.d(LOG_TAG, "IM#execute");

		if (!methodList.contains(action)) {
			return false;
		}
		if(activity == null)
		{
			activity = this.cordova.getActivity();
			ApplicationInfo info = null;
			try {
				info = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
			} catch (PackageManager.NameNotFoundException e) {
				e.printStackTrace();
			}
			if(info == null)
			{
				LOG.e(LOG_TAG, "IM#unable to get im appid");
				return false;
			}
			Bundle a = info.metaData;
			int appid = info.metaData.getInt("IM.AppID");
			IMHelper.initIMSdk(appid);
		}
		cordova.getThreadPool().execute(new Runnable() {
			@Override
			public void run() {
				try {
					Method method = IM.class.getDeclaredMethod(action,
							JSONArray.class, CallbackContext.class);
					method.invoke(IM.this, args, callbackContext);
				} catch (Exception e) {
					Log.e(LOG_TAG, e.toString());
				}
			}
		});
		return true;
	}

	void login(JSONArray data, CallbackContext callbackContext) {
		Log.d(LOG_TAG, data.toString());
		try {
			IMHelper.login(callbackContext, data.getString(0), data.getString(1));
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void logout(JSONArray data, CallbackContext callbackContext) {
		IMHelper.logout(callbackContext);
	}

	void setOfflinePush(JSONArray data, CallbackContext callbackContext){
		Log.d(LOG_TAG, data.toString());
		try {
			IMHelper.setOfflinePush(data.getBoolean(0));
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	void getOfflinePushStatus(JSONArray data, CallbackContext callbackContext){
		IMHelper.getOfflinePushStatus(callbackContext);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		LOG.d(LOG_TAG, "IM#destory");
	}
}
