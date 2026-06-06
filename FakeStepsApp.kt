package com.example.ghoststep

import android.app.Application
import androidx.work.Configuration

class FakeStepsApp : Application(), Configuration.Provider {
    override fun getWorkManagerConfiguration(): Configuration {
        return Configuration.Builder()
            .setMinimumLoggingLevel(android.util.Log.INFO)
            .build()
    }
}