package com.example.ghoststep.config

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore("ghost_step_config")

class SettingsRepository(private val context: Context) {

    private object Keys {
        val AVG = intPreferencesKey("average_steps")
        val WEEKEND = intPreferencesKey("weekend_steps")
        val VARIANCE = intPreferencesKey("variance_percent")
        val START = intPreferencesKey("active_start")
        val END = intPreferencesKey("active_end")
        val BURSTS = intPreferencesKey("bursts_per_day")
        val AUTO = booleanPreferencesKey("auto_enabled")
    }

    val configFlow: Flow<StepConfig> =
        context.dataStore.data.map { prefs -> prefs.toConfig() }

    suspend fun update(config: StepConfig) {
        context.dataStore.edit { prefs ->
            prefs[Keys.AVG] = config.averageStepsPerDay
            prefs[Keys.WEEKEND] = config.weekendAverageSteps
            prefs[Keys.VARIANCE] = config.variancePercent
            prefs[Keys.START] = config.activeStartHour
            prefs[Keys.END] = config.activeEndHour
            prefs[Keys.BURSTS] = config.burstsPerDay
            prefs[Keys.AUTO] = config.autoEnabled
        }
    }

    private fun Preferences.toConfig(): StepConfig {
        return StepConfig(
            averageStepsPerDay = this[Keys.AVG] ?: 8000,
            weekendAverageSteps = this[Keys.WEEKEND] ?: 5000,
            variancePercent = this[Keys.VARIANCE] ?: 20,
            activeStartHour = this[Keys.START] ?: 7,
            activeEndHour = this[Keys.END] ?: 22,
            burstsPerDay = this[Keys.BURSTS] ?: 12,
            autoEnabled = this[Keys.AUTO] ?: false
        )
    }
}