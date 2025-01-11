package com.noanime_app.noanime_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.io.IOException
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.noanime_app/scrape"
    private val executorService = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPopularAnime" -> {
                    executorService.execute {
                        val response = handleGetPopularAnime(call.arguments)
                        runOnUiThread {
                            result.success(response)
                        }
                    }
                }
                "functionTwo" -> {
                    executorService.execute {
                        val response = handleFunctionTwo(call.arguments)
                        runOnUiThread {
                            result.success(response)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun handleGetPopularAnime(arguments: Any?): String {
        val argumentMap = arguments as? Map<*, *> ?: return "Invalid arguments for getPopularAnime"
        val page = argumentMap["page"] as? String ?: return "Missing or invalid 'page' argument"

        val client = OkHttpClient()
        val url = "https://www.arabanime.net/api?page=$page"
        val request = Request.Builder().url(url).build()

        return try {
            // Make the HTTP request and get the response
            val response: Response = client.newCall(request).execute()

            // Check if the response is successful
            if (response.isSuccessful) {
                response.body?.string() ?: "No response body"
            } else {
                "Failed to fetch data"
            }
        } catch (e: IOException) {
            "Error: ${e.message}"
        }
    }

    private fun handleFunctionTwo(arguments: Any?): String {
        // Logic for functionTwo
        return "Result from functionTwo"
    }
}