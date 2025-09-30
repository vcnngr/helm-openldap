{{/*
Expand the name of the chart.
*/}}
{{- define "openldap-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "openldap-ha.fullname" -}}
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
{{- define "openldap-ha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openldap-ha.labels" -}}
helm.sh/chart: {{ include "openldap-ha.chart" . }}
{{ include "openldap-ha.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openldap-ha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openldap-ha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: openldap
{{- end }}

{{/*
phpLDAPadmin labels
*/}}
{{- define "openldap-ha.phpldapadmin.labels" -}}
helm.sh/chart: {{ include "openldap-ha.chart" . }}
{{ include "openldap-ha.phpldapadmin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
phpLDAPadmin selector labels
*/}}
{{- define "openldap-ha.phpldapadmin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openldap-ha.name" . }}-phpldapadmin
app.kubernetes.io/instance: {{ .Release.Name }}
app: phpldapadmin
{{- end }}

{{/*
Calculate base DN from domain if not explicitly set
*/}}
{{- define "openldap-ha.baseDN" -}}
{{- if .Values.openldap.baseDN }}
{{- .Values.openldap.baseDN }}
{{- else }}
{{- $parts := splitList "." .Values.openldap.domain }}
{{- $dcParts := list }}
{{- range $parts }}
{{- $dcParts = append $dcParts (printf "dc=%s" .) }}
{{- end }}
{{- join "," $dcParts }}
{{- end }}
{{- end }}

{{/*
Generate replication hosts list for LDAP_REPLICATION_HOSTS
*/}}
{{- define "openldap-ha.replicationHosts" -}}
{{- $replicas := int .Values.openldap.replication.replicas }}
{{- $namespace := .Values.namespace }}
{{- $fullname := include "openldap-ha.fullname" . }}
{{- $hosts := list }}
{{- range $i := until $replicas }}
{{- $hosts = append $hosts (printf "ldap://%s-%d.%s-headless.%s.svc.cluster.local" $fullname $i $fullname $namespace) }}
{{- end }}
{{- printf "#PYTHON2BASH:%s" (toJson $hosts) }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openldap-ha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openldap-ha.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}