package hewz.plugins.im;

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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 腾讯云通信插件
 *
 * @author hewz
 *
 */
public class IM extends CordovaPlugin {

	/** JS回调接口对象 */
	public static CallbackContext cbContext = null;

	private static final String LOG_TAG = "Plugin IM";

	private final static List<String> methodList =
			Arrays.asList(
					"login",
					"setOfflinePush"
			);
	private ExecutorService threadPool = Executors.newFixedThreadPool(1);

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
		threadPool.execute(new Runnable() {
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
		//IMHelper.initIMSdk(this.cordova.getActivity().getApplicationContext(), "692", "eJxNjlFPgzAUhf8Lr5qtLRaKb9tipgk4si3L4kvT0Du8MqHSjsGM-92GkOjr952cc76DfbqbqaJoLrWTbjAQPAYkuB8xaqgdnhBaD6OETVgZg1oqJ8NW-0tbXclReUYfCCEsEpRPEnqDLUh1cmMZ5ZwzH5lsB63FpvaCEcopCwn5kxZLL7KnbPU87L5eow82kJ6J-RDfaneB8v1chI0RiyPGNqU5y48bK1Yvy22c5qKrKnq49m-bknZJqe4YzJviBjzXmyva*eK8XmfZNOTwE8bvSZKQmPoDP78lb1VD");
		try {
			IMHelper.initIMSdk(callbackContext, this.cordova.getActivity().getApplicationContext(), data.getString(0), data.getString(1));
		} catch (JSONException e) {
			e.printStackTrace();
			callbackContext.error("error args");
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		LOG.d(LOG_TAG, "IM#destory");
	}
}
