{{- define "dynamodb.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "dynamodb.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dynamodb.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
