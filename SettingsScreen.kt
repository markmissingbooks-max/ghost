package com.example.ghoststep.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.ghoststep.config.StepConfig

@Composable
fun SettingsScreen(
    config: StepConfig,
    onConfigChange: (StepConfig) -> Unit,
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("Settings")

        SliderSetting(
            label = "Average steps",
            value = config.averageStepsPerDay.toFloat(),
            range = 1000f..30000f
        ) { new ->
            onConfigChange(config.copy(averageStepsPerDay = new.toInt()))
        }

        SliderSetting(
            label = "Bursts per day",
            value = config.burstsPerDay.toFloat(),
            range = 4f..40f
        ) { new ->
            onConfigChange(config.copy(burstsPerDay = new.toInt()))
        }

        ToggleSetting(
            label = "Auto generate daily",
            checked = config.autoEnabled,
            onCheckedChange = { checked ->
                onConfigChange(config.copy(autoEnabled = checked))
            }
        )

        Button(
            modifier = Modifier.padding(top = 16.dp),
            onClick = onClose
        ) {
            Text("Close")
        }
    }
}