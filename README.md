# configmap-controller

Kubernetes Controller which allows you to periodically update ConfigMaps, based on some external URL which serves the required data.

> ⚠ This project is made for learning/experimentation purposes. Not suitable for producation environments. Ideally, you can replicate similar functionality via other standard configuration practices.

```bash mdox-exec="configmap-controller run --help"
usage: configmap-controller run [<flags>]

Launches ConfigMap Controller

Flags:
  -h, --help                   Show context-sensitive help (also try --help-long
                               and --help-man).
      --version                Show application version.
      --log.level=info         Log filtering level.
      --log.format=clilog      Log format to use.
      --kubeconfig=KUBECONFIG  Path to a kubeconfig. Only required if
                               out-of-cluster.
      --master=MASTER          The address of the Kubernetes API server.
                               Overrides any value in kubeconfig. Only required
                               if out-of-cluster.

```
