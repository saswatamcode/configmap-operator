local defaults = {
  local defaults = self,
  name: error 'must provide name',
  namespace: error 'must provide namespace',
  configMapName: error 'must provide ConfigMap name',
  image: error 'must provide image',
  imagePullPolicy: 'IfNotPresent',
  source: error 'must provide source',
  key: error 'must provide key',
  refreshInterval: error 'must provide refreshInterval',
  replicas: 1,
  resources: {},

  commonLabels:: {
    'app.kubernetes.io/name': 'configmap-operator',
    'app.kubernetes.io/instance': defaults.name,
    'app.kubernetes.io/component': 'kubernetes-operator',
  },

  annotations:: {
    'configmap-operator-src': defaults.source,
    'configmap-operator-key': defaults.key,
  },

  podLabelSelector:: {
    [labelName]: defaults.commonLabels[labelName]
    for labelName in std.objectFields(defaults.commonLabels)
    if !std.setMember(labelName, ['app.kubernetes.io/version'])
  },

};

function(params) {
  local co = self,
  config:: defaults + params,
  assert std.isObject(co.config.resources),

  namespace: {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: co.config.namespace,
      labels: co.config.commonLabels,
    },
  },

  serviceAccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: co.config.name + '-sa',
      namespace: co.config.namespace,
      labels: co.config.commonLabels,
    },
  },

  role: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: co.config.name + '-role',
      namespace: co.config.namespace,
      labels: co.config.commonLabels,
    },
    rules: [
      {
        apiGroups: [''],
        resources: ['configmaps'],
        verbs: ['list', 'watch', 'get', 'update'],
      },
    ],
  },

  roleBinding: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: co.config.name + '-rolebinding',
      namespace: co.config.namespace,
      labels: co.config.commonLabels,
    },

    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: co.role.metadata.name,
    },
    subjects: [{
      kind: 'ServiceAccount',
      name: co.serviceAccount.metadata.name,
      namespace: co.serviceAccount.metadata.namespace,
    }],
  },

  configmap: {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: co.config.configMapName,
      namespace: co.config.namespace,
      labels: co.config.commonLabels,
      annotations: co.config.annotations,
    },
  },

  deployment:
    local c = {
      name: 'configmap-operator',
      image: co.config.image,
      imagePullPolicy: co.config.imagePullPolicy,
      args: [
        'run',
        '--log.level=info',
        '--log.format=json',
        '--refresh.interval=%s' % co.config.refreshInterval,
        '--namespace=$(NAMESPACE)',
      ],
      env: [
        { name: 'NAMESPACE', valueFrom: { fieldRef: { fieldPath: 'metadata.namespace' } } },
      ],
      ports: [{ containerPort: 9090 }],
      resources: if co.config.resources != {} then co.config.resources else {},
    };

    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: co.config.name,
        namespace: co.config.namespace,
        labels: co.config.commonLabels,
      },
      spec: {
        replicas: co.config.replicas,
        selector: { matchLabels: co.config.podLabelSelector },
        template: {
          metadata: {
            labels: co.config.commonLabels,
          },
          spec: {
            containers: [c],
            serviceAccount: co.serviceAccount.metadata.name,
          },
        },
      },
    },
}
