{{/*
Define the SignServer deployment parameters
*/}}
{{- define "signserver-community-helm.signserverDeploymentParameters" -}}
{{- if .Values.signserver.useEphemeralH2Database }}
- name: DATABASE_JDBC_URL
  value: "jdbc:h2:mem:signserverdb;DB_CLOSE_DELAY=-1"
{{- else if .Values.signserver.useH2Persistence }}
- name: DATABASE_JDBC_URL
  value: "jdbc:h2:/mnt/persistent/signserverdb;DB_CLOSE_DELAY=-1"
{{- end }}
{{- if hasKey .Values.signserver "env" }}
{{- range $key, $value := .Values.signserver.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- if hasKey .Values.signserver "envRaw" }}
{{ toYaml .Values.signserver.envRaw }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "signserver-community-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "signserver-community-helm.fullname" -}}
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
{{- define "signserver-community-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "signserver-community-helm.labels" -}}
helm.sh/chart: {{ include "signserver-community-helm.chart" . }}
{{ include "signserver-community-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "signserver-community-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signserver-community-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "signserver-community-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "signserver-community-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
