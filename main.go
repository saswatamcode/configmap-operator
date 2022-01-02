// Copyright (c) Saswata Mukherjee (@saswatamcode)
// Licensed under the Apache License 2.0.

package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"github.com/bwplotka/mdox/pkg/clilog"
	"github.com/go-kit/log"
	"github.com/go-kit/log/level"
	"github.com/oklog/run"
	"github.com/pkg/errors"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/saswatamcode/configmap-operator/pkg/extkingpin"
	"github.com/saswatamcode/configmap-operator/pkg/runtime"
	"github.com/saswatamcode/configmap-operator/pkg/subscription"
	"github.com/saswatamcode/configmap-operator/pkg/version"
	"gopkg.in/alecthomas/kingpin.v2"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

const (
	logFormatLogfmt = "logfmt"
	logFormatJson   = "json"
	logFormatCLILog = "clilog"
)

func setupLogger(logLevel, logFormat string) log.Logger {
	var lvl level.Option
	switch logLevel {
	case "error":
		lvl = level.AllowError()
	case "warn":
		lvl = level.AllowWarn()
	case "info":
		lvl = level.AllowInfo()
	case "debug":
		lvl = level.AllowDebug()
	default:
		panic("unexpected log level")
	}
	switch logFormat {
	case logFormatJson:
		return level.NewFilter(log.NewJSONLogger(log.NewSyncWriter(os.Stderr)), lvl)
	case logFormatLogfmt:
		return level.NewFilter(log.NewLogfmtLogger(log.NewSyncWriter(os.Stderr)), lvl)
	case logFormatCLILog:
		fallthrough
	default:
		return level.NewFilter(clilog.New(log.NewSyncWriter(os.Stderr)), lvl)
	}
}

func main() {
	app := extkingpin.NewApp(kingpin.New(filepath.Base(os.Args[0]), `ConfigMap Operator.`).Version(version.Version))
	logLevel := app.Flag("log.level", "Log filtering level.").
		Default("info").Enum("error", "warn", "info", "debug")
	logFormat := app.Flag("log.format", "Log format to use.").
		Default(logFormatCLILog).Enum(logFormatLogfmt, logFormatJson, logFormatCLILog)

	ctx, cancel := context.WithCancel(context.Background())
	registerCommands(ctx, app)

	cmd, runner := app.Parse()
	logger := setupLogger(*logLevel, *logFormat)

	var g run.Group
	g.Add(func() error {
		return runner(ctx, logger)
	}, func(err error) {
		cancel()
	})

	srv := &http.Server{Addr: ":9091"}

	g.Add(func() error {
		http.Handle("/metrics", promhttp.Handler())
		return srv.ListenAndServe()
	}, func(err error) {
		_ = srv.Shutdown(ctx)
		cancel()
	})

	// Listen for termination signals.
	{
		cancel := make(chan struct{})
		g.Add(func() error {
			return interrupt(logger, cancel)
		}, func(error) {
			close(cancel)
		})
	}

	if err := g.Run(); err != nil {
		if *logLevel == "debug" {
			// Use %+v for github.com/pkg/errors error to print with stack.
			level.Error(logger).Log("err", fmt.Sprintf("%+v", errors.Wrapf(err, "%s command failed", cmd)))
			os.Exit(1)
		}
		level.Error(logger).Log("err", errors.Wrapf(err, "%s command failed", cmd))
		os.Exit(1)
	}
}

func interrupt(logger log.Logger, cancel <-chan struct{}) error {
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	select {
	case s := <-c:
		level.Info(logger).Log("msg", "caught signal. Exiting.", "signal", s)
		return nil
	case <-cancel:
		return errors.New("canceled")
	}
}

// TODO(saswatamcode): Add tests and observability.
func registerCommands(_ context.Context, app *extkingpin.App) {
	cmd := app.Command("run", "Launches ConfigMap Operator")
	kubeconfig := cmd.Flag("kubeconfig", "Path to a kubeconfig. Only required if out-of-cluster.").String()
	masterURL := cmd.Flag("master", "The address of the Kubernetes API server. Overrides any value in kubeconfig. Only required if out-of-cluster.").String()
	namespace := cmd.Flag("namespace", "The namespace to watch.").Default("default").String()
	refreshInterval := cmd.Flag("refresh.interval", "The interval after which the ConfigMap will be refreshed.").Default("10s").Duration()

	cmd.Run(func(ctx context.Context, logger log.Logger) error {
		cfg, err := clientcmd.BuildConfigFromFlags(*masterURL, *kubeconfig)
		if err != nil {
			level.Error(logger).Log("building kubeconfig error", err)
			return err
		}

		level.Info(logger).Log("built config from flags", "success")

		defaultKubernetesClientSet, err := kubernetes.NewForConfig(cfg)
		if err != nil {
			level.Error(logger).Log("building watcher clientset error", err)
			return err
		}

		if err := runtime.RunLoop(ctx, []subscription.Subscription{
			&subscription.ConfigMapSubscription{
				Ctx:             ctx,
				Logger:          logger,
				ClientSet:       defaultKubernetesClientSet,
				Namespace:       *namespace,
				RefreshInterval: *refreshInterval,
			},
		}); err != nil {
			panic(err)
		}

		return nil
	})
}
