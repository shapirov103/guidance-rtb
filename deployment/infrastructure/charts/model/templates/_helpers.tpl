{{/*
Expand the name of the chart.
*/}}
{{- define "model.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "model.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Service suffix for multiple service setup. The first one will not change.
The rest will have sequential suffixes (eg. "-2", "-3"...).
*/}}
{{- define "model.serviceSuffix" -}}
{{- if gt . 0 -}}
-{{ add1 . }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "model.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "model.labels" -}}
helm.sh/chart: {{ include "model.chart" . }}
{{ include "model.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "model.selectorLabels" -}}
app.kubernetes.io/name: {{ include "model.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: model
{{- end }}


{{/*
Internal service labels
*/}}
{{- define "model.internalLabels" -}}
helm.sh/chart: {{ include "model.chart" . }}
app.kubernetes.io/name: {{ include "model.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: model-internal
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "model.serviceAccountName" -}}
{{- default (include "model.fullname" .) .Values.serviceAccount.name }}
{{- end }}

{{/*
Image pull policy for the specified image tag.
*/}}
{{- define "model.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{ .Values.image.pullPolicy }}
{{- else if eq .Values.image.tag "latest" -}}
Always
{{- else -}}
IfNotPresent
{{- end -}}
{{- end }}

{{/*
Expand to the GOMAXPROCS config key if it's absent from values config and the
model has a corresponding CPU limit.
*/}}
{{- define "model.gomaxprocs" -}}
{{- if and (empty .Values.config.GOMAXPROCS) .Values.resources.limits -}}
{{- if regexFind "\\d+(\\d{3}m)?$" .Values.resources.limits.cpu -}}
GOMAXPROCS: {{ regexReplaceAll "\\d{3}m$" .Values.resources.limits.cpu "" }}
{{- end -}}
{{- end -}}
{{- end }}
