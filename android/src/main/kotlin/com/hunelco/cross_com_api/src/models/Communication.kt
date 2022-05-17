package com.hunelco.cross_com_api.src.models

import com.google.gson.annotations.SerializedName

data class VerificationRequest(
    @SerializedName("code") val code: String,
    @SerializedName("args") val args: Map<String, String>
)

data class VerificationResponse(@SerializedName("args") val args: Map<String, String>)