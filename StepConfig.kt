package com.example.ghoststep.config

data class StepConfig(
    val averageStepsPerDay: Int = 8000,
    val weekendAverageSteps: Int = 5000,
    val variancePercent: Int = 20,
    val activeStartHour: Int = 7,
    val activeEndHour: Int = 22,
    val burstsPerDay: Int = 12,
    val autoEnabled: Boolean = false
)