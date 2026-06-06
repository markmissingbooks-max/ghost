package com.example.ghoststep.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.example.ghoststep.work.StepsWorker

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val request = OneTimeWorkRequestBuilder<StepsWorker>().build()
        WorkManager.getInstance(context).enqueue(request)
    }
}