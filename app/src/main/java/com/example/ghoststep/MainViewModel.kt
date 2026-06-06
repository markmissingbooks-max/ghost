package com.example.ghoststep

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.example.ghoststep.config.StepConfig
import com.example.ghoststep.config.SettingsRepository
import com.example.ghoststep.work.StepsWorker
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

data class UiState(
    val config: StepConfig = StepConfig(),
    val autoEnabled: Boolean = false
)

class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val repo = SettingsRepository(app)
    private val workManager = WorkManager.getInstance(app)

    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState

    init {
        viewModelScope.launch {
            repo.configFlow.collect { cfg ->
                _uiState.value = _uiState.value.copy(config = cfg)
            }
        }
    }

    fun toggleAuto(enabled: Boolean) {
        _uiState.value = _uiState.value.copy(autoEnabled = enabled)
        // In a fuller version, hook into StepAlarmScheduler here
    }

    fun writeNow() {
        val request = OneTimeWorkRequestBuilder<StepsWorker>().build()
        workManager.enqueue(request)
    }

    fun openSettings() {
        // Navigation stub – you can wire this to a NavHost later
    }
}
