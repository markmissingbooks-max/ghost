package com.example.ghoststep.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.ghoststep.UiState

@Composable
fun HomeScreen(
    state: UiState,
    onToggleAuto: (Boolean) -> Unit,
    onWriteNow: () -> Unit,
    onOpenSettings: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("GhostStep", modifier = Modifier.padding(bottom = 8.dp))
        Text("Average steps per day: ${state.config.averageStepsPerDay}")
        Text("Bursts per day: ${state.config.burstsPerDay}")

        Button(
            modifier = Modifier.padding(top = 16.dp),
            onClick = onWriteNow
        ) {
            Text("Write fake steps now")
        }

        Button(
            modifier = Modifier.padding(top = 8.dp),
            onClick = onOpenSettings
        ) {
            Text("Open settings (stub)")
        }
    }
}