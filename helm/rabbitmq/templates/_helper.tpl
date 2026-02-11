{{- define "rabbitmq.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "rabbitmq.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "rabbitmq.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
