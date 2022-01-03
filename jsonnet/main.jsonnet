local co = (import 'lib/configmap-operator.libsonnet')({
  local cfg = self,
  name: 'configmap-operator',
  namespace: 'configmap-operator-demo',
  image: 'saswatamcode/configmap-operator',
  configMapName: 'example-prom-config',
  source: 'https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus.yml',
  key: 'prom.yaml',
  refreshInterval: '15s',
  replicas: 1,
});

{ [name]: co[name] for name in std.objectFields(co) if co[name] != null }
