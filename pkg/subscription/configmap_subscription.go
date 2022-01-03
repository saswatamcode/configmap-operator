// Copyright (c) Saswata Mukherjee (@saswatamcode)
// Licensed under the Apache License 2.0.

package subscription

import (
	"context"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/go-kit/log"
	"github.com/go-kit/log/level"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/kubernetes"
)

const (
	configMapOperatorSrc = "configmap-operator-src"
	configMapOperatorKey = "configmap-operator-key"
)

type ConfigMapSubscription struct {
	Ctx             context.Context
	Logger          log.Logger
	ClientSet       kubernetes.Interface
	Namespace       string
	RefreshInterval time.Duration

	watcherInterface watch.Interface
}

func (c *ConfigMapSubscription) Reconcile(object runtime.Object, event watch.EventType) {
	configMap := object.(*v1.ConfigMap)
	level.Info(c.Logger).Log("ConfigMap subscription event", event, "ConfigMap name", configMap.Name)

	switch event {
	case watch.Added:
		// Check if ConfigMap has required annotations.
		annotations := configMap.GetAnnotations()
		dataSrc, srcExists := annotations[configMapOperatorSrc]
		key, keyExists := annotations[configMapOperatorKey]

		if srcExists && keyExists {

			// Update ConfigMaps in goroutines to support multiple ConfigMaps with annotations. End goroutine based on ctx.
			// TODO(saswatamcode): Improve error handling.
			go func() {
				ticker := time.NewTicker(c.RefreshInterval)
				for {
					select {
					case <-ticker.C:
						level.Info(c.Logger).Log("updating ConfigMap", configMap.Name)
						updatedConfigMap := configMap.DeepCopy()
						if len(updatedConfigMap.Data) == 0 {
							updatedConfigMap.Data = make(map[string]string)
						}

						// Get data from src and update ConfigMap with key.
						updatedConfigMap.Data[key] = string(getData(dataSrc, c.Logger))
						var err error
						configMap, err = c.ClientSet.CoreV1().ConfigMaps(configMap.Namespace).Update(c.Ctx, updatedConfigMap, metav1.UpdateOptions{})
						if err != nil {
							level.Error(c.Logger).Log("error updating ConfigMap", err)
						}
					case <-c.Ctx.Done():
						return
					}
				}
			}()
		}
	}
}

func (c *ConfigMapSubscription) Subscribe() (watch.Interface, error) {
	var err error
	c.watcherInterface, err = c.ClientSet.CoreV1().ConfigMaps(c.Namespace).Watch(c.Ctx, metav1.ListOptions{})
	if err != nil {
		return nil, err
	}
	return c.watcherInterface, nil
}

func getData(dataSrc string, logger log.Logger) []byte {
	if isValidUrl(dataSrc) {
		// Src is valid URL so make request.
		level.Info(logger).Log("making GET request", dataSrc)
		response, err := http.Get(dataSrc)
		if err != nil {
			level.Error(logger).Log("error fetching data", err)
			return nil
		}

		defer response.Body.Close()

		body, err := ioutil.ReadAll(response.Body)
		if err != nil {
			level.Error(logger).Log("error reading response", err)
			return nil
		}
		return body
	}

	level.Info(logger).Log("not URL reading file", dataSrc)

	// Assume file if not URL.
	data, err := os.ReadFile(dataSrc)
	if err != nil {
		level.Error(logger).Log("error reading file", err)
		return nil
	}
	return data
}

func isValidUrl(toTest string) bool {
	_, err := url.ParseRequestURI(toTest)
	if err != nil {
		return false
	}

	u, err := url.Parse(toTest)
	if err != nil || u.Scheme == "" || u.Host == "" {
		return false
	}

	return true
}
