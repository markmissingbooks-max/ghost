package com.example.ghoststep.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        // You can reschedule alarms here if needed
        val scheduler = StepAlarmScheduler(context)
        scheduler.scheduleDaily(hour = 9, minute = 0)
    }
}