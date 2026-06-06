package com.example.ghoststep.work

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.ghoststep.config.StepConfig
import com.example.ghoststep.health.HealthConnectManager
import com.example.ghoststep.plan.StepPlanner
import kotlinx.coroutines.delay

class StepsWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val config = StepConfig()
        val planner = StepPlanner()
        val bursts = planner.planDay(config, isWeekend = false)
        val total = bursts.sumOf { it.steps }

        val manager = HealthConnectManager(applicationContext)
        manager.writeFakeSteps(total)

        // Simulate some work
        delay(500)

        return Result.success()
    }
}