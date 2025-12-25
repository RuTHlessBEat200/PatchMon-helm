{{/*
Expand the name of the chart.
*/}}
{{- define "patchmon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "patchmon.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "patchmon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "patchmon.labels" -}}
helm.sh/chart: {{ include "patchmon.chart" . }}
{{ include "patchmon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "patchmon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "patchmon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component labels for database
*/}}
{{- define "patchmon.database.labels" -}}
{{ include "patchmon.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Selector labels for database
*/}}
{{- define "patchmon.database.selectorLabels" -}}
{{ include "patchmon.selectorLabels" . }}
app.kubernetes.io/component: database
app: {{ include "patchmon.fullname" . }}-database
{{- end }}

{{/*
Component labels for redis
*/}}
{{- define "patchmon.redis.labels" -}}
{{ include "patchmon.labels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{/*
Selector labels for redis
*/}}
{{- define "patchmon.redis.selectorLabels" -}}
{{ include "patchmon.selectorLabels" . }}
app.kubernetes.io/component: redis
app: {{ include "patchmon.fullname" . }}-redis
{{- end }}

{{/*
Component labels for backend
*/}}
{{- define "patchmon.backend.labels" -}}
{{ include "patchmon.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Selector labels for backend
*/}}
{{- define "patchmon.backend.selectorLabels" -}}
{{ include "patchmon.selectorLabels" . }}
app.kubernetes.io/component: backend
app: {{ include "patchmon.fullname" . }}-backend
{{- end }}

{{/*
Component labels for frontend
*/}}
{{- define "patchmon.frontend.labels" -}}
{{ include "patchmon.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Selector labels for frontend
*/}}
{{- define "patchmon.frontend.selectorLabels" -}}
{{ include "patchmon.selectorLabels" . }}
app.kubernetes.io/component: frontend
app: {{ include "patchmon.fullname" . }}-frontend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "patchmon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "patchmon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the proper image registry
*/}}
{{- define "patchmon.imageRegistry" -}}
{{- if .global.imageRegistry -}}
{{- .global.imageRegistry -}}
{{- else if .registry -}}
{{- .registry -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database image name
*/}}
{{- define "patchmon.database.image" -}}
{{- $registry := include "patchmon.imageRegistry" (dict "registry" .Values.database.image.registry "global" .Values.global) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.database.image.repository .Values.database.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.database.image.repository .Values.database.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper redis image name
*/}}
{{- define "patchmon.redis.image" -}}
{{- $registry := include "patchmon.imageRegistry" (dict "registry" .Values.redis.image.registry "global" .Values.global) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.redis.image.repository .Values.redis.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.redis.image.repository .Values.redis.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper backend image name
*/}}
{{- define "patchmon.backend.image" -}}
{{- $registry := include "patchmon.imageRegistry" (dict "registry" .Values.backend.image.registry "global" .Values.global) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.backend.image.repository .Values.backend.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.backend.image.repository .Values.backend.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "patchmon.frontend.image" -}}
{{- $registry := include "patchmon.imageRegistry" (dict "registry" .Values.frontend.image.registry "global" .Values.global) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.frontend.image.repository .Values.frontend.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.frontend.image.repository .Values.frontend.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper storage class
*/}}
{{- define "patchmon.storageClass" -}}
{{- $storageClass := .local -}}
{{- if .global -}}
{{- if .global.storageClass -}}
{{- $storageClass = .global.storageClass -}}
{{- end -}}
{{- end -}}
{{- if $storageClass -}}
{{- printf "%s" $storageClass -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name for database password
*/}}
{{- define "patchmon.database.secretName" -}}
{{- if .Values.database.auth.existingSecret -}}
{{- .Values.database.auth.existingSecret -}}
{{- else -}}
{{- include "patchmon.fullname" . -}}-secrets
{{- end -}}
{{- end -}}

{{/*
Return the secret name for redis password
*/}}
{{- define "patchmon.redis.secretName" -}}
{{- if .Values.redis.auth.existingSecret -}}
{{- .Values.redis.auth.existingSecret -}}
{{- else -}}
{{- include "patchmon.fullname" . -}}-secrets
{{- end -}}
{{- end -}}

{{/*
Return the secret name for JWT secret
*/}}
{{- define "patchmon.backend.secretName" -}}
{{- if .Values.backend.existingSecret -}}
{{- .Values.backend.existingSecret -}}
{{- else -}}
{{- include "patchmon.fullname" . -}}-secrets
{{- end -}}
{{- end -}}

{{/*
Return the configmap name
*/}}
{{- define "patchmon.configMapName" -}}
{{- include "patchmon.fullname" . -}}-config
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "patchmon.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Return the proper init container image name (busybox)
*/}}
{{- define "patchmon.initContainer.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- if $registry -}}
{{- printf "%s/busybox:latest" $registry -}}
{{- else -}}
docker.io/busybox:latest
{{- end -}}
{{- end -}}
