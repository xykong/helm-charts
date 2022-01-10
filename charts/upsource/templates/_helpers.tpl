{{/*
Expand the name of the chart.
*/}}
{{- define "upsource.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "upsource.fullname" -}}
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
{{- define "upsource.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "upsource.labels" -}}
helm.sh/chart: {{ include "upsource.chart" . }}
{{ include "upsource.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "upsource.selectorLabels" -}}
app.kubernetes.io/name: {{ include "upsource.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "upsource.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "upsource.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "upsource.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper log4j.xml volumes config
*/}}
{{- define "configmap.volume.log4j.xml" -}}
- name: config-log4j-xml
  configMap:
    name: upsource
    items:
    - key: log4j.xml
      path: log4j.xml
{{- end -}}

{{/*
Return the proper log4j.xml volumeMounts config
*/}}
{{- define "configmap.volumeMounts.log4j.xml" -}}
- name: config-log4j-xml
  mountPath: /opt/upsource-analyzer/conf/log4j.xml
  subPath: log4j.xml
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "upsource.service.name" -}}
{{ .name }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}

{{/*
Return the proper image name
    # Comma-separated list of cassandra cluster hosts
    CASSANDRA_HOSTS: cassandra.default.svc.cluster.local
*/}}
{{- define "upsource.global.envirments" -}}
{{- $envirments := set .Values.global.env "UPSOURCE_PSI_BROKER_LISTEN_PORT" .Values.psiBroker.service.port -}}
{{- $envirments := set .Values.global.env "UPSOURCE_MONITORING_LISTEN_PORT" .Values.opsCenter.service.port -}}
{{- $envirments := set .Values.global.env "UPSOURCE_WEB_SERVER_LISTEN_PORT" .Values.frontend.service.port -}}
{{- $envirments := set .Values.global.env "CASSANDRA_NATIVE_TRANSPORT_PORT" .Values.cassandra.service.port -}}
{{- $envirments := set .Values.global.env "CASSANDRA_HOSTS" (include "upsource.service.name" (set $ "name" "cassandra")) -}}
{{- range $index, $topping := $envirments }}
  {{- if $topping }}
  - name: {{ $index }}
    value: {{ $topping | quote }}
  {{- end }}
{{- end }}
{{- end -}}
