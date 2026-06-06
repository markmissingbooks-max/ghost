package com.example.ghoststep

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import com.example.ghoststep.ui.HomeScreen

class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface {
                    HomeScreen(
                        state = viewModel.uiState,
                        onToggleAuto = viewModel::toggleAuto,
                        onWriteNow = viewModel::writeNow,
                        onOpenSettings = viewModel::openSettings
                    )
                }
            }
        }
    }
}