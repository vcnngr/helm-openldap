{{/* templates/_helpers.tpl */}}

{{/* --- Include all standard helpers from the common chart --- */}}
{{- include "common.names.factory" . }}

{{/* --- Validation Section (Bitnami Style) --- */}}
{{- define "openldap-enterprise.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "openldap-enterprise.validateValues.directory" .) -}}
{{- $messages := append $messages (include "openldap-enterprise.validateValues.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/* Validate directory values */}}
{{- define "openldap-enterprise.validateValues.directory" -}}
{{- if not .Values.directory.baseDN -}}
directory.baseDN: "The Base DN is a required parameter."
{{- end -}}
{{- end -}}

{{/* Validate TLS values */}}
{{- define "openldap-enterprise.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.existingSecret) -}}
tls.existingSecret: "If TLS is enabled, an existing secret must be specified."
{{- end -}}
{{- end -}}

{{/* --- OpenLDAP-specific Helper Section --- */}}

{{/* Return the OpenLDAP image name */}}
{{- define "openldap-enterprise.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the service account to use
MODIFIED: Added 'and .Values.serviceAccount' to prevent nil pointer errors
*/}}
{{- define "openldap-enterprise.serviceAccountName" -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create -}}
    {{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{- default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Return the OpenLDAP Secret Name */}}
{{- define "openldap-enterprise.secretName" -}}
{{- if .Values.auth.existingSecret }}
    {{- .Values.auth.existingSecret -}}
{{- else -}}
    {{- include "common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/* Return true if a secret object should be created */}}
{{- define "openldap-enterprise.createSecret" -}}
{{- if not .Values.auth.existingSecret }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* --- Logic for Dynamic Replication Provider List --- */}}
{{- define "openldap-enterprise.replication.uris" -}}
{{- $fullname := include "common.names.fullname" . -}}
{{- $serviceName := printf "%s-headless" $fullname -}}
{{- $namespace := .Release.Namespace -}}
{{- $replicaCount := int .Values.highAvailability.replicaCount -}}
{{- range $i, $e := until $replicaCount -}}
    {{- if $i -}},{{- end -}}
    {{- printf "ldaps://%s-%d.%s.%s.svc.%s" $fullname $i $serviceName $namespace $.Values.clusterDomain -}}
{{- end -}}
{{- end -}}