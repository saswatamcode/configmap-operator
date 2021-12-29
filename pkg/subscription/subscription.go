// Copyright (c) Saswata Mukherjee (@saswatamcode)
// Licensed under the Apache License 2.0.

package subscription

import (
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/watch"
)

type Subscription interface {
	Subscribe() (watch.Interface, error)
	Reconcile(object runtime.Object, event watch.EventType)
}
