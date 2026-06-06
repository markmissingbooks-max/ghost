package com.example.ghoststep.plan

import com.example.ghoststep.config.StepConfig
import kotlin.random.Random

data class StepBurst(
    val hour: Int,
    val minute: Int,
    val steps: Int
)

class StepPlanner {

    fun planDay(config: StepConfig, isWeekend: Boolean): List<StepBurst> {
        val avg = if (isWeekend) config.weekendAverageSteps else config.averageStepsPerDay
        val variance = config.variancePercent / 100.0
        val minTotal = (avg * (1 - variance)).toInt()
        val maxTotal = (avg * (1 + variance)).toInt()
        val total = Random.nextInt(minTotal, maxTotal + 1)

        val bursts = mutableListOf<StepBurst>()
        var remaining = total

        repeat(config.burstsPerDay) { i ->
            val share = remaining / (config.burstsPerDay - i).coerceAtLeast(1)
            val steps = (share * Random.nextDouble(0.5, 1.5)).toInt().coerceAtLeast(10)
            remaining -= steps

            val hour = Random.nextInt(config.activeStartHour, config.activeEndHour)
            val minute = Random.nextInt(0, 60)

            bursts += StepBurst(hour, minute, steps)
        }

        return bursts
    }
}
